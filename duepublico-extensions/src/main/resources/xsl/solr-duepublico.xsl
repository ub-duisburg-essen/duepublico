<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:xalan="http://xml.apache.org/xalan" exclude-result-prefixes="xalan xlink">
  <xsl:import href="xslImport:solr-document:solr-duepublico.xsl" />

  <xsl:template match="mycoreobject">
    <xsl:apply-imports />
    <xsl:apply-templates select="service/servflags/servflag[@type='alias']" mode="alias" />
  </xsl:template>
  
  <xsl:template match="service/servflags/servflag[@type='alias']" mode="alias">
    <field name="alias">
      <xsl:apply-templates select="ancestor::mycoreobject" mode="parent.alias" />
      <xsl:value-of select="text()" />
    </field>
  </xsl:template>

  <xsl:template match="mycoreobject" mode="parent.alias">
    <xsl:for-each select="document(concat('notnull:mcrobject:',structure/parents/parent[1]/@xlink:href))/mycoreobject">
      <xsl:apply-templates select="." mode="parent.alias" />
      <xsl:value-of select="service/servflags/servflag[@type='alias']" />
      <xsl:text>/</xsl:text>
    </xsl:for-each>
  </xsl:template>
  
</xsl:stylesheet>