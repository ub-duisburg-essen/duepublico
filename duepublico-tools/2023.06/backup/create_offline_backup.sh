#!/bin/bash
logtemplate=" - create_offline_backup.sh:"
current_dir=$(pwd)

cd ..

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

# create temp
if [ -d ./env/backup/ ]; then
    rm -rf ./env/backup
fi

# cleanup old saves
printf '%s Cleanup duepublico-2023 backup images\n' "$(date) $logtemplate"
docker rmi duepublico-2023-war-backup:latest >/dev/null
docker rmi duepublico-2023-postgres-backup:latest >/dev/null
docker rmi duepublico-2023-postgres-backup:latest >/dev/null

printf '%s Backup current docker containers\n' "$(date) $logtemplate"
mkdir ./env/backup/

# check if there are running containers and cleanup
if $(docker inspect -f '{{.State.Running}}' duepublico-2023-postgres) = "true"; then
    mkdir ./env/backup/duepublico-postgres
    mkdir ./env/backup/duepublico-postgres/data

    docker commit duepublico-2023-postgres duepublico-2023-postgres-backup
    docker save duepublico-2023-postgres-backup | gzip >./env/backup/duepublico-postgres/duepublico-2023-postgres-backup.tar.gz
    docker cp duepublico-2023-postgres:/var/lib/postgresql/data ./env/backup/duepublico-postgres/data
fi
