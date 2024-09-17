#!/bin/bash
logtemplate=" - dockerize_from_local.sh:"
appname="duepublico"

container_name=$appname"_solr"
image_name=$container_name":latest"

while getopts m: flag; do
	case "${flag}" in
	m) mcr_directory=${OPTARG} ;;
	esac
done

# is docker running ?
if ! docker info >/dev/null 2>&1; then

	printf '%s This script uses docker, and it is not running or you does not have permission to use it - please start docker and try again!\n' "$(date) $logtemplate"
	exit 1
fi

# create temp and db directory for db decryption
if [ -d ./temp ]; then
	rm -rf ./temp
fi

printf "%s Get current mycore solr configset from github\n" "$(date) $logtemplate"
mkdir ./temp && mkdir ./temp/configsets && cd ./temp/configsets
# Get current mycore configsets from github
git clone https://github.com/MyCoRe-Org/mycore_solr_configset_classification
git clone https://github.com/MyCoRe-Org/mycore_solr_configset_main

cd ..
# Get current mcrhome index (if available)
if [ -d $mcr_directory ]; then

	# check for current local solr
	if ! [ -d $mcr_directory/data/solr ]; then
		printf "%s Local solr for mcr home was not found - please make it available\n" "$(date) $logtemplate"
		exit 1
	fi

	mkdir index
	cd index

	mkdir dupeublico && cd duepublico
	cp -rp $mcr_directory/data/solr/cores/duepublico/data/index ./
	cd ..

	mkdir duepublico-classifications && cd duepublico-classifications
	cp -rp $mcr_directory/data/solr/cores/duepublico-classifications/data/index ./
	cd ..
fi

cd ..

# remove current container and image (if exists) and recreate with dockerfile and docker-compose
printf '%s Stop and remove current docker container '$container_name' (if exists)\n' "$(date) $logtemplate"

docker stop $container_name >/dev/null
docker rm $container_name >/dev/null
docker rmi $image_name >/dev/null

printf '%s Build docker image\n' "$(date) $logtemplate"

docker build -f dockerfile -t $image_name . >/dev/null
docker run -d -p 8983:8983 --name $container_name $image_name

printf '%s Create cores from mycore configsets image\n' "$(date) $logtemplate"
docker exec -it $container_name solr create -c duepublico_classifications -d /var/solr/configsets/mycore_solr_configset_classification
docker exec -it $container_name solr create -c duepublico_main -d /var/solr/configsets/mycore_solr_configset_main

# is mcrhome set?
if [[ -z "$mcr_directory" ]]; then

	printf '%s Copy previous solr index from mcrhome\n' "$(date) $logtemplate"
	docker stop $container_name >/dev/null
fi
