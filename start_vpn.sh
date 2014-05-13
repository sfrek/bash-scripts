#!/bin/bash
##
# Author: Fernando Israél García Martínez
#         mail: frekofefe@gmail.com
#
# Limitation: This script only runs in bash version 4 or higher.
#
# Es necesario e impepinable tener ya creada la configuración del tunnel:
# pptpsetup --create <nombre_tunnel> --server <server> --username <user> --password <password> --encrypt
#
#COMMAND="pon inlog debug dump logfd 2 noipdefault nodetach"
#SCREEN_OPTIONS="-S vpn_inlog -t vpn_inlog -m -d"
#screen ${SCREEN_OPTIONS} ${COMMAND}
#
#sleep 10
#ip r add 192.168.1.0/24 via 192.168.1.1 dev ppp0
#
#ip a show ppp0
#ip r

declare -a PIDS
RUN_FILE="/tmp/vpn_run_file"
PREFIX="vpn_inlog"

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
			tput setaf 1
cat << __EOF__
There's a similar screen/process runnig, check it or remove ${RUN_FILE}.
__EOF__
			tput sgr0
			;;
		2)
			tput setaf 1
cat << __EOF__
There isn't ${RUN_FILE}, check your 'screen' execution.
__EOF__
			tput sgr0
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

	# Es necesario e impepinable tener ya creada la configuración del tunnel:
	# pptpsetup --create <nombre_tunnel> --server <server> --username <user> --password <password> --encrypt
	#

	#### ----------- ####
	ID="${PREFIX}_$(openssl rand -hex 4)"
	COMMAND="pon inlog debug dump logfd 2 noipdefault nodetach"
	SCREEN_OPTIONS="-S ${ID} -t ${ID} -m -d"
	#### ---------- ####


	techo 2 "Starting screen-vpn inLog process"
	screen ${SCREEN_OPTIONS} ${COMMAND}
	sleep 10
	# Add the route that we need
	ip route add 192.168.1.0/24 via 192.168.1.1 dev ppp0

	echo "ID=${ID}" > ${RUN_FILE}
	SCREEN=$(screen -ls | awk '/'${ID}'/ {print $1}')
	echo "SCREEN=${SCREEN}" >> ${RUN_FILE}
	echo "SCREEN_PID=${SCREEN%.*}" >> ${RUN_FILE}

	techo 5 "status:"
	status

}

function stop(){
	[ ! -f ${RUN_FILE} ] && error 2
	
	source ${RUN_FILE}
	get_pids ${SCREEN_PID}
	techo 1 "Stoping vpn screen process pid==${SCREEN_PID}"
	kill -9 ${PIDS[*]}
	screen -wipe
	[ $? ] && rm ${RUN_FILE}

	techo 5 "status:"
	status

}

function status(){
	techo 2 "screens UP"
	screen -ls
	
	[ ! -f ${RUN_FILE} ] && error 2
	source ${RUN_FILE}
	get_pids ${SCREEN_PID}
	techo 3 "screen: ${SCREEN}"
	techo 1 "pids  : ${PIDS[*]}"
	
	techo 2 -e "\nPIDs"
	for PID in ${PIDS[*]}
	do
		ps h --pid ${PID}
	done

	techo 2 -e "\nVPN interface"
	ip addr show ppp0

	techo 2 -e "\nNetwork routes"
	ip route show
}

function flush(){
	# brute force
	for SCREEN in $(screen -ls | awk '/'${PREFIX}'/ {print $1}')
	do
		get_pids ${SCREEN%.*}
		techo 6 "Killing all screens ${PIDS[*]}"
		kill -9 ${PIDS[*]}
	done
	[ $? ] && rm ${RUN_FILE}
	sleep 5
	screen -wipe

	techo 4 "The rest screens ..."
	screen -ls
}


function usage(){
	cat << __EOF__
Script to start/stop/status VPN inLog process:

Usage:
	$(pwd)/start_vpn.sh {start|stop|status|flush|help}

	* start    :Start VPN
	* stop     :Stop VPN
	* status   :Show status about "screens process".
	* flush    :It is a brute force cleaner killer of all VPN screens process.
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

