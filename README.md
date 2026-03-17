# GCP Cowrie SOC Lab (Terraform + Ansible)

This project deploys a small SOC lab on Google Cloud:

- Public Cowrie honeypot VM (`cowrie-1`)
- Private logging VM (`logging-1`) running Loki + Grafana
- Promtail shipping Cowrie logs to Loki
- Optional Cloudflare Tunnel (`cloudflared`) to publish Grafana securely

## Architecture

- VPC: custom network with isolated subnets
- Honeypot path: Internet -> GCP firewall (`tcp/22`) -> Cowrie
- Admin path: your IP -> GCP firewall (`tcp/2022`) -> real SSH
- Logging path: Cowrie JSON logs -> Promtail -> Loki -> Grafana

See [docs/architecture.md](docs/architecture.md) for details.

## Repo Layout

- `terraform/`: infra provisioning (VPC, firewall rules, VMs)
- `ansible/`: VM software config (Loki, Grafana, Promtail, Cloudflared)
- `docs/`: runbook and architecture notes

## Prerequisites

- `terraform` (>= 1.6)
- `ansible` (core 2.15+ recommended)
- `gcloud` CLI authenticated to your GCP project
- IAM roles for provisioning (Compute + network + service usage permissions)

## Quick Start

1. Create your infra config:
   - secure path (recommended): follow [docs/secrets-management.md](docs/secrets-management.md)
   - legacy path: copy `terraform/terraform.tfvars.example` to `terraform/terraform.tfvars`
2. Provision infra:
   - `cd terraform`
   - `terraform init`
   - `terraform plan`
   - `terraform apply`
3. Configure Ansible values:
   - update `ansible/group_vars/all.yml`
   - update `ansible/inventory/hosts.ini`
4. Run Ansible:
   - `cd ../ansible`
   - `ansible-playbook playbooks/site.yml`

## Cloudflare Tunnel (Optional)

To publish Grafana at your own domain without opening inbound ports on VM2:

1. Create a Cloudflare Tunnel and public hostname.
2. Set service target to `http://localhost:443`.
3. Provide token via environment variable:
   - copy `ansible/group_vars/.env.example` to `ansible/group_vars/.env`
   - set `cloudflared_tunnel_token`
4. Run:
   - `ansible-playbook playbooks/05-cloudflared.yml -e cloudflared_enabled=true`

## Secure Secrets Workflow (Recommended)

- Bootstrap encrypted files:
  - `cp terraform/terraform.sops.tfvars.json.example terraform/terraform.sops.tfvars.json`
  - `cp ansible/group_vars/secrets.sops.yml.example ansible/group_vars/secrets.sops.yml`
  - `sops -e -i terraform/terraform.sops.tfvars.json ansible/group_vars/secrets.sops.yml`
- Run Terraform with decrypted temp vars only:
  - `./scripts/terraform-sops.sh plan`
- Run Ansible with decrypted temp vars only:
  - `./scripts/ansible-playbook-sops.sh playbooks/site.yml`
- Full setup: [docs/secrets-management.md](docs/secrets-management.md)

## Security Notes

- Do not commit:
  - `terraform.tfvars`
  - `.tfstate` files
  - `ansible/group_vars/.env`
- Restrict admin SSH (`tcp/2022`) to your `/32` IP.
- Keep Cowrie on public `22` only after hardening/monitoring is active.
- Recommended: use encrypted secrets files with `age + sops` via [docs/secrets-management.md](docs/secrets-management.md).

## Demo Scope

This repo is intended as an educational/demonstration lab, not a production SOC platform.
