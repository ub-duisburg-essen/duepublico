<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:param name="MCR.RePEc.ArchiveCode" />

  <xsl:template match="/response">
    <repec>
      <node name="{$MCR.RePEc.ArchiveCode}arch.redif" />
      <node name="{$MCR.RePEc.ArchiveCode}seri.redif" />
      <xsl:for-each select="result/doc">
        <node name="{str[@name='repecID']}" />
      </xsl:for-each>
    </repec>
  </xsl:template>

</xsl:stylesheet>
