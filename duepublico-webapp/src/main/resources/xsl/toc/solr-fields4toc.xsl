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

  <xsl:variable name="nbsp" select="'&#xa0;'"/>

  <xsl:template match="mycoreobject">
    <xsl:apply-imports />
    
    <xsl:apply-templates select="service/servflags/servflag[@type='tocLayout']" mode="toc" />

    <xsl:for-each select="metadata/def.modsContainer/modsContainer/mods:mods">
      <xsl:apply-templates select="mods:titleInfo" mode="toc" />
      <xsl:apply-templates select="(.)[mods:name[@type='personal'][contains($MIR.TableOfContents.RolesToDisplay,mods:role/mods:roleTerm)]]" mode="toc.authors" />

      <xsl:apply-templates select="descendant::mods:relatedItem[contains('host series',@type)]/@xlink:href" mode="toc" />
      
      <xsl:choose>
        <xsl:when test="mods:relatedItem[contains('host',@type)]/@xlink:href">
          <xsl:apply-templates select="mods:relatedItem[contains('host',@type)]/@xlink:href" mode="toc.legacyParent" />
        </xsl:when>
        <xsl:when test="mods:relatedItem[contains('series',@type)]/@xlink:href">
          <xsl:apply-templates select="mods:relatedItem[contains('series',@type)][1]/@xlink:href" mode="toc.legacyParent" />
        </xsl:when>
      </xsl:choose>

      <xsl:variable name="topHostsParts" select="mods:relatedItem[@type='host']/mods:part"/>
      <xsl:variable name="topSeriesParts" select="mods:relatedItem[@type='series']/mods:part"/>
      <xsl:variable name="allHostsParts" select="descendant::mods:relatedItem[@type='host']/mods:part"/>
      <xsl:variable name="allSeriesParts" select="descendant::mods:relatedItem[@type='series']/mods:part"/>

      <!-- host.volume.top, host.issue.top, host.articleNumber.top, series.volume.top - only first occurrence -->
      <xsl:apply-templates select="($topHostsParts/mods:detail[@type='volume'])[1]/mods:number" mode="toc.field" >
        <xsl:with-param name="name">volume.top</xsl:with-param>
      </xsl:apply-templates>
      <xsl:apply-templates select="($topHostsParts/mods:detail[@type='issue'])[1]/mods:number" mode="toc.field" >
        <xsl:with-param name="name">issue.top</xsl:with-param>
      </xsl:apply-templates>
      <xsl:apply-templates select="($topHostsParts/mods:detail[@type='article_number'])[1]/mods:number" mode="toc.field" >
        <xsl:with-param name="name">articleNumber.top</xsl:with-param>
      </xsl:apply-templates>
      <xsl:apply-templates select="($topSeriesParts/mods:detail[@type='volume'])[1]/mods:number" mode="toc.field" >
        <xsl:with-param name="name">volume.top</xsl:with-param>
      </xsl:apply-templates>

      <!-- host.volume, host.issue, host.articleNumber, series.volume - only first occurrence -->
      <xsl:apply-templates select="($allHostsParts/mods:detail[@type='volume'])[1]/mods:number" mode="toc.field" >
        <xsl:with-param name="name">volume</xsl:with-param>
      </xsl:apply-templates>
      <xsl:apply-templates select="($allHostsParts/mods:detail[@type='issue'])[1]/mods:number" mode="toc.field" >
        <xsl:with-param name="name">issue</xsl:with-param>
      </xsl:apply-templates>
      <xsl:apply-templates select="($allHostsParts/mods:detail[@type='section'])[1]/mods:caption" mode="toc.field">
        <xsl:with-param name="name">section</xsl:with-param>
      </xsl:apply-templates>
      <xsl:apply-templates select="($allHostsParts/mods:detail[@type='article_number'])[1]/mods:number" mode="toc.field" >
        <xsl:with-param name="name">articleNumber</xsl:with-param>
      </xsl:apply-templates>
      <xsl:apply-templates select="($allSeriesParts/mods:detail[@type='volume'])[1]/mods:number" mode="toc.field" >
        <xsl:with-param name="name">volume</xsl:with-param>
      </xsl:apply-templates>

      <!-- host.page - only first occurrence -->
      <xsl:apply-templates select="($allHostsParts/mods:extent[@unit='pages'])[1]/mods:start" mode="toc.field">
        <xsl:with-param name="name">page</xsl:with-param>
      </xsl:apply-templates>

      <!-- host.order, series.order - only first occurrence -->
      <xsl:apply-templates select="($topHostsParts[@order])[1]/@order" mode="toc.field">
        <xsl:with-param name="name">order</xsl:with-param>
      </xsl:apply-templates>
      <xsl:apply-templates select="($topSeriesParts[@order])[1]/@order" mode="toc.field">
        <xsl:with-param name="name">order</xsl:with-param>
      </xsl:apply-templates>

    </xsl:for-each>
  </xsl:template>
  
  <xsl:template match="service/servflags/servflag[@type='tocLayout']" mode="toc">
    <field name="tocLayout">
      <xsl:value-of select="text()" />
    </field>
  </xsl:template>

  <xsl:template match="mods:titleInfo[not(@type)][not(@altFormat)][1]" mode="toc">
    <field name="mir.toc.title">
      <xsl:for-each select="mods:nonSort">
        <xsl:value-of select="text()" />
        <xsl:text> </xsl:text>
      </xsl:for-each>
      <xsl:value-of select="mods:title" />
      <xsl:for-each select="mods:subTitle">
        <xsl:value-of select="$nbsp" />
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

  <xsl:template match="mods:relatedItem/@xlink:href" mode="toc.legacyParent">
    <field name="mir.toc.legacyParent">
      <xsl:value-of select="." />
    </field>
  </xsl:template>
  
  <xsl:template match="*|@*" mode="toc.field">
    <xsl:param name="name" />
    
    <xsl:variable name="type" select="(ancestor::mods:relatedItem/@type)[last()]" />

    <field name="mir.toc.{$type}.{$name}">
      <xsl:value-of select="." />
    </field>
    <field name="mir.sort-toc.{$type}.{$name}">
      <xsl:choose>
        <!-- Sorting is done using a single field, so convert numbers -->
        <xsl:when test="floor(.)=.">
          <xsl:value-of select="format-number(.,'00000000')" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="." />
        </xsl:otherwise>
      </xsl:choose>
    </field>

  </xsl:template>

  <!--  Store the category ID of the section for output in the TOC -->
  <xsl:template match="mods:detail[@type='section']/mods:caption" mode="toc.field">
    <field name="mir.toc.host.section">
      <xsl:value-of select="text()" />
    </field>
  </xsl:template>

</xsl:stylesheet>
