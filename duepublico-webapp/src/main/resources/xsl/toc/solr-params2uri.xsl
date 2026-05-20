<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
 
  <xsl:template match="/solr-params">
    <uri>
      <xsl:text>solr:</xsl:text>
      <xsl:for-each select="param">
        <xsl:value-of select="@name" />
        <xsl:text>=</xsl:text>
        <xsl:value-of select="encoder:encode(.,'UTF-8')" xmlns:encoder="xalan://java.net.URLEncoder" />
        <xsl:if test="position() != last()">&amp;</xsl:if>
      </xsl:for-each>
    </uri>
  </xsl:template>
  
</xsl:stylesheet>
