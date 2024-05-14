#!/bin/bash
timestamp=$(date)

logtemplate=""$timestamp" - clean_rebuild_duepublico.sh:"

cd ..

# check for current build
if [ -d ./target ]; then

	printf "%s Check running solr and webapp\n" "$logtemplate"
	if [ $(
		nc -z -w30 localhost 8983
		echo $?
	) -eq 0 ]; then

		printf "%s Stop solr for duepublico2\n" "$logtemplate"
		mvn solr-runner:stop
	fi

	if [ $(
		nc -z -w30 localhost 8291
		echo $?
	) -eq 0 ]; then

		printf "%s Stop duepublico2 webapp\n" "$logtemplate"
		ps -ef | grep tomcat | awk '{print $2}' | xargs kill -9
	fi

fi

printf "%s Clean and install duepublico2\n" "$logtemplate"
git submodule init && git submodule update
mvn clean install -DskipTests
