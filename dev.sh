#!/bin/sh
set -e
cd $( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
export ANSIBLE_PRIVATE_ROLE_VARS=True
export ANSIBLE_STDOUT_CALLBACK=yaml

nodemon -w $(pwd) -w ./roles/borg/tasks -e yaml,sh,py -x ansible-playbook -- -i localhost, -M ./roles ./borg.yaml 
