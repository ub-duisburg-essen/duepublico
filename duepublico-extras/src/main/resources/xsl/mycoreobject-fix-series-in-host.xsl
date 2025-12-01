<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:mods="http://www.loc.gov/mods/v3" 
  exclude-result-prefixes="xsl mods">
  
  <xsl:output method="xml" />
  
  <xsl:include href="copynodes.xsl" />

  <!-- remove all kind of unwanted relations -->
  <xsl:template match="mods:relatedItem[not((@type='host') or (@type='series'))]" />
  
  <xsl:template match="mods:relatedItem/@type[.='host'][../mods:genre[contains(@valueURI,'mir_genres#series')]]">
    <xsl:attribute name="type">series</xsl:attribute>
  </xsl:template>
  
</xsl:stylesheet>
