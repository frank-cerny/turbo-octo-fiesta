#!/bin/zsh

if [ -z "$1" ]
then
    printf "Invaid usage. Usage: \n./strip-changeset-id.sh <folder of xml files to strip>"
    exit 1
fi

for f in ../app/src/**/*.xml; 
do
    # Reference: https://mkyong.com/mac/sed-command-hits-undefined-label-error-on-mac-os-x/
    # Remove the changeset if from the file (it changes each time so it makes it look like every file is changed)
    sed -i ".bak" "/<changeSet id=/d" temp.xml
    # Remove the backup file that sed created
    rm *.bak
done

# TODO
# 1. Figure out why I am getting permission denied errors from zsh
# 2. Add code to create a workspace
# 3. Figure out how to handle Okta secrets
# 4. Fill out README :)