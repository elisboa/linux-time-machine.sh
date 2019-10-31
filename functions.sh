#!/usr/bin/env bash

### functions.sh
# This file isn't meant to be run. It's a collection of functions used by other scripts
# Author: Eduardo Lisboa <eduardo.lisboa@gmail.com>
# Date: 2019 - 01 - 04

# Push to remote, mirroring repository
function push-remote () {

	set-vars "$1"
	
	# For each remote repository, do...
	$TMGIT remote 2> /dev/null |\
	while read -r remote_repo
	do
		# ... show repo name...
		echo -n "${remote_repo} "
		# ... and push local branches, using mirror
<<<<<<< HEAD
		#$TMGIT push ${remote_repo} --mirror 2> /dev/null
		#... and push local branches, using update
		$TMGIT push -u --set-upstream origin ${CUR_BRANCH}
		#$TMGIT push ${remote_repo} -u --follow-tags 2> /dev/null
=======
		$TMGIT push "${remote_repo}" -u 2> /dev/null
>>>>>>> 3618a0171eec16c38e604d7708631b39d9dc6079
	done

}

# Set environment vars and aliases
function set-vars () {

	if [[ -n "${1}" ]] 
	then
		TMGIT_WORK_DIR="${1}"
	else
		TMGIT_WORK_DIR="${HOME}"
	fi

  ## Set aliases
	# Creates an alias to tmgit, so we can use tmgit instead of git to access our customized git environment
	#alias tmgit="git --git-dir $HOME/.dotfiles/.git --work-tree $HOME"
	# Trying some fancy hack here, because this alias actually doesn't work. Only works when added to ~/.bashrc and script called in interactive mode, by '#!/bin/bash -i'...
	GIT_BIN="$(command -v git)"
	GIT_PARAMS="--git-dir ${TMGIT_WORK_DIR}/.dotfiles/.git --work-tree ${TMGIT_WORK_DIR}"
	TMGIT="${GIT_BIN} ${GIT_PARAMS}"

    ## Set vars
	# Check which branch we are
	CUR_BRANCH="$($TMGIT branch | grep '*' | cut -d\  -f2 2> /dev/null)"

	# Check which day is today
	TODAY_DATE="$(date +'%Y.%m.%d')"

    # Set commit date based on current time
	COMMIT_DATE="$(date +'%Y.%m.%d-%H.%M')"

    # Force current language to C, so all git messages are in default english
    LANG="C"

	# After all set, call check-env function
	check-env
}

# Check all environment requirements
function check-env () {
	
	echo -e "Checking if working environment is ok"

	if cd "${TMGIT_WORK_DIR}" ; then
		echo -e "Current directory is $PWD"
	else
		echo -e "Failed to access ${TMGIT_WORK_DIR}"
		exit 1
	fi

	# Check whether git is a valid command
	echo -ne "git status is: "
	if command git --version > /dev/null 2>&1
	then
		echo -e "OK"
	else
		echo -e "FAIL: git check"
		exit 1
	fi

	# Check whether tmgit alias works or not
	echo -ne "tmgit status is: "
	if $TMGIT --version > /dev/null 2>&1
	then
		echo -e "OK"
	else
		echo -e "FAIL: tmgit check"
		exit 1
	fi

	echo -e "All checked"

  echo -e "Git being run as:"
  echo -e "${TMGIT}"
  echo -e "Consider adding this line to your $HOME/.profile: alias tmgit='${TMGIT}'"
}

function check-branch () {

	echo -e "Current branch is: ${CUR_BRANCH}"

	# Check whether we need a new branch or not
	if [[ "${CUR_BRANCH}" == "${TODAY_DATE}" ]]
	
	then
		echo -e "${COMMIT_DATE}: A new branch is not needed"

	else
		echo -e "${COMMIT_DATE}: Creating a new branch"
		create-branch
	fi	
}

# create a new branch based on todays' day
function create-branch () {
	
	# Create new branch
	$TMGIT checkout -b "${TODAY_DATE}"
}

# Check what is needed to commit or remove
function check-commit () {

	# Check Removed files
	if $TMGIT status | grep -E 'deleted'
	then
		remove-files
	fi

	# Check if any file was changed
	if $TMGIT status | grep 'working tree clean' > /dev/null 2>&1
	then
		echo -e "${COMMIT_DATE}: Working tree is clean, yay : )"
	else
		echo -e "${COMMIT_DATE}: Trying to commit changes"
		if commit-changes
		then
			echo -e "${COMMIT_DATE}: Changes committed successfully"
		else
			echo -e "${COMMIT_DATE}: Couldn't commit changes this time :/"
		fi
	fi
}

# Remove from repo files which were removed from the disk
function remove-files () {

		# Delete files using tmgit status and tmgit rm
		$TMGIT rm -f -r "$($TMGIT status | grep -E 'deleted:' | cut -d':' -f2 | xargs)"

}

function commit-changes () {

	echo -e "Starting commit ${COMMIT_DATE}"
	# Commit changes to branch
	if cd "${TMGIT_WORK_DIR}" ; then
		${TMGIT} ls-files | while read -r file ; do ${TMGIT} add -f "${file}" ; done
		#$TMGIT reset -- .dotfiles
		$TMGIT rm --cached .dotfiles
		echo ""
		echo "running ${TMGIT} status"
		$TMGIT status
		echo ""
		if $TMGIT commit --author "tmgit script <tmgit@localhost>" -a -m "$($TMGIT status | grep -E -v "Changes not staged for commit" | grep 'ed: ' | cut -d':' -f2- | xargs ; echo -e "\n") Automated commit at ${COMMIT_DATE}"
		then
			echo -e "Commit is OK!"
		else
			echo -e "Commit failed, exiting now"
			exit 1
		fi
	else
		echo -e "Failed to access ${TMGIT_WORK_DIR}"
		exit 1
	fi

}

# Check the customized git repository
function check-tmgit-repo () {
	
	if [[ -n "${1}" ]] 
	then
		TMGIT_WORK_DIR="${1}"
	else
		TMGIT_WORK_DIR="${HOME}"
	fi
	
	# Check if $TMGIT_WORK_DIR/.dotfiles/.git is present
	if [[ -d "${TMGIT_WORK_DIR}"/.dotfiles/.git ]]
    then
		echo "Repository already present"
    # If not, create and initialize git repository
	else
		echo "Trying to create tmgit repository"
		create-tmgit-repo
	fi
}

# Check and create Git repository, if necessary 
function create-tmgit-repo () {

	# Try to create git custom dir, exit in case of fail
	echo -ne "Creating $TMGIT_WORK_DIR repository: "
	if mkdir -pv "${TMGIT_WORK_DIR}"/.dotfiles
	then
		echo OK
	else
		echo FAIL
		exit 1
	fi

	# Try to initialize the git repository
	if cd "${TMGIT_WORK_DIR}"/.dotfiles ; then
		if command git init .
		then
			echo "Git init OK"
		else
			echo "Git init FAIL. Exiting now"
			exit 1
		fi
	else
		echo -e "Failed to access ${TMGIT_WORK_DIR}"
		exit 1
	fi

#	# Try to create a gitignore file on the dir to be versioned
#	if command echo "*" > ${TMGIT_WORK_DIR}/.gitignore
#    then
#        echo "gitignore file created OK"
#    else
#        echo "gitignore couldn't be written, FAIL. Exiting now"
#        exit 1
#  fi


	# Try to create a gitignore file on the repository
	if command echo "*" >> .gitignore
    then
        echo "gitignore file created OK"
  else
        echo "gitignore couldn't be written, FAIL. Exiting now"
        exit 1
  fi

	# Try to add gitignore file to repository
	if command git add -f .gitignore
    then
        echo "Git add OK."
    else
        echo "Git add FAIL. Exiting now"
        exit 1
  fi

	# Try to commit the newly added gitignore file
    if command git commit .gitignore -m "gitignore added with * entry"
    then
        echo "Git commit OK"
    else
        echo "Git commit FAIL. Exiting now"
        exit 1
    fi

    # Try to copy our .gitignore file to TMGIT_WORK_DIR root
    if [[ ! -e "${TMGIT_WORK_DIR}/.gitignore" ]]
    then
      cp -uva .gitignore "${TMGIT_WORK_DIR}"
    else
      echo "${TMGIT_WORK_DIR}/.gitignore already present, giving up"
      diff -Nur .gitignore "${TMGIT_WORK_DIR}/.gitignore"
    fi

	# Go to $TMGIT_WORK_DIR dir, reset repository (with an * on gitignore, nothing should happen, actually)
#    cd "${TMGIT_WORK_DIR}"
#    if git --git-dir "${TMGIT_WORK_DIR}"/.dotfiles/.git --work-tree "${TMGIT_WORK_DIR}" reset --hard
#    then
#        echo "tmgit reset OK"
#    else
#        echo "tmgit reset FAIL. Exiting now"
#        exit 1
#    fi
#
	# Now print repo status
	git --git-dir "${TMGIT_WORK_DIR}"/.dotfiles/.git --work-tree "${TMGIT_WORK_DIR}" status
}
