#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
export PATH="$HOME/.local/bin:$PATH"

ensure_ansible() {
  if command -v ansible-playbook >/dev/null 2>&1; then
    return 0
  fi

  if [[ "$(uname)" == "Darwin" ]]; then
    if ! command -v brew >/dev/null 2>&1; then
      echo "error: Homebrew is required to install ansible on macOS." >&2
      exit 1
    fi
    brew install ansible
  else
    if command -v apt-get >/dev/null 2>&1; then
      sudo apt-get update
      sudo apt-get install -y ansible
    elif command -v pip3 >/dev/null 2>&1; then
      pip3 install --user ansible
      export PATH="$HOME/.local/bin:$PATH"
    else
      echo "error: unable to install ansible automatically (missing apt-get and pip3)." >&2
      exit 1
    fi
  fi

  if ! command -v ansible-playbook >/dev/null 2>&1; then
    export PATH="$HOME/.local/bin:$PATH"
  fi
  if ! command -v ansible-playbook >/dev/null 2>&1; then
    echo "error: ansible-playbook not found after bootstrap." >&2
    exit 1
  fi
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
