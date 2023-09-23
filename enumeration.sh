#!/bin/bash

echo "enumeration script takes in | ip addr (provide the file if it is a file) | nmap scan mode"
echo "-sS | Nmap stealth scan (-sS -T2 -disable-arp-ping --top-ports 20)"
echo "-n  | Nmap normal scan (-Pn -T3 -A)"

#getting arguements
ipaddr=$1
scanmode=$2

#check who is the user
username=$(uname -n) 
echo "user is $username" 

# creating required directories
if [ ! -d "enumeration" ]; then
	sudo -u $username mkdir enumeration
fi
if [ ! -d "enumeration/nmapScan" ]; then
	sudo -u $username mkdir enumeration/nmapScan
fi
if [ ! -d "enumeration/dnsreconScan" ]; then
	sudo -u $username mkdir enumeration/dnsrecon
fi
if [ ! -d "enumeration/fierceScan" ]; then
	sudo -u $username mkdir enumeration/fierce
fi
if [ ! -d "enumeration/ffufScan" ]; then
	sudo -u $username mkdir enumeration/ffufScan
fi
if [ ! -d "enumeration/enum4linux-ngScan" ]; then
	sudo -u $username mkdir enumeration/enum4linux-ngScan
fi
if [ ! -d "enumeration/searchsploitScan" ]; then
	sudo -u $username mkdir enumeration/searchsploitScan
fi

# nmap script take in ip addr | scan mode 
if [ -f $ipaddr ]; then
	IFS=$'\r\n' GLOBIGNORE='*' command eval  'XYZ=($(cat $ipaddr))'
else  
	sudo nmap -n $ipaddr -oG - | awk '/Up$/{print $2}' > enumeration/nmapScan/hostup.txt

	IFS=$'\r\n' GLOBIGNORE='*' command eval  'XYZ=($(cat enumeration/nmapScan/hostup.txt))'
fi

# Initiating nmap scans
echo -e "[+] Initiating Nmap scans for ${XYZ[*]} \n"

if [ $scanmode == "-sS" ]; then
	for line in "${XYZ[@]}" ; do sudo nmap $line -sS -Pn -T2 -oG enumeration/nmapScan/$line-grep.txt -oN enumeration/nmapScan/$line-text.txt ; done
fi
if [ $scanmode == "-n" ]; then
	for line in "${XYZ[@]}" ; do sudo nmap $line -A -Pn --script=vuln -oG enumeration/nmapScan/$line-grep.txt -oN enumeration/nmapScan/$line-text.txt ; done
fi

#put all nmap results into a single file for better viewing
for line in "${XYZ[@]}" ; do cat enumeration/nmapScan/$line-text.txt >> enumeration/nmapScan/allineoneReport.txt ; done

# grep out the Openports into their own textfile
for line in "${XYZ[@]}" ; do cat enumeration/nmapScan/$line-grep.txt | grep open > enumeration/nmapScan/$line-openPorts.txt ; done

#txt grep out open ports and save to ipaddr.txt

for IP in "${XYZ[@]}"
do
    for line in enumeration/nmapScan/$IP-openPorts.txt
    do
       if [ $(grep -c "53" enumeration/nmapScan/$IP-openPorts.txt) -eq 1 ]; then 
		echo -e "[+] Port 53 is Open! \n Engaging in Reverse dns lookup for $IP ! \n"
		dnsrecon -r 127.0.0.1/24 -n $IP -d blah -x enumeration/dnsrecon/$IP.xml -c enumeration/dnsrecon/$IP.csv -j enumeration/dnsrecon/$IP.json
		if [ $(grep -c "PTR" enmeration/dnsrecon/$IP.xml) ]; then
			echo -e "\n[+] Running fierce on domain\n"
#			fierce domain > fierce$Domain.txt
		fi
	fi
	if [ $(grep -c "8080" enumeration/nmapScan/$IP-openPorts.txt) -eq 1 ]; then
		echo -e "[+] Port 8080 is Open! \n Engaging in Directory Busting for $IP ! \n"
		ffuf -u http://$IP:8080/FUZZ -w /usr/share/seclists/Discovery/Web-Content/directory-list-2.3-medium.txt -mc 301 200 403 -o enumeration/ffufScan/$IP-8080.txt
		echo -e "\n[+] finished Directory Busting port 8080 for $IP ! \n"
	fi
	if [ $(grep -c "80" enumeration/nmapScan/$IP-openPorts.txt) -eq 1 ]; then
		echo -e "[+] Port 80 is Open! \n Engaging in Directory Busting for $IP ! \n"
		ffuf -u http://$IP:80/FUZZ -w /usr/share/seclists/Discovery/Web-Content/directory-list-2.3-medium.txt -mc 301 200 403 -o enumeration/ffufScan/$IP-80.txt
		echo -e "\n[+] finished Directory Busting port 80 for $IP ! \n"
		
	fi
       if [ $(grep -c "445" enumeration/nmapScan/$IP-openPorts.txt) -eq 1 ]; then
       		echo -e "[+] Port 445 is Open! \n Engaging in smb enumeration for $IP ! \n"
       		python3 enum4linux-ng/enum4linux-ng.py $IP -oA enumeration/enum4linx-ngScan/$IP-Port-445
       		echo -e "\n[+] finished SMB enumeration port 445 for $IP ! \n"
       fi
    done
done

echo "[+] enumeration.sh had finished it's job..."

