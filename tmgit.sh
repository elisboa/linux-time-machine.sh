#!/bin/bash -i
### tmgit.sh
# This is the main script. It imports all functions from an external file and them run them in a determined order 
# Author: Eduardo Lisboa <eduardo.lisboa@gmail.com>
# Date: 2019 - 01 - 11

# Determine the order which all other functions are called
function main () {
    
    check-tmgit-repo
    
    set-vars
    
    check-branch
    
    check-commit

    # Check if parameters were passed
    if [[ "${1}" == "push-remote" ]]
    then
        sleep 5 #sleep so it doesnt conflict with another 
        echo -ne "\nPushing to remote repos: "
        if push-remote
        then
            echo -e "\nAll repos are done"
        else
            echo -e "\nProblem pushing to remote repo $remote_repo"
            exit 1
        fi
    fi

}

# Source all functions from functions.sh
source $(dirname ${0})/functions.sh

# Run main function
main $@
