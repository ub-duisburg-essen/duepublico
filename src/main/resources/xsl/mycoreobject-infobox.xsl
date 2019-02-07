<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xlink="http://www.w3.org/1999/xlink" 
  xmlns:mods="http://www.loc.gov/mods/v3" 
  xmlns:xalan="http://xml.apache.org/xalan"
  xmlns:fo="http://www.w3.org/1999/XSL/Format"  
  exclude-result-prefixes="xsl mods xalan xlink">

<xsl:output method="xml" encoding="UTF-8" media-type="application/pdf" />

  <xsl:param name="WebApplicationBaseURL" />
  <xsl:param name="MCR.DOI.Resolver.MasterURL" />
  <xsl:param name="MCR.URN.Resolver.MasterURL" />
  
  <xsl:template match="/mycoreobject">
    <fo:root>
      <fo:layout-master-set>
        <fo:simple-page-master master-name="infobox" page-height="105mm" page-width="148mm">        
          <fo:region-body />
        </fo:simple-page-master>
      </fo:layout-master-set>
      <fo:page-sequence master-reference="infobox">
        <fo:flow flow-name="xsl-region-body">
          <fo:block-container height="97mm" margin="2mm" padding="0mm" background-color="white" border="2mm solid #666666">
            <xsl:call-template name="logo" />
            <xsl:call-template name="info" />
            <xsl:for-each select="metadata/def.modsContainer/modsContainer/mods:mods">
              <xsl:apply-templates select="." mode="links" />
              <xsl:apply-templates select="mods:accessCondition[contains(@xlink:href,'mir_licenses')]" />
            </xsl:for-each>
          </fo:block-container>
        </fo:flow>
      </fo:page-sequence>
    </fo:root>
  </xsl:template>
  
  <xsl:template name="logo">
    <fo:block start-indent="3mm">
      <fo:basic-link external-destination="url('{$WebApplicationBaseURL}')">
        <fo:external-graphic src="{$WebApplicationBaseURL}images/DuEPublicoDocInfoBoxA6-Banner.png" content-width="135mm" />
      </fo:basic-link>
    </fo:block>
  </xsl:template>
  
  <xsl:template name="info">
    <fo:block font-family="Times" font-size="10pt" margin-top="12mm" start-indent="5mm">
      Dieser Text wird über 
      <fo:basic-link external-destination="url('{$WebApplicationBaseURL}')">DuEPublico</fo:basic-link>, 
      dem Dokumenten- und Publikationsserver der Universität
      Duisburg-Essen, zur Verfügung gestellt. Die hier veröffentlichte Version der E-Publikation kann
      von einer eventuell ebenfalls veröffentlichten Verlagsversion abweichen.
    </fo:block>
  </xsl:template>
  
  <xsl:template match="mods:mods[mods:identifier[@type='doi'] or mods:identifier[@type='urn']]" mode="links">
    <fo:table table-layout="fixed" font-family="Times" font-size="10pt" margin-top="5mm" padding="0mm">
      <fo:table-column column-width="12mm" />
      <fo:table-column column-width="118mm"/>
      <fo:table-body>
        <xsl:apply-templates select="mods:identifier[@type='doi']" />
        <xsl:apply-templates select="mods:identifier[@type='urn']" />
      </fo:table-body>
    </fo:table>
  </xsl:template>
  
  <xsl:template match="mods:mods" mode="links">
    <fo:block font-family="Times" font-size="10pt" margin-top="5mm" start-indent="5mm">
      <fo:inline font-weight="bold">Link: </fo:inline>
      <xsl:variable name="link" select="concat($WebApplicationBaseURL,'receive/',/mycoreobject/@ID)" /> 
      <fo:basic-link external-destination="url('{$link}')">
        <xsl:value-of select="$link" />
      </fo:basic-link> 
    </fo:block>
  </xsl:template>
  
  <xsl:template match="mods:identifier">
    <fo:table-row>
      <fo:table-cell>
        <fo:block font-weight="bold" start-indent="1mm">
          <xsl:value-of select="translate(@type,'doiurn','DOIURN')" />
          <xsl:text>:</xsl:text>
        </fo:block>
      </fo:table-cell>
      <fo:table-cell>
        <fo:block>
          <xsl:variable name="link">
            <xsl:apply-templates select="." mode="link" />
          </xsl:variable>
          <fo:basic-link external-destination="url('{$link}')">
            <xsl:value-of select="$link" />
          </fo:basic-link>
        </fo:block>
      </fo:table-cell>
    </fo:table-row>
  </xsl:template>
  
  <xsl:template match="mods:identifier[@type='doi']" mode="link">
    <xsl:value-of select="$MCR.DOI.Resolver.MasterURL" />
    <xsl:value-of select="." />
  </xsl:template>

  <xsl:template match="mods:identifier[@type='urn']" mode="link">
    <xsl:value-of select="$MCR.URN.Resolver.MasterURL" />
    <xsl:value-of select="." />
  </xsl:template>

  <xsl:template match="mods:accessCondition[contains(@xlink:href,'mir_licenses#rights_reserved')]" priority="1">
    <fo:block-container absolute-position="fixed" top="95mm" left="5mm">
      <fo:block font-family="Times" font-size="10pt">Alle Rechte vorbehalten.</fo:block>
    </fo:block-container>
  </xsl:template>

  <xsl:template match="mods:accessCondition[contains(@xlink:href,'mir_licenses#cc_')]">
    <xsl:variable name="id" select="substring-after(@xlink:href,'#')" />
    <xsl:variable name="uri">classification:metadata:-1:children:mir_licenses</xsl:variable>
    <xsl:variable name="licenses" select="document($uri)/mycoreclass" />
    
    <fo:block-container absolute-position="fixed" top="87mm" left="5mm">
      <fo:block font-family="Times" font-size="10pt">
        <xsl:text>Dieses Werk kann unter einer </xsl:text>
        <xsl:for-each select="$licenses//category[@ID=$id]">
          <fo:basic-link external-destination="url('{url/@xlink:href}')">
            <xsl:value-of select="label[lang('de')]/@description" />
            <xsl:text> (</xsl:text>
            <xsl:value-of select="label[lang('de')]/@text" />
            <xsl:text>)</xsl:text>
          </fo:basic-link>
        </xsl:for-each>
        <xsl:text> genutzt werden.</xsl:text>
      </fo:block>
    </fo:block-container>
  </xsl:template>

</xsl:stylesheet>
