#!/bin/bash




if [ "$(whoami)" = "inlog" ] 
then
	# With ID, we don't have problem y anyone tries to start one new screen
	ID=$(openssl rand -hex 4)
	JBOSS_COMMAND="/bin/bash /inLog/jboss-as-7.1.1.Final/bin/standalone.sh -b 0.0.0.0 -bmanagement=0.0.0.0"
	SCREEN_OPTIONS="-S jboss_${ID} -t jboss_${ID} -m -d"
	screen ${SCREEN_OPTIONS} ${JBOSS_COMMAND}
	[ ! -d ${HOME}/.jboss ] && mkdir ${HOME}/.jboss
	echo "ID=${ID}" > ${HOME}/.jboss/jboss.runnig
	echo "SCREEN=$(screen -ls | grep ${ID} | awk '{awk $1}')" >> ${HOME}/.jboss/jboss.runnig
	echo "SCREEM_PID=${SCREEN%.*}" >> ${HOME}/.jboss/jboss.runnig
else
	echo "Your aren't 'inlog' user"
fi
