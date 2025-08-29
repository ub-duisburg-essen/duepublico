<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:output method="html" encoding="UTF-8" />

  <xsl:template match="/repec">
    <html>
      <body>
        <ul>
          <xsl:apply-templates select="node" />
        </ul>
      </body>
    </html>
  </xsl:template>
  
  <xsl:template match="node">
    <li>
      <a href="{@name}">
        <xsl:value-of select="@name" />
      </a>
    </li>
  </xsl:template>

</xsl:stylesheet>
