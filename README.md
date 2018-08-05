# linux-time-machine.sh
A very, very simple and buggy time machine for Linux written in shell script that uses cron and git


How to use:

1. Copy your scripts to a place like ~/.scripts
2. Put an alias in your .bashrc:
```
alias dgit='git --git-dir ~/.dotfiles/.git' --work-tree $HOME
```
3. Follow these steps: https://www.electricmonk.nl/log/2015/06/22/keep-your-home-dir-in-git-with-a-detached-working-directory/
4. With your own user, do a crontab -e and call your scripts. Actually I'm using this

** ** ** ** ** /home/elisboa/.scripts/dgit-create-branch.sh >> /tmp/dgit-create-branch.sh.log

** ** ** ** ** /home/elisboa/.scripts/dgit-commit-branch.sh >> /tmp/dgit-commit-branch.sh.log

5. Monitor log files: tail -f /tmp/dgit*log

6. Report your bugs or post me a pull-request with bufixes
