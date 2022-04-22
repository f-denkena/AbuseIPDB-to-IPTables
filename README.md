# AbuseIPDB-to-IPTables
 A script which helps to enter suspicious IP addresses from the AbuseIPDB in iptables

## Usage
If you haven't already done so, you have to install the curl command

```bash
apt install curl

```
Simply create an [AbuseIPDB](https://abuseipdb.com) account and then generate a key in your account settings under APIv2

```bash
_countMinimum=15                        # raw report count
_maxAgeInDays=60                        # determines how far back in time we go to fetch reports counted for the countMinimum parameter
_confidenceMinimum=90                   # confidence of abuse score
_apiv2Key=__yourKey__                   # abuseipdb.com APIv2 Key
```

Replace __yourKey__ with your created key
Of course, you can also adjust the other values as needed


## Special thanks
This script is inspired by [Timo Korthals](http://www.timokorthals.de/?p=334)