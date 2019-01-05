#!/bin/bash -i
### dgit-create-branch
# This script's purpouse is to create a branch using dgit, which is a previously set alias for git with some specific parameters. This script is part of linux-home-timemachine project
# Author: Eduardo Lisboa <eduardo.lisboa@gmail.com>
# Date: 2018 - 08 - 04

function main () {
	set-env
	create-repo
	check-env
	check-branch
}

# Source all functions from functions.sh
source $HOME/.scripts/functions.sh
# Call main function
main
