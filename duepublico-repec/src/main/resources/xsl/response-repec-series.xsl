<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:template match="/response">
    <repec>
      <xsl:for-each select="result/doc">
        <node name="{str[@name='id']}.redif" />
      </xsl:for-each>
    </repec>
  </xsl:template>

</xsl:stylesheet>
