#!/bin/bash

# Update all plug-in to remote master head
for dir in plugins/*/ ; do
	pushd ${dir}
	git pull origin master
	popd
done

