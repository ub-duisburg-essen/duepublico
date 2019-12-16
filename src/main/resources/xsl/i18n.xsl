<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:i="http://www.mycore.org/i18n"
  exclude-result-prefixes="xsl i">

  <xsl:include href="copynodes.xsl" />
  
  <xsl:param name="CurrentLang" />
  
  <xsl:template match="i:*">
    <xsl:if test="$CurrentLang=local-name()">
      <xsl:apply-templates select="text()|*" />
    </xsl:if>
  </xsl:template>

  <xsl:template match="@*[starts-with(.,'|')][contains(.,':')]">
    <xsl:attribute name="{name()}">
      <xsl:value-of select="substring-before(substring-after(.,concat('|',$CurrentLang,':')),'|')" />
    </xsl:attribute>
  </xsl:template>

</xsl:stylesheet>
