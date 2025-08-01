#!/bin/bash

if [ -f .env ]
then
    export $(cat .env | sed 's/#.*//g' | xargs)
else 
    echo "No environment found. Abort."
    exit 1
fi

FILES="-f compose.seafile.yml"

if [ $DBMS -eq 0 ]
then
    FILES="$FILES -f compose.db.mariadb.yml"
elif [ $DBMS -eq 1 ]
then
    FILES="$FILES -f compose.db.mysql.yml"
else
    echo "Unsupported DBMS"
    exit 1
fi

if [ $NOSWAG -eq 1 ]
then
    FILES=$FILES" -f compose.proxy.noswag.yml"
else
    FILES=$FILES" -f compose.proxy.swag.yml"
fi

command="docker compose"
if [ "$($command version | grep "version 2")" = "" ]
then
    command=docker-compose
fi

(set -x; $command $FILES $@)

