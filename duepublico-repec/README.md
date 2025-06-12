# RePEc (Recommended Papers in Economics) interface

This module implements a RePEc interface for DuEPublico.
The interface specification is described at <https://ideas.repec.org/t/serverintro.html>
**RePEcServlet** implements this interface by creating output that corresponds to that virtual folder structure.
The resulting interface is provided at {$WebApplicationBaseURL}/RePEc/

**solr-repec.xsl** generates SOLR fields to index metadata used for the RePEc output
  
/ --> sendRepecRoot 
  <repec><node name="{archiveCode}" /> --> repec.xsl --> html output
/ajt --> sendArchiveDirectory 
  MCR.RePEc.AllSeries.SOLR=solr:fl=repecID,repecData&q=(mods.genre:journal+OR+mods.genre:series)+AND+repecID:*+AND+repecData:*+AND+state:published
  MCR.RePEc.ArchiveDir.URI=xslStyle:response-repec-archive:%MCR.RePEc.AllSeries.SOLR%
  SOLR response > response-repec-archive.xsl --> repec.xsl --> html output
/ajt/wcinch --> sendSeriesDir
  String objectID = getSeriesIDByRepecID(repecID);
  MCR.RePEc.SeriesDir.SOLR=solr:fl=id&q=parent:%s+AND+state:published+AND+repecData:*
  MCR.RePEc.SeriesDir.URI=xslStyle:response-repec-series:%MCR.RePEc.SeriesDir.SOLR%
  SOLR response > response-repec-archive.xsl --> repec.xsl --> html output
/ajt/ajtarch.redif --> sendArchiveFile
  new Element("redif-archive") --> redif-archive.xsl > redif.xsl -> txt redif output
/ajt/ajtseri.redif --> sendSeriesFile
  MCR.RePEc.SeriesFile.URI=xslStyle:response-redif-file:%MCR.RePEc.AllSeries.SOLR%
  xslStyle:mycoreobject-redif-from-node:mcrobject:" + objectID
 