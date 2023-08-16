# Installation
## Install solr home
DuEPublico uses solr configsets for main core (https://github.com/MyCoRe-Org/mycore_solr_configset_main) and classification core (https://github.com/MyCoRe-Org/mycore_solr_configset_classification) from MyCoRe.  
The configsets are included in *./src/main/setup/solr/cores* as git submodules. Use the following git commands (from the main directory of cloned duepublico repository) to fetch the modules:

`git submodule init`

`git submodule update`

With the maven goal `mvn solr-runner:copyHome` the solr cores and configsets will be initialized in duepublico home directory.

# Local Environment

For local environment you can use the cargo plugin that provides an embedded webserver (tomcat10x). Use the following maven goal to run the application:

`mvn cargo:run`

**Debug**

Change the following line in duepublico pom.xml to enable debug mode for cargo plugin:

`<cargo.jvmargs>-DMCR.AppName=${MCR.AppName} -Dsolr.solr.home=${solr.home} -Dsolr.data.dir=${solr.data.dir} -Xms512m -Xmx2048m -Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=n,address=8000 -Xnoagent -Djava.compiler=NONE</cargo.jvmargs>`


**Hot code replacement - Settings for Eclipse**

Project -> Build Automatically ---- Enable this

Preferences -> Java -> Compiler -> Building ---- Uncheck *Abort build when build path errors occur*