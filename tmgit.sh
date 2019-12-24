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
        export GIT_WORK_TREE="${1}"
    else
        echo -e "Using $HOME as GIT_WORK_TREE"
        export GIT_WORK_TREE="${HOME}"
    fi

    shift

	for argument in "${@}"
    do
	    # Check if parameters were passed
	    if [[ ${argument} == "push-remote" ]]
	    then
	        echo -ne "\nPushing to remote repos: "
	        if push-remote "${GIT_WORK_TREE}"
	        then
	            echo -e "\nAll repos are done"
                exit 0
	        else
	            echo -e "\nProblem pushing to remote repo ${GIT_WORK_TREE}"
	            exit 1
	        fi
	    fi

        # Check if 'mirror-mode' parameter was passed
        if [[ ${argument} == "mirror-code" ]]
	    then
            echo -e "Mirroring last commit "
	        if echo mirror-all "$GIT_WORK_TREE" $@
	        then
	            echo -e "Mirror OK"
	        else
	            echo -e "Mirror FAIL"
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

    check-tmgit-repo "${GIT_WORK_TREE}"
    
    set-vars "${GIT_WORK_TREE}"
    
    check-branch
    
    check-commit "${VERSION_ALL}"

}

# Source all functions from functions.sh
# shellcheck source=/dev/null
source "$(dirname "${0}")"/functions.sh

# Run main function
main "$@"
