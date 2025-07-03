#!/bin/bash
logtemplate=" - stop_and_create_backup:"

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
    printf '%s Export current solr cores to ./env/duepublico-2023-solr\n' "$(date) $logtemplate"

    if [ -d ./env/duepublico-2023-solr ]; then
        rm -rf ./env/duepublico-2023-solr
    fi

    docker cp duepublico-2023-solr:/var/solr ./env/
    mv ./env/solr ./env/duepublico-2023-solr

    printf '%s Stop Container duepublico-2023-solr\n' "$(date) $logtemplate"
    docker stop duepublico-2023-solr
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
fi

printf '%s create_offline_backup was successful\n' "$(date) $logtemplate"
exit 0
