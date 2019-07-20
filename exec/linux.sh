#!/bin/bash

if [ $# -eq 0 ]; then
  OPTIONS="1"
else
  OPTIONS=$@
fi

CURRENT_DIR=`pwd`
ANSIBLE_DIR=${CURRENT_DIR}/ansible/
CDK_DIR=cdk/ec2/
METADATA="--path-metadata false --version-reporting false"
CONTEXTDATA="-c count=${OPTIONS}"

###############
# CloudFormation
###############
# Ansible
if [ ${OPTIONS} = "ansible" ]; then
  cd ${ANSIBLE_DIR}

  ansible-playbook -i hosts/prd/hosts.ini aws_linux.yml -l aws_linux
  test $? -ne 0 && exit 1

# AWS CDK
else

  cd ${CDK_DIR}

  npm install
  test $? -ne 0 && exit 1

  npm run build
  test $? -ne 0 && exit 1

  # remove
  if [ ${OPTIONS} = "x" ]; then
    cdk destroy -f
    exit 0
  fi

  cdk synth ${METADATA} ${CONTEXTDATA}
  test $? -ne 0 && exit 1

  cdk deploy -f ${METADATA} ${CONTEXTDATA}
  test $? -ne 0 && exit 1

fi

###############
# OS
###############
# skip OS
if [ ${OPTIONS} = "s" ]; then
  exit 0
fi

cd ${ANSIBLE_DIR}

ansible-playbook -i hosts/prd/ os_linux.yml --tags common -l tag_os_linux
test $? -ne 0 && exit 1

###############
# Final
###############
exit 0