<?xml version="1.0" encoding="UTF-8"?>

<!-- Re-links related items after migrating from miless. Use "xslt [ID] with xsl/relink-related-items" command -->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mcr="xalan://org.mycore.common.xml.MCRXMLFunctions"
  xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation" xmlns:mods="http://www.loc.gov/mods/v3" xmlns:xlink="http://www.w3.org/1999/xlink"
  exclude-result-prefixes="i18n mcr mods xlink">

  <xsl:include href="copynodes.xsl" />

  <xsl:template match="mods:relatedItem[mods:identifier[@type='duepublico']]">
    <xsl:variable name="id1" select="mods:identifier[@type='duepublico']" />
    <xsl:variable name="id2" select="substring(concat('00000000',$id1),string-length($id1)+1,8)" />
    <xsl:variable name="id3" select="concat('duepublico_mods_',$id2)" />

    <xsl:choose>
      <xsl:when test="@type='succeeding'" />
      <xsl:when test="@type='constituent'" />
      <xsl:when test="@type='isReferencedBy'" />
      <xsl:when test="document(concat('notnull:mcrobject:',$id3))/mycoreobject">
        <xsl:copy>
          <xsl:apply-templates select="@*" />
          <xsl:attribute name="xlink:type">simple</xsl:attribute>
          <xsl:attribute name="xlink:href">
            <xsl:value-of select="$id3" />
          </xsl:attribute>
        </xsl:copy>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="." />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
