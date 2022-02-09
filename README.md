# env-setup
Quickly setup environment for development

## Installation
### Normal feature
```
./install
```
### Additional feature
- tmux-mem-cpu-load: Display memory, CPU loading at tmux status bar.
Dependencies: `g++`, `make`, `cmake`, [delta](https://github.com/dandavison/delta)
```
./install -a
```

## Dependencies
### Must have
Ubuntu 18.04/20.04

    sudo apt install cscope exuberant-ctags silver_searcher-ag

Centos 8

    sudo yum install cscope ctags the_silver_searcher

### Optional
- [delta](https://github.com/dandavison/delta): A syntax-highlighting pager for git, diff, and grep output
- [bat](https://github.com/sharkdp/bat): A cat(1) clone with syntax highlighting and Git integration.
