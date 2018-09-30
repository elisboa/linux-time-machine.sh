# linux-time-machine.sh
A very, very simple and buggy time machine for Linux written in shell script that uses cron and git. This application is used to version your entire home directory using days as branches and minutely commits.

PS1: You should avoid some larger files for now.
PS2: The add-files function has been disabled, so you have to forcibly add files:
```
dgit add -f ~/my_file
```
PS3: may be a folder as well


How to use:

1. Copy your scripts to a place like ~/.scripts
2. Put an alias in your .bashrc:
```
alias dgit='git --git-dir ~/.dotfiles/.git' --work-tree $HOME
```
3. as seen in: https://www.electricmonk.nl/log/2015/06/22/keep-your-home-dir-in-git-with-a-detached-working-directory/
```
mkdir -pv ~/.dotfiles
cd ~/.dotfiles
git init .
echo "*" > .gitignore
git add -f .gitignore
git commit -m "gitignore"
echo "alias dgit='git --git-dir ~/.dotfiles/.git --work-tree=\$HOME'" >> ~/.bashrc
cd ~
dgit reset --hard
dgit status
```
4. Create and add a file to test it:
```
echo "this is a silly test" > ~/dgittestfile
dgit add -f ~/dgittestfile
dgit commit -m "Added ~/dgittestfile"
```
5. With your own user, do a crontab -e and call your scripts. Actually I'm using this
```
** ** ** ** ** HISTFILE="" /home/elisboa/.scripts/dgit-create-branch.sh >> /tmp/dgit-create-branch.sh.log
** ** ** ** ** HISTFILE="" /home/elisboa/.scripts/dgit-commit-branch.sh >> /tmp/dgit-commit-branch.sh.log
```
6. Monitor log files: tail -f /tmp/dgit*log
7. Report your bugs or post me a pull-request with bufixes
