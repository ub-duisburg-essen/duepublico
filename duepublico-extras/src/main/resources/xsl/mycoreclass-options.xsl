<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:str="http://exslt.org/strings"
  exclude-result-prefixes="xsl str"
>

  <xsl:param name="CurrentLang" />
  <xsl:param name="DefaultLang" />
  <xsl:param name="includeClassID" />

  <xsl:variable name="nbsp" select="'&#160;'" />
  <xsl:variable name="arrow" select="'&#187;'" />
  <xsl:variable name="parentChildDelimiter" select="concat($nbsp,$arrow,' ')" />

  <xsl:variable name="classID" select="/mycoreclass/@ID" />

  <xsl:template match="/mycoreclass">
    <includes>
      <xsl:apply-templates select="categories/category" />
    </includes>
  </xsl:template>
  
  <xsl:template match="category">
    <xsl:param name="parentTitle" />
    <xsl:param name="indent" />
    <xsl:param name="level" select="1" />
    
    <xsl:variable name="label">
      <xsl:apply-templates select="." mode="label" />
    </xsl:variable>
    
    <xsl:variable name="title">
      <xsl:if test="$level &gt; 1">
        <xsl:value-of select="concat($parentTitle,$parentChildDelimiter)" />
      </xsl:if>
      <xsl:value-of select="$label" />
    </xsl:variable>
    
    <xsl:choose>
      <xsl:when test="label[lang('x-group')]">

        <optgroup label="{$label}">
          <xsl:apply-templates select="category">
            <xsl:with-param name="level" select="$level + 1" />
            <xsl:with-param name="parentTitle" select="$title" />
            <xsl:with-param name="indent" select="concat($indent,$nbsp,$nbsp,$nbsp,$nbsp)" />
          </xsl:apply-templates>
        </optgroup>

      </xsl:when>
      <xsl:otherwise>

        <option>
          <xsl:attribute name="value">
            <xsl:if test="$includeClassID='true'">
              <xsl:value-of select="concat($classID,':')" />
            </xsl:if>
            <xsl:value-of select="@ID" />
          </xsl:attribute>
          
          <xsl:if test="$level &gt; 1">
            <xsl:attribute name="data-subtext">
              <xsl:value-of select="concat($nbsp,$nbsp,'in ',$parentTitle)" />
            </xsl:attribute>
          </xsl:if>
        
          <xsl:value-of select="$indent" />
          <xsl:value-of select="$label" />
        </option>

        <xsl:apply-templates select="category">
          <xsl:with-param name="level" select="$level + 1" />
          <xsl:with-param name="parentTitle" select="$title" />
          <xsl:with-param name="indent" select="concat($indent,$nbsp,$nbsp,$nbsp,$nbsp)" />
        </xsl:apply-templates>

      </xsl:otherwise>
    </xsl:choose>
    
   
  </xsl:template>
  
  <xsl:template match="category" mode="label">
    <xsl:choose>
      <xsl:when test="label[lang($CurrentLang)]">
        <xsl:value-of select="label[lang($CurrentLang)]/@text" />
      </xsl:when>
      <xsl:when test="label[lang($DefaultLang)]">
        <xsl:value-of select="label[lang($DefaultLang)]/@text" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="label[not(starts-with(@lang,'x-'))][1]/@text" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>