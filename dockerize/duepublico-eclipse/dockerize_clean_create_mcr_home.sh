#!/bin/bash
timestamp=$(date)

logtemplate=""$timestamp" - dockerize_clean_create_mcr_home.sh:"

# is docker running ?
if ! docker info >/dev/null 2>&1; then

	printf '%s This script uses docker, and it is not running or you does not have permission to use it - please start docker and try again!\n' "$logtemplate"
	exit 1
fi

# check if duepublico eclipse container is running
if [ "$(docker container inspect -f '{{.State.Status}}' duepublico-eclipse_master)" == "running" ]; then

	printf '%s duepublico-eclipse Container is running\n' "$logtemplate"

	printf '%s Clean duepublico home (if exists) running\n' "$logtemplate"
	docker exec -it duepublico-eclipse_master sh -c "test -d /home/mycore/.mycore/duepublico &&  rm -rf /home/mycore/.mycore/duepublico"

	printf '%s Generate solr for duepublico\n' "$logtemplate"
	docker exec -it duepublico-eclipse_master sh -c "cd /home/mycore/git/duepublico && mvn clean install && mvn solr-runner:copyHome && mvn solr-runner:start"
fi
