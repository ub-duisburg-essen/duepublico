<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:xalan="http://xml.apache.org/xalan"
  xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
  xmlns:mcr="http://www.mycore.org/"
  xmlns:mods="http://www.loc.gov/mods/v3"
  exclude-result-prefixes="xalan mcr i18n mods"
>

  <xsl:param name="MCR.RePEc.ArchiveCode" />

  <xsl:template match="mods:identifier[@type='repec']" mode="present">
    <xsl:variable name="handle">
      <xsl:text>RePEc:</xsl:text>
      <xsl:value-of select="$MCR.RePEc.ArchiveCode" />
      <xsl:text>:</xsl:text>
      <xsl:value-of select="." />
    </xsl:variable>
    <tr>
      <td valign="top" class="metaname">RePEc Handle:</td>
      <td class="metavalue">
        <a href="{$WebApplicationBaseURL}{translate($handle,':','/')}/">
          <xsl:value-of select="$handle" />
        </a>
      </td>
    </tr>
  </xsl:template>

</xsl:stylesheet>
