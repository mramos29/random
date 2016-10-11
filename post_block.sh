#!/bin/bash

thold=20

# Get top 10 ips with POST requests for the last 5000 request (10 minutes aprox.)
tail -5000 /var/log/httpd/access_log | grep POST | awk '{print $1}' | sort -rn | uniq -c | sort -rn | head -10 | while read -r line; do
  number=`echo $line | awk '{print $1}'`
  # If it's above treshold...
  if [ "$number" -gt "$thold" ] 
  then
    ip=`echo $line | awk '{print $2}'`
    iptables -L -n | grep $ip
    # ...and wasn't blocked yet, we will block it
    if [ $? ]
    then 
      echo "IP $ip with too much posts. Will Block!" >> /tmp/post_block.log
      /sbin/iptables -I INPUT 1 -p tcp --source $ip -j DROP
    fi
  fi 
done

