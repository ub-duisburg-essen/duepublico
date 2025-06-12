<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:mods="http://www.loc.gov/mods/v3"
  exclude-result-prefixes="xsl xlink mods">

  <xsl:param name="ServletsBaseURL" />
  <xsl:param name="WebApplicationBaseURL" />

  <xsl:param name="MCR.RePEc.ArchiveCode" />

  <xsl:template match="/">
    <redif>
      <xsl:for-each select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods">
        <field name="Template-Type">ReDIF-Paper 1.0</field>
        <xsl:apply-templates select="mods:name[@type='personal'][mods:role/mods:roleTerm='aut']" />
        <xsl:apply-templates select="mods:titleInfo[not(@altFormat)][1]" />
        <xsl:apply-templates select="mods:abstract[not(@altFormat)][1]" />
        <xsl:apply-templates select="mods:subject" />
        <xsl:apply-templates select="//mods:dateIssued[1]" />
        <xsl:apply-templates select="mods:identifier[@type='doi']" />
        <xsl:call-template name="files" />
        <xsl:call-template name="handle" />
      </xsl:for-each>
    </redif>
  </xsl:template>

  <xsl:template match="mods:name">
    <xsl:apply-templates select="." mode="complete" />
    <xsl:apply-templates select="mods:namePart[@type='given'][1]" />
    <xsl:apply-templates select="mods:namePart[@type='family']" />
  </xsl:template>

  <xsl:template match="mods:name[mods:displayForm]" mode="complete">
    <field name="Author-Name">
      <xsl:value-of select="mods:displayForm" />
    </field>
  </xsl:template>

  <xsl:template match="mods:name" mode="complete">
    <field name="Author-Name">
      <xsl:for-each select="mods:namePart[@type='given']">
        <xsl:value-of select="." />
        <xsl:text> </xsl:text>
      </xsl:for-each>
      <xsl:value-of select="mods:namePart[@type='family']" />
    </field>
  </xsl:template>

  <xsl:template match="mods:namePart[@type='family']">
    <field name="Author-Name-Last">
      <xsl:value-of select="." />
    </field>
  </xsl:template>

  <xsl:template match="mods:namePart[@type='given'][1]">
    <field name="Author-Name-First">
      <xsl:for-each select="../mods:namePart[@type='given']">
        <xsl:value-of select="." />
        <xsl:if test="position() != last()">
          <xsl:text> </xsl:text>
        </xsl:if>
      </xsl:for-each>
    </field>
  </xsl:template>

  <xsl:template match="mods:titleInfo">
    <field name="Title">
      <xsl:value-of select="mods:title" />
      <xsl:for-each select="mods:subTitle">
        <xsl:text>: </xsl:text>
        <xsl:value-of select="." />
      </xsl:for-each>
    </field>
  </xsl:template>

  <xsl:template match="mods:abstract">
    <field name="Abstract">
      <xsl:value-of select="translate(text(),'&#xa;&#xd;','  ')" />
    </field>
  </xsl:template>

  <xsl:template match="mods:subject">
    <field name="Keywords">
      <xsl:for-each select="mods:topic">
        <xsl:value-of select="." />
        <xsl:if test="position() != last()">
          <xsl:text>, </xsl:text>
        </xsl:if>
      </xsl:for-each>
    </field>
  </xsl:template>

  <xsl:template match="mods:dateIssued">
    <field name="Creation-Date">
      <xsl:value-of select="." />
    </field>
  </xsl:template>

  <xsl:template match="mods:identifier[@type='doi']">
    <field name="DOI">
      <xsl:value-of select="." />
    </field>
  </xsl:template>

  <xsl:template name="files">
    <xsl:for-each select="/mycoreobject/structure/derobjects/derobject">
      <xsl:apply-templates select="document(concat('ifs:',@xlink:href,'/'))/mcr_directory/children/child[@type='file']" />
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="mcr_directory/children/child[@type='file']">
    <field name="File-URL">
      <xsl:value-of select="concat($ServletsBaseURL,'MCRFileNodeServlet/',../../ownerID,'/',name)" />
    </field>
    <field name="File-Format">
      <xsl:value-of select="contentType" />
    </field>
    <field name="File-Size">
      <xsl:value-of select="size" />
    </field>
  </xsl:template>

  <xsl:template name="handle">
    <field name="Handle">
      <xsl:text>RePEc:</xsl:text>
      <xsl:value-of select="$MCR.RePEc.ArchiveCode" />
      <xsl:text>:</xsl:text>
      <xsl:value-of select="number(substring-after(/mycoreobject/@ID,'_mods_'))" />
    </field>
  </xsl:template>

  <xsl:template match="@*|node()" />

</xsl:stylesheet>