<?xml version="1.0" encoding="utf-8"?>

<!-- Adds collection to imported metadata from DeepGreen via SWORD -->

<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:mods="http://www.loc.gov/mods/v3">

  <xsl:output method="xml" encoding="UTF-8" />

  <xsl:include href="copynodes.xsl" />

  <xsl:template match="mods:mods">
    <xsl:copy>
      <xsl:call-template name="collection" />
      <xsl:apply-templates />
    </xsl:copy>
  </xsl:template>

  <xsl:template name="collection">
    <mods:classification>
      <xsl:variable name="uri1" select="'classification:metadata:1:children:collection'" />
      <xsl:variable name="authorityURI" select="document($uri1)/*/label[@xml:lang='x-uri']/@text" />
      <xsl:attribute name="authorityURI">
        <xsl:value-of select="$authorityURI" />
      </xsl:attribute>
      <xsl:attribute name="valueURI">
        <xsl:value-of select="$authorityURI" />
        <xsl:text>#Pub</xsl:text>
      </xsl:attribute>
    </mods:classification>
  </xsl:template>

</xsl:stylesheet>
