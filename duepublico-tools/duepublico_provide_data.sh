#!/bin/bash
timestamp=$(date)

logtemplate=""$timestamp" - duepublico_provide_data.sh:"

data_directory="/data"
dependent_dir=$(pwd)
provide_out="/data/webserver_provide_out"

# Are there needed environmental files ?
if ! [ -f ./env/dc.txt ]; then

	printf '%s This script needs environmental information - please make them available!\n' "$logtemplate"
	exit 1
fi

# check for current temp directory
if ! [ -d ./tmp ]; then
	rm -rf ./env/tmp
fi

mkdir ./env/tmp
mkdir ./env/tmp/data

# copy all metadata

printf '%s Copy metadata\n' "$logtemplate"
cp -rp $data_directory/metadata ./env/tmp/data/

printf '%s Copy versions-metadata\n' "$logtemplate"
# copy all versions_metadata
cp -rp $data_directory/versions-metadata ./env/tmp/data/

printf '%s Create dummy content\n' "$logtemplate"
# create dummy data
mkdir ./env/tmp/data/content

cd $data_directory/content

# get directory structure
find . -type d >$dependent_dir/env/tmp/directories.txt

# get structure of original mcrdata.xml
find . -type f -name 'mcrdata.xml' >$dependent_dir/env/tmp/mcrdata.txt

# structure of all other files
find . -type f ! -name 'mcrdata.xml' >$dependent_dir/env/tmp/files.txt

# create directory structure
cd $dependent_dir/env/tmp/data/content
cat $dependent_dir/env/tmp/directories.txt | xargs -d '\n' mkdir -p

# copy original mcrdata.xml into structure
cat $dependent_dir/env/tmp/mcrdata.txt | xargs -d '\n' -I {} cp -rp $data_directory/content/{} ./{}

# mv original mcrdata.xml
cat $dependent_dir/env/tmp/files.txt | xargs -d '\n' -I {} touch {}

printf '%s Pack data directory (duepublico_export_data.tar.gz)\n' "$logtemplate"
# tar + pack file
cd $dependent_dir/env/tmp/
tar cfz duepublico_export_data.tar.gz ./data

# encrypt duepublico_export_data.tar.dz
printf '%s Encrypt duepublico_export_data.tar.gz\n' "$logtemplate"
openssl enc -aes-256-cbc -md sha512 -pbkdf2 -iter 1000000 -salt -in ./duepublico_export_data.tar.gz -out ./duepublico_export_data.tar.gz.enc -pass file:../dc.txt

# move encrypted duepublico_export_data.tar.dz to provide_out directory
printf '%s Move encrypted duepublico_export_data.tar.dz to provide_out directory\n' "$logtemplate"
mv ./duepublico_export_data.tar.gz.enc $provide_out/duepublico_export_data.tar.gz.enc

# remove unnecessary files
printf '%s Remove tmp directory\n' "$logtemplate"
rm -rf $dependent_dir/env/tmp
