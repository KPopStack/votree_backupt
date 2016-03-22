#!/bin/sh
APACHE_DIR=/home1/irteam/apps/apache
TOMCAT_DIR=/home1/irteam/apps/tomcat

L7TESTURL=http://localhost/monitor/l7check.html

USER=`/usr/bin/whoami`
if [ $USER != "irteam" ]
then
	echo "irteam 계정으로 실행해 주세요";
	exit;
fi

function echo_host
{
        host=`hostname`
        echo "[$host] $1"
}

function removezerojsp
{
    echo_host "zero size jsp 삭제 $host"
	find $TOMCAT_DIR/work/ -size 0k | sed 's/\([a-zA-Z0-9]*\)\_jsp.\([a-zA-Z0-9]*\)/\1/g' | xargs -t -i rm -f '{}_jsp'.java '{}_jsp'.class
}

function start_tomcat
{
	#톰켓 실행
        echo_host "Tomcat Start"
        $TOMCAT_DIR/bin/startup.sh

        echo_host "Tomcat is running"

}

function stop_tomcat
{
        echo_host "Shutdown Tomcat"

        $TOMCAT_DIR/bin/shutdown.sh
        sleep 5
        tomcat_status=`ps aux | grep catalina | grep java | grep -v grep | grep -v hudson | wc -l | awk '{print $1}'`
	end_count=0
        while [ $tomcat_status -ge 1 ]
        do
                echo_host "Tomcat is shutdowning"

        	# 시도횟수가 5번이상되면 프로세스 kill
       		 if [ $end_count -eq 5 ]
        	then
            		ps -ef | grep catalina | grep java | grep -v grep | grep -v hudson | awk '{print $2}' | xargs kill -9
            		sleep 2
            		end_count=0
        	fi

                sleep 5
        	end_count=`expr $end_count + 1`
        	tomcat_status=`ps aux | grep catalina | grep java | grep -v grep | grep -v hudson | wc -l | awk '{print $1}'`
        done
        echo_host "Tomcat has stopped"

}

function start_apache
{
        echo_host "Starting apache"
        $APACHE_DIR/bin/apachectl start
        httpd_num=`ps -ef | grep httpd | wc -l | awk '{print $1}'`
        while [ $httpd_num -le 2 ]
        do
                echo_host "Apache is starting"
                sleep 2
                httpd_num=`ps -ef | grep httpd | wc -l | awk '{print $1}'`
        done
        echo_host "Starting apache completed"
}

function stop_apache
{
        echo_host "Stopping apache"
        $APACHE_DIR/bin/apachectl stop
        sleep 2
        httpd_num=`ps -ef | grep -c 'http[d]'`
	end_count=0
        while [ $httpd_num -ge 1 ]
        do
                echo_host "Apache is stopping"
        	$APACHE_DIR/bin/apachectl stop

		# 시도횟수가 5번이상되면 프로세스 kill
		if [ $end_count -eq 5 ]
		then
			ps -ef | grep 'http[d]'| awk '{print $2}' | xargs kill -9
			sleep 2
			end_count=0
		fi

                sleep 2
        	httpd_num=`ps -ef | grep -c 'http[d]'`
        done
        echo_host "Stopping apache completed"
}

function restart_server
{

        #아파치 정지
        stop_apache

        #톰캣 정지 
        stop_tomcat

        #톰캣 시작
        start_tomcat

        #아파치 실행
        start_apache
}


#### Main #####
   
OPTION=$1

case $OPTION in
		"start")
		#톰캣 시작
		start_tomcat
		
		#아파치 실행
		start_apache
		;;

		"stop")
		#아파치
		stop_apache
		
		#톰캣 정지
		stop_tomcat
		;;

		"restart")
			restart_server
		;;

        *)
            echo_host "사용법: $0 start|stop|restart"
        ;;
esac
