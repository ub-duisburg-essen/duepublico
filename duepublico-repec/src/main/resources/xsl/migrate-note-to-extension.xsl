<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:mods="http://www.loc.gov/mods/v3"
  exclude-result-prefixes="xsl">

  <xsl:include href="copynodes.xsl" />

  <xsl:template match="mods:note[@type='repec']" priority="1">
    <mods:extension displayLabel="RePEc Metadata">
      <xsl:copy-of select="node()" />
    </mods:extension>
  </xsl:template>
  
</xsl:stylesheet>
