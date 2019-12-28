#!/bin/sh
set -e
cd $( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
npm i nodemon -g

[[ ! -f ~/.local/bin/ansible-playbook ]] && pip3 install ansible==2.8.7 --user

[[ ! -f ~/.local/bin/borg ]] && { wget -4q https://github.com/borgbackup/borg/releases/download/1.1.10/borg-linux64 -O ~/.local/bin/borg && chmod 700 ~/.local/bin/borg; }
