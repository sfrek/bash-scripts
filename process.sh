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
	echo "SCREEN=$(screen -ls | awk '/'${ID}'/ {awk $1}')" >> ${RUN_FILE}
	echo "SCREEM_PID=${SCREEN%.*}" >> ${RUN_FILE}

}

function stop(){
	[ ! -f ${RUN_FILE} ] && error 2
	
	source ${RUN_FILE}
	get_pids ${SCREEM_PID}
	techo 1 "Stoping screen-jboss process"
	kill -9 ${PIDS[*]}
	[ $? ] && rm ${RUN_FILE}

}

ACTION=${1:-stop}

case $ACTION in
	start)
		start
		;;
	stop)
		stop
		;;
esac

