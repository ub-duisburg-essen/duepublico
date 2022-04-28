<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0"
  xmlns:acl="xalan://org.mycore.access.MCRAccessManager"
  xmlns:cc="http://www.d-nb.de/standards/cc/"
  xmlns:cmd="http://www.cdlib.org/inside/diglib/copyrightMD"
  xmlns:dc="http://purl.org/dc/elements/1.1/"
  xmlns:dcmitype="http://purl.org/dc/dcmitype/"
  xmlns:dcterms="http://purl.org/dc/terms/"
  xmlns:ddb="http://www.d-nb.de/standards/ddb/"
  xmlns:dini="http://www.d-nb.de/standards/xmetadissplus/type/"
  xmlns:doi="http://www.d-nb.de/standards/doi/"
  xmlns:exslt="http://exslt.org/common"
  xmlns:gndo="http://d-nb.info/standards/elementset/gnd#"
  xmlns:hdl="http://www.d-nb.de/standards/hdl/"
  xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
  xmlns:mcrxsl="xalan://org.mycore.common.xml.MCRXMLFunctions"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:pc="http://www.d-nb.de/standards/pc/"
  xmlns:piUtil="xalan://org.mycore.pi.frontend.MCRIdentifierXSLUtils"
  xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
  xmlns:sub="http://www.d-nb.de/standards/subject/"
  xmlns:thesis="http://www.ndltd.org/standards/metadata/etdms/1.0/"
  xmlns:urn="http://www.d-nb.de/standards/urn/"
  xmlns:xMetaDiss="http://www.d-nb.de/standards/xmetadissplus/"
  xmlns:xalan="http://xml.apache.org/xalan"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"

  exclude-result-prefixes="xalan mcrxsl mods i18n xsl piUtil xlink exslt rdf cmd">

  <xsl:output method="xml" encoding="UTF-8" indent="yes" />

  <xsl:include href="mods2record.xsl" />

  <xsl:param name="ServletsBaseURL" />
  <xsl:param name="WebApplicationBaseURL" />

  <!-- ====================   Short path to access the MODS   ==================== -->
  
  <xsl:variable name="mods" select="/mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods" />
  
  <!-- ====================   Main XMetaDissPlus output   ==================== -->

  <xsl:template match="mycoreobject" mode="metadata">
    <xMetaDiss:xMetaDiss xsi:schemaLocation="http://www.d-nb.de/standards/xmetadissplus/ http://files.dnb.de/standards/xmetadissplus/xmetadissplus.xsd">
      <xsl:for-each select="$mods">
        <xsl:call-template name="dc_title" />
        <xsl:call-template name="dcterms_alternative" />
        <xsl:call-template name="dc_creator" />
        <xsl:call-template name="dc_subject" />
        <xsl:call-template name="dcterms_abstract" />
        <xsl:call-template name="dc_publisher" />
        <xsl:call-template name="dc_contributor" />
        <xsl:call-template name="dcterms_created" />
        <xsl:call-template name="dcterms_dateAccepted" />
        <xsl:call-template name="dcterms_issued" />
        <xsl:call-template name="dcterms_modified" />
        <xsl:call-template name="dc_type" />
        <xsl:call-template name="dini_version_driver" />
        <xsl:call-template name="dc_identifier" />
        <xsl:call-template name="dcterms_extent" />
        <xsl:call-template name="dcterms_medium" />
        <xsl:call-template name="dc_source" />
        <xsl:call-template name="dc_language" />
        <xsl:call-template name="dcterms_isPartOf" />
        <xsl:call-template name="thesis_degree" />
        <xsl:call-template name="files" />
        <xsl:call-template name="ddb_identifier" />
        <xsl:call-template name="ddb_rights" />
        <xsl:call-template name="ddb_license" />
       </xsl:for-each>
    </xMetaDiss:xMetaDiss>
  </xsl:template>
  
  <!-- ====================   Helpers to set language info   ==================== -->

  <xsl:param name="MCR.Metadata.DefaultLang" select="'de'" />

  <xsl:variable name="languages" select="document('classification:metadata:-1:children:rfc5646')" />

  <xsl:key name="category" match="category" use="@ID" />

  <xsl:variable name="modsLang" select="$mods/mods:language/mods:languageTerm[@authority='rfc5646'][1]" />

  <xsl:template name="setLangAttribute">
    <xsl:variable name="langCode">
      <xsl:choose>
        <xsl:when test="@xml:lang">
          <xsl:value-of select="@xml:lang" />
        </xsl:when>
        <xsl:when test="$modsLang">
          <xsl:value-of select="$modsLang" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$MCR.Metadata.DefaultLang" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:attribute name="lang">
      <xsl:for-each select="$languages">
        <xsl:value-of select="key('category', $langCode)/label[lang('x-bibl')]/@text" />
      </xsl:for-each>
    </xsl:attribute>
  </xsl:template>

  <!-- ====================   Helpers to output files info   ==================== -->

  <xsl:variable name="derivatesTemp">
    <xsl:for-each select="mycoreobject/structure/derobjects/derobject[mcrxsl:isDisplayedEnabledDerivate(@xlink:href)]">
      <der id="{@xlink:href}">
        <xsl:copy-of select="document(concat('xslStyle:mcr_directory-recursive:ifs:',@xlink:href,'/'))" />
      </der>
    </xsl:for-each>
  </xsl:variable>
  <xsl:variable name="derivates" select="xalan:nodeset($derivatesTemp)" />

  <xsl:key name="contentType" match="child" use="contentType" />

  <!-- ====================   Helper for roles  ==================== -->

  <xsl:variable name="marcrelator" select="document('classification:metadata:-1:children:marcrelator')" />

  <!-- ====================   dc:title   ==================== -->

  <xsl:template name="dc_title">
    <xsl:for-each select="mods:titleInfo[not(@altFormat)][not(@type) or (@type='translated')]">
      <dc:title xsi:type="ddb:titleISO639-2">
        <xsl:call-template name="setLangAttribute" />
        <xsl:apply-templates select="@type" />
        <xsl:apply-templates select="." mode="titleText">
          <xsl:with-param name="withSubTitle" select="false()" />
        </xsl:apply-templates>
      </dc:title>
    </xsl:for-each>
  </xsl:template>

  <!-- ====================   dcterms:alternative   ==================== -->

  <xsl:template name="dcterms_alternative">
  
    <!--  mods:subTitle should be delivered as dcterms:alternative -->
    <xsl:for-each select="mods:titleInfo[not(@altFormat)][not(@type) or (@type='translated')][mods:subTitle]">
      <dcterms:alternative xsi:type="ddb:talternativeISO639-2">
        <xsl:call-template name="setLangAttribute" />
        <xsl:apply-templates select="@type" />
        <xsl:value-of select="mods:subTitle" />
      </dcterms:alternative>
    </xsl:for-each>
    
    <!-- Note: No uniform, abbreviated or alternative title should be delivered (e-mail from DNB) -->
    
  </xsl:template>

  <!-- ====================   helpers for title output   ==================== -->

  <xsl:template match="mods:titleInfo" mode="titleText">
    <xsl:param name="withSubTitle" />

    <xsl:for-each select="mods:nonSort">
      <xsl:value-of select="." />
      <xsl:text> </xsl:text>
    </xsl:for-each>
    <xsl:value-of select="mods:title" />
    <xsl:if test="boolean($withSubTitle)">
      <xsl:for-each select="mods:subTitle">
        <xsl:text> : </xsl:text>
        <xsl:value-of select="." />
      </xsl:for-each>
    </xsl:if>
  </xsl:template>

  <xsl:template match="mods:titleInfo/@type[.='translated']">
    <xsl:attribute name="ddb:type">translated</xsl:attribute>
  </xsl:template>

  <!-- ====================   dc:creator   ==================== -->

  <xsl:template name="dc_creator">
    <xsl:variable name="creatorRoles" select="$marcrelator/mycoreclass/categories/category[@ID='cre']/descendant-or-self::category" />
    <xsl:for-each select="mods:name[mods:role/mods:roleTerm[$creatorRoles/@ID=text()]]">
      <dc:creator xsi:type="pc:MetaPers">
        <xsl:apply-templates select="." mode="pc_person" />
      </dc:creator>
    </xsl:for-each>
  </xsl:template>

  <!-- ====================   pc:person   ==================== -->

  <xsl:template match="mods:name" mode="pc_person">
    <pc:person>
      <xsl:apply-templates select="mods:nameIdentifier[@type='gnd']" />
      <xsl:apply-templates select="mods:nameIdentifier[@type='orcid']" />
      <xsl:apply-templates select="." mode="pc_name" />
    </pc:person>
  </xsl:template>

  <xsl:template match="mods:nameIdentifier[@type='gnd']">
    <xsl:attribute name="ddb:GND-Nr">
      <xsl:value-of select="." />
    </xsl:attribute>
  </xsl:template>

  <xsl:template match="mods:nameIdentifier[@type='orcid']">
    <ddb:ORCID>
      <xsl:value-of select="." />
    </ddb:ORCID>
  </xsl:template>

  <xsl:template match="mods:name[@type='personal']" mode="pc_name">
    <pc:name type="nameUsedByThePerson">
      <xsl:choose>
        <xsl:when test="mods:namePart[@type='family'] and mods:namePart[@type='given']">
          <pc:foreName>
            <xsl:for-each select="mods:namePart[@type='given']">
              <xsl:value-of select="."/>
              <xsl:if test="position() != last()">
                <xsl:text> </xsl:text>
              </xsl:if>
            </xsl:for-each>
          </pc:foreName>
          <pc:surName>
            <xsl:value-of select="normalize-space(mods:namePart[@type='family'])" />
          </pc:surName>
        </xsl:when>
        <xsl:when test="contains(mods:displayForm, ',')">
          <pc:foreName>
            <xsl:value-of select="normalize-space(substring-after(mods:displayForm,','))" />
          </pc:foreName>
          <pc:surName>
            <xsl:value-of select="normalize-space(substring-before(mods:displayForm,','))" />
          </pc:surName>
        </xsl:when>
        <xsl:otherwise>
          <pc:personEnteredUnderGivenName>
            <xsl:value-of select="mods:displayForm" />
          </pc:personEnteredUnderGivenName>
        </xsl:otherwise>
      </xsl:choose>
    </pc:name>
  </xsl:template>

  <xsl:template match="mods:name[@type='corporate']" mode="pc_name">
    <pc:name type="otherName" otherNameType="organisation">
      <pc:organisationName>
        <xsl:value-of select="(mods:name|mods:displayForm)[1]" />
      </pc:organisationName>
    </pc:name>
  </xsl:template>

  <!-- ====================   dc:subject   ==================== -->

  <xsl:template name="dc_subject">
    <xsl:apply-templates select="mods:classification[@authority='sdnb']" />
    <xsl:apply-templates select="mods:classification[@authority='ddc']" />
    <xsl:apply-templates select="mods:subject/mods:topic|mods:subject/mods:geographic" />
  </xsl:template>

  <xsl:template match="mods:classification[@authority='sdnb']">
    <dc:subject xsi:type="xMetaDiss:DDC-SG">
      <xsl:value-of select="." />
    </dc:subject>
  </xsl:template>

  <xsl:template match="mods:classification[@authority='ddc']">
    <dc:subject xsi:type="dcterms:DDC">
      <xsl:variable name="uri" select="concat('classification:metadata:0:parents:DDC:',.)" />
      <xsl:value-of select="substring-before(document($uri)//category/label[1]/@text(),' ')" />
    </dc:subject>
  </xsl:template>
  
  <xsl:template match="mods:topic[@authority='gnd']|mods:geographic[@authority='gnd']">
    <dc:subject xsi:type="xMetaDiss:GND">
      <xsl:attribute name="ddb:GND-Nr" >
        <xsl:value-of select="substring-after(@valueURI,'d-nb.info/gnd/')"/>
      </xsl:attribute>
      <xsl:value-of select="." />
    </dc:subject>
  </xsl:template>

  <xsl:template match="mods:topic[not(@authority) or (@authority != 'gnd')]|mods:geographic[not(@authority) or (@authority != 'gnd')]">
    <dc:subject xsi:type="xMetaDiss:noScheme">
      <xsl:value-of select="text()" />
    </dc:subject>
  </xsl:template>

  <!-- ====================   dcterms:abstract   ==================== -->

  <xsl:template name="dcterms_abstract">
    <xsl:for-each select="mods:abstract[not(@altFormat)]">
      <dcterms:abstract xsi:type="ddb:contentISO639-2">
        <xsl:call-template name="setLangAttribute" />
        <xsl:value-of select="text()" />
      </dcterms:abstract>
    </xsl:for-each>
  </xsl:template>

  <!-- ====================   dc:publisher   ==================== -->

  <xsl:template name="dc_publisher">
    <xsl:variable name="publishers">
      <xsl:apply-templates select="//mods:originInfo[@eventType='publication'][mods:publisher][mods:place]" mode="dc_publisher" />
      <xsl:apply-templates select="//mods:name[mods:role/mods:roleTerm/text()='his' and @valueURI]" mode="dc_publisher" />
      <xsl:call-template name="publisherAsConfigured" />
    </xsl:variable>
    <xsl:copy-of select="xalan:nodeset($publishers)/dc:publisher[1]" />
  </xsl:template>

  <!-- ====================   dc:publisher from mods:originInfo   ==================== -->

  <xsl:template match="mods:originInfo[@eventType='publication'][mods:publisher][mods:place]" mode="dc_publisher">
    <dc:publisher xsi:type="cc:Publisher" type="dcterms:ISO3166">
      <cc:universityOrInstitution>
        <cc:name>
          <xsl:value-of select="mods:publisher" />
        </cc:name>
        <cc:place>
          <xsl:value-of select="mods:place/mods:placeTerm[@type='text']" />
        </cc:place>
      </cc:universityOrInstitution>
    </dc:publisher>
  </xsl:template>

  <!-- ====================   dc:publisher from mir_institutes   ==================== -->

  <xsl:template match="mods:name[mods:role/mods:roleTerm/text()='his' and @valueURI]" mode="dc_publisher">
    <xsl:variable name="hostingInstitutionID" select="substring-after(@valueURI, '#')" />
    <xsl:variable name="uri" select="concat('classification:metadata:0:parents:mir_institutes:',$hostingInstitutionID)" />
    <xsl:for-each select="document($uri)//category[@ID=$hostingInstitutionID]/ancestor-or-self::category[label[lang('x-place')]][1]">
      <xsl:variable name="placeSet" select="xalan:tokenize(string(label[lang('x-place')]/@text),'|')" />
      <dc:publisher xsi:type="cc:Publisher" type="dcterms:ISO3166" countryCode="DE">
        <cc:universityOrInstitution>
          <cc:name>
            <xsl:value-of select="$placeSet[1]" />
          </cc:name>
          <cc:place>
            <xsl:value-of select="$placeSet[2]" />
          </cc:place>
        </cc:universityOrInstitution>
        <xsl:if test="$placeSet[3]">
          <cc:address cc:Scheme="DIN5008">
            <xsl:value-of select="$placeSet[3]" />
          </cc:address>
        </xsl:if>
      </dc:publisher>
    </xsl:for-each>
  </xsl:template>

  <!-- ====================   dc:publisher from configuration   ==================== -->

  <xsl:param name="MCR.OAIDataProvider.RepositoryPublisherName" select="''" />
  <xsl:param name="MCR.OAIDataProvider.RepositoryPublisherPlace" select="''" />
  <xsl:param name="MCR.OAIDataProvider.RepositoryPublisherAddress" select="''" />

  <xsl:template name="publisherAsConfigured">
    <dc:publisher xsi:type="cc:Publisher" type="dcterms:ISO3166" countryCode="DE">
      <cc:universityOrInstitution>
        <cc:name>
          <xsl:value-of select="$MCR.OAIDataProvider.RepositoryPublisherName" />
        </cc:name>
        <cc:place>
          <xsl:value-of select="$MCR.OAIDataProvider.RepositoryPublisherPlace" />
        </cc:place>
      </cc:universityOrInstitution>
      <cc:address cc:Scheme="DIN5008">
        <xsl:value-of select="$MCR.OAIDataProvider.RepositoryPublisherAddress" />
      </cc:address>
    </dc:publisher>
  </xsl:template>

  <!-- ====================   dc:contributor   ==================== -->

  <xsl:template name="dc_contributor">
    <xsl:for-each select="mods:name[mods:role/mods:roleTerm[@type='code'][contains('ths rev edt',.)]]">
      <dc:contributor xsi:type="pc:Contributor">
        <xsl:attribute name="thesis:role">
          <xsl:if test="mods:role[mods:roleTerm='ths']">advisor</xsl:if>
          <xsl:if test="mods:role[mods:roleTerm='rev']">referee</xsl:if>
          <xsl:if test="mods:role[mods:roleTerm='edt']">editor</xsl:if>
        </xsl:attribute>
        <xsl:apply-templates select="." mode="pc_person" />
      </dc:contributor>
    </xsl:for-each>
  </xsl:template>

  <!-- ====================   dcterms:created   ==================== -->

  <xsl:template name="dcterms_created">
    <xsl:for-each select="mods:originInfo[@eventType='creation']/mods:dateCreated[@encoding='w3cdtf'][1]">
      <dcterms:created xsi:type="dcterms:W3CDTF">
        <xsl:value-of select="." />
      </dcterms:created>
    </xsl:for-each>
  </xsl:template>

  <!-- ====================   dcterms:dateAccepted   ==================== -->

  <xsl:template name="dcterms_dateAccepted">
    <xsl:for-each select="mods:originInfo[@eventType='creation']/mods:dateOther[@type='accepted'][@encoding='w3cdtf'][1]">
      <dcterms:dateAccepted xsi:type="dcterms:W3CDTF">
        <xsl:value-of select="." />
      </dcterms:dateAccepted>
    </xsl:for-each>
  </xsl:template>

  <!-- ====================   dcterms:issued   ==================== -->

  <xsl:template name="dcterms_issued">
    <xsl:for-each select="((.|mods:relatedItem[@type='host'])/mods:originInfo[@eventType='publication']/mods:dateIssued[@encoding='w3cdtf'])[1]">
      <dcterms:issued xsi:type="dcterms:W3CDTF">
        <xsl:value-of select="." />
      </dcterms:issued>
    </xsl:for-each>
  </xsl:template>

  <!-- ====================   dcterms:modified   ==================== -->

  <xsl:template name="dcterms_modified">
    <xsl:for-each select="/mycoreobject/service/servdates/servdate[@type='modifydate'][1]">
      <dcterms:modified xsi:type="dcterms:W3CDTF">
        <xsl:value-of select="." />
      </dcterms:modified>
    </xsl:for-each>
  </xsl:template>

  <!-- ====================   dc:type   ==================== -->

  <xsl:template name="dc_type">
    <dc:type xsi:type="dini:PublType">
      <xsl:choose>
        <xsl:when test="mods:classification[contains(@valueURI,'diniPublType#other')]">
          <xsl:text>Other</xsl:text>
        </xsl:when>
        <xsl:when test="mods:classification[contains(@authorityURI,'diniPublType')]">
          <xsl:value-of select="substring-after(mods:classification[contains(@authorityURI,'diniPublType')]/@valueURI,'diniPublType#')" />
        </xsl:when>
        <xsl:when test="contains(mods:genre/@valueURI, 'article')">contributionToPeriodical</xsl:when>
        <xsl:when test="contains(mods:genre/@valueURI, 'issue')">PeriodicalPart</xsl:when>
        <xsl:when test="contains(mods:genre/@valueURI, 'journal')">Periodical</xsl:when>
        <xsl:when test="contains(mods:genre/@valueURI, 'book')">book</xsl:when>
        <xsl:when test="contains(mods:genre/@valueURI, 'dissertation')">doctoralThesis</xsl:when>
        <xsl:when test="contains(mods:genre/@valueURI, 'habilitation')">doctoralThesis</xsl:when>
        <xsl:otherwise>Other</xsl:otherwise>
      </xsl:choose>
    </dc:type>
    <dc:type xsi:type="dcterms:DCMIType">Text</dc:type>
  </xsl:template>

  <!-- ====================   dini:version_driver   ==================== -->

  <xsl:template name="dini_version_driver">
    <dini:version_driver>publishedVersion</dini:version_driver>
  </xsl:template>

  <!-- ====================   dc:identifier   ==================== -->

  <xsl:variable name="primaryIdentifier">
    <xsl:variable name="URNs" select="$mods/mods:identifier[@type='urn'][starts-with(text(),'urn:nbn')]" />
    <xsl:variable name="DOIs" select="$mods/mods:identifier[@type='doi']" />
    <xsl:variable name="HDLs" select="$mods/mods:identifier[@type='hdl']" />
    <xsl:variable name="managedURNs" select="$URNs[piUtil:isManagedPI(text(), /mycoreobject/@ID)]" />
    <xsl:variable name="managedDOIs" select="$DOIs[piUtil:isManagedPI(text(), /mycoreobject/@ID)]" />
    
    <xsl:choose>
      <xsl:when test="$managedURNs[1]">
        <xsl:text>urn:nbn </xsl:text>
        <xsl:value-of select="$managedURNs[1]" />
      </xsl:when>
      <xsl:when test="$URNs[1]">
        <xsl:text>urn:nbn </xsl:text>
        <xsl:value-of select="$URNs[1]" />
      </xsl:when>
      <xsl:when test="$managedDOIs[1]">
        <xsl:text>doi:doi </xsl:text>
        <xsl:value-of select="$managedDOIs[1]" />
      </xsl:when>
      <xsl:when test="$DOIs[1]">
        <xsl:text>doi:doi </xsl:text>
        <xsl:value-of select="$DOIs[1]" />
      </xsl:when>
      <xsl:when test="$HDLs[1]">
        <xsl:text>hdl:hdl </xsl:text>
        <xsl:value-of select="$HDLs[1]" />
      </xsl:when>
    </xsl:choose>
  </xsl:variable>

  <xsl:template name="dc_identifier">
    <dc:identifier xsi:type="{substring-before($primaryIdentifier,' ')}">
      <xsl:value-of select="substring-after($primaryIdentifier,' ')" />
    </dc:identifier>
  </xsl:template>

  <!-- ====================   dcterms:extent   ==================== -->

  <xsl:template name="dcterms_extent">
    <xsl:for-each select="$mods/mods:physicalDescription/mods:extent">
      <dcterms:extent>
        <xsl:value-of select="text()"/>
      </dcterms:extent>
    </xsl:for-each>
  </xsl:template>

  <!-- ====================   dcterms:medium   ==================== -->

  <xsl:template name="dcterms_medium">
    <xsl:for-each select="$derivates/der/mcr_directory/children/child[generate-id(.)=generate-id(key('contentType', contentType)[1])]">
      <dcterms:medium xsi:type="dcterms:IMT">
        <xsl:value-of select="contentType" />
      </dcterms:medium>
    </xsl:for-each>
  </xsl:template>

  <!-- ====================   dc:source   ==================== -->

  <xsl:template name="dc_source">

    <xsl:for-each select="mods:identifier[@type='isbn']">
      <dc:source xsi:type="ddb:ISBN">
        <xsl:value-of select="text()" />
      </dc:source>
    </xsl:for-each>

    <xsl:for-each select="mods:note[@type='original version']">
      <dc:source xsi:type="ddb:noScheme">
        <xsl:value-of select="text()" />
      </dc:source>
    </xsl:for-each>

    <xsl:variable name="publisherRoles" select="$marcrelator/mycoreclass/categories/category[@ID='pbl']/descendant-or-self::category" />
    <xsl:variable name="publisherName" select="
      (.|mods:relatedItem[@type='host'])/mods:name[$publisherRoles/@ID=mods:role/mods:roleTerm/text()]/mods:name
      |
      (.|mods:relatedItem[@type='host'])/mods:name[$publisherRoles/@ID=mods:role/mods:roleTerm/text()]/mods:displayForm
    " />
    <xsl:variable name="publisherPlace" select="(.|mods:relatedItem[@type='host'])/mods:originInfo[not(@eventType) or @eventType='publication']/mods:place" />
    <xsl:for-each select="$publisherName[1]">
      <dc:source xsi:type="ddb:noScheme">
        <xsl:for-each select="$publisherPlace">
          <xsl:value-of select="mods:placeTerm" />
          <xsl:text> : </xsl:text>
        </xsl:for-each>
        <xsl:value-of select="text()" />
      </dc:source>
    </xsl:for-each>

  </xsl:template>

  <!-- ====================   dc:language   ==================== -->

  <xsl:template name="dc_language">
    <xsl:variable name="numLanguages" select="count(mods:language/mods:languageTerm[@authority='rfc5646'])" />
    <dc:language xsi:type="dcterms:ISO639-2">
      <xsl:choose>
        <xsl:when test="count(mods:language/mods:languageTerm[@authority='rfc5646']) &gt; 1">
          <!-- XMetaDissPlus allows only one language. In case of an multilingual publication send langcode "mul" -->
          <xsl:text>mul</xsl:text>
        </xsl:when>
        <xsl:when test="mods:language/mods:languageTerm[@authority='rfc5646']">
          <xsl:for-each select="mods:language/mods:languageTerm[@authority='rfc5646']">
            <xsl:value-of select="$languages//category[@ID=current()]/label[lang('x-bibl')]/@text" />
          </xsl:for-each>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$languages//category[@ID=$MCR.Metadata.DefaultLang]/label[lang('x-bibl')]/@text" />
        </xsl:otherwise>
      </xsl:choose>
    </dc:language>
  </xsl:template>

  <!-- ====================   dcterms:isPartOf   ==================== -->

  <xsl:template match="mods:relatedItem[@type='series']" mode="isPartOf">
  
    <xsl:apply-templates select="mods:identifier[@type='issn']" mode="isPartOf" />
        
    <dcterms:isPartOf xsi:type="ddb:noScheme">
      <xsl:apply-templates select="mods:titleInfo[not(@altFormat)][not(@type)][1]" mode="titleText">
        <xsl:with-param name="withSubtitle" select="boolean('true')" />
      </xsl:apply-templates>
      <xsl:for-each select="mods:part/mods:detail[@type='volume']">
        <xsl:text> ; </xsl:text>
        <xsl:value-of select="mods:number" />
      </xsl:for-each>
    </dcterms:isPartOf>

  </xsl:template>
  
  <xsl:template match="mods:identifier[@type='issn']" mode="isPartOf">
    <dcterms:isPartOf xsi:type="ddb:ISSN">
      <xsl:value-of select="text()" />
    </dcterms:isPartOf>
  </xsl:template>

  <xsl:template name="dcterms_isPartOf">
    <xsl:apply-templates select="mods:relatedItem[@type='series']" mode="isPartOf" />
    
    <!-- 
    <xsl:for-each select="mods:relatedItem[@type='host')]">

      <xsl:if test="@xlink:href">
        <dcterms:isPartOf xsi:type="ddb:ZSTitelID">
          <xsl:value-of select="@xlink:href" />
        </dcterms:isPartOf>
      </xsl:if>

      <xsl:for-each select="mods:identifier[@type='issn']">
        <dcterms:isPartOf xsi:type="ddb:ISSN">
          <xsl:value-of select="text()" />
        </dcterms:isPartOf>
      </xsl:for-each>

      <xsl:for-each select="mods:identifier[@type='isbn']">
        <dcterms:isPartOf xsi:type="ddb:ISBN">
          <xsl:value-of select="text()" />
        </dcterms:isPartOf>
      </xsl:for-each>

      <xsl:for-each select="mods:part/mods:detail[@type='volume']">
        <dcterms:isPartOf xsi:type="ddb:ZS-Volume">
          <xsl:value-of select="mods:number" />
        </dcterms:isPartOf>
      </xsl:for-each>

      <xsl:for-each select="mods:part/mods:detail[@type='issue']">
        <dcterms:isPartOf xsi:type="ddb:ZS-Issue">
          <xsl:value-of select="mods:number" />
        </dcterms:isPartOf>
      </xsl:for-each>

      <dcterms:isPartOf xsi:type="ddb:noScheme">
        <xsl:choose>
          <xsl:when test="mods:part/mods:detail[@type='volume']">
            <xsl:value-of select="mods:part/mods:detail[@type='volume']/mods:number" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:text> </xsl:text>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:text>;</xsl:text>
        <xsl:text> </xsl:text> Jahr 
        <xsl:text>;</xsl:text>
        <xsl:choose>
          <xsl:when test="mods:part/mods:detail[@type='issue']">
            <xsl:value-of select="mods:part/mods:detail[@type='issue']/mods:number" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:text> </xsl:text>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:text>;</xsl:text>
        <xsl:text>Stand: </xsl:text>
        <xsl:for-each select="//service/servdates/servdate[@type='modifydate'][1]">
          <xsl:value-of select="substring(.,9,2)" />
          <xsl:text>.</xsl:text>
          <xsl:value-of select="substring(.,6,2)" />
          <xsl:text>.</xsl:text>
          <xsl:value-of select="substring(.,1,4)" />
        </xsl:for-each>
        <xsl:text>;</xsl:text>
        <xsl:choose>
          <xsl:when test="mods:part/mods:extent[@unit='pages']/mods:start">
            <xsl:value-of select="mods:part/mods:extent[@unit='pages']/mods:start" />
            <xsl:if test="mods:part/mods:extent[@unit='pages']/mods:end">
              <xsl:text> - </xsl:text>
              <xsl:value-of select="mods:part/mods:extent[@unit='pages']/mods:end" />
            </xsl:if>
          </xsl:when>
          <xsl:when test="mods:part/mods:extent[@unit='pages']/mods:list">
            <xsl:value-of select="mods:part/mods:extent[@unit='pages']/mods:list" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:text> </xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </dcterms:isPartOf>
      
    </xsl:for-each>
    -->
      
  </xsl:template>

  <!-- ====================   thesis:degree   ==================== -->

  <xsl:template name="thesis_degree">
    <xsl:for-each select="mods:classification[contains(@authorityURI,'XMetaDissPlusThesisLevel')][1]">
      <thesis:degree>
        <thesis:level>
          <xsl:value-of select="substring-after(@valueURI,'#')" />
        </thesis:level>
        <thesis:grantor xsi:type="cc:Corporate" type="dcterms:ISO3166" countryCode="DE">
          <xsl:for-each select="..">
            <xsl:choose>
              <xsl:when test="mods:originInfo[@eventType='creation'][mods:publisher]">
                <cc:universityOrInstitution>
                  <xsl:for-each select="mods:originInfo[@eventType='creation']">
                    <cc:name>
                      <xsl:value-of select="mods:publisher" />
                    </cc:name>
                    <xsl:for-each select="mods:place">
                      <cc:place>
                        <xsl:value-of select="mods:placeTerm" />
                      </cc:place>
                    </xsl:for-each>
                  </xsl:for-each>
                </cc:universityOrInstitution>
              </xsl:when>
              <xsl:otherwise>
                <xsl:variable name="publishers">
                  <xsl:apply-templates select="//mods:name[mods:role/mods:roleTerm/text()='his' and @valueURI]" mode="dc_publisher" />
                  <xsl:call-template name="publisherAsConfigured" />
                </xsl:variable>
                <xsl:copy-of select="xalan:nodeset($publishers)[1]//cc:universityOrInstitution" />
              </xsl:otherwise>
            </xsl:choose>
          </xsl:for-each>
        </thesis:grantor>
      </thesis:degree>
    </xsl:for-each>
  </xsl:template>

  <!-- ====================   ddb:fileNumber   ==================== -->
  <!-- ====================   ddb:fileProperties   ==================== -->
  <!-- ====================   ddb:checksum   ==================== -->
  <!-- ====================   ddb:transfer   ==================== -->

  <xsl:template name="files">
    <xsl:if test="$derivates/der">

      <xsl:variable name="numFiles" select="count($derivates/der/mcr_directory/children//child[@type='file'])" />
      <ddb:fileNumber>
        <xsl:value-of select="$numFiles" />
      </ddb:fileNumber>

      <xsl:apply-templates mode="fileproperties" select="$derivates/der">
        <xsl:with-param name="numFiles" select="$numFiles" />
      </xsl:apply-templates>

      <xsl:if test="$numFiles = 1">
        <ddb:checksum ddb:type="MD5">
          <xsl:value-of select="$derivates/der/mcr_directory/children//child[@type='file']/md5" />
        </ddb:checksum>
      </xsl:if>

      <ddb:transfer ddb:type="dcterms:URI">
        <xsl:variable name="numDerivates" select="count($derivates/der)" />
        <xsl:choose>
          <xsl:when test="$numFiles = 1">
            <xsl:variable name="uri" select="$derivates/der/mcr_directory/children//child[@type='file']/uri" />
            <xsl:variable name="derId" select="substring-before(substring-after($uri,':/'), ':')" />
            <xsl:variable name="filePath" select="substring-after(substring-after($uri, ':'), ':')" />
            <!-- DNB requires ASCII-only URLs -->
            <xsl:variable name="encodedPath" select="mcrxsl:encodeURIPath(mcrxsl:decodeURIPath($filePath), true())" />
            <xsl:value-of select="concat($ServletsBaseURL,'MCRFileNodeServlet/',$derId,$encodedPath)" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:choose>
              <xsl:when test="$numDerivates = 1">
                <xsl:value-of select="concat($ServletsBaseURL,'MCRZipServlet/',$derivates/der/@id)" />
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="concat($ServletsBaseURL,'MCRZipServlet/',/mycoreobject/@ID)" />
              </xsl:otherwise>
            </xsl:choose>
          </xsl:otherwise>
        </xsl:choose>
      </ddb:transfer>
    </xsl:if>
  </xsl:template>

  <xsl:template mode="fileproperties" match="der[@id]">
    <xsl:param name="numFiles" />
    <xsl:variable name="derId" select="@id" />
    <xsl:for-each select="mcr_directory/children//child[@type='file']">
      <ddb:fileProperties>
        <xsl:attribute name="ddb:fileName"><xsl:value-of select="name" /></xsl:attribute>
        <xsl:attribute name="ddb:fileID"><xsl:value-of select="uri" /></xsl:attribute>
        <xsl:attribute name="ddb:fileSize"><xsl:value-of select="size" /></xsl:attribute>
        <xsl:if test="$numFiles &gt; 1">
          <xsl:attribute name="ddb:fileDirectory">
            <xsl:value-of select="concat($derId, substring-after(uri, concat('ifs:/',$derId,':')))" />
          </xsl:attribute>
        </xsl:if>
      </ddb:fileProperties>
    </xsl:for-each>
  </xsl:template>

  <!-- ====================   ddb:identifier   ==================== -->

  <xsl:template name="ddb_identifier">

    <xsl:for-each select="mods:identifier[not(text()=substring-after($primaryIdentifier,' '))][contains('urn doi hdl issn isbn',@type)]">
      <ddb:identifier ddb:type="DOI">
        <xsl:attribute name="ddb:type">
          <xsl:choose>
            <xsl:when test="@type='hdl'">HANDLE</xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="translate(@type,'abcdefghijklmnopqrstuvwxyz','ABCDEFGHIJKLMNOPQRSTUVWXYZ')" />
            </xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>
        <xsl:value-of select="text()" />
      </ddb:identifier>
    </xsl:for-each>

    <xsl:for-each select="/mycoreobject">
      <ddb:identifier ddb:type="URL">
        <xsl:value-of select="concat($WebApplicationBaseURL,'receive/',@ID)" />
      </ddb:identifier>
    </xsl:for-each>

  </xsl:template>

  <!-- ====================   ddb:rights   ==================== -->

  <xsl:template name="ddb_rights">
    <ddb:rights>
      <xsl:attribute name="ddb:kind">
        <xsl:choose>
          <xsl:when test="/mycoreobject/structure/derobjects/derobject[acl:checkPermission(@xlink:href,'read')]">free</xsl:when>
          <xsl:otherwise>domain</xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
    </ddb:rights>
  </xsl:template>

  <!-- ====================   ddb:license   ==================== -->

  <xsl:template name="ddb_license">

    <ddb:licence ddb:licenceType="access">
      <xsl:choose>
        <xsl:when test="$mods/mods:classification[contains(@authorityURI,'XMetaDissPlusAccessState')]">
          <xsl:value-of select="substring-after($mods/mods:classification[contains(@authorityURI,'XMetaDissPlusAccessState')]/@valueURI,'#')" />
        </xsl:when>
        <xsl:otherwise>uOA</xsl:otherwise>
      </xsl:choose>
  
    </ddb:licence>

    <xsl:for-each select="$mods/mods:accessCondition[@type='use and reproduction' and @xlink:href]">
      <xsl:variable name="licenseID" select="substring-after(@xlink:href,'#')" />
      <xsl:variable name="license" select="document(concat('classification:metadata:0:children:mir_licenses:',$licenseID))" />
      
      <xsl:choose>
        <!-- no license, all rights reserved -->
        <xsl:when test="$licenseID='rights_reserved'" />

        <!-- license classification contains a x-dnb-* label -->
        <xsl:when test="$license//label[starts-with(@xml:lang,'x-dnb-')]"> 
          <xsl:for-each select="$license//label[starts-with(@xml:lang,'x-dnb-')][contains(@text,':')]">
            <ddb:licence ddb:licenceType="{substring-before(@text,':')}">
              <xsl:value-of select="substring-after(@text,':')"/>
            </ddb:licence>
          </xsl:for-each>
        </xsl:when>
        
        <!-- license ID in classification starts with cc_ -> is Creative Commons -->
        <xsl:when test="starts-with($licenseID,'cc_')">
          <ddb:licence ddb:licenceType="cc">
            <xsl:value-of select="translate($licenseID,'_','-')"/>
          </ddb:licence>
        </xsl:when>
        
        <!-- output license label -->
        <xsl:otherwise>
          <ddb:licence ddb:licenceType="otherScheme">
            <xsl:for-each select="$license//category/label[lang('de')]">
              <xsl:value-of select="@text" />
              <xsl:if test="@description">
                <xsl:text>: </xsl:text>
                <xsl:value-of select="@description" />
              </xsl:if>
            </xsl:for-each> 
          </ddb:licence>
        </xsl:otherwise>
        
      </xsl:choose>
      
      <xsl:for-each select="$license//url[@xlink:href and @xlink:type='locator']">
        <ddb:licence ddb:licenceType="URL">
          <xsl:value-of select="@xlink:href"/>
        </ddb:licence>
      </xsl:for-each>
            
    </xsl:for-each>
    
  </xsl:template>

</xsl:stylesheet>
