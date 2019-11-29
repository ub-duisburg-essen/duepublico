<?xml version="1.0" encoding="UTF-8"?>

<!-- Transforms <mycoreobject> with <mods:mods> into Adobe <xfdf> to fill PDF form -->

<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:mods="http://www.loc.gov/mods/v3" 
  xmlns:xalan="http://xml.apache.org/xalan"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns="http://ns.adobe.com/xfdf/"
  exclude-result-prefixes="xsl mods xalan xlink">

  <xsl:output method="xml" encoding="UTF-8" indent="yes" xalan:indent-amount="2" />

  <xsl:param name="WebApplicationBaseURL" />
  <xsl:param name="CurrentLang" />
  
  <xsl:template match="/mycoreobject">
    <xfdf>
      <xsl:apply-templates select="metadata/def.modsContainer/modsContainer/mods:mods" />
    </xfdf>
  </xsl:template>

  <xsl:template match="mods:mods">
    <xsl:variable name="collection" select="substring-after(mods:classification[contains(@valueURI,'/collection')]/@valueURI,'#')" />
    <xsl:variable name="config" select="document('resource:xfdf-config.xml')/xfdf-config" />
    <xsl:variable name="form" select="$config/collection[@id=$collection]/form[lang($CurrentLang)]" />
    
    <f href="{$WebApplicationBaseURL}{$form/file}" />
    <xsl:apply-templates select="." mode="fields" />
    <ids original="{$form/original}" modified="{$form/modified}" />
  </xsl:template>

  <xsl:template match="mods:mods" mode="fields">
    <fields>
      <xsl:apply-templates select="mods:titleInfo[1]" />
      <xsl:call-template name="authors" />
      <xsl:apply-templates select="mods:name[@type='personal'][mods:role/mods:roleTerm='aut'][1]" />
      <xsl:apply-templates select="mods:name[@type='corporate'][mods:role/mods:roleTerm='his'][1]" />
      <xsl:apply-templates select="mods:name[@type='personal'][mods:role/mods:roleTerm='ths'][1]" />
      <xsl:apply-templates select="mods:genre[@type='intern']" />
      <xsl:apply-templates select="mods:originInfo/mods:dateOther[@type='accepted']" />
      <xsl:apply-templates select="mods:accessCondition[@type='use and reproduction'][contains(@xlink:href,'mir_licenses')]" /> 
    </fields>
  </xsl:template>
  
  <xsl:template name="authors">
    <field name="Authors">
      <value>
      <xsl:for-each select="mods:name[mods:role/mods:roleTerm='aut']">
        <xsl:value-of select="mods:namePart[@type='family']" />
        <xsl:for-each select="mods:namePart[@type='given']">
          <xsl:text>, </xsl:text>
          <xsl:value-of select="." />
        </xsl:for-each>
        <xsl:if test="position() != last()">, </xsl:if>
      </xsl:for-each>
      </value>
    </field>
  </xsl:template>

  <xsl:template match="mods:name[mods:role/mods:roleTerm='aut']">
    <field name="Name">
      <value>
        <xsl:value-of select="mods:namePart[@type='family']" />
      </value>
    </field>
    <field name="Firstname">
      <value>
        <xsl:value-of select="mods:namePart[@type='given']" />
      </value>
    </field>
  </xsl:template>
  
  <xsl:template match="mods:name[mods:role/mods:roleTerm='his']">
    <xsl:variable name="categoryID" select="substring-after(@valueURI,'#')" />
    <xsl:variable name="categories" select="document(concat('classification:metadata:-1:parents:mir_institutes:',$categoryID))" />
    
    <field name="Faculty">
      <value>
        <xsl:value-of select="$categories//category[1]/label[lang('de')]/@text" />
      </value>
    </field>
  </xsl:template>

  <xsl:template match="mods:titleInfo">
    <field name="Title">
      <value>
        <xsl:if test="mods:nonSort">
          <xsl:value-of select="mods:nonSort" />
          <xsl:text> </xsl:text>
        </xsl:if>
        <xsl:value-of select="mods:title" />
        <xsl:if test="mods:subTitle">
          <xsl:text> : </xsl:text>
          <xsl:value-of select="mods:subTitle" />
        </xsl:if>
      </value>
    </field>
  </xsl:template>
  
  <xsl:template match="mods:dateOther[@type='accepted']">
    <field name="Date_oral">
      <xsl:call-template name="output.date" />
    </field>
  </xsl:template>
  
  <xsl:template name="output.date">
    <value>
      <xsl:value-of select="substring(.,9,2)" />
      <xsl:text>.</xsl:text>
      <xsl:value-of select="substring(.,6,2)" />
      <xsl:text>.</xsl:text>
      <xsl:value-of select="substring(.,1,4)" />
    </value>
  </xsl:template>

  <xsl:template match="mods:name[mods:role/mods:roleTerm='ths']">
    <field name="Name_assessor">
      <value>
        <xsl:value-of select="mods:namePart[@type='family']" />
        <xsl:text>, </xsl:text>
        <xsl:value-of select="mods:namePart[@type='given']" />
      </value>
    </field>
  </xsl:template>
  
  <xsl:template match="mods:genre[@type='intern']">
    <xsl:variable name="categoryID" select="substring-after(@valueURI,'#')" />
    <xsl:variable name="categories" select="document(concat('classification:metadata:-1:parents:mir_genres:',$categoryID))" />
    
    <field name="genre">
      <value>
        <xsl:value-of select="$categories//category[1]/label[lang($CurrentLang)]/@text" />
      </value>
    </field>
  </xsl:template>
  
  <xsl:template match="mods:accessCondition[@type='use and reproduction'][contains(@xlink:href,'mir_licenses')]">
    <xsl:variable name="categoryID" select="substring-after(@xlink:href,'#')" />
    
    <field name="{$categoryID}">
      <value>Ja</value>
    </field>
  </xsl:template>

</xsl:stylesheet>
