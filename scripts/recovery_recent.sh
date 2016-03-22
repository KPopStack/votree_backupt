#! /bin/bash

TARGET_DIR=/home1/irteam/deploy/basecamp-3rd.1.love.votree/target
TARGET_WAR_NAME=votree-1.0.0-BUILD-SNAPSHOT.war

cd $TARGET_DIR/backup

ls -tr | tail -n 1 | xargs -t -i mv -i {} $TARGET_DIR/$TARGET_WAR_NAME


