#
# Colors with tput and echo -e
#


function techo(){
# Action 	Parameters
# Set background color 	tput setab color
# Set foreground color 	tput setaf color
# Set bold mode 	tput bold
# Set half-bright mode 	tput dim
# Set underline mode 	tput smul
# Exit underline mode 	tput rmul
# Reverse mode 	tput rev
# Set standout mode 	tput smso
# Exit standout mode 	tput rmso
# Reset all attributes 	tput sgr0
# Color 	Code
# Black 	0
# Red 	1
# Green 	2
# Yellow 	3
# Blue 	4
# Magenta 	5
# Cyan 	6
# White 	7
	local COLOR=${1}
	shift
	tput setaf ${COLOR}
	echo "$@"
	tput sgr0
}
