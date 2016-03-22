#! /bin/bash

TARGET_DIR=/home1/irteam/deploy/basecamp-3rd.1.love.votree/target
TARGET_WAR_NAME=votree-1.0.0-BUILD-SNAPSHOT.war

cd $TARGET_DIR
date -r $TARGET_WAR_NAME +"votree-%Y%m%d-%H:%M:%S".war | xargs -i -t mv $TARGET_WAR_NAME ./backup/{}

cd backup
ls -t | tail -n +11 | xargs -t rm -f

