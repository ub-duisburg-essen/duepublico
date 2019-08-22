<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:mcrmods="xalan://org.mycore.mods.classification.MCRMODSClassificationSupport"
  xmlns:mcrxsl="xalan://org.mycore.common.xml.MCRXMLFunctions" 
  xmlns:config="xalan://org.mycore.common.config.MCRConfiguration" 
  xmlns:xlink="http://www.w3.org/1999/xlink" 
  xmlns:mods="http://www.loc.gov/mods/v3" 
  exclude-result-prefixes="mcrxsl mcrmods mods xlink config">
  
  <xsl:param name="action" />
  <xsl:param name="type" />

  <xsl:param name="CurrentUser" />
  <xsl:param name="DefaultLang" />
  
  <xsl:param name="WebApplicationBaseURL" />
  <xsl:param name="ServletsBaseURL" />
  
  <xsl:param name="MCR.mir-module.EditorMail" />
  <xsl:param name="MCR.mir-module.MailSender" />

  <xsl:variable name="newline" select="'&#xa;&#xd;'" />
  
  <xsl:template match="/">
    <email>
      <xsl:choose>
        <xsl:when test="mycorederivate" />
        <xsl:when test="$CurrentUser = 'MCRJANITOR'" />
        <xsl:when test="mcrxsl:isCurrentUserInRole('admin')" />
        <xsl:when test="mcrxsl:isCurrentUserInRole('ediss')" />
        <xsl:when test="mcrxsl:isCurrentUserInRole('submitter')">
          <xsl:apply-templates select="mycoreobject" mode="e-mail" />
        </xsl:when>
      </xsl:choose>
    </email>
  </xsl:template>

  <xsl:template match="mycoreobject" mode="e-mail">
    <xsl:call-template name="from" />
    <xsl:apply-templates select="." mode="to" />
    <xsl:apply-templates select="." mode="reply-to" />
    <xsl:apply-templates select="." mode="subject" />
    
    <body>
      <xsl:call-template name="intro" />
      
      <xsl:for-each select="metadata/def.modsContainer/modsContainer/mods:mods">
        <xsl:apply-templates select="mods:titleInfo[1]" />
        <xsl:apply-templates select="mods:name[mods:role/mods:roleTerm='aut']" />
        <xsl:apply-templates select="mods:name[contains(@authorityURI,'mir_institutes')]" />
      </xsl:for-each>
      
      <xsl:apply-templates select="." mode="link" />
      <xsl:value-of select="$newline" />
      <xsl:apply-templates select="document('user:current')/user" />
    </body>
  </xsl:template>

  <!-- ========== from ========== -->
  
  <xsl:template name="from">
    <from>
      <xsl:value-of select="$MCR.mir-module.MailSender" />
    </from>
  </xsl:template>

  <!-- ========== to ========== -->

  <xsl:template match="mycoreobject" mode="to">
    <xsl:variable name="collection">
      <xsl:for-each select="metadata//mods:classification[contains(@valueURI,'/collection#')][1]">
        <xsl:value-of select="substring-after(@valueURI,'#')" />
      </xsl:for-each>
    </xsl:variable>

    <xsl:variable name="property" select="concat('DuEPublico.E-Mail.Collection.',$collection)" />
    <xsl:variable name="to" select="config:getString(config:instance(),$property,$MCR.mir-module.EditorMail)" />

    <xsl:if test="contains($to,'@')">
      <to>
        <xsl:value-of select="$to" />
      </to>
    </xsl:if>
  </xsl:template>
    
  <xsl:template match="mycoreobject" mode="reply-to">
    <xsl:variable name="createdBy" select="service/servflags[@class='MCRMetaLangText']/servflag[@type='createdby']" />
    <xsl:if test="string-length($createdBy) &gt; 0">
      <xsl:variable name="userEMail" select="document(concat('user:',$createdBy))/user/eMail" />
      <xsl:if test="string-length($userEMail) &gt; 0">
        <reply-to>
          <xsl:value-of select="$userEMail" />
        </reply-to>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <!-- ========== subject ========== -->

  <xsl:template match="mycoreobject" mode="subject">
    <subject>
      <xsl:for-each select="metadata/def.modsContainer/modsContainer/mods:mods">
        <xsl:choose>
          <xsl:when test="mods:genre[@type='kindof']">
            <xsl:apply-templates select="mods:genre[@type='kindof']" mode="printModsClassInfo" />
          </xsl:when>
          <xsl:when test="mods:genre[@type='intern']">
            <xsl:apply-templates select="mods:genre[@type='intern']" mode="printModsClassInfo" />
          </xsl:when>
          <xsl:otherwise>Objekt</xsl:otherwise>
        </xsl:choose>
        <xsl:text> </xsl:text>
       <xsl:call-template name="action" />
        <xsl:text>: </xsl:text>
        <xsl:value-of select="number(substring-after(/mycoreobject/@ID,'_mods_'))" />
        <xsl:for-each select="mods:name[1]">
          <xsl:text> / </xsl:text>
          <xsl:value-of select="mods:namePart[@type='family']" />
        </xsl:for-each>
        <xsl:for-each select="mods:titleInfo[1]">
          <xsl:text> / </xsl:text>
          <xsl:value-of select="mods:title" />
        </xsl:for-each>
      </xsl:for-each>
    </subject>
  </xsl:template>

  <!-- ========== action ========== -->

  <xsl:template name="action">
    <xsl:choose>
      <xsl:when test="$action='create'">erstellt</xsl:when>
      <xsl:when test="$action='update'">geändert</xsl:when>
      <xsl:when test="$action='delete'">gelöscht</xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$action" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- ========== intro ========== -->
 
  <xsl:template name="intro">
    <xsl:text>Eine Publikation wurde auf DuEPublico </xsl:text>
    <xsl:call-template name="action" />
    <xsl:text>:</xsl:text>
    <xsl:value-of select="$newline" />
    <xsl:value-of select="$newline" />
  </xsl:template>  

  <!-- ========== title ========== -->

  <xsl:template match="mods:titleInfo">
    <xsl:value-of select="mods:title" />
    <xsl:for-each select="mods:subTitle">
      <xsl:text> : </xsl:text>
      <xsl:value-of select="text()" />
    </xsl:for-each>
    <xsl:value-of select="$newline" />
  </xsl:template>  
  
  <!-- ========== authors ========== -->

  <xsl:template match="mods:name[mods:role/mods:roleTerm='aut']">
    <xsl:choose>
      <xsl:when test="mods:namePart[@type='given'] and mods:namePart[@type='family']">
        <xsl:value-of select="concat(mods:namePart[@type='family'], ', ',mods:namePart[@type='given'])" />
      </xsl:when>
      <xsl:when test="mods:displayForm">
        <xsl:value-of select="mods:displayForm" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="mods:namePart" />
      </xsl:otherwise>
    </xsl:choose>
    <xsl:choose>
      <xsl:when test="position() != last()">
        <xsl:text>; </xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$newline" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- ========== faculty / institute ========== -->
  
  <xsl:template match="mods:name[contains(@authorityURI,'mir_institutes')]">
    <xsl:for-each select="document(mcrmods:getClassCategParentLink(.))/mycoreclass/categories//category">
      <xsl:value-of select="label[lang('de')]/@text" />
      <xsl:if test="position() != last()"> &#187; </xsl:if>
    </xsl:for-each>
    <xsl:value-of select="$newline" />
  </xsl:template>

  <!-- ========== link ========== -->

  <xsl:template match="mycoreobject" mode="link">
    <xsl:value-of select="concat($WebApplicationBaseURL,'receive/',@ID)" />
    <xsl:value-of select="$newline" />
  </xsl:template>

  <!-- ========== user ========== -->

  <xsl:template match="user">
    <xsl:call-template name="action" />
    <xsl:text> von:</xsl:text>
    <xsl:value-of select="$newline" />
    <xsl:value-of select="$newline" />
    <xsl:value-of select="concat(realName,$newline)" />
    <xsl:value-of select="concat(eMail,$newline)" />
    <xsl:value-of select="concat(@name,' (',@realm,')',$newline)" />
    <xsl:value-of select="concat($ServletsBaseURL,'MCRUserServlet?action=show&amp;id=',@name,'@',@realm,$newline)" />
  </xsl:template>

  <!-- ========== classification support ========== -->

  <xsl:template match="category" mode="printModsClassInfo">
    <xsl:variable name="categurl">
      <xsl:if test="url">
        <xsl:choose>
            <!-- MCRObjectID should not contain a ':' so it must be an external link then -->
          <xsl:when test="contains(url/@xlink:href,':')">
            <xsl:value-of select="url/@xlink:href" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="concat($WebApplicationBaseURL,'receive/',url/@xlink:href)" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>
    </xsl:variable>
    <xsl:variable name="selectLang">
      <xsl:choose>
        <xsl:when test="label[lang($DefaultLang)]">
          <xsl:value-of select="$DefaultLang" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="label[1]/@xml:lang" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:for-each select="./label[lang($selectLang)]">
      <xsl:choose>
        <xsl:when test="string-length($categurl) != 0">
          <xsl:value-of select="concat(@text,' (',$categurl,')')" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="@text" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="*" mode="printModsClassInfo">
    <xsl:variable name="classlink" select="mcrmods:getClassCategLink(.)" />
    <xsl:choose>
      <xsl:when test="string-length($classlink) &gt; 0">
        <xsl:for-each select="document($classlink)/mycoreclass/categories/category">
          <xsl:apply-templates select="." mode="printModsClassInfo" />
        </xsl:for-each>
      </xsl:when>
      <xsl:when test="@valueURI">
        <xsl:apply-templates select="." mode="hrefLink" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="text()" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="*[@valueURI]" mode="hrefLink">
    <xsl:choose>
      <xsl:when test="mods:displayForm">
        <xsl:value-of select="mods:displayForm" />
      </xsl:when>
      <xsl:when test="@displayLabel">
        <xsl:value-of select="@displayLabel" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="@valueURI" />
      </xsl:otherwise>
    </xsl:choose>
    <xsl:value-of select="concat(' (',@valueURI,')')" />
  </xsl:template>

</xsl:stylesheet>