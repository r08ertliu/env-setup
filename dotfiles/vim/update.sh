#!/bin/bash

# Update all plug-in to remote master head
for dir in plugged/*/ ; do
	pushd ${dir}
	git pull origin master
	popd
done

