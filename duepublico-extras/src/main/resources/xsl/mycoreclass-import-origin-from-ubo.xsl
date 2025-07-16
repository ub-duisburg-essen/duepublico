<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- transform ORIGIN to mir_institutes classification suitable for DuEPublico -->

  <xsl:output method="xml" indent="yes" />

  <xsl:include href="copynodes.xsl" />

  <xsl:template match="/mycoreclass">
    <xsl:copy>
      <xsl:apply-templates select="@*" />
      <xsl:apply-templates select="label" />
      <label xml:lang="x-uri" text="https://duepublico.uni-due.de/api/v1/classifications/mir_institutes" />
      <xsl:apply-templates select="categories" />
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="mycoreclass/@ID">
    <xsl:attribute name="ID">mir_institutes</xsl:attribute>
  </xsl:template>
  
  <xsl:template match="label[@xml:lang='x-mapping']" />
  
</xsl:stylesheet>