#!/bin/bash

# Get Okta Authentication Scheme Id
# TODO

# Get Current Enabled Authentication Scheme Id
# Line of the form: ,p_authentication_id=>wwv_flow_api.id(10178205176271421) 
a=$(cat app/deploy/f100.xml | grep ",p_authentication_id=>wwv_flow_api.id" | awk -F '[()]' '{print $2}')

# Replace so that Okta is the enabled authentication scheme on install
# TODO