#!/bin/bash
logtemplate=" - duepublico_migration_2023_06_dockerize_offline.sh:"
current_dir=$(pwd)

mcr_export="./env/mcr_export/"
sql_dump=$mcr_export"db/duepublico_2023_migration.sql"

function prop {
    grep "${1}" ./.env | cut -d "=" -f2
}

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

printf '%s Import postgres image\n' "$(date) $logtemplate"
docker load -i ./env/images/postgres.tar >/dev/null

printf '%s Import duepublico-2023-solr image\n' "$(date) $logtemplate"
docker load -i ./env/images/duepublico-2023-solr.tar >/dev/null

printf '%s Import duepublico-2023-war image (tomcat/java with migration copy of mcrhome 2023.06)\n' "$(date) $logtemplate"
docker load -i ./env/images/duepublico-2023-war.tar >/dev/null

# check if there is a solr volume
if [ -d ./env/duepublico-2023-solr ]; then
    printf '%s solr volume detected in /env/duepublico-2023-solr\n' "$(date) $logtemplate"
else
    printf '%s There is no existing solr volume. \n' "$(date) $logtemplate"
    printf '%s Create cores from mycore configsets image\n' "$(date) $logtemplate"
    CREATE_CORES=true
fi

printf '%s Start docker containers with docker compose\n' "$(date) $logtemplate"
docker-compose up -d

# Wait for solr and db
sleep 10

if [ "$CREATE_CORES" = true ]; then
    printf '%s Create cores from mycore configsets \n' "$(date) $logtemplate"
    docker exec -it duepublico-2023-solr solr create -c duepublico_classifications -d /var/solr/temp/configsets/mycore_solr_configset_classification
    docker exec -it duepublico-2023-solr solr create -c duepublico_main -d /var/solr/temp/configsets/mycore_solr_configset_main
fi

printf '%s Restore sql_dump into duepublico-2023-postgres container\n' "$(date) $logtemplate"
cat $sql_dump | docker exec -i duepublico-2023-postgres psql -d $(prop POSTGRES_DB) -U $(prop POSTGRES_USER)

printf '%s duepublico (migration 2023.06) was created successfully in docker container\n' "$(date) $logtemplate"
exit 0
