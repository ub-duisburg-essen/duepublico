# Installation
## Install solr home
DuEPublico uses solr configsets for main core (https://github.com/MyCoRe-Org/mycore_solr_configset_main) and classification core (https://github.com/MyCoRe-Org/mycore_solr_configset_classification) from MyCoRe.  
The configsets are included in *./src/main/setup/solr/cores* as git submodules. Use the following git commands (from the main directory of cloned duepublico repository) to fetch the modules:

`git submodule init`

`git submodule update`

With the maven goal `mvn solr-runner:copyHome` the solr cores and configsets will be initialized in duepublico home directory.