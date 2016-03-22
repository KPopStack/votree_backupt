#!/bin/sh
TOMCAT_DIR=/home1/irteam/apps/tomcat
APACHE_DIR=/home1/irteam/apps/apache
SCRIPT_DIR=/home1/irteam/scripts
Total="$(free | grep '^Mem' | awk '{print $2}')"
Used="$(free | grep '^-/' | awk '{print $3}')"
Check="$(($Used * 100 / $Total))"



function echo_host
{
        host=`hostname`
        echo "[$host] $1"
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

function start_tomcat
{
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

function send_mail
{
	$SCRIPT_DIR/send_mail.py -m dev-support.smtp.nhnent.com -s noreply@nhnent.com -r noble17@nhnent.com -e "$1"
	$SCRIPT_DIR/send_mail.py -m dev-support.smtp.nhnent.com -s noreply@nhnent.com -r sangwoo.chon@nhnent.com -e "$1"
 	$SCRIPT_DIR/send_mail.py -m dev-support.smtp.nhnent.com -s noreply@nhnent.com -r dongjae.lee@nhnent.com -e "$1"
 	$SCRIPT_DIR/send_mail.py -m dev-support.smtp.nhnent.com -s noreply@nhnent.com -r seongwon.kong@nhnent.com -e "$1"
	
}

function restart_service
{
		stop_apache
		stop_tomcat
		start_tomcat
		start_apache
}

NowDate=`date`
echo '현재시각 : '$NowDate
echo 'CRON이 작동합니다.'
http_num=`ps -ef | grep -c 'http[d]'`
tomcat_status=`ps aux | grep catalina | grep java | grep -v grep | grep -v hudson | wc -l | awk '{print $1}'`

echo $http_num
echo $tomcat_status

count=0
if [[ $tomcat_status -eq 0 && $http_num -eq 0 ]];
then
	echo '1'
	$SCRIPT_DIR/webapps.sh start
	count=1
	message='tomcat과 apache가 모두 동작하지 않아 재시작합니다.'

	echo $message
elif [ $tomcat_status -eq 0 ]; then
	echo '2'
	start_tomcat
	count=1
	message='tomcat이 동작하지 않아 재시작합니다.'

	echo $message
elif [ $http_num -eq 0 ]; then
		
	echo '3'
	start_apache
	count=1
	message='apache가 동작하지 않아 재시작합니다.'
	echo $message
elif [ $Check -ge 75 ]; then
	echo '4'
        echo 'memory과사용으로 TOMCAT 재구동'
        restart_service
	count=1
	message='메모리 사용량이 너무 많아 TOMCAT과 APACHE를 재시작합니다.'
	echo $message
fi

if [ $count -eq 1 ]
then
	send_mail "$message"
fi
echo 'CRON이 종료됩니다'
