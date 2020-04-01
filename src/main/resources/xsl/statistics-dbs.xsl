<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:output method="text" />

  <xsl:template match="/">
    <xsl:variable name="numAccessPDF" select="sum(//object[@type='file'][contains(@path,'.pdf')]/num)" />
    <xsl:variable name="numPDF"      select="count(//object[@type='file'][contains(@path,'.pdf')])" />

    Zugriffe auf PDFs: <xsl:value-of select="$numAccessPDF" />
          Anzahl PDFs: <xsl:value-of select="$numPDF" />
  </xsl:template>

</xsl:stylesheet>