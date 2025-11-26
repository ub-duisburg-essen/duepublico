<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:mods="http://www.loc.gov/mods/v3" 
  exclude-result-prefixes="xsl mods">
  
  <xsl:output method="xml" />
  
  <xsl:include href="copynodes.xsl" />

  <!-- remove all kind of unwanted relations -->
  <xsl:template match="mods:relatedItem[not((@type='host') or (@type='series'))]" />
  
  <xsl:template match="mods:relatedItem[@type='host']">
    <xsl:choose>
      <xsl:when test="mods:relatedItem[@type='host']">
        <xsl:apply-templates select="mods:relatedItem[@type='host']" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy>
          <xsl:copy-of select="@*" />
          <xsl:apply-templates />
        </xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="mods:part">
    <xsl:copy>
      <xsl:for-each select="ancestor::mods:relatedItem[@type='host']">
        <xsl:copy-of select="mods:part/*" />
      </xsl:for-each>
    </xsl:copy>
  </xsl:template>
  
</xsl:stylesheet>
