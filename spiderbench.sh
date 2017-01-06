#!/bin/bash

#Variables
DEFAULT='\033[1;37m' #white text
BLUE='\033[1;36m'
RED='\033[0;31m'
HB=$(which brew)
AB=$(which ab)
WGET=$(which wget)
URL=''

spinner() {
	local pid=$1
	local delay=0.10
	local spinstr="|/-\'"
	tput civis;
	while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
	local temp=${spinstr#?}
	printf " [%c] " "$spinstr"
	local spinstr=$temp${spinstr%"$temp"}
	sleep $delay
	printf "\b\b\b\b\b\b"
	done
	printf " \b\b\b\b"
	tput cnorm;
}
crawl() {
	touch 'crawl.txt'
	wget --spider -r -nv -m -np -R js,css,jpeg,jpg,png,pdf --reject-regex '(.*)\?(.*)' -o crawl.txt $URL
}
genlinks() {
	touch 'links.txt'
	# get the (raw) wget output and make it more readable
	awk 'BEGIN {FS = " " }; { print $3 }' crawl.txt | sed '/^URL:.*/!d; s/URL://;' | sed '/^[[:space:]]*$/d' > links.txt
	# so we can use the unix 'read' command, add a blank line at end of file.
	sed -i '' -e '$a\' links.txt
}


clear
printf "${DEFAULT}"
echo "Checking dependencies..."
sleep 1
echo "Looking for Homebrew installation..."
sleep $[ ( $RANDOM % 5 )  + 1 ]s
if [[ -z "$HB" ]]; then
	echo "${RED}We didn't find Homebrew installed on your system.${DEFAULT}"
else
	echo "Homebrew is installed on your system ${BLUE}[OK]${DEFAULT}."
fi
echo "Looking for wget installation..."
sleep $[ ( $RANDOM % 5 )  + 1 ]s
if [[ -z "$WGET" ]]; then
	echo "${RED}We didn't find wget installed on your system.${DEFAULT}"
	exit
else
	echo "wget utility is installed on your system ${BLUE}[OK]${DEFAULT}"
fi
echo "Looking for Apache Bench installation..."
sleep $[ ( $RANDOM % 5 )  + 1 ]s
if [[ -z "$AB" ]]; then
	echo "${RED}We didn't find Apache Bench (ab) installed on your system.${DEFAULT}"
	read -p "Would you like to install it now? (Y/n): " ab
		case $ab in
			[Yy]*) INSTALL_AB=1; echo "Installing Apache Bench...";;
			[Nn]*) echo "Ok, we won't install right now. Goodbye!"; exit;; 
		esac
	if [ $INSTALL_AB -eq 1 ] && [ -z "$HB" ]; then
		sudo apt-get install apache2utils
	elif [[ $INSTALL_AB -eq 1 ]]; then
		brew install ab
	fi
	
else
	echo "Apache Bench was installed on your system ${BLUE}[OK]${DEFAULT}."
fi
sleep 1
echo "Cleaning up some older files..."
if [[ -f ./crawl.txt ]]; then
	echo "Previous 'crawl.txt' found. Removing."
	rm ./crawl.txt
fi
if [[ -f ./links.txt ]]; then
	echo "Previous 'links.txt' file was found. Removing."
	rm ./links.txt
fi
if [[ -f ./output.csv ]]; then
	echo "Previous 'output.csv' file was found. Removing."
	rm ./output.csv
fi
echo "System check COMPLETED!"
echo "Press the ENTER key to get started..."
read -n 1 -s
sleep 1
clear
read -p "Enter the URL of the website you'd like to benchmark [http://mydomain.com], without the trailing slash (/) on the end: " URL
echo "URL saved as ${BLUE}$URL${DEFAULT}"
sleep 1
echo "Next, we'll create a sitemap with ${BLUE}wget${DEFAULT}"
echo "Crawling $URL..."
crawl & spinner $!
echo "Crawl ${BLUE}FINISHED!${DEFAULT}"
sleep 1

echo "Building Links list..."
genlinks & spinner $!
echo "Links generated SUCCESSFULLY. Open the ${BLUE}links.txt${DEFAULT} file to see them."
echo "Press the ENTER key to run the Apache Bench tests.."
read -n 1 -s
clear

echo "Running Bench tests..."
touch output.csv
echo "URL,MIN,MEAN,SD,MED,MAX" >> output.csv
while read url; do
echo "$url, $(ab -n 5 -c 5 $URL/ | sed -n '/Total:/p' | awk -v OFS=, '{ print $2, $3, $4, $5, $6 }')" >> output.csv 
done < links.txt & spinner $!

echo "Bench tests COMPLETED. Look at ${BLUE}output.csv${DEFAULT} for your bench test output!"