#!/bin/sh

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
echo "Checking requirements..."
sleep $[ ( $RANDOM % 5 )  + 1 ]s
if [[ -z "$HB" ]]; then
	echo "We didn't find Homebrew intalled on your system."
else
	echo "Homebrew is installed on your system ${BLUE}[OK]${DEFAULT}."
fi
echo "..."
sleep $[ ( $RANDOM % 5 )  + 1 ]s
if [[ -z "$WGET" ]]; then
	echo "We didn't find wget installed on your system\n".
else
	echo "wget utility is installed on your system ${BLUE}[OK]${DEFAULT}."
fi
echo "..."
sleep $[ ( $RANDOM % 5 )  + 1 ]s
if [[ -z "$AB" ]]; then
	echo "We didn't find Apache Bench (ab) installed on your system\n".
else
	echo "Apache Bench was installed on your system ${BLUE}[OK]${DEFAULT}."
fi
echo "..."
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
read -p "Enter the URL of the website you'd like to benchmark [http://mydomain.com]: " URL
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
echo "$url, $(ab -n 5 -c 5 http://www.saml-dev.digium.com:8082/ | sed -n '/Total:/p' | awk -v OFS=, '{ print $2, $3, $4, $5, $6 }')" >> output.csv 
done < links.txt & spinner $!

echo "Bench tests COMPLETED. Look at ${BLUE}output.csv${DEFAULT} for your bench test output!"