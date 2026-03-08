#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
export PATH="$HOME/.local/bin:$PATH"

ensure_ansible() {
  if command -v ansible-playbook >/dev/null 2>&1; then
    return 0
  fi

  if ! command -v python3 >/dev/null 2>&1; then
    echo "error: python3 is required to install ansible-core via pipx." >&2
    exit 1
  fi

  if ! python3 -m pip --version >/dev/null 2>&1; then
    echo "error: python3 pip is required to install pipx." >&2
    exit 1
  fi

  if ! command -v pipx >/dev/null 2>&1; then
    python3 -m pip install --user pipx
    export PATH="$HOME/.local/bin:$PATH"
    python3 -m pipx ensurepath >/dev/null 2>&1 || true
  fi

  if ! command -v pipx >/dev/null 2>&1; then
    echo "error: pipx not found after installation." >&2
    exit 1
  fi

  if ! pipx list 2>/dev/null | grep -q "package ansible-core "; then
    pipx install ansible-core
  else
    pipx upgrade ansible-core >/dev/null 2>&1 || true
  fi

  if ! command -v ansible-playbook >/dev/null 2>&1; then
    export PATH="$HOME/.local/bin:$PATH"
  fi
  if ! command -v ansible-playbook >/dev/null 2>&1; then
    echo "error: ansible-playbook not found after bootstrap." >&2
    exit 1
  fi

  hash -r
}

main() {
  local -a ansible_args=()
  for arg in "$@"; do
    if [[ "$arg" == "--dry-run" ]]; then
      ansible_args+=("--check" "--diff")
    else
      ansible_args+=("$arg")
    fi
  done

  ensure_ansible
  if [[ ${#ansible_args[@]} -gt 0 ]]; then
    ansible-playbook \
      -i "localhost," \
      -c local \
      "$ROOT_DIR/ansible/bootstrap.yml" \
      -e "dotfiles_root=$ROOT_DIR" \
      "${ansible_args[@]}"
  else
    ansible-playbook \
      -i "localhost," \
      -c local \
      "$ROOT_DIR/ansible/bootstrap.yml" \
      -e "dotfiles_root=$ROOT_DIR"
  fi
}

main "$@"
