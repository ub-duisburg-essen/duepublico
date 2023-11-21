#!/bin/bash

# Script to find all files that have been overwritten:
#	mvn install
#	src/main/migration/find-overwritten-files.sh

echo
echo XSL stylesheets that overwrite the MIR/MyCoRe versions:
echo

find src/main/resources/xsl -type f -name '*.xsl' | cut -d / -f 5-10 | sort | while read xsl_file
do
	( cd target/duepublico-*/WEB-INF/lib
	for jar_file in m[iy][rc]*-*.jar
	do 
		jar -tf "$jar_file" | grep -q $xsl_file && echo "$xsl_file in $jar_file"
	done )
done

echo
echo Config files that overwrite the MIR/MyCoRe versions:
echo

find src/main/resources -type f -name '*.xml'| cut -d / -f 4-10 | sort | while read config_file
do
        ( cd target/duepublico-*/WEB-INF/lib
        for jar_file in m[iy][rc]*-*.jar
        do
                jar -tf "$jar_file" | grep -q $config_file && echo "$config_file in $jar_file"
        done )
done

echo
echo Webapp files that overwrite the MIR/MyCoRe versions:
echo

find src/main/webapp -type f | cut -d / -f 4-10 | sort | while read webapp_file
do
	( cd target/duepublico-*/WEB-INF/lib
	for jar_file in m[iy][rc]*-*.jar
	do 
		jar -tf "$jar_file" | grep -q $webapp_file && echo "$webapp_file in $jar_file"
	done )
done

