# linux-time-machine.sh
A very, very simple time machine for Linux written in shell script that uses cron and git. This application is used to version your entire home directory using days as branches and minutely commits.

## Running

All you have to do is run manually:
```
./tmgit.sh
```

If you want to use a custom directory, other than your $HOME, run this instead:
```
./tmgit.sh my_custom_dir
```

You can use an argument to version all the files of a given dir. To do so, just run like this:
```
./tmgit.sh my_custom_dir version-all
```

Currently the following arguments are supported:
* push-remote — pushes your local git repository to all your configured remote repositories
* version-all — automatically adds every single file on the specified dir before versioning. This is useful if you have a /etc or a docs/ dir which you want do save everything
* mirror-mode — instead of version your current changes, it goes back in time and resets last valid branch. You can pass a custom branch or a (part of a) commit hash too. This feature is available only on `dev` brach actually

PS: the custom dir MUST BE the first argument. By default it uses your $HOME dir, if no custom_dir is specified.

## Scheduling with cron

If you must, you should edit your crontab to add the script, so you can run it automatically:
```
** ** ** ** ** /home/elisboa/.scripts/tmgit.sh >& /tmp/tmgit.sh.log
```

## Adding files to your repository

Now you can use `add-file` argument to automatically add files or folders, like this:
```
./tmgit.sh add-file file_or_folder
```

It will automatically check if the following argument is a file or a folder.

But ou can also must manually (and forcibly) add files or folders to you tmgit repository:
```
alias tmgit='git --git-dir $HOME/.tmgit/.git --work-tree=\$HOME'
tmgit add -f my_file
tmgit add -f my_folder
```

## Removing files

Now you can use `del-file` argument to automatically delete files or folders, like this:
```
./tmgit.sh add-file file_or_folder
```

It will automatically check if the following argument is a file or a folder. Note that this will only remove the file or folder from your tmgit repository, not from the disc.

Otherwise, you can manually remove:
```
alias tmgit='git --git-dir $HOME/.tmgit/.git --work-tree=\$HOME'
tmgit rm -f --cached -r my_file
```
It will not remove the dir or file from disk, only from your tmgit repository :)

## Background story

Detailed explanation:

[As seen here](https://www.electricmonk.nl/log/2015/06/22/keep-your-home-dir-in-git-with-a-detached-working-directory/), this project aims to automatically version control files in your home directory using an aliased git and a customized workdir to store your git settings. 


A very simplified project's resume: basically the tmgit repository is built using these commands:

```
mkdir -pv $HOME/.tmgit
cd $HOME/.tmgit
git init .
echo "*" > .gitignore
git add -f .gitignore
git commit -m "gitignore"
alias tmgit='git --git-dir $HOME/.tmgit/.git --work-tree=\$HOME'
cd ~
tmgit status
```

You now have a customized git repository pointing to your $HOME directory. However, as seen above, it ignores ALL files on your home directory, so you don't add anything by accident. You will only version what you explictitly add.

You can create and add a file to test it:
```
alias tmgit='git --git-dir $HOME/.tmgit/.git --work-tree=\$HOME'
echo "this is a silly test" > $HOME/tmgit_test_file
tmgit add -f $HOME/tmgit_test_file
tmgit commit -m "Added $HOME/tmgit_test_file"
```

## Logging

Monitor log files:
```
tail -f /tmp/tmgit*log
```

## Contact

Report your bugs by creating an issue or post me a pull-request with bugfixes.

## Questions

Do you have more questions? Check our [Wiki](https://github.com/elisboa/linux-time-machine.sh/wiki) out! 
