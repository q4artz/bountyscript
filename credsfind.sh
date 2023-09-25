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
echo -e "[+] Running theHarvester..."
sudo theHarvester -d $domain -b all -f $domain-creds/theHarvesterScan/
echo -e "[+] Finished Running theHarvester..."

#sort theHarvester emails into text file for h8mail
echo -e "[+] Extracting emails from theHarvester's file..."
grep -oP '(?<=<email>).*?(?=</email>)' $domain-creds/theHarvesterScan/$(echo "$domain" | tr -d .com).xml > $domain-creds/theHarvesterScan/allemail.txt 
echo -e "[+] Finished Extracting emails..."

#Run breach-Parse
echo -e "[+] Running breach-Parse..."
sudo ./breach-parse/breach-parse.sh @$domain $domain-BP.txt "/opt/BreachCompilation/data"
echo -e "[+] Finished Running breach-Parse..."

#combine emails of breach-Parse and theHarvester
mv tesla-master.txt tesla-passwords.txt tesla-users.txt tesla.com-creds/breachparseScan
cat $domain-creds/theHarvesterScan/allemail.txt >> $domain-creds/Allemails.txt
cat $domain-creds/breachparseScan/tesla-users.txt >> $domain-creds/Allemails.txt

#Run h8mail
echo -e "[+] Running h8mail..."
sudo h8mail -t $domain-creds/Allemails.txt -c config.ini -o $domain-creds/h8mailScan/h8mailinfo.csv -j $domain-creds/h8mailScan/h8mailinfo.json
echo -e "[+] FinishedRunning h8mail..."

