<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:output method="html" encoding="UTF-8" />

  <xsl:param name="MCR.RePEc.ArchiveCode" />

  <xsl:param name="Mode" />

  <xsl:template match="/">
    <html>
      <body>
        <ul>
          <xsl:apply-templates select="*" />
        </ul>
      </body>
    </html>
  </xsl:template>

  <xsl:template match="/repec-root">
   <xsl:call-template name="dir">
      <xsl:with-param name="name" select="$MCR.RePEc.ArchiveCode" />
   </xsl:call-template>
  </xsl:template>

  <xsl:template match="/response[$Mode='archive']">
    <xsl:call-template name="file">
      <xsl:with-param name="name" select="concat($MCR.RePEc.ArchiveCode,'arch')" />
    </xsl:call-template>
    <xsl:call-template name="file">
      <xsl:with-param name="name" select="concat($MCR.RePEc.ArchiveCode,'seri')" />
    </xsl:call-template>
    <xsl:for-each select="result/doc">
      <xsl:call-template name="dir" />
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="/response[$Mode='series']">
    <xsl:for-each select="result/doc">
      <xsl:call-template name="file" />
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="file">
    <xsl:param name="name" select="str[@name='id']" />

    <xsl:variable name="file" select="concat($name,'.redif')" />
    <li>
      <a href="{$file}">
        <xsl:value-of select="$file" />
      </a>
    </li>
  </xsl:template>

  <xsl:template name="dir">
    <xsl:param name="name" select="str[@name='repecID']" />

    <li>
      <a href="{$name}/">
        <xsl:value-of select="$name" />
      </a>
    </li>
  </xsl:template>

</xsl:stylesheet>
