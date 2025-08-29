<?xml version="1.0" encoding="UTF-8"?>

<!-- Builds solr fields used for RePEc interface -->

<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:mods="http://www.loc.gov/mods/v3"
  exclude-result-prefixes="mods">

  <xsl:import href="xslImport:solr-document:solr-repec.xsl" />

  <xsl:template match="mycoreobject">
    <xsl:apply-imports />
    <xsl:for-each select="metadata/def.modsContainer/modsContainer/mods:mods">
      <xsl:apply-templates select="mods:extension[@displayLabel='RePEc Metadata']" mode="repec" />
      <xsl:apply-templates select="mods:identifier[@type='repec']" mode="repec" />
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="mods:identifier[@type='repec']" mode="repec">
    <field name="repecID">
      <xsl:value-of select="." />
    </field>
  </xsl:template>

  <xsl:template match="mods:extension[@displayLabel='RePEc Metadata']" mode="repec">
    <field name="repecData">
      <xsl:value-of select="." />
    </field>
  </xsl:template>

</xsl:stylesheet>