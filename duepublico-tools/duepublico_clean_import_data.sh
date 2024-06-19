#!/bin/bash
logtemplate=" - duepublico_clean_import_data.sh:"

while getopts d:u: flag; do
	case "${flag}" in
	d) mcr_home=${OPTARG} ;;
	u) data_url=${OPTARG} ;;
	esac
done

# flags d, u are required
if [[ -z "$mcr_home" || -z "$data_url" ]]; then

	printf '%s This script requires flags -d (mcr home directory) and -u (data url with encrypted mcr data archive) -> please make them available\n' "$(date) $logtemplate"
	exit 1
fi

if ! [ -d $mcr_home/data ]; then
	printf '%s Error - Invalid mcr home directory \n' "$(date) $logtemplate"
	exit 1
fi

# Are there needed environmental files ?
if ! [ -f ./env/dc.txt ]; then

	printf '%s This script needs environmental information (./env/dc.txt for decryption) - please make them available!\n' "$(date) $logtemplate"
	exit 1
fi

# check for current temp directory
if [ -d ./env/tmp ]; then
	rm -rf ./env/tmp
fi

mkdir ./env/tmp

printf "%s Start download encrypted mcr data archive from $data_url\n" "$(date) $logtemplate"
wget -O ./env/tmp/data.enc $data_url

if [[ $? -ne 0 ]]; then
	printf "%s Error downloading encrypted mcr data archive from $data_url\n" "$(date) $logtemplate"
	exit 1
fi

printf "%s Decrypt mcr data archive\n" "$(date) $logtemplate"
openssl enc -d -aes-256-cbc -md sha512 -pbkdf2 -iter 1000000 -salt -in ./env/tmp/data.enc -out ./env/tmp/data.tar.gz -pass file:./env/dc.txt

printf "%s Unpack mcr data archive\n" "$(date) $logtemplate"
tar xfz ./env/tmp/data.tar.gz -C ./env/tmp

#check data archive
if ! [ -d ./env/tmp/data ] ||
	! [ -d ./env/tmp/data/content ] || ! [ -d ./env/tmp/data/metadata ] || ! [ -d ./env/tmp/data/versions-metadata ]; then

	printf "%s Error - Downloaded archive from $data_url hasn't got the required structure \n" "$(date) $logtemplate"
	exit 1
fi

printf "%s Clean current mcr data directory in $mcr_home \n" "$(date) $logtemplate"
if [ -d $mcr_home/data/metadata ]; then
	printf "%s Remove $mcr_home/data/metadata\n" "$(date) $logtemplate"
	rm -rf $mcr_home/data/metadata
fi

if [ -d $mcr_home/data/versions-metadata ]; then
	printf "%s Remove $mcr_home/data/versions-metadata\n" "$(date) $logtemplate"
	rm -rf $mcr_home/data/versions-metadata
fi

if [ -d $mcr_home/data/content ]; then
	printf "%s Remove $mcr_home/data/content\n" "$(date) $logtemplate"
	rm -rf $mcr_home/data/content
fi

printf "%s Move\n" "$(date) $logtemplate"

printf '%s MCR data archive was recovered successfully\n' "$(date) $logtemplate"

exit 0
