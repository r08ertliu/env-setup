#!/bin/bash

PREFIX=${HOME}

# Update submodules
git submodule update --init --recursive

# Backup current dotfiles
BACKUP_DIR=${PREFIX}/dotfiles_bak
if [ -d "${BACKUP_DIR}" ]; then
	echo "Backup dir: ${BACKUP_DIR} is exist!!"
	exit 1
fi

mkdir ${BACKUP_DIR}

bashrc_path=${PREFIX}/.bashrc
if [ -f "${bashrc_path}" ]; then
	mv ${bashrc_path} ${BACKUP_DIR}
fi

gitconfig_path=${PREFIX}/.gitconfig
if [ -f "${gitconfig_path}" ]; then
	mv ${gitconfig_path} ${BACKUP_DIR}
fi

tmux_path=${PREFIX}/.tmux
if [ -d "${tmux_path}" ]; then
	mv ${tmux_path} ${BACKUP_DIR}
fi

tmux_conf_path=${PREFIX}/.tmux.conf
if [ -f "${tmux_conf_path}" ]; then
	mv ${tmux_conf_path} ${BACKUP_DIR}
fi

vim_path=${PREFIX}/.vim
if [ -d "${vim_path}" ]; then
	mv ${vim_path} ${BACKUP_DIR}
fi

vimrc_path=${PREFIX}/.vimrc
if [ -f "${vimrc_path}" ]; then
	mv ${vimrc_path} ${BACKUP_DIR}
fi

# Link dotfiles
ln -s ${PWD}/dotfiles/bashrc ${bashrc_path}
ln -s ${PWD}/dotfiles/gitconfig ${gitconfig_path}
ln -s ${PWD}/dotfiles/tmux ${tmux_path}
ln -s ${PWD}/dotfiles/tmux.conf ${tmux_conf_path}
ln -s ${PWD}/dotfiles/vim ${vim_path}
ln -s ${PWD}/dotfiles/vimrc ${vimrc_path}

# Install fuzzy finder
if [ ! -f "${HOME}/.fzf/install" ]; then
	git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
fi
${HOME}/.fzf/install --all
