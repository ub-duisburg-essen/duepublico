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

# sonstige
**duepublico_provide_data.sh**
* script provides an encrypted export of mcr data directory (metadata, versions-metadata) and creates dummy content to keep sandbox data size small
* flags **d, n, o** are required
* **-d** flag - mcr data directory
* **-n** flag - output name of file
* **-o** flag - provide_out directory (set this also via webserver configuration to allow http/https access)


* **-l** flag - exclude latest n modified files from content directory to provide real content files
* **-e** flag - exclude individual derivates from content directory to provide real content files

examples:
* default call with required flags: `./duepublico_provide_data.sh -d "/data" -n "duepublico_export_data_allDummy.tar.gz" -o "/data/provide_out"`
* provide latest 100 real content files: `./duepublico_provide_data.sh -d "/data" -n "duepublico_export_data_latestContent.tar.gz" -o "/data/provide_out" -l 100`
* Exclude some selected derivate files (Altersuebergangs_Report) + latest 100: `./duepublico_provide_data.sh -d "/data" -n "duepublico_export_test2023.tar.gz" -o "/data/provide_out" -l 100 -e "duepublico_derivate_00071129 duepublico_derivate_00082000 duepublico_derivate_00081779 duepublico_derivate_00081177 duepublico_derivate_00080968 duepublico_derivate_00078446"`