# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# User specific aliases and functions
	### WEBAPPS ENV ###
        export APP_HOME=/home1/irteam
        export JAVA_HOME=${APP_HOME}/apps/jdk
        export APACHE_HTTP_HOME=${APP_HOME}/apps/apache
        export TOMCAT_HOME=${APP_HOME}/apps/tomcat
	export MAVEN_HOME=${APP_HOME}/apps/maven
        
	export PATH=${MAVEN_HOME}/bin:$PATH
	export PATH=${JAVA_HOME}/bin:$PATH
        export PATH=${APACHE_HTTP_HOME}/bin:$PATH
	
