<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:mods="http://www.loc.gov/mods/v3"
  exclude-result-prefixes="xsl xlink mods">

  <xsl:output method="text" encoding="UTF-8" />

  <xsl:template match="/redif">
    <xsl:apply-templates select="field" />
  </xsl:template>
  
  <xsl:template name="field">
    <xsl:value-of select="@name" />
    <xsl:text>: </xsl:text>
    <xsl:value-of select="text()" />
    <xsl:text>&#xa;</xsl:text>
  </xsl:template>

</xsl:stylesheet>