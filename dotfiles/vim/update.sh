#!/bin/bash

PREFIX="plugged"

# Update all plug-in to remote master head
for dir in ${PREFIX}/*/ ; do
	pushd ${dir}
	if [ ${dir} == "${PREFIX}/cscope-fzf/" ]; then
		git pull origin main
	else
		git pull origin master
	fi
	popd
done

