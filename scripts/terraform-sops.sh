#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TF_DIR="${ROOT_DIR}/terraform"
SOPS_TFVARS="${TF_DIR}/terraform.sops.tfvars.json"

if ! command -v sops >/dev/null 2>&1; then
  echo "error: sops is required but not installed" >&2
  exit 1
fi

if ! command -v terraform >/dev/null 2>&1; then
  echo "error: terraform is required but not installed" >&2
  exit 1
fi

if [[ ! -f "${SOPS_TFVARS}" ]]; then
  echo "error: missing ${SOPS_TFVARS}" >&2
  echo "hint: copy terraform/terraform.sops.tfvars.json.example and encrypt it with sops" >&2
  exit 1
fi

TMP_TFVARS="$(mktemp)"
cleanup() {
  if command -v shred >/dev/null 2>&1; then
    shred -u "${TMP_TFVARS}" 2>/dev/null || rm -f "${TMP_TFVARS}"
  else
    rm -f "${TMP_TFVARS}"
  fi
}
trap cleanup EXIT

sops -d "${SOPS_TFVARS}" > "${TMP_TFVARS}"

terraform -chdir="${TF_DIR}" "$@" -var-file="${TMP_TFVARS}"
