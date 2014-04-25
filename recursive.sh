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
		recursive $(ps h --ppid ${PID} -o pid)
		PIDS+=(${PID})
	elif [ "$(ps -pid ${PID} -o pid)" != "PID" ]
	then
		PIDS+=${PID}
	fi
}

get_pids 30977


