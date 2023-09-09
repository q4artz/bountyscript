#!/bin/bash
#!/bin/python3

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
cat $url/recon/assetfinderSubs.txt | sort -u | httprobe -s -p https:443| sed 's/https\?:\/\///' | tr -d ':443' >> $url/recon/aliveSubs.txt
echo -e "[+] Httprobe found " $(cat $url/recon/aliveSubs.txt | wc -l) "Alive subdomains\n"

#capturing screenshots with gowitness
echo "[+] Running Eyewitness"
eyewitness --web -f $url/recon/aliveSubs.txt -d $url/recon/aliveScreenshots --resolve
echo "[+] Screenshots put into " $url/recon/aliveScreenshots 

