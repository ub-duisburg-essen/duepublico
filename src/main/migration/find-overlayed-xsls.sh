#!/bin/bash

# Script to find all *.xsl files that have been overwritten:
#	mvn install
#   src/main/migration/find-overlayed-xsls.sh
 
find src/main/resources/xsl -type f -name *.xsl | cut -d / -f 5-10 | sort | while read xsl_file
do
	( cd target/duepublico-*/WEB-INF/lib
	for jar_file in m[iy][rc]*-*.jar
	do 
		jar -tf "$jar_file" | grep -q $xsl_file && echo "$xsl_file in $jar_file"
	done )
done
