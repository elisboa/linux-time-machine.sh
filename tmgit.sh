#!/bin/bash
### tmgit.sh
# This is the main script. It imports all functions from an external file and them run them in a determined order 
# Author: Eduardo Lisboa <eduardo.lisboa@gmail.com>
# Date: 2019 - 01 - 11

# Determines the order which all other functions are called
function main () {
    check-repo
    check-env
    check-branch
    check-commit
}

# Source all functions from functions.sh
source $(dirname ${0})/functions.sh

# Run main function
main
