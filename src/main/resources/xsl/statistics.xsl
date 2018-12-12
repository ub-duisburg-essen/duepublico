<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xalan="http://xml.apache.org/xalan"
  xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
  exclude-result-prefixes="xsl xalan i18n"
>

<xsl:param name="ServletsBaseURL" />
<xsl:param name="WebApplicationBaseURL" />

<xsl:variable name="base.loggedMonth" select="/statistics/loggedMonth"/>

<xsl:template match="/statistics">
  <site>
    <xsl:attribute name="title">
      <xsl:call-template name="title" />
    </xsl:attribute>

    <h3>
      <xsl:call-template name="title" />
    </h3>

    <xsl:apply-templates select="min" />
    <xsl:call-template name="choose" />
  
    <xsl:apply-templates select="object[@type='document']" mode="table">
      <xsl:sort select="@id" data-type="number" />
    </xsl:apply-templates>
  </site>
  
</xsl:template>

<xsl:template name="title">
  <xsl:value-of select="i18n:translate('statistics.title')" />
  <xsl:text> </xsl:text>
  <xsl:value-of select="substring-before(substring-after(loggedMonth[1]/@first,' '),' ')" />
  <xsl:text> - </xsl:text>
  <xsl:value-of select="substring-before(substring-after(loggedMonth[position()=last()]/@last,' '),' ')" />
</xsl:template>

<xsl:template match="min">
  <p>
    <xsl:value-of select="i18n:translate('statistics.min',concat(@month,'/',@year))" />
  </p>
</xsl:template>

<xsl:template name="choose">
  <xsl:if test="@updatable='true'">
    <form action="StatisticsServlet" method="get" class="form-inline">
      <input type="hidden" name="id" value="{object[@type='document']/@id}" />
      <div class="form-group">
        <label>
          <xsl:value-of select="i18n:translate('statistics.period')" />
          <xsl:text>: </xsl:text>
        </label>
        <xsl:call-template name="selects">
          <xsl:with-param name="var" select="'from'" />
          <xsl:with-param name="loggedMonth" select="loggedMonth[1]" />
        </xsl:call-template>
        <label> - </label>
        <xsl:call-template name="selects">
          <xsl:with-param name="var" select="'to'" />
          <xsl:with-param name="loggedMonth" select="loggedMonth[position() = last()]" />
        </xsl:call-template>
      </div>
      <button type="submit" class="btn btn-default">
        <xsl:value-of select="i18n:translate('statistics.show')" />
      </button>
    </form>
  </xsl:if>
</xsl:template>
 
<xsl:template name="selects">
  <xsl:param name="var" />
  <xsl:param name="loggedMonth" />

  <xsl:variable name="nodes" select="//node()|//*/@*" />
  <select name="{$var}Month" class="form-control">
    <xsl:for-each select="$nodes[position() &lt; 13]">
      <option value="{position()}">
        <xsl:if test="number($loggedMonth/@month) = position()">
          <xsl:attribute name="selected">selected</xsl:attribute>
        </xsl:if>
        <xsl:if test="position() &lt; 10">0</xsl:if>
        <xsl:value-of select="position()" />
      </option>
    </xsl:for-each>
  </select>
  <xsl:variable name="numYears" select="now/@year - min/@year + 1" />
  <select name="{$var}Year" class="form-control">
    <xsl:for-each select="$nodes[position() &lt;= $numYears]">
      <xsl:variable name="currentYear" select="position() - 1 + /statistics/min/@year" />
      <option value="{$currentYear}">
        <xsl:if test="$loggedMonth/@year = $currentYear">
          <xsl:attribute name="selected">selected</xsl:attribute>
        </xsl:if>
        <xsl:value-of select="$currentYear" />
      </option>
    </xsl:for-each>
  </select>
</xsl:template>

<xsl:template match="object[@type='document']" mode="table">
  <table class="table table-bordered table-condensed table-hover">
    <xsl:call-template name="table.headers" />
    <xsl:apply-templates select="." mode="data" />
  </table>
</xsl:template>

<xsl:template name="table.headers">
  <tr>
    <th scope="col">
      <xsl:value-of select="i18n:translate('statistics.accesses')" />
      <xsl:text>:</xsl:text>
    </th>
    <xsl:if test="count($base.loggedMonth) &gt; 1">
      <th scope="col" class="text-right">
        <xsl:value-of select="i18n:translate('statistics.sum')" />
        <xsl:text>:</xsl:text>
      </th>
    </xsl:if>
    <xsl:for-each select="/statistics/loggedMonth">
      <xsl:sort order="descending" data-type="number" select="position()"/>
      <th scope="col" class="text-right">
        <xsl:value-of select="@month" />/<xsl:value-of select="@year" />:<xsl:text />
      </th>
    </xsl:for-each>
  </tr>
</xsl:template>

<xsl:template match="object[@type='document']" mode="data">
  <xsl:variable name="nr" select="number(substring-after(@id,'_mods_'))" />
  <xsl:call-template name="data">
    <xsl:with-param name="nodes" select="num|object[@type='derivate']/num|object[@type='derivate']/object[@type='file']/num" />
    <xsl:with-param name="label" select="concat(i18n:translate('statistics.document'),' ',$nr,' ',i18n:translate('statistics.overall'))" />
  </xsl:call-template>
  <xsl:call-template name="data">
    <xsl:with-param name="nodes" select="num" />
    <xsl:with-param name="label" select="concat(i18n:translate('statistics.document'),' ',$nr,' ',i18n:translate('statistics.metadata'))" />
    <xsl:with-param name="link"  select="concat($WebApplicationBaseURL,'receive/',@id)" />
  </xsl:call-template>
  <xsl:call-template name="data">
    <xsl:with-param name="nodes" select="object[@type='derivate']/object[@type='file']/num" />
    <xsl:with-param name="label" select="concat(i18n:translate('statistics.document'),' ',$nr,' ',i18n:translate('statistics.files'))" />
  </xsl:call-template>

  <xsl:apply-templates select="object[@type='derivate'][num|object[@type='file']/num]" />
</xsl:template>

<xsl:template match="object[@type='derivate']">
  <xsl:variable name="nr" select="number(substring-after(@id,'_derivate_'))" />
  <xsl:call-template name="data">
    <xsl:with-param name="nodes" select="object[@type='file']/num" />
    <xsl:with-param name="label" select="concat(i18n:translate('statistics.filespace'),' ',$nr,' ',i18n:translate('statistics.overall'))" />
  </xsl:call-template>

  <xsl:apply-templates select="object[@type='file']">
    <xsl:sort select="@path" />
  </xsl:apply-templates>
</xsl:template>

<xsl:template match="object[@type='file']">
  <xsl:variable name="nr" select="number(substring-after(../@id,'_derivate_'))" />
  <xsl:call-template name="data">
    <xsl:with-param name="nodes" select="num" />
    <xsl:with-param name="label" select="concat(i18n:translate('statistics.file'),' ',$nr,'/',@path)" />
    <xsl:with-param name="link" select="concat($ServletsBaseURL,'MCRFileNodeServlet/',../@id,'/',@path)" />
  </xsl:call-template>
</xsl:template>

<xsl:template name="data">
  <xsl:param name="nodes" />
  <xsl:param name="label" />
  <xsl:param name="link" />

  <tr>
    <th scope="row" class="text-nowrap">
      <xsl:choose>
        <xsl:when test="string-length($link) &gt; 0">
          <a href="{$link}"><xsl:value-of select="$label" /></a>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$label" />
        </xsl:otherwise>
      </xsl:choose>
    </th>
    <xsl:if test="count(/statistics/loggedMonth) &gt; 1">
      <td class="text-right">
        <xsl:value-of select="sum($nodes)" />
      </td>
    </xsl:if>
    <xsl:for-each select="/statistics/loggedMonth">
      <xsl:sort order="descending" data-type="number" select="position()"/>
      <td class="text-right">
        <xsl:variable name="num" select="sum($nodes[(@year=current()/@year) and (@month=current()/@month)])" />
        <xsl:choose>
          <xsl:when test="string-length($num) &gt; 0">
            <xsl:value-of select="$num" />
          </xsl:when>
          <xsl:otherwise>0</xsl:otherwise>
        </xsl:choose>
      </td>
    </xsl:for-each>
  </tr>
</xsl:template>

</xsl:stylesheet>
