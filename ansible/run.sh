#!/bin/bash
echo "" > ansible.log
ansible-playbook -e "@vars" playbook.yml
