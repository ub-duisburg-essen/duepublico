#!/bin/bash
logtemplate=" - duepublico_clean_import_data.sh:"

while getopts d:u: flag; do
	case "${flag}" in
	d) data_directory=${OPTARG} ;;
	u) data_url=${OPTARG} ;;
	esac
done

# flags d, u are required
if [[ -z "$data_directory" || -z "$data_url" ]]; then

	printf '%s This script requires flags -d (mcr data directory) and -u (data url with encrypted mcr data archive) -> please make them available\n' "$(date) $logtemplate"
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

printf '%s mcr data archive was recovered successfully\n' "$(date) $logtemplate"

exit 0
