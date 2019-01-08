#!/bin/sh

set -e
#sysctl -w vm.max_map_count=262144
echo "Starting the Elasticsearch server"
nohup elasticsearch & 

/bin/bash
#Extra line added in the script to run all command line arguments
#while true; do sleep 1; done

#echo "navigating to volume /var/www"
#cd /var/www
#echo "Creating soft link"
#ln -s /opt/mysite mysite

#a2enmod headers
#service elasticsearch restart

#if [ -z "$1" ]
#then
#    exec "/usr/sbin/apache2 -D -foreground"
#else
#    exec "$1"
#fi
