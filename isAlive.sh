#!/bin/sh
# [Usage] isAlive.sh bsd1.cs.nctu.edu.tw

Usage="[Usage] $0 host"
temp="$1.ping"
Admin="tsaimh fs"
count="3"

if [ $# != 1 ] ; then
    echo "$Usage"
else
    /sbin/ping -c "${count:=10}" "$1" | /usr/bin/grep 'transmitted' > "$temp"
    Lost=$(awk -F" " '{print $7}' "$temp" | awk -F"." '{print $1}' )
    if [ "${Lost:=0}" -ge 50 ] ; then
        mail -s "$1 failed" "$Admin" < "$temp"
    fi 
    /bin/rm "$temp"
fi