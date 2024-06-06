<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:xalan="http://xml.apache.org/xalan"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
  xmlns:mods="http://www.loc.gov/mods/v3"
  exclude-result-prefixes="xsl xalan">

  <xsl:output method="xml" encoding="UTF-8" media-type="application/rss+xml" indent="yes" xalan:indent-amount="2" />

  <xsl:template match="/document">
    <mycoreobject xsi:noNamespaceSchemaLocation="datamodel-mods.xsd">
      <xsl:call-template name="label" />
      <xsl:apply-templates select="@ID" />
      <xsl:apply-templates select="." mode="errors" />
      
      <xsl:apply-templates select="relation[@type='isPartOf']" mode="structure" />
      
      <metadata>
        <def.modsContainer class="MCRMetaXML" heritable="false" notinherit="true">
          <modsContainer inherited="0">
            <mods:mods>
              <xsl:apply-templates select="titles/title" />
              <xsl:apply-templates select="creators/creator" />
              <xsl:apply-templates select="contributors/contributor" />
              <xsl:apply-templates select="publishers/publisher" />
              <xsl:apply-templates select="mediaTypes/category" />
              <xsl:apply-templates select="documentTypes/category" />
              <xsl:apply-templates select="orgUnits/category" />
              <xsl:apply-templates select="@collection" />
              <xsl:apply-templates select="subjects/subject/category" />
              <xsl:apply-templates select="subjects[subject/category[@CLASSID='DDC']]" mode="ddc2sdnb" />
              <xsl:apply-templates select="languages/language" />
              <xsl:apply-templates select="descriptions/description" />
              <xsl:apply-templates select="sources/source" />
              <xsl:apply-templates select="coverages/coverage" />
              <xsl:apply-templates select="rightsRemarks/rightsRemark[not(starts-with(.,$LICENSE_PREFIX))]" />
              <xsl:apply-templates select="keywords" />
              <xsl:apply-templates select="." mode="license" />
              <xsl:apply-templates select="identifier" mode="dateIssued" />
              <xsl:apply-templates select="dates" />
              <xsl:apply-templates select="identifier" />
              <xsl:apply-templates select="purl" />
              <xsl:apply-templates select="links" />
              <xsl:apply-templates select="relation" />
            </mods:mods>
          </modsContainer>
        </def.modsContainer>
      </metadata>
      <service>
        <xsl:apply-templates select="@alias" />
        <xsl:apply-templates select="@status" />
      </service>
      
      <xsl:apply-templates select="derivates/derivate" />
      
    </mycoreobject>
  </xsl:template>
  
  <xsl:template name="label">
    <xsl:attribute name="label">
      <xsl:value-of select="creators/creator[1]/@name" />
      <xsl:text>:</xsl:text>
      <xsl:for-each select="xalan:tokenize(titles/title[1],' ')">
        <xsl:if test="position() &lt; 5">
          <xsl:text> </xsl:text>
          <xsl:value-of select="." />
        </xsl:if>
      </xsl:for-each>
    </xsl:attribute>
  </xsl:template>
  
  <xsl:template name="formatID">
    <xsl:value-of select="concat(substring('00000000',1,8-string-length(.)),.)" />
  </xsl:template>
  
  <xsl:template match="document/@ID">
    <xsl:attribute name="ID">
      <xsl:text>duepublico_mods_</xsl:text>
      <xsl:call-template name="formatID" />
    </xsl:attribute>
  </xsl:template>
  
  <xsl:variable name="URI_BASE">https://duepublico.uni-due.de/api/v1/classifications/</xsl:variable>
  
  <xsl:template match="document/@collection">
    <mods:classification authorityURI="{$URI_BASE}collection" valueURI="{$URI_BASE}collection#{.}" />
  </xsl:template>

  <xsl:variable name="SUBSTRING_DELIM">: </xsl:variable>
  
  <xsl:template match="title">
    <xsl:choose>
      <xsl:when test="preceding::title[@lang=current()/@lang]" />
      <xsl:otherwise>
        <mods:titleInfo>
          <xsl:apply-templates select="@lang" />
          <xsl:apply-templates select="@translated" />
          <xsl:choose>
            <xsl:when test="following::title[@lang=current()/@lang]">
              <xsl:call-template name="build.title">
                <xsl:with-param name="text" select="text()" />
              </xsl:call-template>
              <mods:subTitle>
                <xsl:for-each select="following::title[@lang=current()/@lang]">
                  <xsl:value-of select="text()" />
                  <xsl:if test="position() != last()"> </xsl:if>
                </xsl:for-each>
              </mods:subTitle>
            </xsl:when>
            <xsl:when test="contains(.,$SUBSTRING_DELIM)">
              <xsl:call-template name="build.title">
                <xsl:with-param name="text" select="normalize-space(substring-before(.,$SUBSTRING_DELIM))" />
              </xsl:call-template>
              <mods:subTitle>
                <xsl:value-of select="normalize-space(substring-after(.,$SUBSTRING_DELIM))" />
              </mods:subTitle>
            </xsl:when>
            <xsl:otherwise>
              <xsl:call-template name="build.title">
                <xsl:with-param name="text" select="text()" />
              </xsl:call-template>
            </xsl:otherwise>
          </xsl:choose>
        </mods:titleInfo>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="@lang">
    <xsl:attribute name="xml:lang">
      <xsl:value-of select="document(concat('language:',.))/language/@xmlCode" />
    </xsl:attribute>
  </xsl:template>
  
  <xsl:template match="title/@translated[.='true']">
    <xsl:attribute name="type">translated</xsl:attribute>
  </xsl:template>
  
  <xsl:template name="build.title">
    <xsl:param name="text" />
    
    <xsl:choose>
      <xsl:when test="contains(' der die das the ',concat(' ',translate(substring-before($text,' '),'DERIASTH','deriasth'),' '))">
        <mods:nonSort>
          <xsl:value-of select="substring-before($text,' ')" />
        </mods:nonSort>
        <mods:title>
          <xsl:value-of select="substring-after($text,' ')" />
        </mods:title>
      </xsl:when>
      <xsl:otherwise>
        <mods:title>
          <xsl:value-of select="$text" />
        </mods:title>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="creator|contributor|publisher">
    <xsl:if test="not(/document/@collection='Diss' and @code='rev')">
      <mods:name>
        <xsl:apply-templates select="legalEntity/@type" />
        <xsl:apply-templates select="@name" />
        <xsl:apply-templates select="legalEntity/title" />
        <xsl:apply-templates select="legalEntity/@pid" />
        <xsl:apply-templates select="@code" />
      </mods:name>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="legalEntity/@type">
    <xsl:attribute name="type">
      <xsl:choose>
        <xsl:when test=".='person'">personal</xsl:when>
        <xsl:otherwise>corporate</xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
  </xsl:template>
  
  <xsl:template match="legalEntity/title">
    <mods:namePart type="termsOfAddress">
      <xsl:value-of select="text()" />
    </mods:namePart>
  </xsl:template>
  
  <xsl:template match="@code">
    <mods:role>
      <mods:roleTerm type="code" authority="marcrelator">
        <xsl:value-of select="." />
      </mods:roleTerm>
    </mods:role>
  </xsl:template>
  
  <xsl:template match="@name">
    <xsl:choose>
      <xsl:when test="../legalEntity/@type='corporation'">
        <mods:namePart>
          <xsl:value-of select="." />
        </mods:namePart>
      </xsl:when>
      <xsl:when test="contains(.,', ')">
        <mods:namePart type="family">
          <xsl:value-of select="substring-before(.,', ')" />
        </mods:namePart>
        <mods:namePart type="given">
          <xsl:value-of select="substring-after(.,', ')" />
        </mods:namePart>
      </xsl:when>
      <xsl:otherwise>
        <mods:displayForm>
          <xsl:value-of select="." />
        </mods:displayForm>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="legalEntity/@pid">
    <mods:nameIdentifier type="lsf">
      <xsl:value-of select="." />
    </mods:nameIdentifier>
  </xsl:template>
  
  <xsl:template match="documentTypes/category">
    <xsl:variable name="uri" select="concat('classification:metadata:0:children:TYPE:',@ID)" />
    <xsl:for-each select="document($uri)/mycoreclass/categories/category/label[@xml:lang='x-mapper']/@text">
      <mods:genre type="intern" authorityURI="{$URI_BASE}mir_genres" valueURI="{$URI_BASE}mir_genres#{substring-after(.,':')}" />
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="mediaTypes/category">
    <xsl:variable name="uri" select="concat('classification:metadata:0:children:FORMAT:',@ID)" />
    <xsl:for-each select="document($uri)/mycoreclass/categories/category/label[@xml:lang='x-mapper']/@text">
      <xsl:for-each select="xalan:tokenize(substring-after(translate(.,'_',' '),':'),',')">
        <mods:typeOfResource>
          <xsl:value-of select="normalize-space(.)" />
        </mods:typeOfResource>
      </xsl:for-each>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="orgUnits/category">
    <mods:name type="corporate" authorityURI="{$URI_BASE}mir_institutes" valueURI="{$URI_BASE}mir_institutes#{@ID}">
      <mods:role>
        <mods:roleTerm authority="marcrelator" type="code">his</mods:roleTerm>
      </mods:role>
    </mods:name>
  </xsl:template>
  
  <xsl:template match="subject/category[@CLASSID='DDC']" priority="1">
    <mods:classification authority="ddc">
      <xsl:value-of select="@ID" />
    </mods:classification>
  </xsl:template>

  <xsl:template match="subject/category">
    <mods:classification authorityURI="{$URI_BASE}{@CLASSID}" valueURI="{$URI_BASE}{@CLASSID}#{@ID}" />
  </xsl:template>
  
  <xsl:template match="subjects[subject/category[@CLASSID='DDC']]" mode="ddc2sdnb">
    <!-- Map DDC to SDNB using mapping attributes in DDCM classification: -->
    <xsl:variable name="mapped">
      <mapped>
        <xsl:for-each select="subject/category[@CLASSID='DDC']">
          <xsl:variable name="uri" select="concat('classification:metadata:0:children:DDCm:',@ID)" />
          <xsl:for-each select="document($uri)//category/label[lang('x-mapping')]/@text">
            <sdnb>
              <xsl:value-of select="substring-after(.,'SDNB:')" />
            </sdnb>
          </xsl:for-each>
        </xsl:for-each>
      </mapped>
    </xsl:variable>
    
    <!-- Remove duplicate mappings: -->
    <xsl:for-each select="xalan:nodeset($mapped)/mapped/sdnb">
      <xsl:if test="not(preceding-sibling::sdnb[text()=current()/text()])">
        <mods:classification authority="sdnb">
          <xsl:value-of select="text()" />
        </mods:classification>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="languages/language">
    <mods:language>
      <mods:languageTerm type="code" authority="rfc5646">
        <xsl:value-of select="document(concat('language:',.))/language/@xmlCode" />
      </mods:languageTerm>
    </mods:language>
  </xsl:template>
  
  <xsl:variable name="LICENSE_PREFIX">license:</xsl:variable>

  <xsl:template match="document" mode="license">
    <mods:accessCondition type="use and reproduction" xlink:type="simple">
      <xsl:attribute name="xlink:href">
        <xsl:value-of select="$URI_BASE" />
        <xsl:text>mir_licenses#</xsl:text>
        <xsl:choose>
          <xsl:when test="rightsRemarks/rightsRemark[starts-with(.,$LICENSE_PREFIX)]">
            <xsl:for-each select="rightsRemarks/rightsRemark[starts-with(.,$LICENSE_PREFIX)][1]">
              <xsl:value-of select="substring-after(text(),$LICENSE_PREFIX)" />
              <xsl:if test="starts-with(text(),concat($LICENSE_PREFIX,'cc_'))">_4.0</xsl:if> <!-- all existing CC categories are CC 4.0 in miless -->
            </xsl:for-each>
          </xsl:when>
          <xsl:otherwise>rights_reserved</xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
    </mods:accessCondition>
  </xsl:template>
  
  <xsl:template match="description">
    <mods:abstract>
      <xsl:apply-templates select="@lang" />
      <xsl:value-of select="text()" />
    </mods:abstract>
  </xsl:template>

  <xsl:template match="source|coverage|rightsRemark">
    <mods:note>
      <xsl:attribute name="type">
        <xsl:choose>
          <xsl:when test="name()='source'">original version</xsl:when>
          <xsl:when test="name()='coverage'">biographical/historical</xsl:when>
          <xsl:when test="name()='rightsRemark'">restriction</xsl:when>
        </xsl:choose>
      </xsl:attribute>
      <xsl:apply-templates select="@lang" />
      <xsl:value-of select="text()" />
    </mods:note>
  </xsl:template>

  <xsl:template match="identifier">
    <mods:identifier type="urn">
      <xsl:value-of select="." />
    </mods:identifier>
  </xsl:template>
  
  <xsl:variable name="DOI_PREFIX">doi.org/</xsl:variable>
  
  <xsl:template match="purl[contains(text(),$DOI_PREFIX)]">
    <mods:identifier type="doi">
      <xsl:value-of select="substring-after(text(),$DOI_PREFIX)" />
    </mods:identifier>
  </xsl:template>
  
  <xsl:variable name="PURL_PREFIX">purl.oclc.org/</xsl:variable>
  
  <xsl:template match="purl[contains(text(),$PURL_PREFIX)]">
    <mods:identifier type="purl">
      <xsl:value-of select="text()" />
    </mods:identifier>
  </xsl:template>

  <xsl:template match="keywords">
    <xsl:for-each select="xalan:tokenize(text(),',;')">
      <mods:subject>
        <mods:topic>
          <xsl:value-of select="normalize-space(.)" />
        </mods:topic>
      </mods:subject>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template match="@alias">
    <xsl:variable name="alias">
      <xsl:choose>
        <!-- cut alias of child: remove preceding alias of parent -->
        <xsl:when test="../relation[@type='isPartOf']">
          <xsl:variable name="url">
            <xsl:text>notnull:https://duepublico.uni-duisburg-essen.de/</xsl:text>
            <xsl:text>servlets/DocumentServlet?action=retrieve&amp;XSL.Style=xml&amp;id=</xsl:text>
            <xsl:value-of select="../relation[@type='isPartOf']/@target" />
          </xsl:variable>
          <xsl:variable name="parentDoc" select="document($url)/*" />
          <xsl:choose>
            <xsl:when test="not(name($parentDoc)='document')">
              <xsl:value-of select="." />
            </xsl:when>
            <xsl:when test="starts-with(.,$parentDoc/@alias)">
              <xsl:variable name="childAlias" select="substring-after(.,$parentDoc/@alias)" />
              <xsl:choose>
                <xsl:when test="starts-with($childAlias,'/')">
                  <xsl:value-of select="substring-after($childAlias,'/')" /> 
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="$childAlias" /> 
                </xsl:otherwise>
              </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="." />
            </xsl:otherwise>
          </xsl:choose> 
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="." />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <servflags class="MCRMetaLangText">
      <servflag type="alias" inherited="0" form="plain">
        <xsl:value-of select="$alias" />
      </servflag>
    </servflags>
  </xsl:template>

  <xsl:template match="@status">
    <servstates class="MCRMetaClassification">
      <servstate inherited="0" classid="state">
        <xsl:attribute name="categid">
          <xsl:choose>
            <xsl:when test=".='mirgrated'">published</xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="." />
            </xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>
      </servstate>
    </servstates>
  </xsl:template>
  
  <xsl:template match="identifier" mode="dateIssued">
    <xsl:variable name="urn_j" select="translate(.,'0123456789','JJJJJJJJJJ')" />

    <xsl:if test="contains($urn_j,'JJJ-JJJJJJJJ-')">
      <xsl:variable name="pos" select="string-length(substring-before($urn_j,'JJJ-JJJJJJJJ-'))+string-length('JJJ-')+1" />
      <xsl:variable name="day" select="substring(.,$pos,8)" />

      <mods:originInfo eventType="publication">
        <mods:dateIssued encoding="w3cdtf">
          <xsl:value-of select="substring($day,1,4)" />
          <xsl:text>-</xsl:text>
          <xsl:value-of select="substring($day,5,2)" />
          <xsl:text>-</xsl:text>
          <xsl:value-of select="substring($day,7,2)" />
        </mods:dateIssued>
      </mods:originInfo>
    </xsl:if>
  </xsl:template>

  <xsl:template match="dates">
    <mods:originInfo eventType="creation">
      <xsl:apply-templates select="date[@type='created']" />
      <xsl:apply-templates select="date[@type='modified']" />
      <xsl:apply-templates select="date[@type='submitted']" />
      <xsl:apply-templates select="date[@type='accepted']" />
    </mods:originInfo>
    <xsl:if test="date[@type='validFrom']|date[@type='validTo']"> 
      <mods:originInfo eventType="validity">
        <xsl:apply-templates select="date[@type='validFrom']" />
        <xsl:apply-templates select="date[@type='validTo']" />
      </mods:originInfo>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="date[@type='submitted']|date[@type='accepted']">
    <mods:dateOther type="{@type}">
      <xsl:apply-templates select="text()" />
    </mods:dateOther>
  </xsl:template>

  <xsl:template match="date[@type='created']">
    <mods:dateCreated>
      <xsl:apply-templates select="text()" />
    </mods:dateCreated>
  </xsl:template>

  <xsl:template match="date[@type='modified']">
    <mods:dateModified>
      <xsl:apply-templates select="text()" />
    </mods:dateModified>
  </xsl:template>

  <xsl:template match="date[@type='validTo']">
    <mods:dateValid point="start">
      <xsl:apply-templates select="text()" />
    </mods:dateValid>
  </xsl:template>

  <xsl:template match="date[@type='validFrom']">
    <mods:dateValid point="end">
      <xsl:apply-templates select="text()" />
    </mods:dateValid>
  </xsl:template>

  <xsl:template match="date/text()">
    <xsl:attribute name="encoding">w3cdtf</xsl:attribute>
    <xsl:value-of select="substring(.,7,4)" />
    <xsl:text>-</xsl:text>
    <xsl:value-of select="substring(.,4,2)" />
    <xsl:text>-</xsl:text>
    <xsl:value-of select="substring(.,1,2)" />
  </xsl:template>
  
  <xsl:template match="links">
    <mods:location>
      <xsl:for-each select="link">
        <mods:url>
          <xsl:value-of select="." />
        </mods:url>
      </xsl:for-each>
    </mods:location>
  </xsl:template>

  <xsl:template match="relation[@type='isPartOf']" mode="structure">
    <xsl:variable name="href">
      <xsl:text>duepublico_mods_</xsl:text>
      <xsl:for-each select="@target">
        <xsl:call-template name="formatID" />
      </xsl:for-each>
    </xsl:variable>
    <xsl:if test="document(concat('notnull:mcrobject:',$href))/mycoreobject/@ID=$href">
      <structure>
        <parents class="MCRMetaLinkID">
          <parent inherited="0" xlink:type="locator" xlink:href="{$href}" />
        </parents>
      </structure>
    </xsl:if>
  </xsl:template>

  <xsl:template match="relation[@type='isPartOf']|relation[@type='references']|relation[@type='isVersionOf']">
    <xsl:variable name="type">
      <xsl:choose>
        <xsl:when test="@type='isPartOf'">host</xsl:when>
        <xsl:when test="@type='isVersionOf'">preceding</xsl:when>
        <xsl:when test="@type='references'">references</xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="href">
      <xsl:text>duepublico_mods_</xsl:text>
      <xsl:for-each select="@target">
        <xsl:call-template name="formatID" />
      </xsl:for-each>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="document(concat('notnull:mcrobject:',$href))/mycoreobject/@ID=$href">
        <mods:relatedItem type="{$type}" xlink:href="{$href}" />
      </xsl:when>
      <xsl:otherwise>
        <error>Dokument hat Verweis <xsl:value-of select="@type" /> auf nicht migriertes Dokument: <xsl:value-of select="@target" /></error>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="relation[@type='hasPart']" />
  <xsl:template match="relation[@type='hasVersion']" />
  <xsl:template match="relation[@type='isReferencedBy']" />

  <xsl:template match="relation">
    <error>Dokument hat unbekannten Verweistyp <xsl:value-of select="@type" /> auf anderes Dokument: <xsl:value-of select="@target" /></error>
  </xsl:template>

  <xsl:template match="document" mode="errors">
    <xsl:if test="@public='false'">
      <error>Dokument nicht öffentlich zugänglich, Zugriff ist geschützt</error>
    </xsl:if>
    <xsl:if test="derivates/derivate[@private='true']">
      <error>Dokument enthält privates Derivat</error>
    </xsl:if>
    <xsl:if test="derivates/derivate[@streamDownloadAllowed='false']">
      <error>Dokument enthält Derivat, bei dem der Stream-Download verboten sein soll</error>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="derivate">
    <xsl:choose>
      <xsl:when test="not(files/file)">
        <error>Derivat besitzt keine Dateien</error>
      </xsl:when>
      <xsl:otherwise>
        <mycorederivate xsi:noNamespaceSchemaLocation="datamodel-derivate.xsd">
          <xsl:apply-templates select="@ID" />
          <xsl:apply-templates select="@documentID" mode="label" />
          <derivate display="true">
            <xsl:apply-templates select="@documentID" />
            <xsl:call-template name="mainFile" />
          </derivate>
          <service>
            <servdates class="MCRMetaISO8601Date">
              <xsl:apply-templates select="date" />
            </servdates>
          </service>
          <xsl:copy-of select="files/file" />
        </mycorederivate>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="mainFile">
    <internals class="MCRMetaIFS" heritable="false">
      <internal inherited="0">
        <xsl:apply-templates select="files" />
      </internal>
    </internals>
  </xsl:template>
  
  <xsl:template match="files[count(file)=1]">
    <xsl:attribute name="maindoc">
      <xsl:value-of select="file[1]/path" />
    </xsl:attribute>
  </xsl:template>
  
  <xsl:template match="files[file[path=../@main]]">
    <xsl:attribute name="maindoc">
      <xsl:value-of select="@main" />
    </xsl:attribute>
  </xsl:template>
  
  <xsl:variable name="VIRTUAL_MAIN">/_virtual/</xsl:variable>
  
  <xsl:template match="files[contains(@main,$VIRTUAL_MAIN)][file[path=substring-before(../@main,$VIRTUAL_MAIN)]]">
    <xsl:attribute name="maindoc">
      <xsl:value-of select="substring-before(@main,$VIRTUAL_MAIN)" />
    </xsl:attribute>
  </xsl:template>

  <xsl:template match="derivate/@ID">
    <xsl:attribute name="ID">
      <xsl:text>duepublico_derivate_</xsl:text>
      <xsl:call-template name="formatID" />
    </xsl:attribute>
  </xsl:template>

  <xsl:template match="derivate/@documentID" mode="label">
    <xsl:attribute name="label">
      <xsl:text>data object from duepublico_mods_</xsl:text>
      <xsl:call-template name="formatID" />
    </xsl:attribute>
  </xsl:template>

  <xsl:template match="derivate/@documentID">
    <linkmetas class="MCRMetaLinkID" heritable="false">
      <linkmeta inherited="0" xlink:type="locator">
      <xsl:attribute name="xlink:href">
        <xsl:text>duepublico_mods_</xsl:text>
        <xsl:call-template name="formatID" />
      </xsl:attribute>
      </linkmeta>
    </linkmetas>
  </xsl:template>

  <xsl:template match="derivate/date">
    <servdate inherited="0">
      <xsl:apply-templates select="@type" />
      <xsl:value-of select="substring(.,7,4)" />
      <xsl:text>-</xsl:text>
      <xsl:value-of select="substring(.,4,2)" />
      <xsl:text>-</xsl:text>
      <xsl:value-of select="substring(.,1,2)" />
      <xsl:text>T</xsl:text>
      <xsl:value-of select="substring(.,12)" />
      <xsl:text>.000Z</xsl:text>
    </servdate>
  </xsl:template>
  
  <xsl:template match="derivate/date/@type[.='created']">
    <xsl:attribute name="type">createdate</xsl:attribute>
  </xsl:template>

  <xsl:template match="derivate/date/@type[.='modified']">
    <xsl:attribute name="type">modifydate</xsl:attribute>
  </xsl:template>

  <xsl:template match="*|@*" />
  
</xsl:stylesheet>
