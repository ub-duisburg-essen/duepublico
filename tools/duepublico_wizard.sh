#!/bin/bash
timestamp=$(date)

logtemplate=""$timestamp" - duepublico_wizard.sh:"
appname="duepublico"

h2_user="sa"
h2_password=""
current_dir=$(pwd)

cd ..

# check for current build
if ! [ -d ./target ]; then
	printf "%s Clean and install duepublico2\n" "$logtemplate"
	git submodule init && git submodule update
	mvn clean install -DskipTests
fi

# check for current duepublico solr home
if ! [ -d ~/.mycore/$appname/data/solr ]; then

	# Adapt solr cores
	printf "%s Create mcr solr configuration\n" "$logtemplate"
	mvn solr-runner:copyHome
fi

printf "%s Start integrated solr to create configuration\n" "$logtemplate"
mvn solr-runner:start

# check for current mycore home
if ! [ -d ~/.mycore/$appname/resources ]; then

	printf "%s Create mcr configuration directory\n" "$logtemplate"
	./target/bin/duepublico.sh create configuration directory

	# Download h2
	printf "%s Download h2 driver into ~/.mycore/$appname/lib\n" "$logtemplate"
	wget https://repo.maven.apache.org/maven2/com/h2database/h2/1.4.200/h2-1.4.200.jar -O ~/.mycore/$appname/lib/h2-1.4.200.jar

	# Create h2 database
	printf "%s Create empty h2 database in ~/.mycore/$appname/data/h2\n" "$logtemplate"
	cd ~/.mycore/$appname/lib
	java -cp h2-*.jar org.h2.tools.Shell -url "jdbc:h2:~/.mycore/$appname/data/h2/mir" -user "$h2_user" -password "$h2_password" -sql "SHOW TABLES"

	# Copy persistence.xml template into ~/.mycore/$appname/resources/META-INF/\n' "$logtemplate"
	cd $current_dir
	cp -rp ./resources ~/.mycore/$appname

	# Adapt persistence.xml
	printf "%s Adapt persistence.xml in ~/.mycore\/$appname\/resources\/META-INF\/persistence.xml\n" "$logtemplate"
	sed -i "s/javax.persistence.jdbc.url\" value=\"/javax.persistence.jdbc.url\" value=\"jdbc:h2:~\/.mycore\/$appname\/resources\/META-INF\/persistence.xml/g" ~/.mycore/$appname/resources/META-INF/persistence.xml
	sed -i "s/javax.persistence.jdbc.user\" value=\"/javax.persistence.jdbc.user\" value=\"$h2_user/g" ~/.mycore/$appname/resources/META-INF/persistence.xml
	sed -i "s/javax.persistence.jdbc.password\" value=\"/javax.persistence.jdbc.password\" value=\"$h2_password/g" ~/.mycore/$appname/resources/META-INF/persistence.xml

	# Adapt solr settings
	printf "%s Add solr settings into ~/.mycore/$appname/mycore.properties\n" "$logtemplate"
	echo "MCR.Mail.NumTries=1" >>~/.mycore/$appname/mycore.properties
	echo "MCR.Solr.Core.classification.Name=duepublico-classifications" >>~/.mycore/$appname/mycore.properties
	echo "MCR.Solr.Core.main.Name=duepublico" >>~/.mycore/$appname/mycore.properties
	echo "MCR.Solr.ServerURL=http\://localhost\:8983" >>~/.mycore/$appname/mycore.properties

	# Use CLI
	cd ..

	# Reload solr configuration
	./target/bin/duepublico.sh reload solr configuration main in core main
	./target/bin/duepublico.sh reload solr configuration classification in core classification

	# Load classifications
	./target/bin/duepublico.sh update all classifications from directory ./src/main/setup/classifications
	
	# Init superuser
	./target/bin/duepublico.sh init superuser
	
	# Import permissions
	./target/bin/duepublico.sh load permissions data from file ./src/main/setup/permissions.xml
	
	# ediss user
	./target/bin/duepublico.sh import user from file ./src/main/setup/user-ediss.xml
	./target/bin/duepublico.sh set password for user ediss to ediss
	
fi

printf "%s duepublico2 home was created successfully.\n" "$logtemplate"
