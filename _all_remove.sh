#!/bin/bash

ansible-playbook -i hosts/aws/hosts.ini aws.yml -l prd --extra-vars "state=absent"
test $? -ne 0 && exit 1

exit 0