#!/bin/bash

# Bash Numpad Input script by Thomas Galea.
#
# This is very much intended as just an example.
# Some functions are hard-coded inside this script rather than available via external scripts.
# Some of those may not work for you.

tput civis

# Script expects a folder "numpadInput" in the same location as itself.
cd numpadInput
scriptRoot="$PWD"
# We use a variable to contain the "beep" command so that it can be disabled by the user.
beep="beep"

# Main loop.
while true;do
	clear
	# Print date and time at top of screen.
	echo -e " \e[30;47m "`date +%H:%M`" \e[0m \e[30;47m "`date "+%A, %d %B %Y"`" \e[0m \e[30;47m $HOSTNAME \e[0m "
	echo;echo

	# List options in current folder, assigning a number to each.
	# Colour dependant on whether item is a folder or file.
	x=0
	for item in *;do
		echo -ne " \e[30;47m $x \e[0m "
		# Check if folder or file.
		if [ -d "$item" ];then
			cutdown="${item##*_}"
			echo -e "\e[34m$cutdown\e[0m"
			unset cutdown
			#echo -e "\e[34m$item\e[0m"
		else
			cutdown="${item##*_}"
			cutdown="${cutdown%.*}"
			echo -e "\e[32m$cutdown\e[0m"
			unset cutdown
			#echo -e "\e[32m${item%.*}\e[0m"
		fi
		let x+=1
		echo
	done

	# Send cursor to bottom of page and print controls help.
	tput cup $(expr $(tput lines) - 3)
	echo -ne " \e[30;47m - \e[0m Switch to SRV0   "
	echo;echo
	echo -ne " \e[30;47m 0-9 \e[0m Menu Item   "
	echo -ne " \e[30;47m / \e[0m Main Menu   "
	echo -ne " \e[30;47m . \e[0m Back   "
	echo -ne " \e[30;47m + \e[0m Toggle Beeps   "
	echo -ne " \e[30;47m * \e[0m Restart Menu   "

	# Set cursor colour to black so that the user input doens't appear on-screen.
	echo -ne "\e[30m"
	# Take input.
	inpIsNumber=0
	inp=""
	read -t10 -n1 inp
	# Reset cursor colour.
	echo -ne "\e[0m"
	# Check if input is number (I'm pretty sure there's a prettier way to do this but oh well).
	case $inp in
    	0) inpIsNumber=1;;
	    1) inpIsNumber=1;;
    	2) inpIsNumber=1;;
	    3) inpIsNumber=1;;
    	4) inpIsNumber=1;;
	    5) inpIsNumber=1;;
    	6) inpIsNumber=1;;
	    7) inpIsNumber=1;;
    	8) inpIsNumber=1;;
	    9) inpIsNumber=1;;
	esac
	if [ "$inpIsNumber" = "1" ];then
		# Input is number. Cycle through items until number reached.
		x=0
		target=""
		for currentItem in *;do
			if [ "$x" = "$inp" ];then
				target=$currentItem
			fi
			let x+=1
		done
		# Check if item exists, and if file or folder.
		if [ -d "$target" ];then
			$beep -f1000 -l50 &
			cd "$target"
		elif [ -x "$target" ];then
			$beep -f1000 -l50 -nf1200 -l50 &
			./"$target"
		else
			$beep -f600 -l50 &
		fi
	else
		# Input not a number. Check if it's one of the in-script functions.
		# Return to root.
		if [ "$inp" = "/" ];then
			$beep -f1000 -l50 -nf750 -l50 &
			cd $scriptRoot
		# Parent folder.
		elif [ "$inp" = "." ];then
			$beep -f750 -l50
			if [ "$PWD" != "$scriptRoot" ];then
				cd ..
			fi
		# Toggle beeping.
		elif [ "$inp" = "+" ];then
			if [ "$beep" = "beep" ];then
				# Set command in '$beep' to 'true', which simply exits with an exit code of 0.
				beep="true"
				beep -f1000 -l50 -nf750 -l50 &
			else
				# Set command in '$beep' to 'beep'.
				beep="beep"
				beep -f750 -l50 -nf1000 -l50 &
			fi
		# Connect to SRV0.
		elif [ "$inp" = "-" ];then
			$beep -f750 -l50 -nf1000 -l50 -nf1200 -l50
			ssh srv0
		# Exit script.
		elif [ "$inp" = "*" ];then
			$beep -f1000 -l50 -nf750 -l50 -nf1000 -l50
			exit 0
		# Empty input - Either timeout, space or enter.
		elif [ "$inp" = "" ];then
			true
		else
			# No matches.
			$beep -f600 -l50 &
		fi
	fi
done

echo "Reached end of script. How?"
read -n1 pause
unset pause
exit 1