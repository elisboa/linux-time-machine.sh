# shellcheck disable=SC2148

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
		#$TMGIT push ${remote_repo} --mirror 2> /dev/null
		#... and push local branches, using update
		$TMGIT push -u --set-upstream "$remote_repo" "${CUR_BRANCH}"
		$TMGIT push -u $remote_repo HEAD # upload current branch
		$TMGIT remote -v

		#$TMGIT push ${remote_repo} -u --follow-tags 2> /dev/null
	done

}

# Mirror mode: always restore last commit, unless specified via argument
function mirror-mode () {

	# if I had to reset these vars, this would be the place
	#unset MIRROR_BRANCH
	#unset COMMIT_HASH

	set-vars "$1"
	#echo "Debug: arguments passed -> $@"

	for argument in "$@"
	do
		#echo -e "Now parsing argument: $argument"

		# check if we are in a valid repository 
		$TMGIT status >& /dev/null || return 1

		# Checking for a valid branch name passed as an argument
		if MIRROR_BRANCH="$($TMGIT branch -a | grep -Ev 'master|remotes' | grep $argument | tail -n1 | cut -c 3- >& /dev/null)" && [[ -n "$MIRROR_BRANCH" ]]
		then
			echo -e "Mirror branch is now $MIRROR_BRANCH"
		else
			MIRROR_BRANCH="$($TMGIT branch -a | grep -Ev 'master|remotes' | tail -n1 | cut -c 3- >& /dev/null)"
		fi

		# Now checking for a valid part of a commit hash passed as an argument
		if [[ "$(git --no-pager cat-file -t $argument >& /dev/null)" == "commit" ]]
		then
			export COMMIT_HASH="$argument"
			echo -e "Found a valid commit hash: $COMMIT_HASH"
		fi
	done

	#echo debug mirror branch $MIRROR_BRANCH
	#echo debug commit hash $COMMIT_HASH

	# If we have a valid commit hash instead, try resetting to that
	if [[ -n $COMMIT_HASH ]]
	then
		echo -n "Mirroring from commit hash $COMMIT_HASH: "
		if $TMGIT reset --hard "$COMMIT_HASH" >& /dev/null
		then
			echo -e "OK"
			return 0
		else
			echo -e "FAIL"
			return 1
		fi
	fi

	# If we have a valid branch, then let's reset to it
	if [[ -n "$MIRROR_BRANCH" ]]
	then
		echo -n "Mirroring from branch $MIRROR_BRANCH: "
		if $TMGIT reset --hard "$MIRROR_BRANCH" >& /dev/null
		then
			echo -e "OK"
			return 0
		else
			echo -e "FAIL"
			return 1
		fi 
	fi

# this whole code above should be optimized

}