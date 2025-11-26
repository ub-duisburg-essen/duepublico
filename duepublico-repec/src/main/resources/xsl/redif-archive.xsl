<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" exclude-result-prefixes="xsl">

  <xsl:param name="WebApplicationBaseURL" />

  <xsl:param name="MCR.RePEc.ArchiveCode" />
  <xsl:param name="MCR.RePEc.ArchiveName" />
  <xsl:param name="MCR.RePEc.ArchiveMaintainer.EMail" />
  <xsl:param name="MCR.RePEc.ArchiveDescription" />

  <xsl:template match="/redif-archive">
    <redif>
      <field name="Template-Type">ReDIF-Archive 1.0</field>
      <field name="Handle">
        <xsl:value-of select="concat('RePEc:',$MCR.RePEc.ArchiveCode)" />
      </field>
      <field name="Name">
        <xsl:value-of select="$MCR.RePEc.ArchiveName"/>
      </field>
      <field name="Maintainer-Email">
        <xsl:value-of select="$MCR.RePEc.ArchiveMaintainer.EMail"/>
      </field>
      <xsl:if test="string-length($MCR.RePEc.ArchiveDescription) &gt; 0">
        <field name="Description">
          <xsl:value-of select="$MCR.RePEc.ArchiveDescription"/>
        </field>
      </xsl:if>
      <field name="URL">
        <xsl:value-of select="concat($WebApplicationBaseURL,'RePEc/',$MCR.RePEc.ArchiveCode,'/')"/>
      </field>
    </redif>
  </xsl:template>

</xsl:stylesheet>