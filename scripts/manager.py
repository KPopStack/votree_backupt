#!/usr/bin/env python
# -*- coding: utf-8 -*-
import datetime
import operator

def monthStringToNumberString(monthString):
        if monthString == "Jan":
                return "01"
        elif monthString == "Feb":
                return "02"
        elif monthString == "Mar":
                return "03"
        elif monthString == "Apr":
                return "04"
        elif monthString == "May":
                return "05"
        elif monthString == "Jun":
                return "06"
        elif monthString == "Jul":
                return "07"
        elif monthString == "Aug":
                return "08"
        elif monthString == "Sep":
                return "09"
        elif monthString == "Oct":
                return "10"
        elif monthString == "Nov":
                return "11"
        elif monthString == "Dec":
                return "12"
        return 0

def numberStringToMonthString(numberString):
        if numberString == "01":
                return "Jan"
        elif numberString == "02":
                return "Feb"
        elif numberString == "03":
                return "Mar"
        elif numberString == "04":
                return "Apr"
        elif numberString == "05":
                return "May"
        elif numberString == "06":
                return "Jun"
        elif numberString == "07":
                return "Jul"
        elif numberString == "08":
                return "Aug"
        elif numberString == "09":
                return "Sep"
        elif numberString == "10":
                return "Oct"
        elif numberString == "11":
                return "Nov"
        elif numberString == "12":
                return "Dec"
        return "ERR"

def printLog(target):
        inputForLog = raw_input("로그를 보고싶은 날짜와 시간을 입력하세요  : (dd/MMM/yyyy:hh:dd / ex) 29/Feb/2016:17:48) ")
        yearHourMinute = inputForLog.rsplit(':')
        monthDay = inputForLog.rsplit('/',3)
        inputMonth = monthStringToNumberString(monthDay[1])
        inputDay = monthDay[0]
        inputYear = yearHourMinute[0][7:]
        inputHour = yearHourMinute[1]
        inputMinute = yearHourMinute[2]

        if(target == 'apache'):
                searchedDay = datetime.datetime(int(inputYear), int(inputMonth), int(inputDay)).strftime('%Y%m%d')
                f = open ('/home1/irteam/logs/apache/access.log.'+searchedDay, 'r')
                print('## 입력한 시간의 +-5분 동안 Apache 로그는 아래와 같습니다.')
        elif(target == 'tomcat'):
                searchedDay = datetime.datetime(int(inputYear), int(inputMonth), int(inputDay)).strftime('%Y-%m-%d')
                f = open ('/home1/irteam/logs/tomcat/localhost_access_log'+searchedDay+'.txt', 'r')
                print('## 입력한 시간의 +-5분 동안 tomcat 로그는 아래와 같습니다.')

        lines = f.readlines()
        for line in lines:
                logDatetime = line.split()[3][1:]
                yearHourMinute = logDatetime.rsplit(':')
                monthDay = logDatetime.rsplit('/',3)
                logMonth = monthStringToNumberString(monthDay[1])
                logDay = monthDay[0]
                logYear = yearHourMinute[0][7:]
                logHour = yearHourMinute[1]
                logMinute = yearHourMinute[2]
                if(logYear == inputYear and logMonth == inputMonth and logDay == inputDay and logHour == inputHour):
                        if(int(logMinute) >= int(inputMinute)-5 and int(logMinute) <= int(inputMinute)+5):
                                print(line)

        f.close()

def printMostThingByMinutes(target, minute):
        today = datetime.datetime.today()
        todayYmd = today.strftime('%Y-%m-%d')
        nowHour = today.hour
        nowMinute = today.minute
        f = open ('/home1/irteam/logs/tomcat/localhost_access_log'+todayYmd+'.txt', 'r')
        dictForCount = {}
        lines = f.readlines()
        for line in lines :
                logDatetime = line.split()[3][1:]
                hourMinute = logDatetime.rsplit(':')
                logHour = hourMinute[1]
                logMinute = hourMinute[2]
                if(int(logHour) == int(nowHour) and int(logMinute) >= int(nowMinute)- (minute*2)):
			if(target == 'uri'):
				requestUri = line.split()[5][1:] + line.split()[6]
				if(requestUri != 'GET/monitor/l7check' and requestUri != 'GET/'):
					if(requestUri in dictForCount):
                                        	dictForCount[requestUri] +=1
                                        else:
                                        	dictForCount[requestUri] = 1
                        elif(target == 'ip'):
                                requestIp = line.split()[0]
                                if(requestIp != '-'):
                                        if(requestIp in dictForCount):
                                                dictForCount[requestIp] +=1
                                        else:
                                                dictForCount[requestIp] = 1

        if(target == 'uri'):
                print('## 최근 10분 동안 가장 많이 접속한 URI와 그 횟수는 아래와 같습니다.')
        elif(target == 'ip'):
                print('## 최근 10분 동안 가장 많이 접속한 IP와 그 횟수는 아래와 같습니다.')
        
        if(bool(dictForCount)):
                print(sorted(dictForCount.iteritems(), key=operator.itemgetter(1), reverse=True)[0])
        else:
                print("## 최근 10분간 request가 없습니다.")

	f.close()


print ("1 : 아파치 로그 보기 ")
print ("2 : 톰캣 로그 보기 ")
print ("3 : 최근 10분간 많이 접속된 URL 보기 ")
print ("4 : 최근 10분간 많이 접속한 IP 보기 ")
input = input("위 보기에서 원하는 메뉴의 숫자를 입력하세요 : ")

if input == 1:
        printLog('apache')
elif input == 2:
        printLog('tomcat')
elif input == 3:
        printMostThingByMinutes('uri',5)
elif input == 4:
        printMostThingByMinutes('ip',5)
else:
        print("## 잘못된 입력입니다.")

