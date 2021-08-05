#!/bin/bash

if [ -f .env ]
then
  export $(cat .env | sed 's/#.*//g' | xargs)
else 
    echo "No environment found. Abort."
    exit 1
fi

FILES="-f compose.seafile.common.yml -f compose.proxy.common.yml"

if [ $SQLITE -eq 1 ]
then
    FILES=$FILES" -f compose.seafile.sqlite.yml"
else
    FILES=$FILES" -f compose.seafile.mariadb.yml -f compose.mariadb.yml"
fi

if [ $NOSWAG -eq 1 ]
then
    FILES=$FILES" -f compose.proxy.noswag.yml"
else
    FILES=$FILES" -f compose.proxy.swag.yml"
fi

docker-compose $FILES $@

