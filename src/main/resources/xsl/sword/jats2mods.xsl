<?xml version="1.0" encoding="utf-8"?>

<!-- Used to import JATs metadata from DeepGreen via SWORD -->
<!-- See https://jats.nlm.nih.gov -->

<!-- TODO: funding-group -->
<!-- TODO: map article-type to mods:genre -->
<!-- TODO: lookup existing host for xlink:href -->

<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xlink="http://www.w3.org/1999/xlink" 
  xmlns:xalan="http://xml.apache.org/xalan"
  xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation" 
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns:cmd="http://www.cdlib.org/inside/diglib/copyrightMD"
  exclude-result-prefixes="xalan i18n">

  <xsl:output method="xml" encoding="UTF-8" indent="yes" xalan:indent-amount="2" />

  <xsl:param name="MIR.projectid.default" />

  <!-- Helpers to convert uppercase to lowercase -->
  <xsl:variable name="upperABC" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'" />
  <xsl:variable name="lowerABC" select="'abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyz'" />

  <xsl:template match="article">
    <mods:mods>
      <mods:genre type="intern">article</mods:genre>
      <mods:typeOfResource>text</mods:typeOfResource>
      <xsl:call-template name="collection" />
      
      <xsl:for-each select="front/article-meta">
        <xsl:apply-templates select="title-group" />
        <xsl:apply-templates select="contrib-group/contrib" />
        <xsl:apply-templates select="article-id" />
        <xsl:call-template name="originInfo" />
        <xsl:apply-templates select="../journal-meta" />
        <xsl:apply-templates select="abstract" />
        <xsl:apply-templates select="kwd-group/kwd" />
        <xsl:apply-templates select="permissions/copyright-statement" />
        <xsl:apply-templates select="permissions/license" />
        <xsl:call-template name="oa_nlz" />
      </xsl:for-each>
      <xsl:apply-templates select="@xml:lang" />
    </mods:mods>
  </xsl:template>
  
  <xsl:template name="collection">
    <xsl:variable name="uri">https://duepublico.uni-due.de/api/v1/classifications/collection</xsl:variable>
    <mods:classification authorityURI="{$uri}" valueURI="{$uri}#Pub" />
  </xsl:template>
  
  <xsl:template match="journal-meta">
    <mods:relatedItem type="host" xlink:href="{$MIR.projectid.default}_mods_00000000">
      <mods:genre type="intern">journal</mods:genre>
      <xsl:apply-templates select="journal-title-group" />
      <xsl:for-each select="../article-meta">
        <mods:part>
          <xsl:apply-templates select="volume" />
          <xsl:apply-templates select="issue" />
          <xsl:call-template name="pages" />
        </mods:part>
      </xsl:for-each>
      <xsl:apply-templates select="issn" />
      <xsl:call-template name="originInfo" />
    </mods:relatedItem>
  </xsl:template>
  
  <xsl:template name="originInfo">
    <xsl:if test="pub-date|publisher">
      <mods:originInfo eventType="publication">
        <xsl:call-template name="pub-date" />
        <xsl:apply-templates select="publisher" />
      </mods:originInfo>
    </xsl:if>
  </xsl:template>
  
  <xsl:template name="pages">
    <xsl:if test="fpage|lpage">
      <mods:extent unit="pages">
        <xsl:apply-templates select="fpage|lpage" />
      </mods:extent>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="fpage">
    <mods:start>
      <xsl:value-of select="." />
    </mods:start>
  </xsl:template>
  
  <xsl:template match="lpage">
    <mods:end>
      <xsl:value-of select="." />
    </mods:end>
  </xsl:template>

  <xsl:template match="article/@xml:lang">
    <mods:language>
      <mods:languageTerm type="code" authority="rfc5646">
        <xsl:value-of select="translate(.,$upperABC,$lowerABC)" />
      </mods:languageTerm>
    </mods:language>
  </xsl:template>
  
  <xsl:variable name="idTypes" select="document('classification:metadata:-1:children:identifier')//categories" />

  <xsl:template match="article-id">
    <!-- only import supported identifier types -->
    <xsl:if test="$idTypes/category[@ID=current()/@pub-id-type]">
      <mods:identifier type="{@pub-id-type}">
        <xsl:value-of select="." />
      </mods:identifier>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="title-group">
    <mods:titleInfo>
      <xsl:apply-templates select="article-title" />
      <xsl:apply-templates select="subtitle" />
    </mods:titleInfo>
    <xsl:apply-templates select="trans-title-group" />
  </xsl:template>
  
  <xsl:template match="article-title">
    <xsl:copy-of select="@xml:lang" />
    <xsl:if test="not(@xml:lang)">
      <xsl:copy-of select="/*/@xml:lang" />
    </xsl:if>
    <mods:title>
      <xsl:value-of select="." />
    </mods:title>
  </xsl:template>

  <xsl:template match="trans-title">
    <xsl:copy-of select="@xml:lang" />
    <mods:title>
      <xsl:value-of select="." />
    </mods:title>
  </xsl:template>

  <xsl:template match="subtitle|trans-subtitle">
    <mods:subTitle>
      <xsl:value-of select="." />
    </mods:subTitle>
  </xsl:template>
  
  <xsl:template match="trans-title-group">
    <mods:titleInfo type="translated">
      <xsl:apply-templates select="trans-title" />
      <xsl:apply-templates select="trans-subtitle" />
    </mods:titleInfo>
  </xsl:template>
  
  <xsl:template match="journal-title-group">
    <xsl:apply-templates select="journal-title" />
    <xsl:apply-templates select="abbrev-journal-title" />
  </xsl:template>
  
  <xsl:template match="journal-title">
    <mods:titleInfo>
      <xsl:copy-of select="@xml:lang" />
      <mods:title>
        <xsl:value-of select="." />
      </mods:title>
    </mods:titleInfo>
  </xsl:template>

  <xsl:template match="abbrev-journal-title">
    <mods:titleInfo type="abbreviated">
      <xsl:copy-of select="@xml:lang" />
      <mods:title>
        <xsl:value-of select="." />
      </mods:title>
    </mods:titleInfo>
  </xsl:template>

  <xsl:template match="contrib">
    <mods:name type="personal">
      <xsl:for-each select="name">
        <xsl:apply-templates select="surname" />
        <xsl:apply-templates select="given-names" />
        <xsl:apply-templates select="prefix|suffix" />
      </xsl:for-each>
      <xsl:call-template name="affiliation" />
      <xsl:apply-templates select="@contrib-type" />
      <xsl:apply-templates select="contrib-id" />
    </mods:name>
  </xsl:template>
  
  <xsl:template match="surname">
    <mods:namePart type="family">
      <xsl:value-of select="." />
    </mods:namePart>
  </xsl:template>

  <xsl:template match="given-names">
    <mods:namePart type="given">
      <xsl:value-of select="." />
    </mods:namePart>
  </xsl:template>

  <xsl:template match="prefix|suffix">
    <mods:namePart type="termsOfAddress">
      <xsl:value-of select="." />
    </mods:namePart>
  </xsl:template>

  <!-- Try to map contributor roles by comparing labels in marcrelator classification -->

  <xsl:variable name="roles" select="document('classification:metadata:-1:children:marcrelator')/mycoreclass" />
  
  <xsl:template match="@contrib-type">
    <xsl:variable name="role" select="translate(.,$upperABC,$lowerABC)" />
    <xsl:variable name="categoryID" select="$roles//category[label[translate(@text,$upperABC,$lowerABC)=$role]]/@ID" />
  
    <mods:role>
      <mods:roleTerm>
        <xsl:choose>
          <xsl:when test="string-length($categoryID) &gt; 0">
            <xsl:attribute name="type">code</xsl:attribute>
            <xsl:attribute name="authority">marcrelator</xsl:attribute>
            <xsl:value-of select="$categoryID" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:attribute name="type">text</xsl:attribute>
            <xsl:value-of select="." />
          </xsl:otherwise>
        </xsl:choose>
      </mods:roleTerm>
    </mods:role>
  </xsl:template>
  
  <xsl:template name="affiliation">
    <xsl:choose>
      <!-- Link to affiliation via xref ID -->
      <xsl:when test="xref[(@ref-type='aff') or not(@ref-type)][string-length(@rid) > 0]">
        <xsl:apply-templates select="xref[(@ref-type='aff') or not(@ref-type)][string-length(@rid) > 0]" />
      </xsl:when>
      <!-- Affiliation is given at article level -->
      <xsl:when test="not(xref[(@ref-type='aff') or not(@ref-type)]) and //article-meta/aff[not(@*)][position()=last()][string-length(text()) > 0]">
        <xsl:apply-templates select="//article-meta/aff[not(@*)][position()=last()][string-length(text()) > 0]" />
      </xsl:when>
      <!-- Affiliation is given in aff ellement -->
      <xsl:otherwise>
        <xsl:apply-templates select="aff" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Affiliations may be linked via @id/xref -->  
  <xsl:key name="rid2aff" match="//article-meta/aff[@id]" use="@id" />
  
  <xsl:template match="xref[(@ref-type='aff') or not(@ref-type)]">
    <xsl:apply-templates select="key('rid2aff',@rid)" />
  </xsl:template>
  
  <xsl:template match="aff">
    <mods:affiliation>
      <xsl:choose>
        <xsl:when test="institution">
          <xsl:value-of select="institution" />
        </xsl:when>
        <xsl:when test="institution-wrap">
          <xsl:value-of select="institution-wrap/institution" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="." />
        </xsl:otherwise>
      </xsl:choose>
    </mods:affiliation>
  </xsl:template>
  
  <xsl:template match="contrib-id">
    <mods:nameIdentifier type="{@contrib-id-type}">
      <xsl:value-of select="." />
    </mods:nameIdentifier>
  </xsl:template>

  <!-- Ignore empty ORCIDs -->
  <xsl:template match="contrib-id[text()='http://orcid.org/']" />
  
  <xsl:template name="pub-date">
    <xsl:choose>
      <xsl:when test="pub-date[(@pub-type='ppub') or ((@date-type='pub') and (@publication-format='print'))]">
        <xsl:apply-templates select="pub-date[(@pub-type='ppub') or ((@date-type='pub') and (@publication-format='print'))][1]" />
      </xsl:when>
      <xsl:when test="pub-date[(@pub-type='epub') or ((@date-type='pub') and (@publication-format='electronic'))]">
        <xsl:apply-templates select="pub-date[(@pub-type='epub') or ((@date-type='pub') and (@publication-format='electronic'))][1]" />
      </xsl:when>
      <xsl:when test="pub-date[(@pub-type='ppub') or (@date-type='pub')]">
        <xsl:apply-templates select="pub-date[(@pub-type='ppub') or (@date-type='pub')][1]" />
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="pub-date[@iso-8601-date]">
    <mods:dateIssued encoding="iso8601">
      <xsl:value-of select="@iso-8601-date" />
    </mods:dateIssued>
  </xsl:template>
  
  <xsl:template match="pub-date">
    <mods:dateIssued encoding="iso8601">
      <xsl:value-of select="year" />
      <xsl:apply-templates select="month" />
      <xsl:apply-templates select="day" />
    </mods:dateIssued>
  </xsl:template>
  
  <xsl:template match="day|month">
    <xsl:text>-</xsl:text>
    <xsl:if test="string-length(.)=1">0</xsl:if>
    <xsl:value-of select="." />
  </xsl:template>

  <xsl:template match="volume|issue">
    <mods:detail type="{name()}">
      <mods:number>
        <xsl:value-of select="." />
      </mods:number>
    </mods:detail>
  </xsl:template>
  
  <xsl:template match="abstract[@type='toc']">
    <mods:tableOfContents>
      <xsl:copy-of select="@xml:lang" />
      <xsl:apply-templates select="*|text()" />
    </mods:tableOfContents>
  </xsl:template>

  <xsl:template match="abstract">
    <mods:abstract>
      <xsl:copy-of select="@xml:lang" />
      <xsl:apply-templates select="*|text()" />
    </mods:abstract>
  </xsl:template>
  
  <xsl:template match="kwd-group/kwd">
    <mods:subject>
      <mods:topic>
        <xsl:value-of select="." />
      </mods:topic>
    </mods:subject>
  </xsl:template>
  
  <xsl:template match="issn">
    <mods:identifier type="issn">
      <xsl:value-of select="." />
    </mods:identifier>
  </xsl:template>
  
  <xsl:template match="publisher">
    <xsl:apply-templates select="publisher-name" />
    <xsl:apply-templates select="publisher-loc" />
  </xsl:template>
  
  <xsl:template match="publisher-name">
    <mods:publisher>
      <xsl:value-of select="." />
    </mods:publisher>
  </xsl:template>

  <xsl:template match="publisher-loc">
    <mods:place>
      <mods:placeTerm type="text">
        <xsl:value-of select="." />
      </mods:placeTerm>
    </mods:place>
  </xsl:template>

  <xsl:template match="permissions/copyright-statement">
    <mods:accessCondition type="copyrightMD">
      <cmd:copyright copyright.status="copyrighted" publication.status="published"
        xsi:schemaLocation="http://www.cdlib.org/inside/diglib/copyrightMD https://www.cdlib.org/groups/rmg/docs/copyrightMD.xsd">
        <cmd:rights.holder>
          <cmd:name>© 2016 Walter de Gruyter GmbH &amp;amp; Co. KG, Berlin/Boston</cmd:name>
        </cmd:rights.holder>
      </cmd:copyright>
    </mods:accessCondition>
  </xsl:template>
  
  <!-- Map license URL to category in mir_licenses -->

  <xsl:variable name="mir_licenses" select="document('classification:metadata:-1:children:mir_licenses')/mycoreclass" />
  <xsl:variable name="mir_licenses_uri" select="$mir_licenses/label[@xml:lang='x-uri']/@text" />

  <xsl:template match="permissions/license">
    <xsl:variable name="url" select="@xlink:href" />
    <xsl:variable name="categoryID" select="$mir_licenses//category[url[@xlink:href=$url]]/@ID" />
    
    <mods:accessCondition type="use and reproduction">
      <xsl:choose>
        <xsl:when test="@xlink:href and (string-length($categoryID) &gt; 0)">
          <xsl:attribute name="xlink:href">
            <xsl:value-of select="concat($mir_licenses_uri,'#',$categoryID)" />
          </xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="license-p" />
        </xsl:otherwise>
      </xsl:choose>
    </mods:accessCondition>
  </xsl:template>

  <!-- OA im Zuge einer National-/Allianz-Lizenz -->
  <xsl:template name="oa_nlz">
    <mods:accessCondition type="use and reproduction" xlink:href="{$mir_licenses_uri}#oa_nlz" />
  </xsl:template>
  
</xsl:stylesheet>
