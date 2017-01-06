# Spiderbench
Bash script that automates the spidering of a website using wget and collects some quick perf stats using Apache Bench

## About this utility
I created this tiny script out of desparation and angst. After scouring the internet for awhile, I determined there wasn't a simple utility for just crawling the top layers of the website to show my managers some simple performance numbers. I didn't want to pay someone for software when UNIX has the tools I need for free hence, I built my own. Spiderbench scratched the 'itch' at least long enough for me to get out of the meeting and back in front of my regular workload.

## What it does
- Prompts for URL or Fully Qualified Domain Name (FQDN)
- Crawls the 'clean' URLS on the top level of the website, ignoring most asset files
- Writes the list of links (a.k.a Sitemap) to a text file
- Reads (loops) through the links list using Apache Bench and prints to separate .csv file

## How to use
- Download or 'git clone' this project
- In your terminal, type the following:
```
./spiderbench.sh
```
- Follow the prompts :)
- For larger sites, the crawl step takes the longest.
- When the script finishes, you'll find your wget crawled directories, and 3 additonal files in the project directory:
-- `crawl.txt`: the 'raw' results of the wget crawling the site in silent mode
-- `links.txt`: the organized list of URLs taken from the raw wget (crawl)ed output. Instant sitemap!
-- `output.csv`: A comma-separated list of Apache Bench statistics for the URL, MIN, MEAN, Standard Deviation, MED, and MAX load times. Can be dumped into Excel for charting.

## Dependencies
- Homebrew (Mac OS X users)
- wget
- apache bench

## Ways to improve this script

Please fork this script if it helps you, or if you'd like to improve how it works.
A few things it's lacking are:
- No cURL option (which I'm told is more powerful and a little faster)
- No customized apache bench configuration (static ab flags set to -n 5 -c 5)
- advanced mode with zero-prompts (for power users or headless CI tasks)
