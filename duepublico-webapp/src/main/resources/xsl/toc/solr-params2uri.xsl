<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:encoder="xalan://java.net.URLEncoder"
>
 
  <xsl:template match="/solr-params">
    <uri>
      <xsl:text>solr:</xsl:text>
      <xsl:for-each select="param">
        <xsl:apply-templates select="." />
        <xsl:if test="position() != last()">&amp;</xsl:if>
      </xsl:for-each>
    </uri>
  </xsl:template>
  
  <xsl:template match="param">
    <xsl:value-of select="@name" />
    <xsl:text>=</xsl:text>
    <xsl:value-of select="encoder:encode(.,'UTF-8')" />
  </xsl:template>
  
  <xsl:template match="param[contains(@name,'json')]">
    <xsl:value-of select="@name" />
    <xsl:text>=</xsl:text>
    <xsl:variable name="json">
      <xsl:text>{</xsl:text>
      <xsl:apply-templates select="*" mode="xml2json" />
      <xsl:text>}</xsl:text>
    </xsl:variable>
    <xsl:value-of select="encoder:encode($json,'UTF-8')" />
  </xsl:template>

  <xsl:template match="*" mode="xml2json">
    <xsl:text>"</xsl:text>
    <xsl:value-of select="name()" />
    <xsl:text>":</xsl:text>
    
    <xsl:choose>
    
      <xsl:when test="*">
        <xsl:text>{</xsl:text>
        <xsl:apply-templates select="*" mode="xml2json" />
        <xsl:text>}</xsl:text>
      </xsl:when>
      
      <xsl:when test="string(number(text())) != 'NaN'">
        <xsl:value-of select="text()" />
      </xsl:when>
      
      <xsl:otherwise>
        <xsl:text>"</xsl:text>
        <xsl:value-of select="text()" />
        <xsl:text>"</xsl:text>
      </xsl:otherwise>
      
    </xsl:choose>
    
    <xsl:if test="position() != last()">
      <xsl:text>,</xsl:text>
    </xsl:if> 
    
  </xsl:template>
  
</xsl:stylesheet>
