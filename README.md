# linux-time-machine.sh
A very, very simple and buggy time machine for Linux written in shell script that uses cron and git


How to use:

1. Copy your scripts to a place like ~/.scripts
2. With your own user, do a crontab -e and call your scripts. Actually I'm using this

** ** ** ** ** /home/elisboa/.scripts/dgit-create-branch.sh >> /tmp/dgit-create-branch.sh.log
** ** ** ** ** /home/elisboa/.scripts/dgit-commit-branch.sh >> /tmp/dgit-commit-branch.sh.log

3. Monitor log files: tail -f /tmp/dgit*log

4. Report your bugs or post me a pull-request with bufixes
