<?xml version="1.0" encoding="utf-8"?>

<!-- Adds collection to imported metadata from DeepGreen via SWORD -->

<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:mods="http://www.loc.gov/mods/v3">

  <xsl:output method="xml" encoding="UTF-8" indent="yes" />

  <xsl:include href="copynodes.xsl" />

  <xsl:template match="mods:mods">
    <xsl:copy>
      <xsl:call-template name="collection" />
      <xsl:apply-templates />
    </xsl:copy>
  </xsl:template>

  <xsl:template name="collection">
    <xsl:variable name="classification" select="'classification:metadata:1:children:collection'" />
    <xsl:variable name="authorityURI" select="document($classification)/*/label[@xml:lang='x-uri']/@text" />
    
    <mods:classification authorityURI="{$authorityURI}" valueURI="{$authorityURI}#Pub" />
  </xsl:template>

</xsl:stylesheet>
