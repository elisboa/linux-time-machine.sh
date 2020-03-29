# shellcheck disable=SC2148
# shellcheck disable=SC2063
# shellcheck disable=SC2035

### functions.sh
# This file isn't meant to be run. It's a collection of functions used by other scripts
# Author: Eduardo Lisboa <eduardo.lisboa@gmail.com>
# Date: 2019 - 01 - 04

# Set environment vars and aliases
function set-vars () {

	export GIT_AUTHOR_NAME="Tmgit Script"
	export GIT_COMMITTER_NAME="${GIT_AUTHOR_NAME}"
	
	export GIT_AUTHOR_EMAIL="tmgit@localhost"
	export GIT_COMMITTER_EMAIL="${GIT_AUTHOR_EMAIL}"

	if [[ -n "${1}" ]] 
	then
		GIT_WORK_TREE="${1}"
	else
		GIT_WORK_TREE="${HOME}"
	fi

	export GIT_WORK_TREE
	export GIT_DIR="${GIT_WORK_TREE}/.tmgit/.git"

  ## Set aliases
	# Creates an alias to tmgit, so we can use tmgit instead of git to access our customized git environment
	#alias tmgit="git --git-dir $HOME/.dotfiles/.git --work-tree $HOME"
	# Trying some fancy hack here, because this alias actually doesn't work. Only works when added to ~/.bashrc and script called in interactive mode, by '#!/bin/bash -i'...
	GIT_BIN="$(command -v git)"
	
	# Here we can set some parameter for our git
	GIT_ARGS="--no-pager"
	TMGIT="${GIT_BIN} ${GIT_ARGS}"

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

	if cd "${GIT_WORK_TREE}" ; then
		echo -e "Current directory is: $PWD"
	else
		echo -e "Failed to access ${GIT_WORK_TREE}"
		exit 1
	fi

	# Check whether git is a valid command
	echo -n "git command status is: "
	if command git --no-pager --version > /dev/null 2>&1
	then
		echo -e "OK"
	else
		echo -e "FAIL: git check"
		exit 1
	fi

	# Check whether tmgit alias works or not
	echo -n "tmgit status is: "
	if $TMGIT --version > /dev/null 2>&1
	then
		echo -e "OK"
	else
		echo -e "FAIL: tmgit check"
		exit 1
	fi

	echo -e "All checked!"

	echo -e ""

  echo -n "Git being run as: "
  echo -e "${TMGIT}"
  echo -e "\nConsider adding these lines to your $HOME/.profile: "
	cat <<EoF

export GIT_WORK_TREE="${GIT_WORK_TREE}"
export GIT_DIR="${GIT_DIR}"
alias tmgit="${TMGIT}"

EoF
}

function check-branch () {

	echo -n "Current branch is: ${CUR_BRANCH} "

	# Check whether we need a new branch or not
	if [[ "${CUR_BRANCH}" == "${TODAY_DATE}" ]]
	
	then
		echo -e ": already on today's current branch"

	else
		echo -e ": creating a new branch: ${TODAY_DATE}"
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

	# The version-all argument code must be set HERE
	if [[ $VERSION_ALL == "TRUE" ]]
	then
		echo -ne "Versioning ALL files... "
		find $GIT_WORK_TREE -type f -not -path $GIT_WORK_TREE/.tmgit/* -exec git add -f {} > /dev/null 2>&1 \; > /dev/null 2>&1 && echo SUCCESSFUL || echo FAILED
	fi

	# Check if any file was changed
	if $TMGIT status | grep 'working tree clean' > /dev/null 2>&1
	then
		echo -e "Working tree is clean, yay : )"
	else
		echo -e "Trying to commit changes"
		if commit-changes
		then
			echo -e "Changes committed successfully"
		else
			echo -e "Couldn't commit changes this time :/"
		fi
	fi
	
}

# Remove from repo files which were removed from the disk
function remove-files () {

		# Delete files using tmgit status and tmgit rm
		#$TMGIT rm -f -r "$($TMGIT status | grep -E 'deleted:' | cut -d':' -f2 | xargs)"
		$TMGIT -f -r "$($TMGIT log --diff-filter=D --name-only -n1 | xargs)"

}

function commit-changes () {

	echo -e "Starting commit ${COMMIT_DATE}"

	# Commit changes to branch
	if cd "${GIT_WORK_TREE}" ; then
		${TMGIT} ls-files >& /dev/null | while read -r file ; do ${TMGIT} add -f "${file}" ; done
		#$TMGIT reset -- .dotfiles
		#$TMGIT rm --cached .tmgit > /dev/null 2>&1 
		echo ""
		echo "running ${TMGIT} status"
		$TMGIT status
		echo ""
		if $TMGIT commit -a -m "$($TMGIT diff HEAD --name-only | xargs ; echo -e "\n") Automated commit at ${COMMIT_DATE}" >& /dev/null
		then
			echo -e "Commit is OK!"
		else
			echo -e "Commit failed, exiting now"
			exit 1
		fi
	else
		echo -e "Failed to access ${GIT_WORK_TREE}"
		exit 1
	fi

}

# Check the customized git repository
function check-tmgit-repo () {
	
	if [[ -n "${1}" ]] 
	then
		GIT_WORK_TREE="${1}"
	else
		GIT_WORK_TREE="${HOME}"
	fi
	
	# Check if $GIT_WORK_TREE/.tmgit/.git is present
	if [[ -d "${GIT_WORK_TREE}"/.tmgit/.git ]]
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
	echo -ne "Creating $GIT_WORK_TREE repository: "
	if mkdir -pv "${GIT_WORK_TREE}"/.tmgit
	then
		echo OK
	else
		echo FAIL
		exit 1
	fi

	# Try to initialize the git repository
	if cd "${GIT_WORK_TREE}"/.tmgit ; then
		if command git --no-pager --work-tree "$GIT_WORK_TREE" --git-dir "$GIT_WORK_TREE/.tmgit/.git" init .
		then
			echo "Git init OK"
		else
			echo "Git init FAIL. Exiting now"
			exit 1
		fi
	else
		echo -e "Failed to access ${GIT_WORK_TREE}"
		exit 1
	fi

#	# Try to create a gitignore file on the dir to be versioned
#	if command echo "*" > ${GIT_WORK_TREE}/.gitignore
#    then
#        echo "gitignore file created OK"
#    else
#        echo "gitignore couldn't be written, FAIL. Exiting now"
#        exit 1
#  fi


# Try to create a gitignore file on the repository
if command echo "*" > "$GIT_WORK_TREE/.gitignore"
   then
       echo "gitignore file created OK"
 else
       echo "gitignore couldn't be written, FAIL. Exiting now"
       exit 1
 fi

# Try to add gitignore file to repository
# Lines below were commented out because
# I don't think we actually need to version our .gitignore file
	if command git add -f "$GIT_WORK_TREE/.gitignore"
	then
		echo "Git add OK."
	else
  	echo "Git add FAIL. Exiting now"
    exit 1
	fi

# Try to commit the newly added gitignore file
if command git --no-pager commit  "$GIT_WORK_TREE/.gitignore" -m "gitignore added with * entry"
	then
    echo "Git commit OK"
	else
    echo "Git commit FAIL. Exiting now"
    exit 1
fi

### From now on, git must use custom parameters to refer to our versioned directory

	if cd "${GIT_WORK_TREE}" ; then
		echo "Successfully changed to dir ${GIT_WORK_TREE}"
	else
		echo "Failed to change to dir ${GIT_WORK_TREE}. Exitting now"
		exit 1
	fi

   # Try to copy our .gitignore file to GIT_WORK_TREE root
   if [[ ! -e "${GIT_WORK_TREE}/.gitignore" ]]
   then
     cp -uva "${GIT_WORK_TREE}"/.tmgit/.gitignore "${GIT_WORK_TREE}"
   else
     echo "${GIT_WORK_TREE}/.gitignore already present"
     diff -Nur .gitignore "${GIT_WORK_TREE}/.gitignore"
   fi

#	git --git-dir "${GIT_WORK_TREE}"/.dotfiles/.git --work-tree "${GIT_WORK_TREE}" add -f "${GIT_WORK_TREE}/.gitignore"

	# Go to $GIT_WORK_TREE dir, reset repository (with an * on gitignore, nothing should happen, actually)
    cd "${GIT_WORK_TREE}"
    if git --git-dir "${GIT_WORK_TREE}"/.tmgit/.git --work-tree "${GIT_WORK_TREE}" reset --hard
    then
        echo "tmgit reset OK"
    else
        echo "tmgit reset FAIL. Exiting now"
        exit 1
    fi

	# Now print repo status
	git --no-pager --git-dir "${GIT_WORK_TREE}"/.tmgit/.git --work-tree "${GIT_WORK_TREE}" status
}

function add-file() {

	if $TMGIT add -f $1
	then
		echo -e "SUCCESS"
	else
		echo -e "FAIL"
		break
	fi

}