#!/bin/sh

# File date format
DATE=`/bin/date +%y%m%d`

# Archive period
DAYS=30

APACHE_LOG_DIR=/home1/irteam/logs/apache
TOMCAT_LOG_DIR=/home1/irteam/logs/tomcat

### Delete Apache log ###
function delete_apache_log {
	find $APACHE_LOG_DIR -mtime +$DAYS -name "access.log.*" -exec rm {} \;
	find $APACHE_LOG_DIR -mtime +$DAYS -name "error.log.*" -exec rm {} \;
	find $APACHE_LOG_DIR -mtime +$DAYS -name "mod_jk.log.*" -exec rm {} \;
}

### Rotate Tomcat log ###
function rotate_tomcat_log {
	/bin/nice /bin/cp  $TOMCAT_LOG_DIR/catalina.out $TOMCAT_LOG_DIR/catalina.out.$DATE
	/bin/nice /bin/cat /dev/null > $TOMCAT_LOG_DIR/catalina.out
	find $TOMCAT_LOG_DIR -mtime +$DAYS -name "catalina.out.*" -exec rm {} \;
	find $TOMCAT_LOG_DIR -mtime +$DAYS -name "catalina.log*" -exec rm {} \;
}

### Main ###
delete_apache_log
rotate_tomcat_log
