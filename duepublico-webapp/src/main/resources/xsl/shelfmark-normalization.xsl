<?xml version="1.0" encoding="ISO-8859-1"?>

<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:mods="http://www.loc.gov/mods/v3"
  exclude-result-prefixes="xsl mods">
  
  <xsl:template match="mods:shelfLocator" mode="normalize.shelfmark">
    <xsl:choose>
      <xsl:when test="contains(translate(text(),'ABCDEFGHIJKLMNOPQRSTUVWXYZ','AAAAAAAAAAAAAAAAAAAAAAAAAA'),'AAA')">
        <xsl:apply-templates select="." mode="normalize.book.shelfmark" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="." mode="normalize.journal.shelfmark" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="mods:shelfLocator" mode="normalize.book.shelfmark">
    <xsl:variable name="h1" select="translate(normalize-space(.),' ','')" />
    <xsl:variable name="h2" select="concat(translate(substring($h1,1,2),'0123456789',''),substring($h1,3))" />
    <xsl:choose>
      <xsl:when test="contains($h2,'+')">
        <xsl:value-of select="substring-before($h2,'+')" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$h2" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="mods:shelfLocator" mode="normalize.journal.shelfmark">
    <xsl:value-of select="substring(text(),1,1)" />
    <xsl:choose>
      <xsl:when test="substring(text(),2,1) != ' '">
        <xsl:text>+</xsl:text>
        <xsl:value-of select="translate(substring(text(),2),' ','+')" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="translate(substring(text(),3),' ','+')" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
