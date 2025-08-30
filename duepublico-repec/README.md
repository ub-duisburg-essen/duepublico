# RePEc (Recommended Papers in Economics) interface

This module implements a RePEc interface for DuEPublico.<br/>
The interface specification is described at <https://ideas.repec.org/t/serverintro.html><br/>

**RePEcServlet** implements this interface by creating output 
that corresponds to that virtual folder structure.<br/>
The resulting interface is provided at {$WebApplicationBaseURL}/RePEc/<br/>

`solr-repec.xsl` generates SOLR fields to index metadata used for the RePEc output

RePEc metadata for a publication is stored within a `mods:extension[@displayLabel='RePEc Metadata']`. <br/>
`mycoreobject-generate-repec.xsl` generates a template for such RePEc paper metadata to be stored there.

`content/repec/form.xed` can be used to edit the RePEc metadata.
 
`/RePEc/`<br/> 
  is implemented by `RePEcServlet.sendRepecRoot()` <br/>
  which generates a simple XML as `<repec><node name="{archiveCode}" /></repec>` containing the configured archive code <br/>
  which is then rendered by `repec.xsl` to generate the HTML output <br/>
  
`/RePEc/ajt`<br/> 
  is implemented by `RePEcServlet.sendArchiveDirectory()` <br/>
  which does a SOLR query to find all RePEc entries, <br/>
  and transforms the SOLR XML response via `response-repec-archive.xsl` and `repec.xsl` to generate the HTML output <br/>

`/RePEc/ajt/ajtarch.redif`<br/>
  is implemented by `RePEcServlet.sendArchiveFile()` <br/>
  which generates a simple XML as `<redif-archive />` <br/>
  and transforms the SOLR XML response via `response-repec-archive.xsl` and `repec.xsl` to generate the HTML output <br/>
  which is then transformed by `redif-archive.xsl` and afterwards `redif.xsl` to generate the TXT output

`/RePEc/ajt/ajtseri.redif`<br/>
  is implemented by `RePEcServlet.sendSeriesFile()` <br/>
  which does a SOLR query to find all RePEc entries, <br/>
  and transforms the SOLR XML response via `response-redif-file.xsl` to generate the TXT output

`/RePEc/ajt/wcinc/`<br/>
  is implemented by `RePEcServlet.sendSeriesDir()` <br/>
  which does a SOLR query to find the IDs of all objects belonging to this series<br/>
  and transforms the SOLR XML response via `response-repec-series.xsl` and `repec.xsl` to generate the HTML output

`/RePEc/ajt/wcinc/duepublico_mods_00076053.redif`<br/>
  is implemented by `RePEcServlet.sendObjectMetadata()` <br/>
  which retrieves the object metadata 
  and transforms it via `mycoreobject-redif-from-node.xsl` to generate the TXT output
