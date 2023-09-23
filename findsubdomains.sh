#!/bin/bash

#getting arguements
url=$1

#check if directory exist
if [ ! -d "$url" ]; then 
	sudo -u kali mkdir $url
fi
if [ ! -d "$url/recon" ];then
	sudo -u kali mkdir $url/recon
fi
if [ ! -d "$url/recon/dnsreconScan" ];then
	sudo -u kali mkdir $url/recon/dnsreconScan
fi
if [ ! -d "$url/recon/aliveScreenshots" ];then
	sudo -u kali mkdir $url/recon/aliveSreenshots
fi

#running assetfinder
echo "[+] Harvesting Subdomains with assetfinder"
assetfinder $url >> $url/recon/assets.txt
cat $url/recon/assets.txt | grep $url >> $url/recon/assetfinderSubs.txt 
echo "[+] assetfinder Found " $(cat $url/recon/assetfinderSubs.txt | wc -l) "Subdomains"
echo "[+] Subdomains Found by assetfinder added to" $url/recon/assetfinderSubs.txt
rm $url/recon/assets.txt
echo -e "\n"

#running Amass
#echo "[+] Harvesting Subdomains with Amass"
#amass enum -d $url >> $url/recon/assets.txt
#sort $url/recon/assets.txt >> $url/recon/amassSubs.txt
#echo "[+] Amass found " $(cat $url/recon/amassSubs.txt | wc -l) "Subdomains"
#echo "[+] Subdomains Found by Amass added to " $url/recon/amassSubs.txt
#rm $url/recon/assets.txt
#echo -e "\n"

#running httprobe
echo "[+] Running Httprobe"
cat $url/recon/assetfinderSubs.txt | sort -u | httprobe -s -p https:443| sed 's/https\?:\/\///' | tr -d ':443' >> $url/recon/aliveSub.txt
echo -e "[+] Httprobe found " $(cat $url/recon/aliveSubs.txt | wc -l) "Alive subdomains\n"

#Getting all subdomain's ipaddr
echo "[+] Running dnsrecon"
IFS=$'\r\n' GLOBIGNORE='*' command eval  'subdomain=($(cat $url/recon/aliveSub.txt))'
for line in ${subdomain[@]} ; do dnsrecon -d $line -x $url/recon/dnsreconScan/$line-IP.xml -c $url/recon/dnsreconScan/$line-IP.csv -j $url/recon/dnsreconScan/$line-IP.json ; done

for subs in "${subdomain[@]}" 
do
	for line in $url/recon/dnsreconScan/$subs-IP.json
	do
		grep -o '"address": *"[^"]*"'  $line | grep -o '"[^"]*"$' >> $url/recon/dnsreconScan/temp.txt
		cat $url/recon/dnsreconScan/temp.txt | tr -d '"' | sort >> $url/recon/dnsreconScan/allIP.txt 
		rm $url/recon/dnsreconScan/temp.txt
		grep -E -o '[0-9_.]{10,}' $url/recon/dnsreconScan/allIP.txt > $url/recon/dnsreconScan/allIPv4.txt
	done
done

echo -e "[+] Address founded are...\n"
cat $url/recon/dnsreconScan/allIPv4.txt


#capturing screenshots with eyewitness
echo "[+] Running Eyewitness on alive subdomains"
#yes Y | eyewitness --web -f $url/recon/aliveSub.txt -d $url/recon/aliveScreenshots --resolve --delay 5 --threads 15
echo "[+] Screenshots put into " $url/recon/aliveScreenshots 
