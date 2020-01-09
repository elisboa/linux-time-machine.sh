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
		$TMGIT push -u --set-upstream origin "${CUR_BRANCH}"
		$TMGIT remote -v

		#$TMGIT push ${remote_repo} -u --follow-tags 2> /dev/null
	done

}
