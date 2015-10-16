#!/bin/bash
# This is a setup script by Joseph Burger
# It gets the credentials to log into a mysql database,
# and then runs a bunch of commands in a sql file.
# To run this script/program: ($ means you enter the command
# on a command line):
# $bash serverSetup.sh OPTION

# So obviously you need to set up your mysql database first
# so that you can use it over a command line. IDK if windows
# lets you do this... Anyways, look it up on google, but
# you should, by default, be able to log in as html5game. or
# something. Mysql always comes with a default login you
# can use.

# Read the credentials into variables
# Credentials is a file whose first line is the username,
# and second line is the password to log in to the db

cd MySQL/
un=`find . -type f -name "credentials.ini" -exec sed -rn 's/user.*\s(\w+);/\1/ p' {} \;`
pw=`find . -type f -name "credentials.ini" -exec sed -rn 's/password.*\s(\w+);/\1/ p' {} \;`

if [[ $# -eq 1 && $1 =~ "delete" || $1 =~ "d" ]];
then
    echo "Deleting the html5 game database."
    mysql -u$un -p$pw -e "drop database html5game;"
elif [[ $# -eq 1 && $1 =~ "create" || $1 =~ "c" ]];
then
    echo "Creating the html5 game database."
    mysql -u$un -p$pw < commands.sql
    echo "html5 game database created."
elif [[ $# -eq 1 && $1 =~ "remake" || $1 =~ "r" ]];
then
    echo "Deleting the html5 game database."
    mysql -u$un -p$pw -e "drop database html5game;"
    echo "Creating the html5 game database."
    mysql -u$un -p$pw < commands.sql
    echo "html5 game database created."
else
    echo "usage: serverSetup.sh [c(reate)|d(elete)|r(emake)]";
fi;

# Example of a credentials file:
# Ignore the comments and line numbers...
#line 1 Alex
#line 2 Password123

# just get rid of the hashpounds, those are comments in bash.
# so without "line 1/2" your credentials would be

#Alex
#Password123
