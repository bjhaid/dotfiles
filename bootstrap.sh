setup_dependencies() {
  if [[ $(uname) == "Darwin" ]]; then
    brew install golang npm rust nvim xclip tmux
  fi
}

setup_gitconfig() {
  mkdir -p ~/.local
  pip3 install --prefix ~/.local diff-highlight
  mkdir -p ~/.zshrc.d
  echo "export PYTHONPATH=~/.local/lib/python3.9/site-packages" > ~/.zshrc.d/pythonpath

  rm -rf ~/.gitconfig
  ln -s $PWD/git/config ~/.gitconfig
}

setup_zsh() {
  rm -rf ~/.zshrc
  ln -s $PWD/zsh/zshrc ~/.zshrc

  rm -rf ~/.aliases
  ln -s $PWD/zsh/aliases ~/.aliases

  rm -rf ~/.gorc
  ln -s $PWD/zsh/gorc ~/.gorc
}

setup_nvim() {
	mkdir -p ~/.config
	rm -rf ~/.config/nvim
	ln -s $PWD/nvim ~/.config/nvim
}

setup_tmux() {
  rm -rf ~/.tmux.conf
  ln -s $PWD/tmux/tmux.conf ~/.tmux.conf

  rm -rf ~/.tmux/plugins
  mkdir -p ~/.tmux/plugins
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
}

_main() {
  setup_dependencies
  setup_zsh
  setup_gitconfig
	setup_nvim
  setup_tmux
}

_main
