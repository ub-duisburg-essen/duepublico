#!/bin/bash
logtemplate=" - duepublico_provide_test_case_data.sh:"
current_dir=$(pwd)

while getopts d:e:m:n:o: flag; do
	case "${flag}" in
	d) data_directory=${OPTARG} ;;
	e)
		set -f  # disable glob
		IFS=' ' # split on space characters
		exclude_derivate=($OPTARG)
		;; # use the split+glob operator
	m)
		set -f  # disable glob
		IFS=' ' # split on space characters
		exclude_metadata=($OPTARG)
		;; # use the split+glob operator
	n) name_out=${OPTARG} ;;
	o) provide_out=${OPTARG} ;;
	esac
done

# flags d, e, m, n and o are required
if [[ -z "$data_directory" || -z "$exclude_derivate" || -z "$exclude_metadata" || -z "$name_out" || -z "$provide_out" ]]; then

	printf '%s This script requires flags -d (mcr Data directory), -e (excluded derivates), -m (excluded metadata) -n (name_out) and -o (provide output directory) -> please make them available\n' "$(date) $logtemplate"
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

# create metadata for testcase
printf '%s Create metadata directory for test case\n' "$(date) $logtemplate"
mkdir $current_dir/env/tmp/data/metadata
cd $data_directory/metadata

# structure of all metadata files
find . -type f >$current_dir/env/tmp/allMetadata.txt

# Create content for testcase
printf '%s Create content directory for test case\n' "$(date) $logtemplate"
mkdir $current_dir/env/tmp/data/content
cd $data_directory/content

# structure of content files
find . -type f >$current_dir/env/tmp/allContent.txt

# Add metadata excludes
if [ ! -z "$exclude_metadata" ]; then
	printf "%s Add excluded mods metadata into excludedMods.txt\n" "$(date) $logtemplate"

	for a in "${exclude_metadata[@]}"; do
		printf "%s Add $a \n" "$(date) $logtemplate"
		awk "/$a/" $current_dir/env/tmp/allMetadata.txt >>$current_dir/env/tmp/excludedMods.txt
	done
fi

# Add derivate excludes
if [ ! -z "$exclude_derivate" ]; then
	printf "%s Add excluded derivate metadata and content structure into excludedDerivate.txt and excludedContent.txt\n" "$(date) $logtemplate"

	for a in "${exclude_derivate[@]}"; do
		printf "%s Add $a \n" "$(date) $logtemplate"
		awk "/$a/" $current_dir/env/tmp/allMetadata.txt >>$current_dir/env/tmp/excludedDerivate.txt
		awk "/$a/" $current_dir/env/tmp/allContent.txt >>$current_dir/env/tmp/excludedContent.txt
	done
fi

# create mods metadata based on $current_dir/env/tmp/excludedMods.txt
cat $current_dir/env/tmp/excludedMods.txt | xargs -d '\n' -I {} cp -rp $data_directory/metadata/{} ./

# create derivate metadata based on $current_dir/env/tmp/excludedDerivate.txt
cat $current_dir/env/tmp/excludedDerivate.txt | xargs -d '\n' -I {} cp -rp $data_directory/metadata/{} ./

# create derivate metadata based on $current_dir/env/tmp/excludedContent.txt
cat $current_dir/env/tmp/excludedContent.txt | xargs -d '\n' -I {} cp -rp $data_directory/content/{} ./

printf '%s DuEPublico provide data script was executed successfully\n' "$(date) $logtemplate"
exit 0