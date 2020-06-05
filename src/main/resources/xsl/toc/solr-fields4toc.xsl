<?xml version="1.0" encoding="UTF-8"?>

<!-- Builds solr fields used for table of contents -->

<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:xalan="http://xml.apache.org/xalan"
  xmlns:mods="http://www.loc.gov/mods/v3"
  exclude-result-prefixes="xalan xlink mods">

  <xsl:import href="xslImport:solr-document:toc/solr-fields4toc.xsl" />

  <xsl:param name="MIR.TableOfContents.RolesToDisplay" select="'cre aut edt trl ive ivr hnr'" />

  <xsl:template match="mycoreobject">
    <xsl:apply-imports />

    <xsl:for-each select="metadata/def.modsContainer/modsContainer/mods:mods">
      <xsl:apply-templates select="mods:titleInfo" mode="toc" />
      <xsl:apply-templates select="(.)[mods:name[@type='personal'][contains($MIR.TableOfContents.RolesToDisplay,mods:role/mods:roleTerm)]]" mode="toc.authors" />

      <xsl:apply-templates select="descendant::mods:relatedItem[contains('host series',@type)]/@xlink:href" mode="toc" />

      <!-- host.volume, host.issue, series.volume, series.issue - only first occurrence -->
      <xsl:apply-templates select="(descendant::mods:relatedItem[@type='host']/mods:part/mods:detail[@type='volume'])[1]/mods:number" mode="toc.field" />
      <xsl:apply-templates select="(descendant::mods:relatedItem[@type='host']/mods:part/mods:detail[@type='issue'])[1]/mods:number" mode="toc.field" />
      <xsl:apply-templates select="(descendant::mods:relatedItem[@type='series']/mods:part/mods:detail[@type='volume'])[1]/mods:number" mode="toc.field" />
      <xsl:apply-templates select="(descendant::mods:relatedItem[@type='series']/mods:part/mods:detail[@type='issue'])[1]/mods:number" mode="toc.field" />

      <!-- host.page -->
      <xsl:apply-templates select="(descendant::mods:relatedItem[@type='host']/mods:part/mods:extent[@unit='pages'])[1]/mods:start" mode="toc.field">
        <xsl:with-param name="name">page</xsl:with-param>
      </xsl:apply-templates>

      <!-- host.order, series.order - only first occurrence -->
      <xsl:apply-templates select="(descendant::mods:relatedItem[@type='host']/mods:part[@order])[1]/@order" mode="toc.field">
        <xsl:with-param name="name">order</xsl:with-param>
      </xsl:apply-templates>
      <xsl:apply-templates select="(descendant::mods:relatedItem[@type='series']/mods:part[@order])[1]/@order" mode="toc.field">
        <xsl:with-param name="name">order</xsl:with-param>
      </xsl:apply-templates>

    </xsl:for-each>
  </xsl:template>

  <xsl:template match="mods:titleInfo[not(@type)][not(@altFormat)][1]" mode="toc">
    <field name="mir.toc.title">
      <xsl:for-each select="mods:nonSort">
        <xsl:value-of select="text()" />
        <xsl:text> </xsl:text>
      </xsl:for-each>
      <xsl:value-of select="mods:title" />
      <xsl:for-each select="mods:subTitle">
        <xsl:text>: </xsl:text>
        <xsl:value-of select="text()" />
      </xsl:for-each>
    </field>
  </xsl:template>

  <xsl:template match="mods:mods" mode="toc.authors">
    <field name="mir.toc.authors">
      <xsl:for-each select="mods:name[@type='personal'][contains($MIR.TableOfContents.RolesToDisplay,mods:role/mods:roleTerm)]">
        <xsl:choose>
          <xsl:when test="mods:displayForm">
            <xsl:value-of select="mods:displayForm" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="mods:namePart[@type='family']" />
            <xsl:for-each select="mods:namePart[@type='given']">
              <xsl:text>, </xsl:text>
              <xsl:value-of select="text()" />
            </xsl:for-each>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="position() != last()">; </xsl:if>
      </xsl:for-each>
    </field>
  </xsl:template>

  <xsl:template match="mods:relatedItem/@xlink:href" mode="toc">
    <field name="mir.toc.ancestor">
      <xsl:value-of select="." />
    </field>
  </xsl:template>

  <xsl:template match="*|@*" mode="toc.field">
    <xsl:param name="name" select="../@type" />
    <xsl:variable name="field" select="concat('mir.toc.',ancestor::mods:relatedItem/@type,'.',$name)" />

    <field name="{$field}">
      <xsl:value-of select="." />
    </field>

    <xsl:choose>
      <xsl:when test="string(number(.)) = 'NaN'">
        <field name="{$field}.str">
          <xsl:value-of select="." />
        </field>
      </xsl:when>
      <xsl:otherwise>
        <field name="{$field}.int">
          <xsl:value-of select="string(number(.))" />
        </field>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>