# env-setup
Quickly setup environment for development

## Installation
### Normal feature
```
./install
```
### Additional feature
```
./install -a
```
- tmux-mem-cpu-load: Display memory, CPU loading at tmux status bar.
    - Dependencies:
```
sudo apt install g++ make cmake
```
- Better git diff: Present with github style.
    - Dependencies:
        - [delta](https://github.com/dandavison/delta): A syntax-highlighting pager for git, diff, and grep output
        - [bat](https://github.com/sharkdp/bat): A cat(1) clone with syntax highlighting and Git integration.

## Dependencies
### Must have
Ubuntu 18.04/20.04

    sudo apt install cscope universal-ctags silversearcher-ag

Centos 8

    sudo sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
    sudo sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*
    sudo yum install --enablerepo=extras epel-release
    sudo yum install cscope ctags the_silver_searcher
