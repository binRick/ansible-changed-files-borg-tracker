#!/bin/sh
set -e
cd $( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
export ANSIBLE_PRIVATE_ROLE_VARS=True
export ANSIBLE_STDOUT_CALLBACK=unixy
export ANSIBLE_STDOUT_CALLBACK=yaml
export ANSIBLE_DEPRECATION_WARNINGS=False
export ANSIBLE_RETRY_FILES_ENABLED=False
export PATH=~/.local/bin:$PATH


nodemon --delay 5 -w $(pwd) -w ./roles/borg/tasks -e yaml,sh,py -x ansible-playbook -- -c local -i localhost, -M ./roles ./borg.yaml $@
