#!/bin/bash
logtemplate=" - stop_and_create_offline_backup:"

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

if ! [ -d ./env/mcr_export/ ]; then
    printf '%s This script needs a running mcr environment (./env/mcr_export) - please make it available!\n' "$(date) $logtemplate"
    exit 1
fi

if $(docker inspect -f '{{.State.Running}}' duepublico-2023-war) = "true"; then
    printf '%s Stop Container duepublico-2023-war\n' "$(date) $logtemplate"
    docker stop duepublico-2023-war
fi

if $(docker inspect -f '{{.State.Running}}' duepublico-2023-solr) = "true"; then
    printf '%s Stop Container duepublico-2023-solr\n' "$(date) $logtemplate"
    docker stop duepublico-2023-solr
fi

if [ -d ./env/images ]; then
    rm -rf ./env/images
fi
mkdir ./env/images

# Save images locally

if docker container inspect duepublico-2023-war >/dev/null 2>&1; then
    printf '%s Save image locally duepublico-2023-war\n' "$(date) $logtemplate"
    docker save -o ./env/images/duepublico-2023-war.tar duepublico-2023-war:latest
fi

if docker container inspect duepublico-2023-solr >/dev/null 2>&1; then
    printf '%s Save image locally duepublico-2023-solr\n' "$(date) $logtemplate"
    docker save -o ./env/images/duepublico-2023-solr.tar duepublico-2023-solr:latest
fi

if $(docker inspect -f '{{.State.Running}}' duepublico-2023-postgres) = "true"; then

    if [ -d ./env/mcr_export/db ]; then
        rm -rf ./env/mcr_export/db
    fi

    mkdir ./env/mcr_export/db

    printf '%s Export current pg_dump to ./env/mcr_export/db/duepublico_2023_migration.sql\n' "$(date) $logtemplate"
    docker exec -t duepublico-2023-postgres pg_dump -U $(prop POSTGRES_USER) $(prop POSTGRES_DB) >./env/mcr_export/db/duepublico_2023_migration.sql

    printf '%s Stop Container duepublico-2023-postgres\n' "$(date) $logtemplate"
    docker stop duepublico-2023-postgres

    printf '%s Save image locally postgres:17-bookworm\n' "$(date) $logtemplate"
    docker save -o ./env/images/postgres.tar postgres:17-bookworm
fi

printf '%s create_offline_backup was successful\n' "$(date) $logtemplate"
exit 0
