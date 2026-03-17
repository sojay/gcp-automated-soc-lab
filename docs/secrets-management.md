# Secrets Management with `age` + `sops`

This repo now supports encrypted secrets files that are safe to commit.

## Why this approach
- `age` keeps key management simple and scriptable.
- `sops` encrypts only values (not structure), which keeps diffs reviewable.
- Wrapper scripts decrypt to ephemeral temp files only, then securely delete.

## 1) Install prerequisites
- `age`
- `sops` (>= 3.8 recommended)

## 2) Create and protect your `age` key
```bash
mkdir -p ~/.config/sops/age
age-keygen -o ~/.config/sops/age/keys.txt
chmod 600 ~/.config/sops/age/keys.txt
```

Get your public key:
```bash
age-keygen -y ~/.config/sops/age/keys.txt
```

## 3) Update repo encryption policy
Edit [`.sops.yaml`](/var/home/sammie/projects/public-demo/.sops.yaml) and replace the placeholder `age1...` recipient with your team public key(s).

Tip: include multiple recipients so each operator/CI identity can decrypt.

## 4) Create encrypted Terraform vars
```bash
cp terraform/terraform.sops.tfvars.json.example terraform/terraform.sops.tfvars.json
sops -e -i terraform/terraform.sops.tfvars.json
```

Run Terraform with automatic decrypt/cleanup:
```bash
./scripts/terraform-sops.sh init
./scripts/terraform-sops.sh plan
./scripts/terraform-sops.sh apply
```

## 5) Create encrypted Ansible secrets
```bash
cp ansible/group_vars/secrets.sops.yml.example ansible/group_vars/secrets.sops.yml
sops -e -i ansible/group_vars/secrets.sops.yml
```

Run playbooks with decrypted extra-vars (temp file only):
```bash
./scripts/ansible-playbook-sops.sh playbooks/site.yml
```

## CI/CD pattern
- Store the private `age` key in CI secret storage as `SOPS_AGE_KEY`.
- In CI job:
```bash
export SOPS_AGE_KEY="${SOPS_AGE_KEY}"
./scripts/terraform-sops.sh plan
./scripts/ansible-playbook-sops.sh playbooks/04-health-checks.yml
```

## Rotation guidance
- Add new recipient(s) to [`.sops.yaml`](/var/home/sammie/projects/public-demo/.sops.yaml).
- Re-encrypt files:
```bash
sops updatekeys terraform/terraform.sops.tfvars.json
sops updatekeys ansible/group_vars/secrets.sops.yml
```
- Remove old recipient(s) after rollout.

## Operational guardrails
- Never commit plaintext copies of secrets.
- Keep Terraform state in a secured remote backend (GCS + CMEK + IAM least privilege).
- Use short-lived workload identities for CI where possible.
