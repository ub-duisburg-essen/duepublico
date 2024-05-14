#!/bin/bash
timestamp=$(date)

logtemplate=""$timestamp" - clean_create_duepublico.sh:"
appname="duepublico"

h2_user="sa"
h2_password=""
current_dir=$(pwd)
cd ..

# check for current build
if ! [ -d ./target ]; then
	printf '%s Clean and install duepublico2\n' "$logtemplate"
	git submodule init && git submodule update
	mvn clean install -DskipTests
fi

# check for current duepublico solr home
if ! [ -d ~/.mycore/$appname/data/solr ]; then
	# Adapt solr cores

	printf '%s Create mcr solr configuration\n' "$logtemplate"
	mvn solr-runner:copyHome
fi

printf '%s Start integrated solr\n' "$logtemplate"
mvn solr-runner:start

# check for current mycore home
if ! [ -d ~/.mycore/$appname/resources ]; then

	printf '%s Create mcr configuration directory\n' "$logtemplate"
	./target/bin/duepublico.sh create configuration directory

	# Download h2
	printf '%s Download h2 database into ~/.mycore/$appname/\n' "$logtemplate"
	wget https://search.maven.org/remotecontent?filepath=com/h2database/h2/2.2.224/h2-2.2.224.jar -O ~/.mycore/$appname/lib/h2-2.2.224.jar

	# Create h2 database
	printf '%s Create empty h2 database in ~/.mycore/$appname/data/h2/\n' "$logtemplate"
	cd ~/.mycore/$appname/lib
	java -cp h2-*.jar org.h2.tools.Shell -url "jdbc:h2:~/.mycore/$appname/data/h2/mir" -user "$h2_user" -password "$h2_password" -sql "SHOW TABLES"

	# Copy persistence.xml template into ~/.mycore/$appname/resources/META-INF/\n' "$logtemplate"
	cd $current_dir
	cp -rp ./resources ~/.mycore/$appname

	# Adapt persistence.xml
	sed -i 's/javax.persistence.jdbc.url" value="/javax.persistence.jdbc.url" value="jdbc:h2:~\/.mycore\/$appname\/resources\/META-INF\/persistence.xml/g' ~/.mycore/$appname/resources/META-INF/persistence.xml
	sed -i 's/javax.persistence.jdbc.user" value="/javax.persistence.jdbc.user" value="$h2_user/g' ~/.mycore/$appname/resources/META-INF/persistence.xml
	sed -i 's/javax.persistence.jdbc.password" value="/javax.persistence.jdbc.password" value="$h2_password/g' ~/.mycore/$appname/resources/META-INF/persistence.xml

fi

printf '%s duepublico2 home was created successfully./\n' "$logtemplate"
