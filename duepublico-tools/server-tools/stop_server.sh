#!/bin/bash
timestamp=$(date)

logtemplate=""$timestamp" - stop_server.sh:"

cd ../../

# check for current build
printf "%s Check running solr and webapp\n" "$logtemplate"
if [ $(
	nc -z -w30 localhost 8983
	echo $?
) -eq 0 ]; then

	cd duepublico-setup
	printf "%s Stop solr for duepublico2\n" "$logtemplate"
	mvn solr-runner:stop
	cd ..
fi

if [ $(
	nc -z -w30 localhost 8291
	echo $?
) -eq 0 ]; then

	cd duepublico-webapp
	printf "%s Stop duepublico2 webapp\n" "$logtemplate"
	ps -ef | grep tomcat | awk '{print $2}' | xargs kill -9
fi

printf "%s Servers for duepublico2 have been stopped.\n" "$logtemplate"
