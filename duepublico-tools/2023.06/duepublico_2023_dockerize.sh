#!/bin/bash
logtemplate=" - duepublico_migration_2023_06_dockerize.sh:"
current_dir=$(pwd)

mcr_export="./env/mcr_export/"
sql_dump=$mcr_export"db/duepublico_2023_migration.sql"

function prop {
    grep "${1}" ./.env | cut -d "=" -f2
}

# is docker running ?
if ! docker info >/dev/null 2>&1; then

    printf '%s This script uses docker, and it is not running or you does not have permission to use it - please start docker and try again!\n' "$(date) $logtemplate"
    exit 1
fi

# Are there needed environmental files ?
if ! [ -f ./.env ]; then

    printf '%s This script needs environmental information (.env file) - please make them available!\n' "$(date) $logtemplate"
    exit 1
fi

# Is there needed maven build ?
if ! [ -f ../../duepublico-webapp/target/duepublico-webapp-2023.06.3-SNAPSHOT.war ]; then

    printf '%s This script needs a maven build of duepublico - please make them available!\n' "$(date) $logtemplate"
    exit 1
fi

# create temp
if [ -d ./temp ]; then
    rm -rf ./temp
fi

printf "%s Get current mycore solr configset from github\n" "$(date) $logtemplate"
mkdir ./temp && mkdir ./temp/configsets && cd ./temp/configsets
# Get current mycore configsets from github
git clone https://github.com/MyCoRe-Org/mycore_solr_configset_classification >/dev/null 2>&1
git clone https://github.com/MyCoRe-Org/mycore_solr_configset_main >/dev/null 2>&1
cd ../..

printf '%s Cleanup dependent docker containers\n' "$logtemplate"
# check if there are running containers and cleanup
if $(docker inspect -f '{{.State.Running}}' duepublico-2023-war) = "true"; then
    # stop current containers
    printf '%s Stop current docker container duepublico-2023-war\n' "$(date) $logtemplate"
    docker stop duepublico-2023-war >/dev/null

    printf '%s Remove current docker container duepublico-2023-war\n' "$(date) $logtemplate"
    docker rm duepublico-2023-war >/dev/null
fi

if $(docker inspect -f '{{.State.Running}}' duepublico-2023-solr) = "true"; then
    # stop current containers
    printf '%s Stop current docker container duepublico-2023-solr\n' "$(date) $logtemplate"
    docker stop duepublico-2023-solr >/dev/null
fi

printf '%s Remove current docker container duepublico-2023-solr\n' "$(date) $logtemplate"
docker rm duepublico-2023-solr >/dev/null

if $(docker inspect -f '{{.State.Running}}' duepublico-2023-postgres) = "true"; then
    # stop current containers
    printf '%s Stop current docker container duepublico-2023-postgres\n' "$(date) $logtemplate"
    docker stop duepublico-2023-postgres >/dev/null

    printf '%s Remove current docker container duepublico-2023-postgres\n' "$(date) $logtemplate"
    docker rm duepublico-2023-postgres >/dev/null
fi

printf '%s Remove dependent docker images to provide clean build\n' "$logtemplate"
docker rmi duepublico-2023-war:latest >/dev/null
docker rmi duepublico-2023-solr:latest >/dev/null

printf '%s Build duepublico-2023-solr image\n' "$logtemplate"
docker build -f ./helper/solr/dockerfile -t duepublico-2023-solr:latest . >/dev/null

printf '%s Build duepublico-2023-war image (tomcat/java with migration copy of mcrhome 2023.06)\n' "$logtemplate"
docker build -t duepublico-2023-war:latest . >/dev/null

printf '%s Start docker containers with docker compose\n' "$logtemplate"
docker compose up -d

# Wait for solr and db
sleep 10

printf '%s Create cores from mycore configsets image\n' "$(date) $logtemplate"
docker exec -it duepublico-2023-solr solr create -c duepublico_classifications -d /var/solr/temp/configsets/mycore_solr_configset_classification
docker exec -it duepublico-2023-solr solr create -c duepublico_main -d /var/solr/temp/configsets/mycore_solr_configset_main

printf '%s Restore sql_dump into duepublico-2023-postgres container\n' "$(date) $logtemplate"
cat $sql_dump | docker exec -i duepublico-2023-postgres psql -d $(prop POSTGRES_DB) -U $(prop POSTGRES_USER)

printf '%s duepublico (migration 2023.06) was created successfully in docker container\n' "$(date) $logtemplate"
exit 0
