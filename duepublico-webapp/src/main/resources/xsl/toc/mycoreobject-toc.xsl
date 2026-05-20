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
  xmlns:mcrxsl="xalan://org.mycore.common.xml.MCRXMLFunctions"
  xmlns:encoder="xalan://java.net.URLEncoder"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:xalan="http://xml.apache.org/xalan"
  xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
  exclude-result-prefixes="mcrxsl encoder mods xalan i18n">

  <xsl:import href="xslImport:modsmeta:toc/mycoreobject-toc.xsl" />

  <xsl:include href="../debug-viewer.xsl" />

  <xsl:param name="TOC.Debug" />
  <xsl:param name="TOC.LayoutID" />

  <xsl:template match="/">

    <!-- Transform toc-layouts.xml to SOLR parameters to get a TOC via JSON facet API-->
    <xsl:variable name="tocLayouts" select="document('xslStyle:toc/toc-layouts2solr-json-facet-query:resource:toc-layouts.xml')/*" />

    <!-- get preferred ID of toc layout to use from URL parameter of service flag -->
    <xsl:variable name="preferredLayoutID">
      <xsl:choose>
        <xsl:when test="string-length($TOC.LayoutID) &gt; 0">
          <xsl:value-of select="$TOC.LayoutID"/>
        </xsl:when>
        <xsl:when test="mycoreobject/service/servflags/servflag[@type='tocLayout'][string-length(text()) &gt; 0]">
          <xsl:value-of select="mycoreobject/service/servflags/servflag[@type='tocLayout']"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>

    <!-- select actual ID of toc layout to use. Use preferred ID, if available, or fallback to toc-layouts.xml @default -->
    <xsl:variable name="layoutID">
      <xsl:choose>
        <xsl:when test="$preferredLayoutID and $tocLayouts/toc-layout[@id=$preferredLayoutID]">
          <xsl:value-of select="$preferredLayoutID"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$tocLayouts/@default"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <!-- Query to find all objects below this one (children, grand-children) -->
    <xsl:variable name="q">
      <xsl:value-of select="$tocLayouts/toc-layout[@id=$layoutID]/@field" />
      <xsl:text>:</xsl:text>
      <xsl:value-of select="mycoreobject/@ID" />
      <xsl:text> AND (</xsl:text>
      <xsl:text>state:</xsl:text>
      <xsl:choose>
        <xsl:when test="mcrxsl:isCurrentUserInRole('admin')">*</xsl:when>
        <xsl:when test="mcrxsl:isCurrentUserInRole('editor')">*</xsl:when>
        <xsl:otherwise>published OR createdby:<xsl:value-of select="$CurrentUser" /></xsl:otherwise>
      </xsl:choose>
      <xsl:text>)</xsl:text>
    </xsl:variable>

    <!-- Complete SOLR URI including facet parameters to build TOC -->
    <xsl:variable name="solrURI">
      <xsl:text>solr:q=</xsl:text><xsl:value-of select="encoder:encode($q)" />
      <xsl:value-of select="$tocLayouts/toc-layout[@id=$layoutID]" />
    </xsl:variable>

    <!-- First transform SOLR facet response to simpler XML... -->
    <xsl:variable name="prepURI">
      <xsl:text>xslStyle:toc/solr-facets2toc</xsl:text>
      <xsl:text>?tocLayoutID=</xsl:text><xsl:value-of select="$layoutID" />
      <xsl:text>:</xsl:text>
      <xsl:value-of select="$solrURI" />
    </xsl:variable>

    <!-- ... then render to HTML -->
    <xsl:variable name="htmlURI">
      <xsl:text>notnull:xslStyle:toc/render-toc:</xsl:text>
      <xsl:value-of select="$prepURI" />
    </xsl:variable>

    <xsl:if test="$TOC.Debug='true'">
      <div id="toc" class="detail_block mt-4 mb-4">
      
        <xsl:call-template name="debug-viewer">
          <xsl:with-param name="headline">TOC Layout ID</xsl:with-param>
          <xsl:with-param name="text"  >
            <xsl:value-of select="concat('URL parameter (?XSL.TOC.LayoutID):&#160;&#160;',$TOC.LayoutID,'&#xA;')"/>
            <xsl:value-of select="concat('Service flag (servflag[@type=tocLayout]):&#160;&#160;',mycoreobject/service/servflags/servflag[@type='tocLayout'],'&#xA;')"/>
            <xsl:value-of select="concat('Layout ID actually used:&#160;&#160;',$layoutID)"/>
          </xsl:with-param>
        </xsl:call-template>
        
        <xsl:call-template name="debug-viewer">
          <xsl:with-param name="headline">TOC Layouts (vorverarbeitet)</xsl:with-param>
          <xsl:with-param name="xml" select="$tocLayouts" />
        </xsl:call-template>

        <xsl:call-template name="debug-viewer">
          <xsl:with-param name="headline">TOC SOLR Query</xsl:with-param>
          <xsl:with-param name="text" select="$q" />
        </xsl:call-template>
        
        <xsl:call-template name="debug-viewer">
          <xsl:with-param name="headline">TOC SOLR URI</xsl:with-param>
          <xsl:with-param name="text" select="$solrURI" />
        </xsl:call-template>
        
        <xsl:call-template name="debug-viewer">
          <xsl:with-param name="headline">TOC SOLR Response</xsl:with-param>
          <xsl:with-param name="xml" select="document($solrURI)/*" />
        </xsl:call-template>
        
        <xsl:call-template name="debug-viewer">
          <xsl:with-param name="headline">Preprocessed TOC</xsl:with-param>
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
