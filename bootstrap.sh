#!/usr/bin/env bash

setup_dependencies() {
  mkdir -p ~/.local/bin

  if [[ $(uname) == "Darwin" ]]; then
    brew install \
      golang npm nvim tmux iterm2 \
      mike-engel/jwt-cli/jwt-cli staticcheck \
      ripgrep fd bat fzf
  else
    curl -L https://github.com/junegunn/fzf/releases/download/v0.57.0/fzf-0.57.0-linux_amd64.tar.gz | tar -C ~/.local/bin -zxvf -
    sudo apt update && sudo apt install --ignore-missing -y \
      tmux nvim fd-find ripgrep bat
  fi

  setup_rust
  cargo install git-delta
}

setup_rust() {
  curl -o /tmp/rustup.sh --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs
  sh /tmp/rustup.sh -y
}

setup_nvm() {
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  nvm install --lts
  nvm use 'lts/*'
}

setup_gitconfig() {
  mkdir -p ~/.local
  pip3 install --prefix ~/.local diff-highlight
  mkdir -p ~/.zshrc.d
  PYTHON_VERSION=$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')
  echo "export PYTHONPATH=~/.local/lib/python${PYTHON_VERSION}/site-packages" >~/.zshrc.d/pythonpath

  rm -rf ~/.gitconfig
  ln -s "$PWD/git/config" ~/.gitconfig
}

setup_zsh() {
  rm -rf ~/.zshrc
  ln -s "$PWD/zsh/zshrc" ~/.zshrc

  rm -rf ~/.aliases
  ln -s "$PWD/zsh/aliases" ~/.aliases

  rm -rf ~/.gorc
  ln -s "$PWD/zsh/gorc" ~/.gorc
  echo 'source <(kubectl completion zsh)' >~/.zshrc.d/kubectl-completion
  echo 'source <(fzf --zsh)' >~/.zshrc.d/fzf-completion
}

setup_nvim() {
  mkdir -p ~/.config
  rm -rf ~/.config/nvim
  ln -s "$PWD/nvim" ~/.config/nvim
}

setup_tmux() {
  rm -rf ~/.tmux.conf
  ln -s "$PWD/tmux/tmux.conf" ~/.tmux.conf

  rm -rf ~/.tmux/plugins
  mkdir -p ~/.tmux/plugins
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
}

_main() {
  setup_dependencies
  setup_zsh
  setup_gitconfig
  setup_nvm
  setup_nvim
  setup_tmux
}

_main
