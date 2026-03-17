#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ANSIBLE_DIR="${ROOT_DIR}/ansible"
SOPS_VARS="${ANSIBLE_DIR}/group_vars/secrets.sops.yml"

if ! command -v sops >/dev/null 2>&1; then
  echo "error: sops is required but not installed" >&2
  exit 1
fi

if ! command -v ansible-playbook >/dev/null 2>&1; then
  echo "error: ansible-playbook is required but not installed" >&2
  exit 1
fi

if [[ ! -f "${SOPS_VARS}" ]]; then
  echo "error: missing ${SOPS_VARS}" >&2
  echo "hint: copy ansible/group_vars/secrets.sops.yml.example and encrypt it with sops" >&2
  exit 1
fi

TMP_VARS="$(mktemp)"
cleanup() {
  if command -v shred >/dev/null 2>&1; then
    shred -u "${TMP_VARS}" 2>/dev/null || rm -f "${TMP_VARS}"
  else
    rm -f "${TMP_VARS}"
  fi
}
trap cleanup EXIT

sops -d "${SOPS_VARS}" > "${TMP_VARS}"

cd "${ANSIBLE_DIR}"
ansible-playbook -e "@${TMP_VARS}" "$@"
