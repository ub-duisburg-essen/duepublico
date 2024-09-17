#!/bin/bash
logtemplate=" - dockerize_solr.sh:"
appname="duepublico"

container_name=$appname"_solr"
image_name=$container_name":latest"

create_core_classification_name="duepublico_classifications"
create_core_main_name="duepublico_main"

# is docker running ?
while getopts b:c:m:u: flag; do
	case "${flag}" in
	b) main_core=${OPTARG} ;;
	c) classification_core=${OPTARG} ;;
	m) mcr_directory=${OPTARG} ;;
	u) url=${OPTARG} ;;
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
git clone https://github.com/MyCoRe-Org/mycore_solr_configset_classification >/dev/null 2>&1
git clone https://github.com/MyCoRe-Org/mycore_solr_configset_main >/dev/null 2>&1

cd ..
# Get available index from mcrhome (if available)
if [ -n "$mcr_directory" ]; then

	# check for current local solr
	if ! [ -d $mcr_directory/data/solr ]; then
		printf "%s Local solr for mcr home was not found - please make it available\n" "$(date) $logtemplate"
		exit 1
	fi

	# check for current local classification index
	if ! [ -d $mcr_directory/data/solr/cores/$classification_core/data/index ]; then
		printf "%s Local solr mcr classification index was not found - please make it available\n" "$(date) $logtemplate"
		exit 1
	fi
	# check for current local main index
	if ! [ -d $mcr_directory/data/solr/cores/$main_core/data/index ]; then
		printf "%s Local solr mcr main index was not found - please make it available\n" "$(date) $logtemplate"
		exit 1
	fi

	mkdir index
	cd index
	current_dir=$(pwd)

	printf "%s Import solr index from mcrhome '$mcr_directory/data/solr' \n" "$(date) $logtemplate"

	mkdir classification && cd classification
	cp -rp $mcr_directory/data/solr/cores/$classification_core/data/index ./
	cd ..

	mkdir main && cd main
	cp -rp $mcr_directory/data/solr/cores/$main_core/data/index ./
	cd ../..
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
docker exec -it $container_name solr create -c $create_core_classification_name -d /var/solr/temp/configsets/mycore_solr_configset_classification
docker exec -it $container_name solr create -c $create_core_main_name -d /var/solr/temp/configsets/mycore_solr_configset_main

# is mcrhome set?
if [ -n "$mcr_directory" ]; then

	printf '%s Copy previous solr index from mcrhome\n' "$(date) $logtemplate"

	docker exec -it $container_name sh -c "rm -rf /var/solr/data/$create_core_classification_name/data/index/*"
	docker exec -it $container_name mv /var/solr/temp/index/classification/index/ /var/solr/data/$create_core_classification_name/data/

	docker exec -it $container_name sh -c "rm -rf /var/solr/data/$create_core_main_name/data/index/*"
	docker exec -it $container_name mv /var/solr/temp/index/main/index/ /var/solr/data/$create_core_main_name/data/

	docker stop $container_name >/dev/null
	docker start $container_name >/dev/null
fi

rm -rf ./temp