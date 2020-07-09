#!/bin/bash

# Bash Numpad Input script by Thomas Galea.
#
# This is very much intended as just an example.
# Some functions are hard-coded inside this script rather than available via external scripts.
# Some of those may not work for you.

tput civis

[[ -d ./numpadInput ]] && cd numpadInput || printf "Warning: numpadInput directory is missing!\n"
scriptRoot="$PWD"
# We use a variable to contain the "beep" command so that it can be disabled by the user.
beep="beep"

# Main loop.
while true
do
	clear
	# Print date and time at top of screen.
	printf "\e[30;47m `date +%H:%M` \e[0m \e[30;47m \"`date \"+%A, %d %B %Y\"`\" \e[0m \e[30;47m $HOSTNAME \e[0m \n\n\n"

	# List options in current folder, assigning a number to each.
	# Colour dependant on whether item is a folder or file.
	x=0
	for item in *
	do
		printf " \e[30;47m $x \e[0m "
		# Check if folder or file.
		[[ -d "$item" ]] && cutdown="${item##*_}" && printf "\e[34m$cutdown\e[0m\n" && \
		#printf "\e[34m$item\e[0m\n"
		unset cutdown || cutdown="${item##*_}" && cutdown="${cutdown%.*}" && printf "\e[32m$cutdown\e[0m\n" && \
		#printf "\e[32m${item%.*}\e[0m\n"
		unset cutdown
		let x+=1
		printf "\n"
	done

	# Send cursor to bottom of page and print controls help.
	tput cup $(expr $(tput lines) - 3)
	printf " \e[30;47m - \e[0m Switch to SRV0   \n\n"
	printf " \e[30;47m 0-9 \e[0m Menu Item   "
	printf " \e[30;47m / \e[0m Main Menu   "
	printf " \e[30;47m . \e[0m Back   "
	printf " \e[30;47m + \e[0m Toggle Beeps   "
	printf " \e[30;47m * \e[0m Restart Menu   "

	# Set cursor colour to black so that the user input doens't appear on-screen.
	printf "\e[30m"
	# Take input.
	inpIsNumber=0
	inp=""
	read -t10 -n1 inp
	# Reset cursor colour.
	printf "\e[0m"
	# Check if input is number
	[[ $yournumber =~ '^[0-9]+$' ]] && inpIsNum = 0 || inpIsNum = 1
	[[ $inpIsNum == "0" ]] &&
		# Input is number. Cycle through items until number reached.
		x=0
		target=""
		for currentItem in *
		do
			[[ "$x" = "$inp" ]] && target=$currentItem
			let x+=1
		done
		# Check if item exists, and if file or folder.
		[[ -d "$target" ]] && $beep -f1000 -l50 & cd "$target" || [[ -x "$target" ]] && $beep -f1000 -l50 -nf1200 -l50 & ./"$target" || $beep -f600 -l50 &
	[[ $inpIsNum == "1" ]] &&
		# Input not a number. Check if it's one of the in-script functions.
		[[ "$inp" = "/" ]] && \
		# Return to root.
		$beep -f1000 -l50 -nf750 -l50 & cd $scriptRoot || [[ "$inp" = "." ]] && \
		# Parent folder
		$beep -f750 -l50 && [[ "$PWD" != "$scriptRoot" ]] && cd .. || [[ "$inp" = "+" ]] && \
		# Toggle beeping
		[[ "$beep" = "beep" ]] && beep="true" && beep -f1000 -l50 -nf750 -l50 || beep="beep" && beep -f750 -l50 -nf1000 -l50 || [[ "$inp" = "-" ]] && $beep -f750 -l50 -nf1000 -l50 -nf1200 -l50 && ssh srv0 || [[ "$inp" = "*" ]] && \
		# Exit script
		$beep -f1000 -l50 -nf750 -l50 -nf1000 -l50 && exit 0 || [[ "$inp" = "" ]] && \
			# No match
			true || $beep -f600 -l50 &
done

printf "Reached end of script. How?"
read -n1 pause
unset pause
exit 1
