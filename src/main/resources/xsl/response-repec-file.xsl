<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:output method="text" encoding="UTF-8" media-type="text/plain" />

  <xsl:template match="/response">
    <xsl:for-each select="result/doc">
      <xsl:value-of select="str[@name='repecData']/text()" />
      <xsl:if test="position() != last()">
        <xsl:text>&#10;&#10;</xsl:text>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

</xsl:stylesheet>
