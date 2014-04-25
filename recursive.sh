#!/bin/bash
#
# 

declare -a PIDS

function get_pids(){
	local PID=$1
	# PIDS+=(${PID})
	# if [ $(pgrep -P ${PID}) ] 
	if [ $(ps h --ppid ${PID} -o pid) ] 
	then
		get_pids $(ps h --ppid ${PID} -o pid)
		PIDS+=(${PID})
	elif [ "$(ps --pid ${PID} -o pid)" != "PID" ]
	then
		PIDS+=${PID}
	fi
}

get_pids 30977

function get_screen_pid(){
	local PATTERN=$1
	PAT=$(screen -ls | awk '/'${PATTERN}'/ {print $1}')
	return ${PAT%.*}
}

echo $(get_screen_pid jboss_server)


