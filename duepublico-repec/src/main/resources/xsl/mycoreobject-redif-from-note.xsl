<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:mods="http://www.loc.gov/mods/v3"
  exclude-result-prefixes="xsl mods">

  <xsl:output method="text" encoding="UTF-8" media-type="text/plain" />

  <xsl:template match="/mycoreobject">
    <xsl:for-each select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods">
      <xsl:value-of select="translate(mods:note[@type='repec'],'&#13;','')" />
    </xsl:for-each>
  </xsl:template>

</xsl:stylesheet>