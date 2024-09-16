# duepublico-tools

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
* Exclude some selected derivate files: `./duepublico_provide_data.sh -d "/data" -n "duepublico_export_data_excludeSomeContent.tar.gz" -o "/data/provide_for_sandbox" -l 10 -e "duepublico_derivate_00022286 duepublico_derivate_00081047"`

**duepublico_clean_data_url_import.sh**
* Script provides a data import (metadata, versions-metadata, content) via url (wget is necessary)

requirements:
* basic configured duepublico (wizard passed through, updated classifications from setup, updated solr config from setup) 
* decryption information for data archive provided by **duepublico_provide_data.sh** (./env/dc.txt)
* duepublico build (duepublico.sh - default directory is ../duepublico-webapp/target/bin)
* runnable duepublico dependencies (db, solr)

* flags **d, u** are required
* **-d** flag - valid mcr data directory
* **-u** flag - valid data url (provided by **duepublico_provide_data.sh**)

example:
* `./duepublico_clean_data_url_import.sh -d "/home/exampleUser/.mycore/duepublico/data" -u "https://duepublico2.uni-due.de/example/duepublico_data_example.tar.gz"`
