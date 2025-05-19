<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:mcrxml="xalan://org.mycore.common.xml.MCRXMLFunctions"
  xmlns:mcrdataurl="xalan://org.mycore.datamodel.common.MCRDataURL"
  exclude-result-prefixes="mcrxml mcrdataurl">

  <xsl:include href="copynodes.xsl" />
  <xsl:include href="editor/mods-node-utils.xsl" />

  <xsl:template match="mods:abstract[mcrxml:isHtml(text())]|mods:note[mcrxml:isHtml(text())]">
    <xsl:variable name="asXML">
      <xsl:apply-templates select="." mode="asXmlNode">
        <xsl:with-param name="ns" select="''" />
        <xsl:with-param name="serialize" select="true()" />
        <xsl:with-param name="levels">1</xsl:with-param>
      </xsl:apply-templates>
    </xsl:variable>
    <xsl:call-template name="copy-as-plain-text" /> 
    <xsl:call-template name="copy-as-encoded-xml">
      <xsl:with-param name="text" select="string($asXML)" />
    </xsl:call-template> 
  </xsl:template>
  
  <xsl:template match="mods:titleInfo[mcrxml:isHtml(mods:title/text()) or mcrxml:isHtml(mods:subTitle/text())]">
    <xsl:variable name="asXML">
      <xsl:apply-templates select="." mode="asXmlNode">
        <xsl:with-param name="ns" select="''" />
        <xsl:with-param name="serialize" select="true()" />
        <xsl:with-param name="levels">2</xsl:with-param>
      </xsl:apply-templates>
    </xsl:variable>
    <xsl:call-template name="copy-as-plain-text" /> 
    <xsl:call-template name="copy-as-encoded-xml">
      <xsl:with-param name="text" select="string($asXML)" />
    </xsl:call-template> 
  </xsl:template>

  <xsl:template name="copy-as-plain-text">
    <xsl:copy>
      <xsl:call-template name="set-common-attributes" /> 
      <xsl:apply-templates mode="asPlainTextNode" />
    </xsl:copy>
  </xsl:template>
  
  <xsl:template name="copy-as-encoded-xml">
    <xsl:param name="text" />
    <xsl:copy>
      <xsl:call-template name="set-common-attributes" /> 
      <xsl:attribute name="contentType">text/xml</xsl:attribute>
      <xsl:attribute name="altFormat">
        <xsl:value-of select="mcrdataurl:build($text, 'base64', 'text/xml', 'utf-8')" />
      </xsl:attribute>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template name="set-common-attributes">
    <xsl:apply-templates select="@*" />
    <xsl:attribute name="altRepGroup">
      <xsl:value-of select="generate-id(.)" />
    </xsl:attribute>
  </xsl:template>
  
</xsl:stylesheet>
