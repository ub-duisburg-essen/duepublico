<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:include href="resource:xsl/copynodes.xsl" />
  
  <xsl:param name="CurrentLang" />

  <xsl:template match="/webpage">
    <MyCoReWebPage>
      <xsl:copy-of select="@id" />
      <xsl:apply-templates select="title[lang($CurrentLang) or lang('all') or not(@xml:lang)]" />
      <xsl:apply-templates select="section[lang($CurrentLang) or lang('all') or not(@xml:lang)]" />
    </MyCoReWebPage>
  </xsl:template>
  
  <xsl:template match="/webpage/title">
    <section>
      <xsl:copy-of select="@xml:lang" />
      <xsl:attribute name="title">
        <xsl:value-of select="text()" />
      </xsl:attribute>
    </section>
  </xsl:template>

  <xsl:template match="section[not(@xml:lang)]">
    <xsl:copy>
      <xsl:attribute name="xml:lang">all</xsl:attribute>
      <xsl:apply-templates />
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
