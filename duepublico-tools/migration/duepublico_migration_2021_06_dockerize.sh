#!/bin/bash
logtemplate=" - duepublico_migration_2021_06_dockerize.sh:"
current_dir=$(pwd)

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
if ! [ -f ../../duepublico-webapp/target/duepublico-webapp-2.0-SNAPSHOT.war ]; then

    printf '%s This script needs a maven build of duepublico - please make them available!\n' "$(date) $logtemplate"
    exit 1
fi

printf '%s Cleanup dependent docker containersp\n' "$logtemplate"
# check if there are running containers and cleanup
if $(docker inspect -f '{{.State.Running}}' duepublico-postgres) = "true"; then
    # stop current containers
    printf '%s Stop current docker container duepublico-postgres\n' "$(date) $logtemplate"
    docker stop duepublico-postgres >/dev/null

    printf '%s Remove current docker container duepublico-postgres\n' "$(date) $logtemplate"
    docker rm duepublico-postgres >/dev/null
fi

if $(docker inspect -f '{{.State.Running}}' duepublico-war) = "true"; then
    # stop current containers
    printf '%s Stop current docker container duepublico-war\n' "$(date) $logtemplate"
    docker stop duepublico-war >/dev/null

    printf '%s Remove current docker container duepublico-war\n' "$(date) $logtemplate"
    docker rm duepublico-war >/dev/null
fi

printf '%s Build duepublico-solr image\n' "$logtemplate"
docker build -f ../solr/dockerfile -t duepublico-solr:latest . >/dev/null

printf '%s Build duepublico-war image (tomcat/java with migration copy of mcrhome 2021.06)\n' "$logtemplate"
docker build -t duepublico-war:latest . >/dev/null

printf '%s Start docker containers with docker compose\n' "$logtemplate"
docker compose up -d

printf '%s duepublico (migration 2021.06) was created successfully in docker container\n' "$(date) $logtemplate"

exit 0
