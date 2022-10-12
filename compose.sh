#!/bin/bash

if [ -f .env ]
then
    export $(cat .env | sed 's/#.*//g' | xargs)
else 
    echo "No environment found. Abort."
    exit 1
fi

FILES="-f compose.seafile.common.yml -f compose.proxy.common.yml"

if [ $DBMS -eq 1 ]
then
    FILES=$FILES" -f compose.seafile.mariadb.yml -f compose.db.common.yml -f compose.db.mariadb.yml"
elif [ $DBMS -eq 2 ]
then
    FILES=$FILES" -f compose.seafile.mariadb.yml -f compose.db.common.yml -f compose.db.mysql.yml"
else
    FILES=$FILES" -f compose.seafile.sqlite.yml"
    export SQLITE=1
fi

if [ $NOSWAG -eq 1 ]
then
    FILES=$FILES" -f compose.proxy.noswag.yml"
else
    FILES=$FILES" -f compose.proxy.swag.yml"
fi

(set -x; docker-compose $FILES $@)

