#!/bin/bash
logtemplate=" - dockerize_postgres.sh:"
current_dir=$(pwd)

function prop {
    grep "${1}" ./.env | cut -d "=" -f2
}

while getopts d: flag; do
    case "${flag}" in
    d) sql_dump=${OPTARG} ;;
    esac
done

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

# flag d is required
if ! [ -f "$sql_dump" ]; then

    printf '%s This script needs a sql dump file -> please make it available\n' "$(date) $logtemplate"
    exit 1
fi

# check if there is a running postgres container 'duepublico-postgres' and remove it
if $(docker inspect -f '{{.State.Running}}' duepublico-postgres) = "true"; then
    # stop current containers
    printf '%s Stop current docker container duepublico-postgres\n' "$(date) $logtemplate"
    docker stop duepublico-postgres >/dev/null

    printf '%s Remove current docker container duepublico-postgres\n' "$(date) $logtemplate"
    docker rm duepublico-postgres >/dev/null
fi

printf '%s Start docker container duepublico-postgres with docker compose\n' "$(date) $logtemplate"
docker-compose up -d

# It is possible that db server is not ready to accept connections
sleep 15

printf '%s Restore sql_dump into duepublico-postgres container\n' "$(date) $logtemplate"
cat $sql_dump | docker exec -i duepublico-postgres psql -d $(prop POSTGRES_DB) -U $(prop POSTGRES_USER)

printf '%s PostgresDB was created successfully in docker container\n' "$(date) $logtemplate"
exit 0
