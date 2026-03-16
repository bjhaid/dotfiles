#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

prepend_path() {
  local dir="$1"

  if [[ -n "$dir" && -d "$dir" && ":$PATH:" != *":$dir:"* ]]; then
    export PATH="$dir:$PATH"
  fi
}

python_user_bin() {
  if ! command -v python3 >/dev/null 2>&1; then
    return 1
  fi

  local user_base
  user_base="$(python3 -m site --user-base 2>/dev/null)" || return 1
  if [[ -n "$user_base" ]]; then
    printf '%s/bin\n' "$user_base"
  fi
}

prepend_path "$HOME/.local/bin"
prepend_path "$(python_user_bin || true)"

ensure_ansible() {
  local pipx_cmd=(python3 -m pipx)

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
    prepend_path "$(python_user_bin || true)"
    python3 -m pipx ensurepath >/dev/null 2>&1 || true
    hash -r
  fi

  if command -v pipx >/dev/null 2>&1; then
    pipx_cmd=(pipx)
  fi

  if ! "${pipx_cmd[@]}" --version >/dev/null 2>&1; then
    echo "error: pipx could not be executed after installation." >&2
    exit 1
  fi

  if ! "${pipx_cmd[@]}" list 2>/dev/null | grep -q "package ansible-core "; then
    "${pipx_cmd[@]}" install ansible-core
  else
    "${pipx_cmd[@]}" upgrade ansible-core >/dev/null 2>&1 || true
  fi

  if ! command -v ansible-playbook >/dev/null 2>&1; then
    prepend_path "$HOME/.local/bin"
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
