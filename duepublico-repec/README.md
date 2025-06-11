# RePEc (Recommended Papers in Economics) interface

This module implements a RePEc interface for DuEPublico.
The interface specification is described at <https://ideas.repec.org/t/serverintro.html>

- **RePEcServlet**<br/>
  implements the interface by creating output that corresponds to that virtual folder structure.
  The resulting interface is provided at {$WebApplicationBaseURL}/RePEc/
- **response-repec-dir.xsl**<br/>
  creates the file browsing output for the root, archive and series level.
  That is a simple html file with a list of nodes at that level, linking to the levels below.
- **response-repec-file.xsl**
  ...
- **mycoreobject-redif.xsl**
  ...
- **solr-repec.xsl**
  Generates SOLR fields to index metadata used for the RePEc output
  
