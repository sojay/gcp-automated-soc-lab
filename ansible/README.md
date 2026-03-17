# Ansible Playbooks (SOC Lab)

This folder configures VM software after Terraform creates infrastructure.

## Scope
- `logging-1` (private VM2): Docker + Loki + Grafana
- `cowrie-1` (VM1): Promtail shipping Cowrie JSON logs to Loki

## Prerequisites
- `ansible` installed on your laptop
- `gcloud` authenticated as a user with VM access
- IAP SSH firewall + IAM roles configured for `logging-1`

## Inventory
- `inventory/hosts.ini`
  - `cowrie-1` uses public IP + SSH port `2022`
  - `logging-1` uses IAP tunnel proxy command

## Quick start
1. Update variables:
   - `group_vars/all.yml`
   - set `project_id` and region details
2. Configure secrets (recommended):
   - see [../docs/secrets-management.md](../docs/secrets-management.md)
   - run playbooks with `../scripts/ansible-playbook-sops.sh`
3. Legacy env-based secrets (fallback):
   - `cp group_vars/.env.example group_vars/.env`
   - `set -a && source group_vars/.env && set +a`
4. Validate access:
   - `ansible -i inventory/hosts.ini honeypot -m ping`
   - `ansible -i inventory/hosts.ini logging -m ping`
5. Run all playbooks:
   - `ansible-playbook playbooks/site.yml`

## Run per phase
- Bootstrap only:
  - `ansible-playbook playbooks/01-bootstrap.yml`
- Logging VM stack only:
  - `ansible-playbook playbooks/02-logging-stack.yml`
- Promtail on honeypot only:
  - `ansible-playbook playbooks/03-cowrie-promtail.yml`
- Health checks only:
  - `ansible-playbook playbooks/04-health-checks.yml`
- Cloudflared tunnel only:
  - `ansible-playbook playbooks/05-cloudflared.yml`

## Publish Grafana with Cloudflare Tunnel
1. In Cloudflare Zero Trust, create a tunnel and add a public hostname:
   - hostname: your desired subdomain (for example `grafana.example.com`)
   - service: `http://localhost:443`
2. Copy the tunnel token from Cloudflare.
3. Export token and enable deployment:
   - `export CLOUDFLARED_TUNNEL_TOKEN=<token>`
   - run with `-e cloudflared_enabled=true`
4. Deploy:
   - `ansible-playbook playbooks/05-cloudflared.yml`
5. Verify on `logging-1`:
   - `docker ps | grep cloudflared`
   - `docker logs --tail 100 cloudflared`

## Notes
- Current Grafana setup uses HTTP on port `443` to align with existing firewall rule.
- Recommended next iteration: add TLS termination (Caddy/Nginx + cert management).
