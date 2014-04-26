#!/bin/bash
#
# Es necesario e impepinable tener ya creada la configuración del tunnel:
# pptpsetup --create <nombre_tunnel> --server <server> --username <user> --password <password> --encrypt
#
COMMAND="pon inlog debug dump logfd 2 noipdefault nodetach"
SCREEN_OPTIONS="-S vpn_inlog -t vpn_inlog -m -d"
screen ${SCREEN_OPTIONS} ${COMMAND}

sleep 10
ip r add 192.168.1.0/24 via 192.168.1.1 dev ppp0

ip a show ppp0
ip r
