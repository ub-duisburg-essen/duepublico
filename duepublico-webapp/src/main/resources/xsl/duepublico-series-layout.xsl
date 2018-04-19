<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:mcr="xalan://org.mycore.common.xml.MCRXMLFunctions"
  xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  exclude-result-prefixes="i18n mcr mods xlink"
>
  <xsl:import href="xslImport:modsmeta:duepublico-series-layout.xsl" />
  
  <xsl:param name="WebApplicationBaseURL" />
  <xsl:param name="CurrentLang" />
  
  <xsl:template match="/">
    <xsl:for-each select="/mycoreobject">
      <xsl:choose>
        <xsl:when test="metadata/def.modsContainer/modsContainer/mods:mods/mods:relatedItem[@type='host']">
          <xsl:apply-templates select="metadata/def.modsContainer/modsContainer/mods:mods/mods:relatedItem[@type='host']" mode="seriesLayout" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="." mode="seriesLayout" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
    <xsl:apply-imports />
  </xsl:template>
  
  <xsl:template match="mods:relatedItem[@type='host'][@xlink:href]" mode="seriesLayout">
    <xsl:choose>
      <xsl:when test="mods:relatedItem[@type='host'][@xlink:href]">
        <xsl:apply-templates select="mods:relatedItem[@type='host'][@xlink:href]" mode="seriesLayout" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="document(concat('notnull:mcrobject:',@xlink:href))/mycoreobject" mode="seriesLayout" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="mycoreobject" mode="seriesLayout">
    <xsl:apply-templates select="structure/derobjects/derobject[1]/@xlink:href" mode="seriesLayout" />
  </xsl:template>

  <xsl:template match="derobject/@xlink:href" mode="seriesLayout">
    <xsl:apply-templates select="document(concat('notnull:mcrfile:',.,'/navigation.xml'))/item" mode="seriesLayout" />
  </xsl:template>
  
  <xsl:template match="/item" mode="seriesLayout">
    <div id="mir-message">
      <xsl:apply-templates select="@banner" mode="seriesLayout" />
      <ul>
        <xsl:apply-templates select="item" mode="seriesLayout" />
      </ul>
    </div>
  </xsl:template>
  
  <xsl:template match="item/item" mode="seriesLayout">
    <li>
      <a href="{$WebApplicationBaseURL}{@ref}">
        <xsl:value-of select="label[lang($CurrentLang)]" />
      </a>
    </li>
  </xsl:template>

  <xsl:template match="item/@banner" mode="seriesLayout">
    <img src="{$WebApplicationBaseURL}{.}" />
  </xsl:template>

</xsl:stylesheet>
