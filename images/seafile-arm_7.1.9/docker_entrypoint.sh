#!/bin/bash

if [ "$PUID" == "" ]
then
    PUID=$(id -u seafile)
fi

if [ "$PGID" == "" ]
then
    PGID=$(id -g seafile)
fi

groupmod -g $PGID seafile
usermod -u $PUID seafile
chown -R seafile:seafile /home/seafile
chown -R seafile:seafile /opt/seafile
chown -R seafile:seafile /shared

su seafile -pPc /home/seafile/$1.sh
