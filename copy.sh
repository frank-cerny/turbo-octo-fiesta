#!/bin/bash

# Copy relevant ansible configuration to the .ansible directory of the current user and set ANSIBLE_CONFIG accordingly
# @date: 3/13/2022

cp -f -r firewall_services ~/.ansible/
cp -f -r services ~/.ansible/