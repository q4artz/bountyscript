#!/bin/bash

#getting domain
domain=$1

#check who is the user
username=$(uname -n) 
echo "user is $username" 

#check if directories exist
if [ ! -d "$domain-creds" ]; then
	sudo -u osint mkdir $domain-creds
fi 
if [ ! -d "$domain-creds/theHarvesterScan" ]; then
	sudo -u osint mkdir $domain-creds/theHarvesterScan
fi
if [ ! -d "$domain-creds/h8mailScan" ]; then
	sudo -u osint mkdir $domain-creds/h8mailScan
fi
if [ ! -d "$domain-creds/breachparseScan" ]; then
	sudo -u osint mkdir $domain-creds/breachparseScan
fi

#Run theHarvester
sudo theHarvester -d $domain -b all -f $domain-creds/theHarvesterScan/$domain-theHarvester

#sort theHarvester emails into text file fro h8mail
grep -o '"emails": *"[^"]*"'  $line | grep -o '"[^"]*"$' >> $domain-creds/theHarvesterScan/temp.txt
cat $domain-creds/theHarvesterScan/temp.txt | tr -d '"' | sort >> $domain-creds/theHarvesterScan/allemails.txt 
rm $domain-creds/theHarvesterScan/temp.txt

#Run h8mail
sudo h8mail -t emails.txt -c config.ini -o $domain-creds/h8mailScan/h8mailinfo.csv -j $domain-creds/h8mailScan/h8mailinfo.json

#Run breach-Parse
