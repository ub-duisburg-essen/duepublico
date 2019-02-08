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

<xsl:variable name="dateFrom" select="substring-before(substring-after(/statistics/loggedMonth[1]/@first,' '),' ')" />
<xsl:variable name="dateTo" select="substring-before(substring-after(/statistics/loggedMonth[position()=last()]/@last,' '),' ')" />

<xsl:variable name="title">
  <xsl:value-of select="i18n:translate('statistics.title')" />
  <xsl:text> </xsl:text>
  <xsl:value-of select="$dateFrom" />
  <xsl:text> - </xsl:text>
  <xsl:value-of select="$dateFrom" />
</xsl:variable>

<xsl:template match="/statistics">
  <site title="{$title}">

    <div class="panel panel-default">
      <div class="panel-heading">
        <h3 class="panel-title">
          <xsl:value-of select="$title" />
        </h3>
      </div>
      <div class="panel-body">
        <xsl:apply-templates select="min" />
        <xsl:call-template name="choose" />
      </div>
    </div>

    <xsl:apply-templates select="object[@type='document']" mode="chart" />
    <xsl:apply-templates select="object[@type='document']" mode="table" />
  </site>
</xsl:template>

<xsl:template match="min">
  <p>
    <xsl:value-of select="i18n:translate('statistics.min',concat(@month,'/',@year))" />
  </p>
</xsl:template>

<xsl:template name="choose">
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
      <label>&#160;&#8212;&#160;</label>
      <xsl:call-template name="selects">
        <xsl:with-param name="var" select="'to'" />
        <xsl:with-param name="loggedMonth" select="loggedMonth[position() = last()]" />
      </xsl:call-template>
    </div>
    <button type="submit" class="btn btn-default">
      <xsl:value-of select="i18n:translate('statistics.show')" />
    </button>
  </form>
</xsl:template>
 
<xsl:template name="selects">
  <xsl:param name="var" />
  <xsl:param name="loggedMonth" />

  <xsl:variable name="nodes" select="//node()|//*/@*" />
  <select name="{$var}Month" class="form-control" style="margin:1ex;">
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
  <select name="{$var}Year" class="form-control" style="margin:1ex;">
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
  <div class="table-responsive" style="margin-top:2ex;">
    <table class="table table-bordered table-condensed table-hover">
      <xsl:call-template name="table.headers" />
      <xsl:call-template name="table.body" />
    </table>
  </div>
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

<xsl:template name="table.body">
  <xsl:variable name="oid" select="number(substring-after(@id,'_mods_'))" />

  <!-- Sum of access to metadata and all files of all derivates -->
  <xsl:call-template name="data-row">
    <xsl:with-param name="label" select="concat(i18n:translate('statistics.document'),' ',$oid,' ',i18n:translate('statistics.overall'))" />
    <xsl:with-param name="nodes" select="num|object[@type='derivate']/num|object[@type='derivate']/object[@type='file']/num" />
  </xsl:call-template>

  <!-- Access to metadata only -->
  <xsl:call-template name="data-row">
    <xsl:with-param name="label" select="concat(i18n:translate('statistics.document'),' ',$oid,' ',i18n:translate('statistics.metadata'))" />
    <xsl:with-param name="link"  select="concat($WebApplicationBaseURL,'receive/',@id)" />
    <xsl:with-param name="nodes" select="num" />
  </xsl:call-template>

  <!-- Sum of all files of all derivates -->
  <xsl:if test="count(object[@type='derivate']) &gt; 1">
    <xsl:call-template name="data-row">
      <xsl:with-param name="label" select="concat(i18n:translate('statistics.document'),' ',$oid,' ',i18n:translate('statistics.files'))" />
      <xsl:with-param name="nodes" select="object[@type='derivate']/object[@type='file']/num" />
    </xsl:call-template>
  </xsl:if>

  <!-- For each derivate -->
  <xsl:for-each select="object[@type='derivate'][num|object[@type='file']/num]">
    <xsl:variable name="did" select="number(substring-after(@id,'_derivate_'))" />

    <!-- Sum of all files in this derivate -->
    <xsl:if test="count(object[@type='file']) &gt; 1">
      <xsl:call-template name="data-row">
        <xsl:with-param name="label" select="concat(i18n:translate('statistics.filespace'),' ',$did,' ',i18n:translate('statistics.overall'))" />
        <xsl:with-param name="nodes" select="object[@type='file']/num" />
      </xsl:call-template>
    </xsl:if>

    <!-- For each file -->
    <xsl:for-each select="object[@type='file']">
      <xsl:sort select="@path" />

      <xsl:call-template name="data-row">
        <xsl:with-param name="label" select="concat(i18n:translate('statistics.file'),' ',$did,'/',@path)" />
        <xsl:with-param name="link" select="concat($ServletsBaseURL,'MCRFileNodeServlet/',../@id,'/',@path)" />
        <xsl:with-param name="nodes" select="num" />
      </xsl:call-template>

    </xsl:for-each>
  </xsl:for-each>

</xsl:template>

<xsl:template name="data-row">
  <xsl:param name="label" />
  <xsl:param name="link" />
  <xsl:param name="nodes" />

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
        <xsl:call-template name="sum">
          <xsl:with-param name="nodes" select="$nodes" />
        </xsl:call-template>
      </td>
    </xsl:for-each>
  </tr>
</xsl:template>

<xsl:template match="object[@type='document']" mode="chart">
  <div id="chart" />
  
  <script src="{$WebApplicationBaseURL}webjars/highcharts/7.0.3/highcharts.js" />
  <script src="{$WebApplicationBaseURL}webjars/highcharts/7.0.3/modules/exporting.js" />
  <script type="text/javascript">
    new Highcharts.Chart({
        chart: {
            renderTo: 'chart',
            type: 'column',
            borderWidth: 1,
            backgroundColor: null,
            marginTop: 70,
            events: {
                click: function(e) {
                    jQuery('#chart-dialog').dialog({
                        position: 'center',
                        width: jQuery(window).width() - 100,
                        height: jQuery(window).height() - 100,
                        draggable: false,
                        resizable: false,
                        modal: false
                    });
                    var dialogOptions = this.options;
                    dialogOptions.chart.renderTo = 'chart-dialog';
                    dialogOptions.chart.events = null;
                    dialogOptions.chart.zoomType = 'x';
                    new Highcharts.Chart(dialogOptions);
                }
            }
        },
        xAxis: {
            type: 'datetime',
            maxZoom: 60 * 24 * 60 * 60 * 1000, // sixty days
            title: {
                text: null
            },
            dateTimeLabelFormats: {
                day: '%m/%y',
                week: '%m/%y',
                month: '%m/%Y'
            }
        },
        yAxis: {
            title: {
                text: '<xsl:value-of select="i18n:translate('statistics.accesses')" />'
            },
            min: 0,
            stackLabels: {
            enabled: true,
            style: {
                fontWeight: 'bold',
                color: (Highcharts.theme &amp;&amp; Highcharts.theme.textColor) || 'gray'
            }
        }
        },
        plotOptions: {
            column: {
                stacking: 'normal',
                dataLabels: {
                    enabled: true,
                    color: (Highcharts.theme &amp;&amp; Highcharts.theme.dataLabelsColor) || 'white'
                }
            }
        },
        title: {
          text: '<xsl:value-of select="$title" />'
        },
        tooltip: {
            formatter: function() {
                return '&lt;b&gt;' + this.series.name + '&lt;/b&gt;&lt;br/&gt;' + Highcharts.dateFormat('%m/%Y', this.x) + ': ' + this.y;
            }
        },        
        series: [
            <xsl:variable name="oid" select="number(substring-after(@id,'_mods_'))" />
            <xsl:call-template name="series">
              <xsl:with-param name="label" select="concat(i18n:translate('statistics.document'),' ',$oid,' ',i18n:translate('statistics.metadata'))" />
              <xsl:with-param name="nodes" select="num" />
            </xsl:call-template>
            <xsl:for-each select="object[@type='derivate'][num|object[@type='file']/num]">
              <xsl:text>, </xsl:text>
              <xsl:variable name="did" select="number(substring-after(@id,'_derivate_'))" />
              <xsl:call-template name="series">
                <xsl:with-param name="label" select="concat(i18n:translate('statistics.filespace'),' ',$did,' ',i18n:translate('statistics.overall'))" />
                <xsl:with-param name="nodes" select="object[@type='file']/num" />
              </xsl:call-template>
            </xsl:for-each>
        ]
    });
  </script>
</xsl:template>

<xsl:template name="series">
  <xsl:param name="label" />
  <xsl:param name="nodes" />

  <xsl:text>{ </xsl:text>
  <xsl:text>name: '</xsl:text><xsl:value-of select="$label" /><xsl:text>', </xsl:text>
  <xsl:text>data: [</xsl:text>  
  <xsl:for-each select="/statistics/loggedMonth">
    <xsl:text>[ </xsl:text>
    <xsl:value-of select="concat( 'Date.UTC(', @year, ',', number(@month)-1, ',1)' )" />
    <xsl:text>, </xsl:text>
    <xsl:call-template name="sum">
      <xsl:with-param name="nodes" select="$nodes" />
    </xsl:call-template>
    <xsl:text>]</xsl:text>
    <xsl:if test="position() != last()">, </xsl:if>
  </xsl:for-each>
  <xsl:text>] }</xsl:text>
</xsl:template>

<xsl:template name="sum">
  <xsl:param name="nodes" />

  <xsl:variable name="num" select="sum($nodes[(@year=current()/@year) and (@month=current()/@month)])" />
  <xsl:choose>
    <xsl:when test="string-length($num) &gt; 0">
      <xsl:value-of select="$num" />
    </xsl:when>
    <xsl:otherwise>0</xsl:otherwise>
  </xsl:choose>
</xsl:template>

</xsl:stylesheet>
