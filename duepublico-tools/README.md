# duepublico-tools

# ./2023.06/helper/postges

# ./2023.06/helper/solr
**dockerize_solr.sh**
* script allocates a solr server in a docker container with creation of mycore configsets (**mycore_solr_configset_classification, mycore_solr_configset_main**).
With some flags it is possible to import solr index data.

* **-b -c** flags - main core + classification core from existing 
* **-m** flag - imports solr index data from local mcrhome
* **-u** flag - imports solr index data from url (**provide_solr_index.sh**)

examples:
* default call (create solr server with clean mycore configsets): `./dockerize_solr.sh`
* create solr server and import solr index from local mcr_home: `./dockerize_solr.sh -b 'duepublico' -c 'duepublico-classifications' -m '/home/adg167c/.mycore/duepublico'`