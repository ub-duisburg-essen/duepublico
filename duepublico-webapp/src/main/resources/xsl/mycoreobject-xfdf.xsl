<?xml version="1.0" encoding="ISO-8859-1"?>

<!-- Transforms <mycoreobject> with <mods:mods> into Adobe <xfdf> to fill formblatt_ediss_*.xsl -->

<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:mods="http://www.loc.gov/mods/v3" 
  xmlns:xalan="http://xml.apache.org/xalan"
  xmlns="http://ns.adobe.com/xfdf/"
  exclude-result-prefixes="xsl mods xalan">

  <xsl:output method="xml" encoding="UTF-8" indent="yes" xalan:indent-amount="2" />

  <xsl:param name="WebApplicationBaseURL" />
  
  <xsl:param name="DuEPublico.Diss.Formblatt" />
  <xsl:param name="DuEPublico.Diss.Formblatt.ID.Original" />
  <xsl:param name="DuEPublico.Diss.Formblatt.ID.Modified" />

  <xsl:template match="/mycoreobject">
    <xfdf>
      <f href="{$WebApplicationBaseURL}{$DuEPublico.Diss.Formblatt}" />
      <xsl:apply-templates select="metadata/def.modsContainer/modsContainer/mods:mods" />
      <ids original="{$DuEPublico.Diss.Formblatt.ID.Original}" modified="{$DuEPublico.Diss.Formblatt.ID.Modified}" />
    </xfdf>
  </xsl:template>

  <xsl:template match="mods:mods">
    <fields>
      <xsl:apply-templates select="mods:name[@type='personal'][mods:role/mods:roleTerm='aut'][1]" />
      <xsl:apply-templates select="mods:titleInfo[1]" />
      <xsl:apply-templates select="mods:name[@type='corporate'][mods:role/mods:roleTerm='his'][1]" />
      <xsl:apply-templates select="mods:originInfo/mods:dateOther[@type='submitted']" />
      <xsl:apply-templates select="mods:originInfo/mods:dateOther[@type='accepted']" />
      <xsl:apply-templates select="mods:name[@type='personal'][mods:role/mods:roleTerm='ths'][1]" />
    </fields>
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
  
  <xsl:template match="mods:dateOther[@type='submitted']">
    <field name="Date_submission">
      <xsl:call-template name="output.date" />
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

</xsl:stylesheet>
