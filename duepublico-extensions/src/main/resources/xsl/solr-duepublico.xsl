<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:xalan="http://xml.apache.org/xalan" exclude-result-prefixes="xalan xlink">
  <xsl:import href="xslImport:solr-document:solr-duepublico.xsl" />

  <xsl:template match="mycoreobject">
    <xsl:apply-imports />
    <xsl:for-each select="service/servflags/servflag[@type='alias']">
      <field name="alias">
        <xsl:for-each select="ancestor::mycoreobject/structure/parents/parent[1]">
          <xsl:for-each select="document(concat('notnull:mcrobject:',@xlink:href))/mycoreobject">
            <xsl:value-of select="service/servflags/servflag[@type='alias']" />
            <xsl:text>/</xsl:text>
          </xsl:for-each>
        </xsl:for-each>
        <xsl:value-of select="." />
      </field>
    </xsl:for-each>
  </xsl:template>
</xsl:stylesheet>