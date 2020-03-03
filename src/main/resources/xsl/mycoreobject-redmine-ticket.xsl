<?xml version="1.0" encoding="UTF-8"?>

<!-- See https://www.redmine.org/projects/redmine/wiki/Rest_Issues#Creating-an-issue -->

<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:mods="http://www.loc.gov/mods/v3"
  exclude-result-prefixes="mods">

  <xsl:template match="/mycoreobject">
    <issue>
      <xsl:choose>
        <xsl:when test="not('deepgreen'=/mycoreobject/service/servflags/servflag[@type='createdby'])" />
        <xsl:when test="not('submitted'=/mycoreobject/service/servstates/servstate/@categid)" />
        <xsl:otherwise>
          <xsl:call-template name="ticketProperties" />
          <xsl:apply-templates select="@ID" />
          <xsl:apply-templates select="metadata/def.modsContainer/modsContainer/mods:mods" mode="subject" />
          <xsl:apply-templates select="metadata/def.modsContainer/modsContainer/mods:mods" mode="description" />
        </xsl:otherwise>
      </xsl:choose>
    </issue>
  </xsl:template>

  <xsl:param name="MCR.Redmine.ProjectID" />
  <xsl:param name="MCR.Redmine.TrackerID" />
  <xsl:param name="MCR.Redmine.StatusID" />
  <xsl:param name="MCR.Redmine.AuthorID" />
  <xsl:param name="MCR.Redmine.CategoryID" />

  <xsl:template name="ticketProperties">
    <project_id>
      <xsl:value-of select="$MCR.Redmine.ProjectID" />
    </project_id>
    <tracker_id>
      <xsl:value-of select="$MCR.Redmine.TrackerID" />
    </tracker_id>
    <status_id>
      <xsl:value-of select="$MCR.Redmine.StatusID" />
    </status_id>
    <xsl:if test="string-length($MCR.Redmine.AuthorID) &gt; 0">
      <author_id>
        <xsl:value-of select="$MCR.Redmine.AuthorID" />
      </author_id>
    </xsl:if>
    <xsl:if test="string-length($MCR.Redmine.CategoryID) &gt; 0">
      <category_id>
        <xsl:value-of select="$MCR.Redmine.CategoryID" />
      </category_id>
    </xsl:if>
  </xsl:template>

  <xsl:param name="MCR.Redmine.CustomField.ObjectID" />

  <xsl:template match="@ID">
    <custom_fields type="array">
      <custom_field id="{$MCR.Redmine.CustomField.ObjectID}">
        <value>
          <xsl:value-of select="." />
        </value>
      </custom_field>
    </custom_fields>
  </xsl:template>

  <xsl:template match="mods:mods" mode="subject">
    <subject>
      <xsl:for-each select="mods:name[mods:namePart|mods:displayForm][1]">
        <xsl:value-of select="mods:namePart[@type='family']|mods:displayForm" />
        <xsl:text>: </xsl:text>
      </xsl:for-each>
      <xsl:for-each select="mods:titleInfo[not(@altFormat)][1]">
        <xsl:for-each select="mods:nonSort">
          <xsl:value-of select="." />
          <xsl:text> </xsl:text>
        </xsl:for-each>
        <xsl:for-each select="mods:title">
          <xsl:value-of select="substring(text(),1,100)" />
          <xsl:if test="string-length(.) &gt; 100">...</xsl:if>
        </xsl:for-each>
      </xsl:for-each>
    </subject>
  </xsl:template>

  <xsl:template match="mods:mods" mode="description">
    <description>
      <xsl:apply-templates select="mods:titleInfo[not(@altFormat)][1]" />
      <xsl:text>&#xa;</xsl:text>
      <xsl:apply-templates select="mods:name[mods:namePart|mods:displayForm]" />
      <xsl:apply-templates select="mods:originInfo[@eventType='publication']/mods:dateIssued" />
      <xsl:apply-templates select="mods:identifier[@type='doi']" />
      <xsl:apply-templates select="mods:relatedItem[@type='host']" />
    </description>
  </xsl:template>

  <xsl:template match="mods:titleInfo">
    <xsl:for-each select="mods:nonSort">
      <xsl:value-of select="." />
      <xsl:text> </xsl:text>
    </xsl:for-each>
    <xsl:value-of select="mods:title" />
    <xsl:for-each select="mods:subTitle">
      <xsl:text> : </xsl:text>
      <xsl:value-of select="." />
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="mods:name">
    <xsl:choose>
      <xsl:when test="mods:namePart[@type='family']">
        <xsl:value-of select="mods:namePart[@type='family']" />
        <xsl:text>, </xsl:text>
        <xsl:value-of select="mods:namePart[@type='given']" />
      </xsl:when>
      <xsl:when test="mods:displayForm">
        <xsl:value-of select="mods:displayForm" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="mods:namePart[1]" />
      </xsl:otherwise>
    </xsl:choose>
    <xsl:if test="position() != last()">
      <xsl:text>; </xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="mods:dateIssued">
    <xsl:text>&#xa;</xsl:text>
    <xsl:value-of select="." />
  </xsl:template>

  <xsl:template match="mods:identifier[@type='doi']">
    <xsl:text>&#xa;</xsl:text>
    <xsl:text>https://doi.org/</xsl:text>
    <xsl:value-of select="." />
  </xsl:template>

  <xsl:template match="mods:relatedItem[@type='host']">
    <xsl:text>&#xa;</xsl:text>
    <xsl:text>&#xa;</xsl:text>
    <xsl:text>In:</xsl:text>
    <xsl:text>&#xa;</xsl:text>
    <xsl:apply-templates select="mods:titleInfo[not(@altFormat)][1]" />
    <xsl:apply-templates select="mods:part" />
    <xsl:apply-templates select="mods:originInfo[@eventType='publication']/mods:dateIssued" />
    <xsl:apply-templates select="mods:identifier[@type='issn']" />
    <xsl:apply-templates select="mods:originInfo/mods:publisher" />
  </xsl:template>

  <xsl:template match="mods:identifier[@type='issn']">
    <xsl:text>&#xa;</xsl:text>
    <xsl:text>ISSN: </xsl:text>
    <xsl:value-of select="." />
  </xsl:template>

  <xsl:template match="mods:part">
    <xsl:text>&#xa;</xsl:text>
    <xsl:for-each select="mods:detail[@type='volume']">
      <xsl:text>Vol. </xsl:text>
      <xsl:value-of select="mods:number" />
      <xsl:text>, </xsl:text>
    </xsl:for-each>
    <xsl:for-each select="mods:detail[@type='issue']">
      <xsl:text>No. </xsl:text>
      <xsl:value-of select="mods:number" />
      <xsl:text>, </xsl:text>
    </xsl:for-each>
    <xsl:for-each select="mods:extent[@unit='pages']">
      <xsl:text>S. </xsl:text>
      <xsl:choose>
        <xsl:when test="mods:start">
          <xsl:value-of select="mods:start" />
          <xsl:for-each select="mods:end">
            <xsl:text> - </xsl:text>
            <xsl:value-of select="." />
          </xsl:for-each>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="mods:list" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="mods:publisher">
    <xsl:text>&#xa;</xsl:text>
    <xsl:value-of select="." />
  </xsl:template>

</xsl:stylesheet>