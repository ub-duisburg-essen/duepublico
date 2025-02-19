#!/bin/bash
logtemplate=" - dockerize_new_postgres.sh:"
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

# check if there is a running postgres container ' duepublico-2023-postgres' and remove it
if $(docker inspect -f '{{.State.Running}}' duepublico-2023-postgres) = "true"; then
    # stop current containers
    printf '%s Stop current docker container  duepublico-2023-postgres\n' "$(date) $logtemplate"
    docker stop  duepublico-2023-postgres >/dev/null

    printf '%s Remove current docker container  duepublico-2023-postgres\n' "$(date) $logtemplate"
    docker rm  duepublico-2023-postgres >/dev/null
fi

printf '%s Start docker container duepublico-2023-postgres with docker compose\n' "$(date) $logtemplate"
docker-compose up -d

# It is possible that db server is not ready to accept connections
sleep 15

printf '%s PostgresDB was created successfully in docker container\n' "$(date) $logtemplate"
exit 0