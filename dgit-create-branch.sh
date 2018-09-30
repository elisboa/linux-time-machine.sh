#!/bin/bash -i
### dgit-create-branch
# This script's purpouse is to create a branch using dgit, which is a previously set alias for git with some specific parameters. This script is part of linux-home-timemachine project
# Author: Eduardo Lisboa <eduardo.lisboa@gmail.com>
# Date: 2018 - 08 - 04

# check environment requirements
function check-env () {
	
	echo -e "Checking if working environment is ok"

	cd $HOME
	echo -e "Current directory is $PWD"

	# Check whether git is a valid command
	echo -ne "git status is: "
	if command git --version > /dev/null 2>&1
	then
		echo -e "OK"
	else
		echo -e "FAIL: git check"
		exit 1
	fi

	# Check whether dgit alias works or not
	echo -ne "dgit status is: "
	if dgit --version > /dev/null 2>&1
	then
		echo -e "OK"
	else
		echo -e "FAIL: dgit check"
		exit 2
	fi

	# Check which branch we are
	CUR_BRANCH="$(dgit branch | grep \* | cut -d\  -f2 2> /dev/null)"
	echo -e "Current branch is: ${CUR_BRANCH}"

	# Check whether we need a new branch or not
	if [[ "${CUR_BRANCH}" == "$(date +'%Y.%m.%d')" ]]
	then
		echo -e "A new branch is not needed. Exiting now"
		exit 1
	else
		echo -e "Creating a new branch"
		create-branch
	fi
	
}


# create branch
function create-branch () {
	
	# Create new branch
	dgit checkout -b $(date +'%Y.%m.%d')
}

function main () {
	check-env
}


main
