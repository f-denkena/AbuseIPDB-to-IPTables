#!/bin/bash

_tempdb=/tmp/abuseipdb.db		# Name of temp file
_abuseipdbList=abuseipdb-blacklist	# Name of chain in iptables
_countMinimum=15			# Minimum report count
_maxAgeInDays=60			# Age of oldest report
_confidenceMinimum=90			# Confidence of abuse - premium feature
_apiv2Key=yourKey

function setupBlacklist {
	### Check if chain exists... ###
	if $1 -n --list $_abuseipdbList > /dev/null
	then
		### ...if it exists: flush it... ###
		$1 --flush $_abuseipdbList
	else
		### ...else: create it. ###
		echo "Create..."
		$1 -N $_abuseipdbList
		$1 -I INPUT -j $_abuseipdbList
	fi
}

### Get the IP blacklist. ###
/usr/bin/curl -G https://api.abuseipdb.com/api/v2/blacklist \
	-d countMinimum=$_countMinimum \
	-d maxAgeInDays=$_maxAgeInDays \
	-d confidenceMinimum=$_confidenceMinimum \
	-H "Key: $_apiv2Key" \
	-H "Accept: text/plain" > $_tempdb || { 
		echo "$0: Unable to download blacklist."; 
		exit 1; 
	}

### Log status. ###
echo "Download successful."
echo "Total: `cat $_tempdb | wc -l` IPs"

### Setup the blacklist ###
setupBlacklist /sbin/iptables
setupBlacklist /sbin/ip6tables

### Loop through all listed IPs ###
for ip in `cat $_tempdb`
do
	### Append to iptables. ###
	if [[ $ip =~ .*:.* ]]
	then
 		/sbin/ip6tables -A $_abuseipdbList -s $ip -j DROP
	else
 		/sbin/iptables -A $_abuseipdbList -s $ip -j DROP
	fi
done

### Log status. ###
echo "Local blacklist successfully updated."

exit 0

