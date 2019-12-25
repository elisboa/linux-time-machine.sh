#!/usr/bin/env bash

### tmgit.sh
# This is the main script. It imports all functions from an external file and them run them in a determined order 
# Author: Eduardo Lisboa <eduardo.lisboa@gmail.com>
# Date: 2019 - 01 - 11

# Determine the order which all other functions are called
function main () {
    
#    if [[ -d "${1}" ]] 
#    then
#        echo -e "${1} is a valid dir, using it as a work dir"
#        export GIT_WORK_TREE="${1}"
#    else
#        echo -e "Using $HOME as GIT_WORK_TREE"
#        export GIT_WORK_TREE="${HOME}"
#    fi

#    shift

	for argument in "$@"
    do

        echo -e "Now parsing argument: $argument"
        # This whole code below should be optimized
        if [[ -d "$argument" ]]
        then
            if [[ -z "$GIT_WORK_TREE" ]]
            then
                echo -e "Using $argument as a work dir"
                export GIT_WORK_TREE="${argument}"
            else
                echo -e "Using $HOME as GIT_WORK_TREE. If it's not what you expected, try passing it as your first argument"
                export GIT_WORK_TREE="${HOME}"
            fi
        else
            if [[ -z "$GIT_WORK_TREE" ]]
            then
                echo -e "Using $HOME as GIT_WORK_TREE. If it's not what you expected, try passing it as your first argument"
                export GIT_WORK_TREE="${HOME}"
            fi
        fi
    
        # Check if arguments were passed
	    if [[ ${argument} == "push-remote" ]]
	    then
	        echo -ne "\nPushing to remote repos: "
	        if push-remote "${GIT_WORK_TREE}"
	        then
	            echo -e "\nAll repos are done"
                exit 
	        else
	            echo -e "\nProblem pushing to remote repo ${GIT_WORK_TREE}"
	            exit 1
	        fi
	    fi

        if [[ "$argument" == "mirror-mode" ]]
        then
            echo -e "Entering mirror mode"
            if mirror-mode $GIT_WORK_TREE "$@"
            then
                echo -e "Mirror mode ran successfully"
                exit
            else
                echo -e "Mirror mode failed miserably"
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
