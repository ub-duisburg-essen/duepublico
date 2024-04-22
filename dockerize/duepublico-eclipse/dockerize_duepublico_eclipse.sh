#!/bin/bash
timestamp=$(date)

logtemplate=""$timestamp" - dockerize_duepublico_eclipse.sh:"

# is docker running ?
if ! docker info >/dev/null 2>&1; then

	printf '%s This script uses docker, and it is not running or you does not have permission to use it - please start docker and try again!\n' "$logtemplate"
	exit 1
fi

docker build -f dockerfile -t duepublico-eclipse:master . >/dev/null
sudo docker container run --rm --net=host -it --env=DISPLAY --volume=$HOME/.Xauthority:/root/.Xauthority:rw --name duepublico-eclipse_master duepublico-eclipse:master

exit 0
