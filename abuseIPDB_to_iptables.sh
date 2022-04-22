#!/bin/bash

_pub_if=eth0        	    		    # Device which is connected to the internet
_tempdb=abuseipdb.db   		 			# Name of temp file
_abuseipdbList=abuseipdb-blacklist  	# Name of chain in iptables

_countMinimum=15						# raw report count
_maxAgeInDays=60						# determines how far back in time we go to fetch reports counted for the countMinimum parameter
_confidenceMinimum=90					# confidence of abuse score
_apiv2Key=yourKey						# abuseipdb.com APIv2 Key

function setupBlacklist {
	# Check if IPv4 chain exists
	if $1 -n --list $_abuseipdbList > /dev/null
	then
		# if exists: flush it
		$1 --flush $_abuseipdbList
	else
		# else: create it
		echo "Create..."
		$1 -N $_abuseipdbList
		$1 -I INPUT -j $_abuseipdbList
		$1 -I OUTPUT -j $_abuseipdbList
		$1 -I FORWARD -j $_abuseipdbList
	fi
}

# Get the abused IPs
curl -G https://api.abuseipdb.com/api/v2/blacklist \
	-d countMinimum=$_countMinimum \
	-d maxAgeInDays=$_maxAgeInDays \
	-d confidenceMinimum=$_confidenceMinimum \
	-H "Key: $_apiv2Key" \
	-H "Accept: text/plain" > $_tempdb || { 
		echo "$0: Unable to download blacklist."; 
		exit 1; 
	}

### Setup the blacklist ###
setupBlacklist iptables
setupBlacklist ip6tables

# store each ip in temp file
for ip in `cat $_tempdb`
do
	# Append everything to $_abuseipdbList
	if [[ $ip =~ .*:.* ]]
	then
 		ip6tables -A $_abuseipdbList -i ${_pub_if} -s $ip -j DROP
	else
 		iptables -A $_abuseipdbList -i ${_pub_if} -s $ip -j DROP
	fi
done

# Delete temp file
rm $_tempdb
exit 0