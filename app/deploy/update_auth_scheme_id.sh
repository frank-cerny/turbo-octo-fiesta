#!/bin/bash
# Script used to set Okta as default authentication scheme on production deployment only

# References:
# How to use -i on OSX: https://stackoverflow.com/questions/19456518/error-when-using-sed-with-find-command-on-os-x-invalid-command-code

# Arguments
# $1 = absolute or relative file path to deployment xml

# Get Okta Authentication Scheme Id
# Reference: https://stackoverflow.com/questions/1891797/capturing-groups-from-a-grep-regex
# Example:
# wwv_flow_api.create_authentication(
#  p_id=>wwv_flow_api.id(22425424765520547)
# ,p_name=>'Okta'
# regex="wwv_flow_api\.create_authentication\([\r\n]+ p_id=>wwv_flow_api\.id\(([0-9]+)\)[\r\n]+,p_name=>\'Okta\'"
okta_auth_id="1"
regex="prompt --application/shared_components/security/authentications/okta.*wwv_flow_api\.create_authentication\(.* p_id=>wwv_flow_api\.id\(([0-9]+)\).*,p_name=>\'Okta\'"
if [[ $(cat "$1") =~ $regex ]]
then
    okta_auth_id="${BASH_REMATCH[1]}"
    printf "Okta Authentication Scheme Id: $okta_auth_id\n"
else
    printf "Okta Authentication Scheme Id not found in import file. Exiting\n"
    exit 1
fi

# Get Current Enabled Authentication Scheme Id
# Line of the form: ,p_authentication_id=>wwv_flow_api.id(1) 
current_auth_id=$(cat app/deploy/f100.xml | grep ",p_authentication_id=>wwv_flow_api.id" | awk -F '[()]' '{print $2}')
printf "Current Authentication Scheme Id is $current_auth_id\n"

# Replace so that Okta is the enabled authentication scheme on install
printf "Replacing current scheme with Okta\n"
sed -i '' "s/,p_authentication_id=>wwv_flow_api.id($current_auth_id)/,p_authentication_id=>wwv_flow_api.id($okta_auth_id)/" "$1"