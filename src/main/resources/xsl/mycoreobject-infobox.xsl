<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xlink="http://www.w3.org/1999/xlink" 
  xmlns:mods="http://www.loc.gov/mods/v3" 
  xmlns:xalan="http://xml.apache.org/xalan"
  xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
  xmlns:fo="http://www.w3.org/1999/XSL/Format"  
  xmlns:fox="http://xmlgraphics.apache.org/fop/extensions"
  exclude-result-prefixes="xsl mods xalan i18n xlink">

<xsl:output method="xml" encoding="UTF-8" media-type="application/pdf" />

  <xsl:param name="MCR.NameOfProject" />
  <xsl:param name="CurrentLang" />
  <xsl:param name="WebApplicationBaseURL" />
  <xsl:param name="MCR.DOI.Resolver.MasterURL" />
  <xsl:param name="MCR.URN.Resolver.MasterURL" />
  <xsl:param name="MCR.LayoutService.FoFormatter.FOP.FontSerif" />
  
  <xsl:template match="/mycoreobject">
    <fo:root>
      <fo:layout-master-set>
        <fo:simple-page-master master-name="infobox" page-height="105mm" page-width="148mm">        
          <fo:region-body />
        </fo:simple-page-master>
      </fo:layout-master-set>
      <fo:page-sequence master-reference="infobox">
        <fo:flow flow-name="xsl-region-body">
          <fo:block-container height="97mm" margin="2mm" padding="0mm" background-color="white" 
            border="2mm solid #666666" fox:border-radius="2mm">
            <xsl:call-template name="logo" />
            <xsl:for-each select="metadata/def.modsContainer/modsContainer/mods:mods">
              <xsl:apply-templates select="." mode="info" />
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
        <fo:external-graphic src="url('{$WebApplicationBaseURL}images/DuEPublicoDocInfoBoxA6-Banner.png')" content-width="135mm" />
      </fo:basic-link>
    </fo:block>
  </xsl:template>
  
  <xsl:template match="mods:mods" mode="info">
    <fo:block font-family="{$MCR.LayoutService.FoFormatter.FOP.FontSerif}" font-size="10pt" margin-top="12mm" start-indent="5mm">
      <xsl:choose>
        <xsl:when test="mods:genre[contains(@valueURI,'mir_genres#dissertation')]">
          <xsl:value-of select="i18n:translate('duepublico.infobox.info.1.dissertation')" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="i18n:translate('duepublico.infobox.info.1')" />
        </xsl:otherwise>
      </xsl:choose>
      <xsl:text> </xsl:text>
      <fo:basic-link external-destination="url('{$WebApplicationBaseURL}')">
        <xsl:value-of select="$MCR.NameOfProject" />
      </fo:basic-link>
      <xsl:text>, </xsl:text> 
      <xsl:value-of select="i18n:translate('duepublico.infobox.info.2')" />
      <xsl:choose>
        <xsl:when test="mods:genre[contains(@valueURI,'mir_genres#dissertation')]">
          <xsl:text> </xsl:text>
          <xsl:value-of select="i18n:translate('duepublico.infobox.info.3.dissertation')" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="i18n:translate('duepublico.infobox.info.3')" />
        </xsl:otherwise>
      </xsl:choose>
    </fo:block>
  </xsl:template>
  
  <xsl:template match="mods:mods[mods:identifier[@type='doi'] or mods:identifier[@type='urn']]" mode="links">
    <fo:table table-layout="fixed" font-family="{$MCR.LayoutService.FoFormatter.FOP.FontSerif}" font-size="10pt" margin-top="5mm" padding="0mm">
      <fo:table-column column-width="12mm" />
      <fo:table-column column-width="118mm"/>
      <fo:table-body>
        <xsl:apply-templates select="mods:identifier[@type='doi']" />
        <xsl:apply-templates select="mods:identifier[@type='urn']" />
      </fo:table-body>
    </fo:table>
  </xsl:template>
  
  <xsl:template match="mods:mods" mode="links">
    <fo:block font-family="{$MCR.LayoutService.FoFormatter.FOP.FontSerif}" font-size="10pt" margin-top="5mm" start-indent="5mm">
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
            <xsl:value-of select="." />
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
  
  <xsl:variable name="licenses" select="document('classification:metadata:-1:children:mir_licenses')" />

  <xsl:template match="mods:accessCondition[contains(@xlink:href,'mir_licenses#rights_reserved')]" priority="1">
    <fo:block-container absolute-position="fixed" top="95mm" left="5mm">
      <xsl:for-each select="$licenses/mycoreclass//category[@ID='rights_reserved']">
        <fo:block font-family="{$MCR.LayoutService.FoFormatter.FOP.FontSerif}" font-size="10pt">
          <xsl:value-of select="label[lang($CurrentLang)]/@text" />
          <xsl:text>.</xsl:text>
        </fo:block>
      </xsl:for-each>
    </fo:block-container>
  </xsl:template>

  <xsl:template match="mods:accessCondition[contains(@xlink:href,'mir_licenses#cc')]">
    <xsl:variable name="id" select="substring-after(@xlink:href,'#')" />
    
    <xsl:for-each select="$licenses/mycoreclass//category[@ID=$id]">
      <fo:block-container absolute-position="fixed" top="83mm" left="5mm">
        <fo:table table-layout="fixed" font-family="{$MCR.LayoutService.FoFormatter.FOP.FontSerif}" font-size="10pt" margin-top="5mm" padding="0mm">
          <fo:table-column column-width="25mm" />
          <fo:table-column column-width="105mm"/>
          <fo:table-body>
            <fo:table-row>
              <xsl:apply-templates select="label[@xml:lang='x-logo']" />
              <xsl:apply-templates select="label[lang($CurrentLang)]" />
            </fo:table-row>
          </fo:table-body>
        </fo:table>
      </fo:block-container>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="label[@xml:lang='x-logo']">
    <fo:table-cell>
      <fo:block start-indent="0">
        <fo:basic-link external-destination="{../url/@xlink:href}">
          <fo:external-graphic src="{@text}" content-width="25mm" />
        </fo:basic-link>
      </fo:block>
    </fo:table-cell>
  </xsl:template>

  <xsl:template match="label">
    <fo:table-cell display-align="center">
      <fo:block>
        <xsl:value-of select="i18n:translate('duepublico.infobox.license.prefix')" />
        <xsl:text> </xsl:text>
        <fo:basic-link external-destination="url('{../url/@xlink:href}')">
          <xsl:value-of select="@description" />
          <xsl:text> (</xsl:text>
          <xsl:value-of select="@text" />
          <xsl:text>)</xsl:text>
        </fo:basic-link>
        <xsl:value-of select="i18n:translate('duepublico.infobox.license.suffix')" />
      </fo:block>
    </fo:table-cell>
  </xsl:template>

</xsl:stylesheet>
