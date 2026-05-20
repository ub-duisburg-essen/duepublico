<?xml version="1.0" encoding="UTF-8"?>

<!--
  Displays a table of contents as <div id="toc" />
  There are multiple toc layouts defined in toc-layouts.xml.
  The toc layout to use is defined in
    /mycoreobject/service/servflags/servflag[@type='tocLayout']
  There are custom toc layout templates for HTML display of
  toc levels and publications in custom-toc-layouts.xsl

  Add ?XSL.TOC.Debug=true to display transformation steps in debug mode
  Add ?XSL.TOC.LayoutID=[ID] to override configured layout
-->

<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xalan="http://xml.apache.org/xalan"
  xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
  exclude-result-prefixes="xalan i18n">

  <xsl:import href="xslImport:modsmeta:toc/mycoreobject-toc.xsl" />

  <xsl:include href="../debug-viewer.xsl" />

  <xsl:param name="TOC.Debug" />
  <xsl:param name="TOC.LayoutID" />

  <xsl:template match="/">

    <xsl:variable name="servflag" select="mycoreobject/service/servflags/servflag[@type='tocLayout']" />

    <xsl:variable name="tocLayoutsURI">resource:toc-layouts.xml</xsl:variable>

    <!-- get preferred ID of toc layout to use from URL parameter of service flag -->
    <xsl:variable name="preferredLayoutID">
      <xsl:choose>
        <xsl:when test="string-length($TOC.LayoutID) &gt; 0">
          <xsl:value-of select="$TOC.LayoutID"/>
        </xsl:when>
        <xsl:when test="string-length($servflag) &gt; 0">
          <xsl:value-of select="$servflag"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>

    <!-- URI to transform toc-layouts.xml to SOLR parameters using JSON facet API -->
    <xsl:variable name="solrParamsURI">
      <xsl:text>xslStyle:toc/toc-layouts2solr-params</xsl:text>
      <xsl:value-of select="concat('?preferredLayoutID=',$preferredLayoutID)" />
      <xsl:value-of select="concat('&amp;invokingObjectID=',/mycoreobject/@ID)" />
      <xsl:text>:</xsl:text>
      <xsl:value-of select="$tocLayoutsURI" />
    </xsl:variable>

    <!-- URI to query SOLR to get TOC data -->
    <xsl:variable name="solrURI">
      <xsl:value-of select="document(concat('xslStyle:toc/solr-params2uri:',$solrParamsURI))/uri/text()" />
    </xsl:variable>
    
    <!-- First transform SOLR facet response to simpler XML... -->
    <xsl:variable name="prepURI">
      <xsl:text>xslStyle:toc/solr-facets2toc:</xsl:text>
      <xsl:value-of select="$solrURI" />
    </xsl:variable>

    <!-- ... then render to HTML -->
    <xsl:variable name="htmlURI">
      <xsl:text>notnull:xslStyle:toc/render-toc:</xsl:text>
      <xsl:value-of select="$prepURI" />
    </xsl:variable>

    <xsl:if test="$TOC.Debug='true'">
      <div id="toc" class="detail_block">
      
        <xsl:call-template name="debug-viewer">
          <xsl:with-param name="headline">TOC Layout ID</xsl:with-param>
          <xsl:with-param name="text"  >
            <xsl:value-of select="concat('URL parameter (?XSL.TOC.LayoutID):&#160;&#160;',$TOC.LayoutID,'&#xA;')"/>
            <xsl:value-of select="concat('Service flag (servflag[@type=tocLayout]):&#160;&#160;',$servflag,'&#xA;')"/>
          </xsl:with-param>
        </xsl:call-template>
         
        <xsl:call-template name="debug-viewer">
          <xsl:with-param name="headline">TOC Layouts availabe</xsl:with-param>
          <xsl:with-param name="xml" select="document($tocLayoutsURI)/*" />
        </xsl:call-template>

        <xsl:call-template name="debug-viewer">
          <xsl:with-param name="headline">SOLR TOC Request Parameters</xsl:with-param>
          <xsl:with-param name="xml" select="document($solrParamsURI)/*" />
        </xsl:call-template>

        <xsl:call-template name="debug-viewer">
          <xsl:with-param name="headline">SOLR TOC Request URI</xsl:with-param>
          <xsl:with-param name="text" select="$solrURI" />
        </xsl:call-template>

        <xsl:call-template name="debug-viewer">
          <xsl:with-param name="headline">SOLR TOC Response</xsl:with-param>
          <xsl:with-param name="xml" select="document($solrURI)/*" />
        </xsl:call-template>
        
        <xsl:call-template name="debug-viewer">
          <xsl:with-param name="headline">Pre-processed TOC</xsl:with-param>
          <xsl:with-param name="xml" select="document($prepURI)/*" />
        </xsl:call-template>

        <xsl:call-template name="debug-viewer.css" />
        <xsl:call-template name="debug-viewer.js" />
      </div>
    </xsl:if>

    <!-- if the response returned any documents, show a table of contents now -->
    <xsl:copy-of select="document($htmlURI)/div[@id='toc']" />

    <xsl:apply-imports />
  </xsl:template>

</xsl:stylesheet>
