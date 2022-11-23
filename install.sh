#!/bin/bash

ADDITIONAL=0
PREFIX=${HOME}
SCRIPT_FULL_PATH=$(readlink -f $0)
SCRIPT_DIR=$(dirname ${SCRIPT_FULL_PATH})
LOG_PATH=${SCRIPT_DIR}/log
DISTRO=$(cat /etc/os-release | grep "^ID=" | awk -F"=" '{print $2}' | tr '[:upper:]' '[:lower:]' | cut -d"\"" -f2)

function usage() {
	echo "Usage: $0 [-ah]"
	echo "    -a additional feature"
	echo "    -p install prerequisite"
	echo "    -h display usage"
	exit 1
}

function log() {
	echo ${1} | tee -a ${LOG_PATH}
}

function check_cmd() {
	which ${1} > /dev/null 2>&1
	local ret=${?}
	if [ ${ret} != 0 ]; then
		if [ -z ${2} ] || [ ${2} != false ]; then
			log "Command \"${1}\" not found"
			exit ${ret}
		fi
	fi
	return ${ret}
}

function exec_cmd() {
	${1} >> ${LOG_PATH}
	if [ ${?} != 0 ]; then
		log "Command \"${1}\" failed with ${?}"
		exit ${?}
	fi
}

function install_pre() {
	if [[ $(whoami) != "root" ]]; then
		echo "Need root permission to install package"
	fi

	local ret

	check_cmd bat false
	ret=${?}
	local has_bat=$((! ret))

	check_cmd delta false
	ret=${?}
	local has_delta=$((! ret))

	case $DISTRO in
	"centos")
		;&
	"almalinux")
		;&
	"rocky")
		;&
	"rhel")
		log "RPM distro"
		sudo yum update
		sudo yum install --enablerepo=extras epel-release
		sudo yum install g++ make cmake cscope ctags the_silver_searcher tmux

		# install rust
		if [ ${has_bat} == 0 ] || [ ${has_delta} == 0 ]; then
			log "Install rust"
			curl https://sh.rustup.rs -sSf | sh -s -- -y
			source $HOME/.cargo/env
			mkdir -p $HOME/.local/bin
		fi

		if [ ${has_bat} == 0 ]; then
			log "Install bat"
			git clone https://github.com/sharkdp/bat.git
			pushd bat
			cargo build --release
			cp ./target/release/bat $HOME/.local/bin/bat
			popd
		fi

		if [ ${has_delta} == 0 ]; then
			log "Install delta"
			git clone https://github.com/dandavison/delta.git
			pushd delta
			cargo build --release
			cp ./target/release/delta $HOME/.local/bin/delta
			popd
		fi
		;;
	"ubuntu")
		log "DEB distro"
		sudo apt update
		sudo apt install g++ make cmake cscope universal-ctags silversearcher-ag tmux
		if [ ${has_bat} == 0 ]; then
			log "Install bat"
			wget -P /tmp https://github.com/sharkdp/bat/releases/download/v0.22.1/bat_0.22.1_amd64.deb
			sudo dpkg -i /tmp/bat_0.22.1_amd64.deb
		fi
		if [ ${has_delta} == 0 ]; then
			log "Install delta"
			wget -P /tmp https://github.com/dandavison/delta/releases/download/0.14.0/git-delta_0.14.0_amd64.deb
			sudo dpkg -i /tmp/git-delta_0.14.0_amd64.deb
		fi
		;;
	*)
		log "Unsupported distro '$DISTRO'."
		exit 1
		;;
	esac
}

while getopts "aph" opt; do
	case "${opt}" in
		a)
			ADDITIONAL=1
			;;
		p)
			install_pre
			exit 0
			;;
		h)
			usage
			;;
		*)
			usage
			;;
	esac
done

# Update submodules
git submodule update --init --recursive

# tmux-mem-cpu-load
pushd ${PWD}/dotfiles/tmux/plugins/tmux-mem-cpu-load >> ${LOG_PATH}
git clean -ffdx > /dev/null 2>&1
if [ ${ADDITIONAL} == 1 ]; then
	log "Additional feature"
	log "Build tmux-mem-cpu-load"
	check_cmd g++
	check_cmd cmake
	check_cmd make
	exec_cmd "cmake ."
	exec_cmd "make"
else
	log "Normal feature"
fi
popd >> ${LOG_PATH}

# Backup current dotfiles
log "Backup dotfiles"
BACKUP_DIR=${PREFIX}/dotfiles_bak
if [ -d "${BACKUP_DIR}" ]; then
	read -p "Backup dir: ${BACKUP_DIR} is exist, remove it (y/[N])?: " ans
	case ${ans} in
		y|Y|yes|Yes)
			log "Remove old backup dir"
			rm -rf ${BACKUP_DIR}
			;;
		*)
			log "Abort"
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

if [ ${ADDITIONAL} == 1 ]; then
	gitconfig_delta_path=${PREFIX}/.gitconfig.delta
	if [ -f "${gitconfig_delta_path}" ]; then
		mv ${gitconfig_delta_path} ${BACKUP_DIR}
	fi
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
if [ ${ADDITIONAL} == 1 ]; then
	ln -s ${PWD}/dotfiles/gitconfig.delta ${PREFIX}/.gitconfig.delta
fi
ln -s ${PWD}/dotfiles/tmux ${tmux_path}
ln -s ${PWD}/dotfiles/tmux.conf ${tmux_conf_path}
ln -s ${PWD}/dotfiles/vim ${vim_path}
ln -s ${PWD}/dotfiles/vimrc ${vimrc_path}

# Install fuzzy finder
log "Install fzf"
if [ ! -f "${HOME}/.fzf/install" ]; then
	git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf >> ${LOG_PATH}
fi
${HOME}/.fzf/install --all >> ${LOG_PATH}

log "Done!"
