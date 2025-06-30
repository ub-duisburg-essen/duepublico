#!/bin/bash
logtemplate=" - duepublico_migration_2023_06_dockerize_offline.sh:"
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

printf '%s Check if docker images are locally available\n' "$(date) $logtemplate"
# are the docker images locally available ?
if ! [ -f ./env/images/duepublico-2023-solr.tar ]; then

    printf '%s This script needs the docker image duepublico-2023-solr.tar locally - please make it available!\n' "$(date) $logtemplate"
    exit 1
fi

if ! [ -f ./env/images/duepublico-2023-war.tar ]; then

    printf '%s This script needs the docker image duepublico-2023-war.tar locally - please make it available!\n' "$(date) $logtemplate"
    exit 1
fi

if ! [ -f ./env/images/postgres.tar ]; then

    printf '%s This script needs the docker image postgres.tar locally - please make it available!\n' "$(date) $logtemplate"
    exit 1
fi

printf '%s Check db availability (existing dump file)\n' "$(date) $logtemplate"

if ! [ -f $sql_dump ]; then
    printf '%s There is no sql dump file - please make it available.\n' "$(date) $logtemplate"
    exit 1
fi

printf '%s Check solr data availability (configset or docker volume)\n' "$(date) $logtemplate"
# check if there is a solr volume
if [ ! -d ./env/duepublico-2023-solr ] || [ -z "$(ls -A ./env/duepublico-2023-solr 2>/dev/null)" ]; then

    if [ -d ./env/duepublico-2023-solr ]; then
        rm -rf ./env/duepublico-2023-solr
    fi

    mkdir ./env/duepublico-2023-solr
    printf '%s There is no existing solr volume. \n' "$(date) $logtemplate"

    if [ ! -d ./env/temp/configsets ]; then
        printf '%s There are no offline configsets - please make them available or use duepublico_2023_dockerize.sh to download them.\n' "$(date) $logtemplate"
        exit 1
    fi

    printf '%s Create cores from mycore configsets image\n' "$(date) $logtemplate"
    CREATE_CORES=true

else
    printf '%s solr volume detected in ./env/duepublico-2023-solr\n' "$(date) $logtemplate"
fi

printf '%s Cleanup dependent docker containers\n' "$logtemplate"
# check if there are running containers and cleanup
if $(docker inspect -f '{{.State.Running}}' duepublico-2023-war) = "true"; then
    # stop current containers
    printf '%s Stop current docker container duepublico-2023-war\n' "$(date) $logtemplate"
    docker stop duepublico-2023-war >/dev/null
fi
printf '%s Remove current docker container duepublico-2023-war\n' "$(date) $logtemplate"
docker rm duepublico-2023-war >/dev/null

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
fi
printf '%s Remove current docker container duepublico-2023-postgres\n' "$(date) $logtemplate"
docker rm duepublico-2023-postgres >/dev/null

printf '%s Remove dependent docker images to provide clean build\n' "$(date) $logtemplate"
docker rmi duepublico-2023-war:latest >/dev/null
docker rmi duepublico-2023-solr:latest >/dev/null
docker rmi postgres:17-bookworm >/dev/null

printf '%s Build duepublico-2023-solr image\n' "$(date) $logtemplate"
docker build -f ./helper/solr/dockerfile -t duepublico-2023-solr:latest . >/dev/null

printf '%s Build duepublico-2023-war image (tomcat/java with migration copy of mcrhome 2023.06)\n' "$(date) $logtemplate"
docker build -t duepublico-2023-war:latest . >/dev/null

# adapt owner, group for /env/duepublico-2023-solr
# UID und GID aus dem Image holen
UID_GID=$(docker run --rm --entrypoint "" duepublico-2023-solr:latest sh -c 'id -u solr; id -g solr')
USER_ID=$(echo $UID_GID | cut -d' ' -f1)
GROUP_ID=$(echo $UID_GID | cut -d' ' -f2)

printf '%s adapt owner and group for ./env/duepublico-2023-solr\n' "$(date) $logtemplate"
sudo chown -R $USER_ID:$GROUP_ID ./env/duepublico-2023-solr

printf '%s Start docker containers with docker compose\n' "$(date) $logtemplate"
docker-compose up -d

# Wait for solr and db
sleep 10

if [ "$CREATE_CORES" = true ]; then
    printf '%s Create cores from mycore configsets \n' "$(date) $logtemplate"
    docker exec -it duepublico-2023-solr solr create -c duepublico_classifications -d /var/temp/configsets/mycore_solr_configset_classification
    docker exec -it duepublico-2023-solr solr create -c duepublico_main -d /var/temp/configsets/mycore_solr_configset_main
fi

printf '%s Restore sql_dump into duepublico-2023-postgres container\n' "$(date) $logtemplate"
cat $sql_dump | docker exec -i duepublico-2023-postgres psql -d $(prop POSTGRES_DB) -U $(prop POSTGRES_USER)

printf '%s duepublico (migration 2023.06) was created successfully in docker container\n' "$(date) $logtemplate"

exit 0