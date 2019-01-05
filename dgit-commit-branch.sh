#!/bin/bash -i
### dgit-commit-branch
# This script's purpouse is to commit all changes made to $HOME directory using dgit, which is a previously set alias for git with some specific parameters. This script is part of linux-home-timemachine project
# Author: Eduardo Lisboa <eduardo.lisboa@gmail.com>
# Date: 2018 - 08 - 04

function main () {
	set-env
	check-env
	remove-files
	commit-changes
}

# Sleep for some seconds, so dgit-create-branch can run first
sleep 2

# Source all functions from functions.sh
source $HOME/.scripts/functions.sh
# Call main function
main
