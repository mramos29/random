#!/bin/bash

thold=30

# Exclude Cloudflare ips from being blocked
cloudflare="CLOUDFLARE"

# Get top 10 ips with POST requests for the last 5000 request (10 minutes aprox.)
tail -5000 /var/log/httpd/domains/access.log | grep POST | awk '{print $1}' | sort -rn | uniq -c | sort -rn | head -10 | while read -r line; do
  number=`echo $line | awk '{print $1}'`

  # If it's above treshold...
  if [ "$number" -gt "$thold" ] 
  then
    ip=`echo $line | awk '{print $2}'`
    iptables -L -n | grep $ip
    # ...and wasn't blocked yet...
    if [ $? ]
    then 
      ripenet=`whois -n -h whois.ripe.net $ip | grep -i netname | awk '{print $2
}'`
      arinnet=`whois -n -h whois.arin.net $ip | grep -i netname | awk '{print $2}'`
      # ...and ip is not from Cloudflare, we will block it!
      # First, we check RIPE...
      if ! [[ "$ripenet" == *"$cloudflare"* ]]
      then 
        # ...then we check ARIN
        if ! [[ "$arinnet" == *"$cloudflare"* ]]
        then
          echo -n `date ` >> /tmp/post_block.log
          echo " - IP $ip with too much posts ($number). Will Block!"  >> /tmp/post_block.log
          /sbin/iptables -I INPUT 1 -p tcp --source $ip -j DROP
        fi
      fi
    fi
  fi 

done
