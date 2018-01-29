<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:xalan="http://xml.apache.org/xalan" exclude-result-prefixes="xalan xlink">
  <xsl:import href="xslImport:solr-document:solr-duepublico.xsl" />

  <xsl:template match="mycoreobject">
    <xsl:apply-imports />
    <xsl:for-each select="service/servflags/servflag[@type='alias']">
      <field name="alias">
        <xsl:value-of select="." />
      </field>
    </xsl:for-each>
  </xsl:template>
</xsl:stylesheet>