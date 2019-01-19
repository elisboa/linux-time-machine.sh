### functions.sh
# This file isn't meant to be run. It's a collection of functions used by other scripts
# Author: Eduardo Lisboa <eduardo.lisboa@gmail.com>
# Date: 2019 - 01 - 04

# Set environment vars and aliases
function set-vars () {

    ## Set aliases
	# Creates an alias to tmgit, so we can use tmgit instead of git to access our customized git environment
	alias tmgit="git --git-dir $HOME/.dotfiles/.git --work-tree $HOME"

    ## Set vars
	# Check which branch we are
	CUR_BRANCH="$(tmgit branch | grep \* | cut -d\  -f2 2> /dev/null)"

	# Check which day is today
	TODAY_DATE="$(date +'%Y.%m.%d')"

    # Set commit date based on current time
	COMMIT_DATE="$(date +'%Y.%m.%d-%H.%M')"
    # Force current language to C, so all git messages are in default english
    LANG="C"

	check-env
}

# Check all environment requirements
function check-env () {
	
	echo -e "Checking if working environment is ok"

	cd $HOME
	echo -e "Current directory is $PWD"

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
	if tmgit --version > /dev/null 2>&1
	then
		echo -e "OK"
	else
		echo -e "FAIL: tmgit check"
		exit 1
	fi

	echo -e "All checked"
}

function check-branch () {

	echo -e "Current branch is: ${CUR_BRANCH}"

	# Check whether we need a new branch or not
	if [[ "${CUR_BRANCH}" == "${TODAY_DATE}" ]]
	
	then
		echo -e "${COMMIT_DATE}: A new branch is not needed"
		exit 1
	else
		echo -e "${COMMIT_DATE}: Creating a new branch"
		create-branch
	fi	
}

# create a new branch based on todays' day
function create-branch () {
	
	# Create new branch
	tmgit checkout -b ${TODAY_DATE}
}

# Check what is needed to commit or remove
function check-commit () {

	# Check Removed files
	if tmgit status | egrep 'deleted'
	then
		remove-files
	fi

	# Check if any file was changed
	if tmgit status | grep 'working tree clean' > /dev/null 2>&1
	then
		echo -e "${COMMIT_DATE}: Working tree is clean, yay : )"
	else
		echo -e "${COMMIT_DATE}: Trying to commit changes"
		if commit-changes
		then
			echo -e "${COMMIT_DATE}: Changes commited successfully"
		else
			echo -e "${COMMIT_DATE}: Couldn't commit changes this time :/"
		fi
	fi
}

# Remove from repo files which were removed from the disk
function remove-files () {

		# Delete files using tmgit status and tmgit rm
		tmgit rm --cached -f -r $(tmgit status | egrep 'deleted:' | cut -d\: -f2 | xargs)

}

function commit-changes () {

	echo -e "Starting commit ${COMMIT_DATE}"
	# Commit changes to branch
	if tmgit commit -a -m "$(tmgit status | grep \: ; echo) Automated commit at ${COMMIT_DATE}"
	then
		echo "Commit is OK!"
	else
		echo "Commit failed, exiting now"
		exit 1
	fi

}

# Check the customized git repository
function check-repo () {
	
	# Check if $HOME/.dotfiles/.git is present
	if [[ -d $HOME/.dotfiles/.git ]]
    then
		echo "Repository already present"
    # If not, create and initialize git repository
	else
		echo "Trying to create tmgit repository"
		create-repo
	fi
}

# Check and create Git repository, if necessary 
function create-repo () {

	# Try to create git custom dir, exit in case of fail
	echo -ne "Creating $HOME repository: "
	if mkdir -pv $HOME/.dotfiles
	then
		echo OK
	else
		echo FAIL
		exit 1
	fi

	# Try to initialize the git repository
	cd $HOME/.dotfiles
	if command git init .
    then
        echo "Git init OK"
    else
        echo "Git init FAIL. Exiting now"
        exit 1
    fi

	# Try to create a gitignore file
	if command echo "*" > .gitignore
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
    if command git commit -m "gitignore added with * entry"
    then
        echo "Git commit OK"
    else
        echo "Git commit FAIL. Exiting now"
        exit 1
    fi

	# Go to $HOME dir, reset repository (with an * on gitignore, nothing should happen, actually)
    cd $HOME
    if git --git-dir $HOME/.dotfiles/.git --work-tree $HOME reset --hard
    then
        echo "tmgit reset OK"
    else
        echo "tmgit reset FAIL. Exiting now"
        exit 1
    fi

	# Now print repo status
	git --git-dir $HOME/.dotfiles/.git --work-tree $HOME status

}
