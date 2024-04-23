#!/bin/bash
timestamp=$(date)

logtemplate=""$timestamp" - dockerize_duepublico_eclipse.sh:"

# is docker running ?
if ! docker info >/dev/null 2>&1; then

	printf '%s This script uses docker, and it is not running or you does not have permission to use it - please start docker and try again!\n' "$logtemplate"
	exit 1
fi

docker build -f dockerfile -t duepublico-eclipse:master . >/dev/null
docker container run --rm --net=host -it -v /tmp/.X11-unix:/tmp/.X11-unix -v /mnt/wslg:/mnt/wslg -e DISPLAY -e WAYLAND_DISPLAY -e XDG_RUNTIME_DIR -e PULSE_SERVER --name duepublico-eclipse_master duepublico-eclipse:master

exit 0
