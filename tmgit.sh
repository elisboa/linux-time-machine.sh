#!/usr/bin/env bash

### tmgit.sh
# This is the main script. It imports all functions from an external file and them run them in a determined order 
# Author: Eduardo Lisboa <eduardo.lisboa@gmail.com>
# Date: 2019 - 01 - 11

# Determine the order which all other functions are called
function main () {
    
    if [[ -d "${1}" ]] 
    then
        echo -e "${1} is a valid dir, using it as a work dir"
        export TMGIT_WORK_DIR="${1}"
    else
        echo -e "Using $HOME as TMGIT_WORK_DIR"
        export TMGIT_WORK_DIR="${HOME}"
    fi

    shift

	for argument in "${@}"
    do
	    # Check if parameters were passed
	    if [[ ${argument} == "push-remote" ]]
	    then
	        echo -ne "\nPushing to remote repos: "
	        if push-remote "${TMGIT_WORK_DIR}"
	        then
	            echo -e "\nAll repos are done"
	        else
	            echo -e "\nProblem pushing to remote repo ${TMGIT_WORK_DIR}"
	            exit 1
	        fi
	    fi

        # Check if 'version-all' parameter was passed
        if [[ ${argument} == "version-all" ]]
	    then
            echo -e "Versioning all files"
            export VERSION_ALL="True"
	    fi

    done

    check-tmgit-repo "${TMGIT_WORK_DIR}"
    
    set-vars "${TMGIT_WORK_DIR}"
    
    check-branch
    
    check-commit "${VERSION_ALL}"

}

# Source all functions from functions.sh
# shellcheck source=/dev/null
source "$(dirname "${0}")"/functions.sh

# Run main function
main "$@"
