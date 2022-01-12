#!/bin/bash

PREFIX=${HOME}
SCRIPT_FULL_PATH=$(readlink -f $0)
SCRIPT_DIR=$(dirname ${SCRIPT_FULL_PATH})
LOG_PATH=${SCRIPT_DIR}/log

function check_cmd() {
        which ${1} > /dev/null 2>&1
        if [ ${?} != 0 ]; then
                echo "Command \"${1}\" not found"
                exit 1
        fi
}

function exec_cmd() {
        ${1} >> ${LOG_PATH}
        if [ ${?} != 0 ]; then
                echo "Command \"${1}\" failed with ${?}"
                exit ${?}
        fi
}

# Update submodules
git submodule update --init --recursive

# Build tmux-mem-cpu-load
check_cmd cmake
check_cmd make
pushd ${PWD}/dotfiles/tmux/plugins/tmux-mem-cpu-load >> ${LOG_PATH}
exec_cmd "cmake ."
exec_cmd "make"
popd >> ${LOG_PATH}

# Backup current dotfiles
echo "Backup dotfiles"
BACKUP_DIR=${PREFIX}/dotfiles_bak
if [ -d "${BACKUP_DIR}" ]; then
	read -p "Backup dir: ${BACKUP_DIR} is exist, remove it (y/[N])?: " ans
	case ${ans} in
		y|Y|yes|Yes)
			echo "Remove old backup dir"
			rm -rf ${BACKUP_DIR}
			;;
		*)
			echo "Abort"
			exit 0
			;;
	esac
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
echo "Install fzf"
if [ ! -f "${HOME}/.fzf/install" ]; then
	git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
fi
${HOME}/.fzf/install --all >> ${LOG_PATH}
