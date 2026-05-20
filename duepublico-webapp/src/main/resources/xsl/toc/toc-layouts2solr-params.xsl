<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:mcrxsl="xalan://org.mycore.common.xml.MCRXMLFunctions"
>

  <xsl:param name="MIR.TableOfContents.MaxResults" select="'1000'" />
  <xsl:param name="MIR.TableOfContents.LevelLimit" select="'100'" />
  <xsl:param name="MIR.TableOfContents.FieldsUsed" select="'*'" />
  
  <xsl:param name="CurrentUser" />

  <xsl:param name="preferredLayoutID" />
  <xsl:param name="invokingObjectID" />

  <xsl:template match="/toc-layouts">
    <solr-params>
    
      <param name="fl">
        <xsl:value-of select="$MIR.TableOfContents.FieldsUsed" />
      </param>
      <param name="facet">false</param>
      
      <!-- select actual ID of toc layout to use. Use preferred ID, if available, or fallback to toc-layouts.xml @default -->
      <xsl:variable name="layoutID">
        <xsl:choose>
          <xsl:when test="$preferredLayoutID and toc-layout[@id=$preferredLayoutID]">
            <xsl:value-of select="$preferredLayoutID"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="@default"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:apply-templates select="toc-layout[@id=$layoutID]" />
      
    </solr-params>
  </xsl:template>

  <xsl:template match="toc-layout">
    <param name="q">  
      <!-- Query to find all objects below this one (children, grand-children) -->
      <xsl:value-of select="@field" />
      <xsl:text>:</xsl:text>
      <xsl:value-of select="$invokingObjectID" />
      <xsl:text> AND </xsl:text>
      
      <xsl:choose>
        <xsl:when test="mcrxsl:isCurrentUserInRole('admin') or mcrxsl:isCurrentUserInRole('editor')">
          <xsl:text>state:*</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="concat('(state:published OR createdby:',$CurrentUser,')')" />
        </xsl:otherwise>
      </xsl:choose>
    </param>
  
    <param name="rows">
      <xsl:value-of select="$MIR.TableOfContents.MaxResults" />
    </param>
    <param name="sort">
      <xsl:apply-templates select="*[@field][@order]" mode="sort" />
    </param>
    
    <param name="toc.layoutID">
      <xsl:value-of select="@id" />
    </param>
    
    <xsl:for-each select="level">
      <param name="toc.{@field}.expanded"> 
        <xsl:value-of select="@expanded" />
      </param>
      <xsl:if test="@displayField">
        <param name="toc.{@field}.displayField"> 
          <xsl:value-of select="@displayField" />
        </param>
      </xsl:if>
    </xsl:for-each>
    
    <param name="json.facet">
      <xsl:for-each select="*[1]">
        <xsl:call-template name="publications.json" />
      </xsl:for-each>
      <xsl:apply-templates select="level[1]" mode="json" />
    </param>
  </xsl:template>

  <!-- build solr param for sort order of returned documents -->
  <xsl:template match="*" mode="sort">
    <xsl:value-of select="concat(@field,' ',@order)" />
    <xsl:if test="position() != last()">, </xsl:if>
  </xsl:template>

  <!-- build solr json for facet of publication ids at this level -->
  <xsl:template name="publications.json">
    <docs>
      <type>terms</type>
      <field>id</field>
      <limit>
        <xsl:value-of select="$MIR.TableOfContents.MaxResults" />
      </limit>
      <xsl:if test="following-sibling::level">
        <domain>
          <filter>
            <xsl:for-each select="following-sibling::level">
              <xsl:value-of select="concat('-',@field,':[* TO *]')" />
              <xsl:if test="position() != last()"> AND </xsl:if>
            </xsl:for-each>
          </filter>
        </domain>
      </xsl:if>
    </docs>
  </xsl:template>

  <!-- build solr json for a toc level as facet -->
  <xsl:template match="level" mode="json">
    <xsl:element name="{@field}">
      <type>terms</type>
      <limit>
        <xsl:choose>
          <xsl:when test="@limit">
            <xsl:value-of select="@limit" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$MIR.TableOfContents.LevelLimit" />
          </xsl:otherwise>
        </xsl:choose>
      </limit>
      <field>
        <xsl:value-of select="@field" />
      </field>
      <xsl:for-each select="@order">
        <sort>
          <index>
            <xsl:value-of select="." />
          </index>
        </sort>
      </xsl:for-each>
      <facet>
        <xsl:call-template name="publications.json" />
        <xsl:apply-templates select="following-sibling::level[1]" mode="json" />
      </facet>
    </xsl:element>
  </xsl:template>

</xsl:stylesheet>
