<?xml version="1.0" encoding="ISO-8859-1"?>

<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:fo="http://www.w3.org/1999/XSL/Format"  
  xmlns:mods="http://www.loc.gov/mods/v3"
  exclude-result-prefixes="xsl mods"
>

<xsl:output method="xml" encoding="UTF-8" media-type="application/pdf" />

<xsl:include href="shelfmark-normalization.xsl" />

<xsl:param name="WebApplicationBaseURL" />

<xsl:template match="/thesis-list-grouped">
  <fo:root>
    <xsl:call-template name="layoutMasterSet" />
    <xsl:call-template name="metadata" />
    <fo:page-sequence master-reference="a4.title">
      <xsl:call-template name="titlePage" />
    </fo:page-sequence>
    <fo:page-sequence master-reference="a4.header.footer" initial-page-number="2">
      <xsl:call-template name="header" />
      <xsl:call-template name="footer" />
      <fo:flow flow-name="xsl-region-body">
        <xsl:call-template name="preface" />
        <xsl:call-template name="toc" />
        <xsl:apply-templates select="group" />
      </fo:flow>
    </fo:page-sequence>
  </fo:root>
</xsl:template>

<xsl:template name="layoutMasterSet">
  <fo:layout-master-set>
    <fo:simple-page-master master-name="a4.title" page-height="297mm" page-width="210mm"
      margin-top="15mm" margin-bottom="15mm" margin-left="15mm" margin-right="15mm">        
      <fo:region-body background-color="white" />
    </fo:simple-page-master>
    <fo:simple-page-master master-name="a4.header.footer" page-height="297mm" page-width="210mm"
      margin-top="15mm" margin-bottom="10mm" margin-left="15mm" margin-right="15mm">        
      <fo:region-body background-color="white" margin-top="20mm" margin-bottom="8mm" />
      <fo:region-before background-color="#efe4bf" extent="15mm" />
      <fo:region-after extent="8mm" />
    </fo:simple-page-master>
  </fo:layout-master-set>
</xsl:template>

<xsl:template name="metadata">
  <fo:declarations>
    <x:xmpmeta xmlns:x="adobe:ns:meta/">
      <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
        <rdf:Description rdf:about="" xmlns:dc="http://purl.org/dc/elements/1.1/">
          <dc:title>
            <xsl:text>Dissertationsverzeichnis </xsl:text>
            <xsl:value-of select="@year" />
            <xsl:text>(Stand </xsl:text>
            <xsl:value-of select="@today" />
            <xsl:text>)</xsl:text>
          </dc:title>
          <dc:creator>Universitätsbibliothek Duisburg-Essen</dc:creator>
          <dc:description>Veröffentlichte Dissertationen des Promotionsjahres <xsl:value-of select="@year" /></dc:description>
        </rdf:Description>
        <rdf:Description rdf:about="" xmlns:xmp="http://ns.adobe.com/xap/1.0/">
          <xmp:CreatorTool>DuEPublico: Publikationsserver der Universität Duisburg-Essen</xmp:CreatorTool>
        </rdf:Description>
      </rdf:RDF>
    </x:xmpmeta>
  </fo:declarations>
</xsl:template>

<xsl:template name="titlePage">
  <fo:flow flow-name="xsl-region-body">
    <fo:block height="133mm" margin-bottom="3mm">
      <fo:external-graphic src="{$WebApplicationBaseURL}images/imagemotiv1.jpg" width="180mm" content-height="scale-to-fit" />
    </fo:block>
    <fo:block-container color="#004c93" background-color="#efe4bf" height="138mm">
      <fo:block text-align="right" padding-top="10mm">
        <fo:external-graphic src="{$WebApplicationBaseURL}images/UDE_UB_1887px_tansp.png" content-height="scale-to-fit" content-width="40mm" />
      </fo:block>
      <fo:block font-family="Helvetica" font-weight="bold" font-size="34pt" margin-top="62mm" margin-left="5mm">Dissertationsverzeichnis</fo:block>
      <fo:block font-family="Times" font-size="20pt" margin-left="5mm">Veröffentlichte Dissertationen des Promotionsjahres <xsl:value-of select="@year" /></fo:block>
    </fo:block-container>
    <fo:block-container position="fixed" top="124mm" left="22mm" width="80mm" height="80mm" >
      <fo:block>
        <fo:instream-foreign-object xmlns:svg="http://www.w3.org/2000/svg">
          <svg:svg width="80" height="80">
            <svg:g>
              <svg:circle cx="40" cy="40" r="40" fill="#004c93" />
              <svg:text x="42" y="48" text-anchor="middle" font-family="Helvetica" font-size="24" font-weight="bold" fill="white" transform="rotate(355 42,48)">
                <xsl:value-of select="@year" />
              </svg:text>
            </svg:g>
          </svg:svg>
        </fo:instream-foreign-object>
      </fo:block>
    </fo:block-container>
  </fo:flow>
</xsl:template>

<xsl:template name="header">
  <fo:static-content flow-name="xsl-region-before">
    <fo:block-container height="15mm" display-align="center">
      <fo:block color="#004c93" font-family="Times" text-align-last="justify" margin-left="2mm" margin-right="2mm">
        <xsl:text>Dissertationsverzeichnis </xsl:text>
        <xsl:value-of select="@year" />
        <fo:leader leader-pattern="space" />
        <fo:retrieve-marker retrieve-class-name="marker-header" retrieve-position="first-including-carryover" retrieve-boundary="page-sequence" />
      </fo:block>
    </fo:block-container>
  </fo:static-content>
</xsl:template>

<xsl:template name="footer">
  <fo:static-content flow-name="xsl-region-after">
    <fo:block font-family="Times" font-style="italic" text-align="right">
      <fo:page-number/>
    </fo:block>
  </fo:static-content>
</xsl:template>

<xsl:template name="preface">
  <fo:block color="#004c93" font-family="Helvetica" font-size="20pt" margin-top="6mm" margin-bottom="6mm">
    <fo:marker marker-class-name="marker-header">Vorwort</fo:marker>
    <xsl:text>Vorwort</xsl:text>
  </fo:block>
  <fo:block color="#1a171b" text-align="justify" font-family="Times" margin-bottom="4mm">
    Die Universität Duisburg-Essen weist sämtliche Dissertationen (elektronisch oder gedruckt) in einem Online-Dissertationsverzeichnis nach. 
    Die Einträge werden von der Universitätsbibliothek gepflegt und sind in Listenform je Promotionsjahr (Jahr der Disputation) zusammengefasst.
  </fo:block>
  <fo:block color="#1a171b" text-align="justify" font-family="Times" margin-bottom="4mm">
    Das Veröffentlichungsjahr kann vom Jahr der mündlichen Prüfung abweichen. Das Dissertationsverzeichnis führt nur die bereits veröffentlichten Dissertationen auf.
    Diese Liste mit Stand vom <xsl:value-of select="@today" /> enthält <xsl:value-of select="count(group/mods:mods)" /> Dissertationen des Promotionsjahres <xsl:value-of select="@year" />. 
  </fo:block>
  <fo:block color="#1a171b" text-align="justify" font-family="Times" margin-bottom="4mm">
    Die einzelnen Titel sind über die Signatur mit dem Katalog der UB verknüpft. Bei elektronischen Dissertationen ist der Link auf den Volltext angegeben.
  </fo:block>
  <fo:table table-layout="fixed" width="100%">
    <fo:table-column column-width="140mm" />
    <fo:table-column column-width="40mm" />
    <fo:table-body>
      <fo:table-row>
        <fo:table-cell>
          <fo:block color="#1a171b" font-family="Times">
            Aktuelle Listen und weitere Suchmöglichkeiten finden Sie online unter
          </fo:block>
          <fo:block text-decoration="underline" color="#004c93" font-family="Courier" font-size="10pt" break-after="page">
            <xsl:variable name="link">https://www.uni-due.de/ub/publikationsdienste/dissertationen_recherche.php</xsl:variable>
            <fo:basic-link external-destination="{$link}">
              <xsl:value-of select="$link" />
            </fo:basic-link>
          </fo:block>
        </fo:table-cell>
        <fo:table-cell text-align="right">
          <fo:block>
            <fo:external-graphic src="{$WebApplicationBaseURL}images/dissSuche_qr.png" content-height="scale-to-fit" content-width="30mm" />
          </fo:block>
        </fo:table-cell>
      </fo:table-row>
    </fo:table-body>
  </fo:table>
</xsl:template>

<xsl:template name="toc">
  <fo:block color="#004c93" font-family="Helvetica" font-size="20pt" margin-top="6mm" margin-bottom="6mm">
    <fo:marker marker-class-name="marker-header">Inhaltsverzeichnis</fo:marker>
    <xsl:text>Inhaltsverzeichnis</xsl:text>
  </fo:block>
  <xsl:for-each select="group">
    <fo:block color="#1a171b" text-align-last="justify" font-family="Helvetica" margin-bottom="4mm">
      <xsl:if test="position() = last()">
        <xsl:attribute name="break-after">page</xsl:attribute>
      </xsl:if>
      <fo:basic-link internal-destination="{generate-id(.)}">
        <xsl:value-of select="@label" />
        <fo:leader leader-pattern="dots" padding-start="2mm" padding-end="2mm" />
        <fo:page-number-citation ref-id="{generate-id()}" />
      </fo:basic-link>
    </fo:block>
  </xsl:for-each>
</xsl:template>

<xsl:template match="group">
  <fo:block id="{generate-id()}" color="#004c93" font-family="Helvetica" font-size="20pt" margin-bottom="5mm" keep-with-next.within-page="always">
    <fo:marker marker-class-name="marker-header">
      <xsl:value-of select="@label" />
    </fo:marker>
    <xsl:value-of select="@label" />
  </fo:block>
  <fo:table width="175mm" table-layout="fixed" border-style="solid" border-color="grey" border-width="1pt" font-family="Times" font-size="10pt" margin-bottom="15mm">
    <fo:table-column column-width="40mm" />
    <fo:table-column column-width="115mm" />
    <fo:table-column column-width="25mm" />
    <fo:table-header>
      <fo:table-row keep-with-next="always">
        <fo:table-cell padding="2mm 2mm 2mm 2mm">
          <fo:block color="grey" font-style="italic">AutorIn</fo:block>
        </fo:table-cell>
        <fo:table-cell padding="2mm 2mm 2mm 2mm">
          <fo:block color="grey" font-style="italic">Titel</fo:block>
        </fo:table-cell>
        <fo:table-cell padding="2mm 2mm 2mm 2mm">
          <fo:block color="grey" font-style="italic">UB Signatur</fo:block>
        </fo:table-cell>
      </fo:table-row>
    </fo:table-header>
    <fo:table-body>
      <xsl:apply-templates select="mods:mods">
        <xsl:sort select="mods:name[mods:role/mods:roleTerm='aut'][1]/mods:namePart[@type='family']" />
        <xsl:sort select="mods:name[mods:role/mods:roleTerm='aut'][1]/mods:namePart[@type='given']" />
      </xsl:apply-templates>
    </fo:table-body>
 </fo:table>
</xsl:template>

<xsl:template match="mods:mods">
  <fo:table-row border-style="solid" border-color="grey" border-width="1pt" page-break-inside="avoid">
    <fo:table-cell padding="2mm 2mm 2mm 2mm">
      <xsl:apply-templates select="mods:name[mods:role/mods:roleTerm='aut']" />
    </fo:table-cell>
    <fo:table-cell padding="2mm 2mm 2mm 2mm" keep-together.within-page="always">
      <xsl:apply-templates select="mods:titleInfo[1]" />
      <xsl:if test="mods:originInfo|mods:identifier"> 
        <fo:block color="#1a171b" keep-together.within-page="always">
          <xsl:apply-templates select="mods:originInfo" />
          <xsl:apply-templates select="mods:relatedItem[@type='series']" />
        </fo:block>
        <xsl:apply-templates select="mods:identifier[@type='isbn'][1]" />
        <xsl:apply-templates select="mods:identifier[@type='doi']" />
        <xsl:apply-templates select="mods:identifier[@type='urn']" />
      </xsl:if>
    </fo:table-cell>
    <fo:table-cell padding="2mm 2mm 2mm 2mm">
      <xsl:apply-templates select="mods:location/mods:shelfLocator" />
      <fo:block> </fo:block>
    </fo:table-cell>
  </fo:table-row>
</xsl:template>

<xsl:template match="mods:name[@type='personal']">
  <fo:block color="#1a171b">
    <xsl:value-of select="mods:namePart[@type='family']" />
    <xsl:text>, </xsl:text>
    <xsl:value-of select="mods:namePart[@type='given']" />
  </fo:block>
</xsl:template>

<xsl:template match="mods:titleInfo">
  <fo:block color="#1a171b" font-weight="bold">
    <xsl:value-of select="mods:title" />
    <xsl:if test="mods:subTitle">
      <xsl:if test="translate(substring(mods:title,string-length(mods:title)),'?!.:,-;','.......') != '.'">
        <xsl:text> :</xsl:text>
      </xsl:if>
      <xsl:text> </xsl:text>
      <xsl:value-of select="mods:subTitle" />
    </xsl:if>
  </fo:block>
</xsl:template>

<xsl:template match="mods:originInfo">
  <xsl:value-of select="mods:place/mods:placeTerm" />
  <xsl:apply-templates select="mods:publisher" />
  <xsl:apply-templates select="mods:dateIssued" />
</xsl:template>

<xsl:template match="mods:publisher">
  <xsl:if test="../mods:place">
    <xsl:text>: </xsl:text>
  </xsl:if>
  <xsl:value-of select="." />
</xsl:template>

<xsl:template match="mods:dateIssued">
  <xsl:text> (</xsl:text>
  <xsl:value-of select="normalize-space(text())" />
  <xsl:text>)</xsl:text>
</xsl:template>

<xsl:template match="mods:relatedItem[@type='series']">
  <xsl:text> (</xsl:text>
    <xsl:value-of select="mods:titleInfo/mods:title" />
    <xsl:apply-templates select="mods:part" />
  <xsl:text>)</xsl:text>
</xsl:template>

<xsl:template match="mods:part">
  <xsl:text> ; </xsl:text>
  <xsl:value-of select="mods:detail[@type='volume']/mods:number" />
</xsl:template>

<xsl:template match="mods:identifier[@type='isbn']">
  <fo:block color="#1a171b" keep-with-previous.within-page="always" margin-top="2mm">
    <xsl:text>ISBN </xsl:text>
    <fo:inline text-decoration="underline" color="#004c93">
      <fo:basic-link external-destination="http://de.wikipedia.org/w/index.php?title=Spezial%3AISBN-Suche&amp;isbn={.}">
        <xsl:value-of select="."/>
      </fo:basic-link>
    </fo:inline>
  </fo:block>
</xsl:template>

<xsl:template match="mods:identifier[@type='doi']">
  <fo:block color="#1a171b" keep-with-previous.within-page="always" margin-top="2mm">
    <xsl:text>DOI: </xsl:text>
    <fo:inline text-decoration="underline" color="#004c93">
      <fo:basic-link external-destination="http://dx.doi.org/{.}">
        <xsl:value-of select="." /> 
      </fo:basic-link>
    </fo:inline>
  </fo:block>
</xsl:template>

<xsl:template match="mods:identifier[@type='urn']">
  <fo:block color="#1a171b" keep-with-previous.within-page="always" margin-top="2mm">
    <xsl:text>Volltext in DuEPublico: </xsl:text>
    <fo:inline text-decoration="underline" color="#004c93">
    <fo:basic-link external-destination="http://nbn-resolving.org/{.}">
      <xsl:value-of select="." /> 
    </fo:basic-link>
    </fo:inline>
  </fo:block>
</xsl:template>

<xsl:variable name="primo.search">
  <xsl:text>http://primo.ub.uni-due.de/primo_library/libweb/action/dlSearch.do</xsl:text>
  <xsl:text>?vid=UDE&amp;institution=UDE&amp;bulkSize=10&amp;indx=1&amp;onCampus=false&amp;query=</xsl:text>
</xsl:variable>

<xsl:template match="mods:location/mods:shelfLocator">
  <xsl:variable name="sig">
    <xsl:apply-templates select="." mode="normalize.shelfmark" />
  </xsl:variable>
  <fo:block text-decoration="underline" color="#004c93">
    <fo:basic-link external-destination="{$primo.search}lsr11,contains,%22{$sig}%22">
      <xsl:value-of select="text()"/>
    </fo:basic-link>
  </fo:block>
</xsl:template>

</xsl:stylesheet>
