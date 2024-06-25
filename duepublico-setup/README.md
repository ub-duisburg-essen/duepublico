# How to initially build and setup DuEPublico

DuEPublico is an overlay of MyCoRe MIR web application. It adds some extra functionality and customizations. Local data and configuration will be stored
* in a local directory ```${user.home}/AppData/Local/MyCoRe/duepublico/``` (Windows) resp. ```${user.home}/.mycore/duepublico/``` (Linux).
* within an Apache SOLR server instance (see below)
* within a relational database (you create the database, MyCoRe will create the tables and load the data)

## Prepare SOLR cores

DuEPublico uses SOLR configsets for the main core (https://github.com/MyCoRe-Org/mycore_solr_configset_main) and classification core (https://github.com/MyCoRe-Org/mycore_solr_configset_classification) from MyCoRe.  
The configsets are included in ```duepublico-setup/src/main/setup/solr/cores/``` as git submodules. Use the following git commands (from the main directory of cloned duepublico repository) to fetch the modules:

```
git submodule init
git submodule update
```
For a production environment follow the [instructions from MyCoRe on how to setup SOLR](https://www.mycore.de/documentation/search/search_solr_use/) and install these cores.
For a development enviromnent, you can use the built-in solr-runner to configure and run a local SOLR server instance:

```
mvn -pl duepublico-setup solr-runner:copyHome
mvn -pl duepublico-setup solr-runner:installSolrPlugins
```

This will prepare a SOLR instance with data and configuration stored in ```${user.home}/AppData/Local/MyCoRe/duepublico/data/solr``` (Windows) resp. ```${user.home}/.mycore/duepublico/data/solr``` (Linux).
You now can start/stop SOLR using

```
mvn -pl duepublico-setup solr-runner:start
mvn -pl duepublico-setup solr-runner:stop
```

The SOLR server runs at http://localhost:8983/

## Build the duepublico web application

```
mvn install
```

## Create a local database (e.g. MariaDB, PostgreSQL)

Follow the instructions of the database management system. Be sure to use a UTF-8 enabled relational database.

## Basic configuration using the MIR wizard

Start the web application:
```
mvn -pl duepublico-webapp cargo:run
```
Ths will run a local Apache Tomcat 9 instance under http://localhost:8291/
Invoke that link -> the MIR wizard will show up.
Look into the console output at the command line, find and copy the access token.
Enter the configuration

|Field|Value|
|----|----|
|Anwendungs-Kern|duepublico|
|Klassifikationen-Kern|duepublico-classifications|
|Datenbank|JDBC URL, user and password to access the database to use|
|SMTP-Konfiguration|name of the outgoint e-mail server, user/password if needed|

The MIR wizard will now prepare the configuration, setup the database tables, load classifications and ACLs etc. This will take a while.
When the wizard is finished, shutdown the web application and press CTRL-C on the command line to stop the cargo runner.

## Prepare the local mycore.properties

Edit ```${user.home}/AppData/Local/MyCoRe/duepublico/mycore.properties``` (Windows) resp. ```${user.home}/.mycore/duepublico/mycore.properties``` (Linux).
At least, you have to add the credentials to register DOIs at Datacite and Crossref.

```
MCR.PI.Service.Datacite.Username=...
MCR.PI.Service.Datacite.Password=...

MCR.PI.Service.Crossref.Username=...
MCR.PI.Service.Crossref.Password=...
```

## Run additional setup commands

This step will load custom versions of the classifications and set up a user for editing dissertations.

```
cd duepublico-setup\src\main\setup\
..\..\..\..\duepublico-webapp\target\bin\duepublico.cmd process setup-commands.txt
```

## Start and use DuEPublico

To run a local Apache Tomcat 9 instance under http://localhost:8291/, enter
```
mvn -pl duepublico-webapp cargo:run
```

To run the command line interface (CLI) as a local shell application, enter
```
duepublico-webapp/target/bin/duepublico.cmd (Windows)
duepublico-webapp/target/bin/duepublico.sh (Linux)
```

## Debugging environment

Change the following line in duepublico pom.xml to enable debug mode for cargo plugin:

`<cargo.jvmargs>-DMCR.AppName=${MCR.AppName} -Dsolr.solr.home=${solr.home} -Dsolr.data.dir=${solr.data.dir} -Xms512m -Xmx2048m -Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=n,address=8000 -Xnoagent -Djava.compiler=NONE</cargo.jvmargs>`

## Hot code replacement - Settings for Eclipse

Project -> Build Automatically ---- Enable this

Preferences -> Java -> Compiler -> Building ---- Uncheck *Abort build when build path errors occur*
