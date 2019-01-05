# linux-time-machine.sh
A very, very simple and buggy time machine for Linux written in shell script that uses cron and git. This application is used to version your entire home directory using days as branches and minutely commits.

All you have to do is run manually:
0. alias tmgit='git --git-dir $HOME/.dotfiles/.git' --work-tree $HOME
1. tmgit-create-branch.sh
2. tmgit-commit-branch.sh

If you must, you should edit your crontab to add them, so you would have them run automatically:
```
** ** ** ** ** HISTFILE="" /home/elisboa/.scripts/dgit-create-branch.sh >> /tmp/tmgit-create-branch.sh.log
** ** ** ** ** HISTFILE="" /home/elisboa/.scripts/dgit-commit-branch.sh >> /tmp/tmgit-commit-branch.sh.log
```

You must manually add files or folders to you tmgit repository: 
```
tmgit add -f $HOME/my_file
tmgit add -f $HOME/my_folder
```

If you want to remove:
```
tmgit rm -f --cached -r $HOME/my_file
```
It will not remove the dir or file from disk, only from your tmgit repository :)

Detailed explanation:

As seen in: 
https://www.electricmonk.nl/log/2015/06/22/keep-your-home-dir-in-git-with-a-detached-working-directory/
This project aims to automatically version control files in your home directory using an aliased git and a customized workdir to store your git settings. Basically the tmgit repository is built using these commands: 

```
mkdir -pv $HOME/.dotfiles
cd $HOME/.dotfiles
git init .
echo "*" > .gitignore
git add -f .gitignore
git commit -m "gitignore"
echo "alias tmgit='git --git-dir $HOME/.dotfiles/.git --work-tree=\$HOME'" >> $HOME/.bashrc
cd ~
tmgit reset --hard
tmgit status
```

You can create and add a file to test it:
```
echo "this is a silly test" > $HOME/tmgit_test_file
dgit add -f $HOME/tmgit_test_file
dgit commit -m "Added $HOME/tmgit_test_file"
```

With your own user, do a `crontab -e` and call your scripts. Actually I'm using this:
```
** ** ** ** ** HISTFILE="" /home/elisboa/.scripts/tmgit-create-branch.sh >> /tmp/tmgit-create-branch.sh.log
** ** ** ** ** HISTFILE="" /home/elisboa/.scripts/tmgit-commit-branch.sh >> /tmp/tmgit-commit-branch.sh.log
```

Monitor log files: tail -f /tmp/tmgit*log

Report your bugs or post me a pull-request with bugfixes
