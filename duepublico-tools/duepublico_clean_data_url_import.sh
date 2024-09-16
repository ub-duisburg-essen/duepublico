#!/bin/bash
logtemplate=" - duepublico_clean_data_url_import.sh:"

while getopts d:u: flag; do
	case "${flag}" in
	d) mcr_data_directory=${OPTARG} ;;
	u) data_url=${OPTARG} ;;
	esac
done

# flags h, u are required
if [[ -z "$mcr_data_directory" || -z "$data_url" ]]; then

	printf '%s This script requires flags -d (mcr data directory) and -u (data url with encrypted mcr data archive) -> please make them available\n' "$(date) $logtemplate"
	exit 1
fi

# Are there needed environmental files ?
if ! [ -f ./env/dc.txt ]; then

	printf '%s This script needs environmental information (./env/dc.txt for decryption) - please make them available!\n' "$(date) $logtemplate"
	exit 1
fi

if ! [ -f ../duepublico-setup/target/bin/duepublico.sh ]; then
	printf "%s Error - Can't find duepublico.sh in ../duepublico-setup/target/bin/duepublico.sh\n" "$(date) $logtemplate"
	exit 1
fi

# Check runnable duepublico.sh (db, solr)
printf "%s Check runnable duepublico.sh with database and solr dependencies\n" "$(date) $logtemplate"
duepublicoStatus=$(../duepublico-setup/target/bin/duepublico.sh show solr configuration | grep -e "Exception")

if [ -n "$duepublicoStatus" ]; then
	printf "%s Error - duepublico.sh starts with exceptions -> check db, solr\n" "$(date) $logtemplate"
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

printf "%s Clean current mcr data directory in $mcr_data_directory \n" "$(date) $logtemplate"
if [ -d $mcr_data_directory/metadata ]; then
	printf "%s Remove $mcr_data_directory/metadata\n" "$(date) $logtemplate"
	rm -rf $mcr_data_directory/metadata
fi

if [ -d $mcr_data_directory/versions-metadata ]; then
	printf "%s Remove $mcr_data_directory/versions-metadata\n" "$(date) $logtemplate"
	rm -rf $mcr_data_directory/versions-metadata
fi

if [ -d $mcr_data_directory/content ]; then
	printf "%s Remove $mcr_data_directory/content\n" "$(date) $logtemplate"
	rm -rf $mcr_data_directory/content
fi

printf "%s Move unpacked mcr data archive to $mcr_data_directory\n" "$(date) $logtemplate"
mv ./env/tmp/data/* $mcr_data_directory

../duepublico-setup/target/bin/duepublico.sh repair metadata search of base duepublico_mods

printf '%s MCR data archive was recovered successfully\n' "$(date) $logtemplate"

exit 0
