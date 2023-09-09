#!/bin/bash

#getting arguements
url=$1

if [ ! -d "$url" ]; then 
mkdir $url
fi

if [ ! -d "$url/recon" ];then
mkdir $url/recon
fi

function Harvesting(){
	if [ $option == 1 ]; then
		#running assetfinder
		echo "[+] Harvesting Subdomains with assetfinder"
		assetfinder $url >> $url/recon/assets.txt
		cat $url/recon/assets.txt | grep $url >> $url/recon/assetfinderSubs.txt 
		echo "[-] Subdomains Found by assetfinder added to" $url/recon/assetfinderSubs.txt
	
	 elif [ $option == 2 ]; then
		#running Amass
		echo "[+] Harvesting Subdomains with Amass"
		amass enum -d $url >> $url/recon/f.txt
		cat $url/recon/assets.txt | grep $url >> $url/recon/amassSubs.txt
		echo "[+] Subdomains Found by Amass added to " $url/recon/amassSubs.txt
	fi
	rm $url/recon/assets.txt
}

$(Harvesting(1)) 

#old code that could be reused
#$(cat $url/recon/relevantSubdomains.txt | grep $url | wc -l >> $url/recon/relevantSubdomains.txt) 
#(echo "Subdomains Found" >> $url/recon/relevantSubdomains.txt)


