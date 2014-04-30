#!/bin/bash
#
# Author: Fernando Israél García Martínez
#         mail: frekofefe@gmail.com
#
# Limitation: This script only runs in bash version 4 or higher.
#

declare -a PIDS
RUN_FILE=/tmp/run_file

function techo(){
	# Color 	Code
	# Black 	0
	# Red	 	1
	# Green 	2
	# Yellow 	3
	# Blue 		4
	# Magenta 	5
	# Cyan 		6
	# White 	7
	local COLOR=${1}
	shift
	tput setaf ${COLOR}
	echo "$@"
	tput sgr0
}

function error(){
	case $1 in
		1)
cat << __EOF__
There's a similar screen/process runnig, check it or remove ${RUN_FILE}.
__EOF__
			;;
		2)
cat << __EOF__
There isn't ${RUN_FILE}, check your 'screen' execution.
__EOF__
			;;
	esac
	exit $1
		
}

function get_pids(){
	local PID=$1
	if [ $(ps h --ppid ${PID} -o pid) ] 
	then
		get_pids $(ps h --ppid ${PID} -o pid)
		PIDS+=(${PID})
	elif [ "$(ps --pid ${PID} -o pid)" != "PID" ]
	then
		PIDS+=${PID}
	fi
}

function start(){
	[ -f ${RUN_FILE} ] && error 1

	#### ----------- ####
	ID="jboss_$(openssl rand -hex 4)"
	COMMAND="/bin/bash /inLog/jboss-as-7.1.1.Final/bin/standalone.sh -b 0.0.0.0 -bmanagement=0.0.0.0"
	SCREEN_OPTIONS="-S ${ID} -t ${ID} -m -d"
	#### ---------- ####

	techo 2 "Starting screen-jboss process"
	screen ${SCREEN_OPTIONS} ${COMMAND}

	echo "ID=${ID}" > ${RUN_FILE}
	SCREEN=$(screen -ls | awk '/'${ID}'/ {print $1}')
	echo "SCREEN=${SCREEN}" >> ${RUN_FILE}
	echo "SCREEN_PID=${SCREEN%.*}" >> ${RUN_FILE}
	screen -ls

}

function stop(){
	[ ! -f ${RUN_FILE} ] && error 2
	
	source ${RUN_FILE}
	get_pids ${SCREEN_PID}
	techo 1 "Stoping screen-jboss process ${SCREEN_PID}"
	kill -9 ${PIDS[*]}
	screen -wipe
	[ $? ] && rm ${RUN_FILE}

}

function status(){
	techo 2 "screens UP"
	screen -ls
	
	[ ! -f ${RUN_FILE} ] && error 2
	source ${RUN_FILE}
	get_pids ${SCREEN_PID}
	techo 3 "screen: ${SCREEN}"
	techo 1 "pids  : ${PIDS[*]}"
	
	for PID in ${PIDS[*]}
	do
		ps h --pid ${PID}
	done
}

function flush(){
	# brute force
	for SCREEN in $(screen -ls | awk '/jboss_/ {print $1}')
	do
		get_pids ${SCREEN%.*}
		techo 6 "Killing all screens ${PIDS[*]}"
		kill -9 ${PIDS[*]}
	done
	[ $? ] && rm ${RUN_FILE}
	sleep 5
	screen -wipe
}


function usage(){
	cat << __EOF__
Script to start/stop/status JBoss standalone process:

Usage:
	./process.sh {start|stop|status|flush|help}

	* start	   :Start JBoss, It start jboss standalone mode into a screen, this screen is deattach automatly.
	* stop	   :Stop JBoss, It stop jboss, It kill all java process and screen process associate to it.
	* status   :Show status about screens process, not about JBoss, if you want to see JBoss status you must see the logs.
	* flush	   :It is a brute force clearer and killer of all screens and jboss, You can use it if the "stop" procedure fail.

JBoss log:

	You can see the JBoss logs with the tail tool.

	tail -f ${JBOSS_HOME}/standalone/log/*.log
__EOF__

}

ACTION=${1:-stop}

case $ACTION in
	start)
		start
		;;
	stop)
		stop
		;;
	status)
		status
		;;
	flush)
		flush
		;;
	*)
		usage	
		;;
esac

