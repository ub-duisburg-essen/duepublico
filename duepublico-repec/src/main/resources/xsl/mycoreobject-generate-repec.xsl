<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:mods="http://www.loc.gov/mods/v3"
  exclude-result-prefixes="xsl xlink mods">

  <xsl:param name="ServletsBaseURL" />
  <xsl:param name="WebApplicationBaseURL" />

  <xsl:param name="MCR.RePEc.ArchiveCode" />

  <xsl:include href="copynodes.xsl" />

  <xsl:template match="mods:mods">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" />
      <xsl:if test="not(mods:extension[@displayLabel='RePEc Metadata'])">
        <mods:extension displayLabel="RePEc Metadata" generated="true">
          <xsl:text>Template-Type: ReDIF-Paper 1.0&#xa;</xsl:text>
          <xsl:apply-templates select="mods:name[@type='personal'][mods:role/mods:roleTerm='aut']" mode="generate" />
          <xsl:apply-templates select="mods:titleInfo[not(@altFormat)][1]" mode="generate" />
          <xsl:apply-templates select="mods:abstract[not(@altFormat)][1]" mode="generate" />
          <xsl:apply-templates select="mods:subject" mode="generate" />
          <xsl:apply-templates select="//mods:dateIssued[1]" mode="generate" />
          <xsl:apply-templates select="mods:identifier[@type='doi']" mode="generate" />
          <xsl:call-template name="files" />
          <xsl:call-template name="handle" />
        </mods:extension>
      </xsl:if>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="mods:name" mode="generate">
    <xsl:apply-templates select="." mode="complete" />
    <xsl:apply-templates select="mods:namePart[@type='given'][1]" mode="generate" />
    <xsl:apply-templates select="mods:namePart[@type='family']" mode="generate" />
  </xsl:template>

  <xsl:template match="mods:name[mods:displayForm]" mode="complete">
    <xsl:text>Author-Name: </xsl:text>
    <xsl:value-of select="mods:displayForm" />
    <xsl:text>&#xa;</xsl:text>
  </xsl:template>

  <xsl:template match="mods:name" mode="complete">
    <xsl:text>Author-Name: </xsl:text>
    <xsl:for-each select="mods:namePart[@type='given']">
      <xsl:value-of select="." />
      <xsl:text> </xsl:text>
    </xsl:for-each>
    <xsl:value-of select="mods:namePart[@type='family']" />
    <xsl:text>&#xa;</xsl:text>
  </xsl:template>

  <xsl:template match="mods:namePart[@type='family']" mode="generate">
    <xsl:text>Author-Name-Last: </xsl:text>
    <xsl:value-of select="." />
    <xsl:text>&#xa;</xsl:text>
  </xsl:template>

  <xsl:template match="mods:namePart[@type='given'][1]" mode="generate">
    <xsl:text>Author-Name-First: </xsl:text>
    <xsl:for-each select="../mods:namePart[@type='given']">
      <xsl:value-of select="." />
      <xsl:if test="position() != last()">
        <xsl:text> </xsl:text>
      </xsl:if>
    </xsl:for-each>
    <xsl:text>&#xa;</xsl:text>
  </xsl:template>

  <xsl:template match="mods:titleInfo" mode="generate">
    <xsl:text>Title: </xsl:text>
    <xsl:value-of select="mods:title" />
    <xsl:for-each select="mods:subTitle">
      <xsl:text>: </xsl:text>
      <xsl:value-of select="." />
    </xsl:for-each>
    <xsl:text>&#xa;</xsl:text>
  </xsl:template>

  <xsl:template match="mods:abstract" mode="generate">
    <xsl:text>Abstract: </xsl:text>
    <xsl:value-of select="translate(text(),'&#xa;&#xd;','  ')" />
    <xsl:text>&#xa;</xsl:text>
  </xsl:template>

  <xsl:template match="mods:subject" mode="generate">
    <xsl:text>Keywords: </xsl:text>
    <xsl:for-each select="mods:topic">
      <xsl:value-of select="." />
      <xsl:if test="position() != last()">
        <xsl:text>, </xsl:text>
      </xsl:if>
    </xsl:for-each>
    <xsl:text>&#xa;</xsl:text>
  </xsl:template>

  <xsl:template match="mods:dateIssued" mode="generate">
    <xsl:text>Creation-Date: </xsl:text>
    <xsl:value-of select="." />
    <xsl:text>&#xa;</xsl:text>
  </xsl:template>

  <xsl:template match="mods:identifier[@type='doi']" mode="generate">
    <xsl:text>DOI: </xsl:text>
    <xsl:value-of select="." />
    <xsl:text>&#xa;</xsl:text>
  </xsl:template>

  <xsl:template name="files">
    <xsl:for-each select="/mycoreobject/structure/derobjects/derobject">
      <xsl:apply-templates select="document(concat('ifs:',@xlink:href,'/'))/mcr_directory/children/child[@type='file']" mode="generate" />
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="mcr_directory/children/child[@type='file']" mode="generate">
    <xsl:text>File-URL: </xsl:text>
    <xsl:value-of select="concat($ServletsBaseURL,'MCRFileNodeServlet/',../../ownerID,'/',name)" />
    <xsl:text>&#xa;</xsl:text>
    
    <xsl:text>File-Format: </xsl:text>
    <xsl:value-of select="contentType" />
    <xsl:text>&#xa;</xsl:text>

    <xsl:text>File-Size: </xsl:text>
    <xsl:value-of select="size" />
    <xsl:text>&#xa;</xsl:text>
  </xsl:template>

  <xsl:template name="handle">
    <xsl:text>Handle: RePEc:</xsl:text>
    <xsl:value-of select="$MCR.RePEc.ArchiveCode" />
    <xsl:text>:</xsl:text>
    <xsl:value-of select="number(substring-after(/mycoreobject/@ID,'_mods_'))" />
    <xsl:text>&#xa;</xsl:text>
  </xsl:template>

</xsl:stylesheet>