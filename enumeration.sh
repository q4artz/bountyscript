#!/bin/bash

echo "enumeration script takes in | ip addr | nmap scan mode | wordlist for ffuf "

if[ ! -d enumeration ]; then
	mkdir enumeration
fi
if[ ! -d /enumeration/nmapScan]; then
	mkdir /enumeration/nmapScan
fi
if[ ! -d /enumeration/niktoScan ]; then
	mkdir /enumeration/niktoScan
fi
if[ ! -d /enumeration/ffufScan ]; then
	mkdir /enumeration/ffufScan
fi

# nmap script take in ip addr | scan mode 

# port 80 or 8080 detected put into nikto

# port 80 or 8080 put into dirbusting | take in wordlist
