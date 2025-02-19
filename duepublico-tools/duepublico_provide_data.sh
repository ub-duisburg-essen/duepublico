#!/bin/bash
logtemplate=" - duepublico_provide_data.sh:"
current_dir=$(pwd)

while getopts d:e:l:n:o: flag; do
	case "${flag}" in
	d) data_directory=${OPTARG} ;;
	e)
		set -f  # disable glob
		IFS=' ' # split on space characters
		exclude=($OPTARG)
		;; # use the split+glob operator
	l) last=${OPTARG} ;;
	n) name_out=${OPTARG} ;;
	o) provide_out=${OPTARG} ;;
	esac
done

# flags d, n and o are required
if [[ -z "$data_directory" || -z "$name_out" || -z "$provide_out" ]]; then

	printf '%s This script requires flags -d (mcr Data directory), -n (name_out) and -o (provide output directory) -> please make them available\n' "$(date) $logtemplate"
	exit 1
fi

# Are there needed environmental files ?
if ! [ -f ./env/dc.txt ]; then

	printf '%s This script needs environmental information - please make them available!\n' "$(date) $logtemplate"
	exit 1
fi

# check for current temp directory
if [ -d ./env/tmp ]; then
	rm -rf ./env/tmp
fi

# Does provide_out directory exists?
if ! [ -d $provide_out ]; then

	printf '%s This script needs a valid provide_out directory - please make it available\n' "$(date) $logtemplate"
	exit 1
fi

# check for current data export
if [ -f $provide_out/$name_out ]; then
	printf '%s Remove previous data export\n' "$(date) $logtemplate"
	rm -rf $data_directory/$provide_out/$name_out
fi

mkdir ./env/tmp
mkdir ./env/tmp/data

# copy all metadata

printf '%s Copy metadata\n' "$(date) $logtemplate"
cp -rp $data_directory/metadata ./env/tmp/data/

printf '%s Copy versions-metadata\n' "$(date) $logtemplate"
# copy all versions_metadata
cp -rp $data_directory/versions-metadata ./env/tmp/data/

printf '%s Create dummy content\n' "$(date) $logtemplate"
# create dummy data
mkdir ./env/tmp/data/content

cd $data_directory/content

# get directory structure
find . -type d >$current_dir/env/tmp/directories.txt

# get structure of original mcrdata.xml
find . -type f -name 'mcrdata.xml' >$current_dir/env/tmp/mcrdata.txt

# structure of dummy files
find . -type f ! -name 'mcrdata.xml' >$current_dir/env/tmp/dummyfiles.txt

# get latest content data (set amount with -l flag)
if [ ! -z "$last" ]; then
	printf "%s Add real content from latest $last derivates\n" "$(date) $logtemplate"
	find . -type f ! -name 'mcrdata.xml' -printf '%T@ %p\n' | sort -n | tail -"$last" | cut -f2- -d" " >$current_dir/env/tmp/files.txt
fi

# Add excludes
if [ ! -z "$exclude" ]; then
	printf "%s Add excluded derivates as real content\n" "$(date) $logtemplate"

	for a in "${exclude[@]}"; do
		printf "%s Add $a \n" "$(date) $logtemplate"
		awk "/$a/" $current_dir/env/tmp/dummyfiles.txt >>$current_dir/env/tmp/files.txt
	done
fi

# create directory structure
cd $current_dir/env/tmp/data/content
cat $current_dir/env/tmp/directories.txt | xargs -d '\n' mkdir -p

# copy original mcrdata.xml into structure
cat $current_dir/env/tmp/mcrdata.txt | xargs -d '\n' -I {} cp -rp $data_directory/content/{} ./{}

# create dummy content based on dummyfiles.txt
cat $current_dir/env/tmp/dummyfiles.txt | xargs -d '\n' -I {} touch {}

# copy real content into structure
if [ -f $current_dir/env/tmp/files.txt ]; then
	cat $current_dir/env/tmp/files.txt | xargs -d '\n' -I {} cp -rp $data_directory/content/{} ./{}
fi

printf '%s Pack data directory (data.tar.gz)\n' "$(date) $logtemplate"
# tar + pack file
cd $current_dir/env/tmp/
tar cfz data.tar.gz ./data

# encrypt out.tar.gz
printf '%s Encrypt data.tar.gz\n' "$(date) $logtemplate"
openssl enc -aes-256-cbc -md sha512 -pbkdf2 -iter 1000000 -salt -in ./data.tar.gz -out ./$name_out -pass file:../dc.txt

# adapt permissions
chmod 644 ./$name_out

# move encrypted duepublico_export_data.tar.dz to provide_out directory
printf "%s Move encrypted $name_out to provide_out directory ($provide_out)\n" "$(date) $logtemplate"
mv ./$name_out $provide_out/$name_out

# remove unnecessary files
printf '%s Remove tmp directory\n' "$(date) $logtemplate"
rm -rf $current_dir/env/tmp

printf '%s DuEPublico provide data script was executed successfully\n' "$(date) $logtemplate"
exit 0
