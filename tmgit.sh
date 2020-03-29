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

while (( "$#" ))
do

  echo -e "Now parsing argument: $1"

        # This whole code below should be optimized

        # Tell which version we are running
        if [[ "$1" == "-v" ]] || [[ "$1" == "--version" ]] || [[ "$1" == "version" ]]
        then
          echo "$(basename $0) version: $VERSION"
          exit 0
        fi

        if [[ -d "$1" ]]
        then
          if [[ -z "$GIT_WORK_TREE" ]]
          then
            echo -e "Using $1 as a work dir"
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

        if [[ "$1" == "mirror-mode" ]]
        then
          echo -e "Entering mirror mode"
          if mirror-mode "$GIT_WORK_TREE" "$@"
          then
            echo -e "Mirror mode ran successfully"
            exit
          else
            echo -e "Mirror mode failed miserably"
            exit 1
          fi
        fi

        # Check if 'version-all' parameter was passed
        if [[ $1 == "version-all" ]]
        then
          echo -e "Versioning all files"
          export VERSION_ALL="TRUE"
        else
          export VERSION_ALL="FALSE"
        fi

        # Checking if "add-file" parameter was passed
        if [[ $1 == "add-file" ]] && [[ -n $2 ]]
        then

            if [[ -f $2 ]]
            then
                export ADD_FILE_TYPE="file"
            elif [[ -d $2 ]]
            then 
                export ADD_FILE_TYPE="directory"
            else
                echo -e "$2 is not a regular file or directory."
                exit 1
            fi
            # Gotta find a better name for this var, I know
            echo -e "Trying to add $ADD_FILE_TYPE: $2"
        fi

        shift

      done

      check-tmgit-repo "${GIT_WORK_TREE}"

      set-vars "${GIT_WORK_TREE}"

      check-branch

      check-commit "${VERSION_ALL}"

    }

# Source all functions from functions.sh
# shellcheck source=/dev/null
#source "$(dirname "${0}")"/functions.sh # old code to import functions.sh
# source specific files as function sources
for file in functions arguments
do
  echo -n "Importing file $file: "
  if source "$(dirname $0)/$file.sh" >& /dev/null
  then
    echo "OK"
  else
    echo "FAIL"
    exit 1
  fi
done

export VERSION="0.7"

# Run main function
main "$@"
