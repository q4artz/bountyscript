#!/bin/bash

#getting arguements
url=$1

#check if directory exist
if [ ! -d "$url" ]; then 
mkdir $url
fi

if [ ! -d "$url/recon" ];then
mkdir $url/recon
fi

if [ ! -d "$url/recon/aliveScreenshots" ];then
mkdir $url/recon/aliveSreenshots
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
cat $url/recon/assetfinderSubs.txt | sort -u | httprobe -s -p https:443| sed 's/https\?:\/\///' | tr -d ':443' >> $url/recon/aliveSubsclean.txt
cat $url/recon/assetfinderSubs.txt | sort -u | httprobe -s -p https:8080 >> $url/recon/aliveSubsdirty.txt
echo -e "[+] Httprobe found " $(cat $url/recon/aliveSubs.txt | wc -l) "Alive subdomains\n"

#capturing screenshots with eyewitness
echo "[+] Running Eyewitness"
#yes Y | eyewitness --web -f $url/recon/aliveSubsclean.txt -d $url/recon/aliveScreenshots --resolve --delay 10 --threads 15
echo "[+] Screenshots put into " $url/recon/aliveScreenshots 

#dirbusting 
echo "[+] Running FFUF"
for line in $url/recon/aliveSubsdirty.txt ; do ffuf -u $line/FUZZ -w /usr/share/seclists/Discovery/Web-Content/directory-list-2.3-medium.txt -mc 200 -p 2  ; done
