<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:mods="http://www.loc.gov/mods/v3"
  exclude-result-prefixes="xsl xlink mods">

  <xsl:output method="text" encoding="UTF-8" />

  <xsl:param name="generate" select="string(boolean(not(//mods:mods/mods:note[@type='repec'])))" />

  <xsl:param name="ServletsBaseURL" />
  <xsl:param name="WebApplicationBaseURL" />

  <xsl:param name="MCR.RePEc.ArchiveCode" />
  <xsl:param name="MCR.RePEc.ArchiveName" />
  <xsl:param name="MCR.RePEc.ArchiveMaintainer.EMail" />
  <xsl:param name="MCR.RePEc.ArchiveDescription" />

  <xsl:template match="/">
    <xsl:apply-templates select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods|repec-archive" />
  </xsl:template>

  <xsl:template match="/repec-archive">
    <xsl:call-template name="field">
      <xsl:with-param name="name">Template-Type</xsl:with-param>
      <xsl:with-param name="value">ReDIF-Archive 1.0</xsl:with-param>
    </xsl:call-template>
    <xsl:call-template name="field">
      <xsl:with-param name="name">Handle</xsl:with-param>
      <xsl:with-param name="value" select="concat('RePEc:',$MCR.RePEc.ArchiveCode)"/>
    </xsl:call-template>
    <xsl:call-template name="field">
      <xsl:with-param name="name">Name</xsl:with-param>
      <xsl:with-param name="value" select="$MCR.RePEc.ArchiveName"/>
    </xsl:call-template>
    <xsl:call-template name="field">
      <xsl:with-param name="name">Maintainer-Email</xsl:with-param>
      <xsl:with-param name="value" select="$MCR.RePEc.ArchiveMaintainer.EMail"/>
    </xsl:call-template>
    <xsl:if test="string-length($MCR.RePEc.ArchiveDescription) &gt; 0">
      <xsl:call-template name="field">
        <xsl:with-param name="name">Description</xsl:with-param>
        <xsl:with-param name="value" select="$MCR.RePEc.ArchiveDescription"/>
      </xsl:call-template>
    </xsl:if>
    <xsl:call-template name="field">
      <xsl:with-param name="name">URL</xsl:with-param>
      <xsl:with-param name="value" select="concat($WebApplicationBaseURL,'RePEc/',$MCR.RePEc.ArchiveCode,'/')"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="mods:mods[$generate='false']">
    <xsl:value-of select="translate(mods:note[@type='repec'],'&#13;','')" />
  </xsl:template>

  <xsl:template match="mods:mods[$generate='true']">
    <xsl:call-template name="field">
      <xsl:with-param name="name">Template-Type</xsl:with-param>
      <xsl:with-param name="value">ReDIF-Paper 1.0</xsl:with-param>
    </xsl:call-template>
    <xsl:apply-templates select="mods:name[@type='personal'][mods:role/mods:roleTerm='aut']" />
    <xsl:apply-templates select="mods:titleInfo[not(@altFormat)][1]" />
    <xsl:apply-templates select="mods:abstract[not(@altFormat)][1]" />
    <xsl:apply-templates select="mods:subject" />
    <xsl:apply-templates select="//mods:dateIssued[1]" />
    <xsl:apply-templates select="mods:identifier[@type='doi']" />
    <xsl:call-template name="files" />
    <xsl:call-template name="handle" />
  </xsl:template>

  <xsl:template match="mods:name">
    <xsl:apply-templates select="." mode="complete" />
    <xsl:apply-templates select="mods:namePart[@type='given'][1]" />
    <xsl:apply-templates select="mods:namePart[@type='family']" />
  </xsl:template>

  <xsl:template match="mods:name[mods:displayForm]" mode="complete">
    <xsl:call-template name="field">
      <xsl:with-param name="name">Author-Name</xsl:with-param>
      <xsl:with-param name="value" select="mods:displayForm" />
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="mods:name" mode="complete">
    <xsl:call-template name="field">
      <xsl:with-param name="name">Author-Name</xsl:with-param>
      <xsl:with-param name="value">
        <xsl:for-each select="mods:namePart[@type='given']">
          <xsl:value-of select="." />
          <xsl:text> </xsl:text>
        </xsl:for-each>
        <xsl:value-of select="mods:namePart[@type='family']" />
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="mods:namePart[@type='family']">
    <xsl:call-template name="field">
      <xsl:with-param name="name">Author-Name-Last</xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="mods:namePart[@type='given'][1]">
    <xsl:call-template name="field">
      <xsl:with-param name="name">Author-Name-First</xsl:with-param>
      <xsl:with-param name="value">
        <xsl:for-each select="../mods:namePart[@type='given']">
          <xsl:value-of select="." />
          <xsl:if test="position() != last()">
            <xsl:text> </xsl:text>
          </xsl:if>
        </xsl:for-each>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="mods:titleInfo">
    <xsl:call-template name="field">
      <xsl:with-param name="name">Title</xsl:with-param>
      <xsl:with-param name="value">
        <xsl:value-of select="mods:title" />
        <xsl:for-each select="mods:subTitle">
          <xsl:text>: </xsl:text>
          <xsl:value-of select="." />
        </xsl:for-each>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="mods:abstract">
    <xsl:call-template name="field">
      <xsl:with-param name="name">Abstract</xsl:with-param>
      <xsl:with-param name="value">
        <xsl:value-of select="translate(text(),'&#xa;&#xd;','  ')" />
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="mods:subject">
    <xsl:call-template name="field">
      <xsl:with-param name="name">Keywords</xsl:with-param>
      <xsl:with-param name="value">
        <xsl:for-each select="mods:topic">
          <xsl:value-of select="." />
          <xsl:if test="position() != last()">
            <xsl:text>, </xsl:text>
          </xsl:if>
        </xsl:for-each>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="mods:dateIssued">
    <xsl:call-template name="field">
      <xsl:with-param name="name">Creation-Date</xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="mods:identifier[@type='doi']">
    <xsl:call-template name="field">
      <xsl:with-param name="name">DOI</xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="files">
    <xsl:for-each select="/mycoreobject/structure/derobjects/derobject">
      <xsl:apply-templates select="document(concat('ifs:',@xlink:href,'/'))/mcr_directory/children/child[@type='file']" />
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="child">
    <xsl:call-template name="field">
      <xsl:with-param name="name">File-URL</xsl:with-param>
      <xsl:with-param name="value" select="concat($ServletsBaseURL,'MCRFileNodeServlet/',../../ownerID,'/',name)" />
    </xsl:call-template>
    <xsl:call-template name="field">
      <xsl:with-param name="name">File-Format</xsl:with-param>
      <xsl:with-param name="value" select="contentType" />
    </xsl:call-template>
    <xsl:call-template name="field">
      <xsl:with-param name="name">File-Size</xsl:with-param>
      <xsl:with-param name="value" select="size" />
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="handle">
    <xsl:call-template name="field">
      <xsl:with-param name="name">Handle</xsl:with-param>
      <xsl:with-param name="value">
        <xsl:text>RePEc:</xsl:text>
        <xsl:value-of select="$MCR.RePEc.ArchiveCode" />
        <xsl:text>:</xsl:text>
        <xsl:value-of select="number(substring-after(/mycoreobject/@ID,'_mods_'))" />
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="field">
    <xsl:param name="name" />
    <xsl:param name="value" select="." />

    <xsl:value-of select="$name" />
    <xsl:text>: </xsl:text>
    <xsl:value-of select="$value" />
    <xsl:text>&#xa;</xsl:text>
  </xsl:template>

  <xsl:template match="@*|node()" />

</xsl:stylesheet>