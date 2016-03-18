#!/bin/sh

# Checks to see if the database is installed if not, it installs it

if [[ `psql -tAc "SELECT 1 FROM pg_database WHERE datname='docker'"` == "1" ]]
then
    echo "Database already exists"
else
    echo "Database does not exist"
    createdb -O docker --encoding=UTF8 docker
    psql -d docker -f /peptodb.sql
fi
