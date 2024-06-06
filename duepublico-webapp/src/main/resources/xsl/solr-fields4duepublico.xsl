<?xml version="1.0" encoding="UTF-8"?>

<!-- Builds solr fields used for table of contents -->

<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:xalan="http://xml.apache.org/xalan"
  xmlns:mods="http://www.loc.gov/mods/v3"
  exclude-result-prefixes="xalan xlink mods">

  <xsl:import href="xslImport:solr-document:solr-fields4duepublico.xsl" />

  <xsl:template match="mycoreobject">
    <xsl:apply-imports />
    <xsl:for-each select="metadata/def.modsContainer/modsContainer/mods:mods">
      <xsl:apply-templates select="mods:accessCondition" mode="duepublico" />
      <xsl:apply-templates select="mods:note[@type='repec']" mode="duepublico" />
      <xsl:apply-templates select="mods:identifier[@type='repec']" mode="duepublico" />
    </xsl:for-each>
  </xsl:template>

  <!--  <mods:accessCondition type="use and reproduction" xlink:href="https://.../mir_licenses#cc_by-nc-nd_4.0" ... /> -->
  <xsl:template match="mods:accessCondition[@type='use and reproduction'][contains(@xlink:href,'mir_licenses')]" mode="duepublico">
    <field name="license">
      <xsl:value-of select="substring-after(@xlink:href,'mir_licenses#')" />
    </field>
  </xsl:template>

  <xsl:template match="mods:identifier[@type='repec']" mode="duepublico">
    <field name="repecID">
      <xsl:value-of select="." />
    </field>
  </xsl:template>

  <xsl:template match="mods:note[@type='repec']" mode="duepublico">
    <field name="repecData">
      <xsl:value-of select="." />
    </field>
  </xsl:template>

</xsl:stylesheet>