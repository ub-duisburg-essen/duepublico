<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:param name="ServletsBaseURL" />

  <xsl:variable name="az" select="'abcdefghijklmnopqrstuvwxyz'" />
  <xsl:variable name="AZ" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'" />

  <xsl:key name="series" match="//series" use="translate(substring(normalize-space(title),1,1),$az,$AZ)" />

  <xsl:template match="seriesA2Z">
    <ul class="a2z">
      <xsl:for-each select="//series[count(.|key('series',translate(substring(normalize-space(title),1,1),$az,$AZ))[1])=1]">
        <li>
          <a href="#{@alias}">
            <xsl:value-of select="translate(substring(normalize-space(title),1,1),$az,$AZ)" />
          </a>
        </li>
      </xsl:for-each>
    </ul>
  </xsl:template>

  <!--
    <series alias="aiss">
      <title>AISS - Autonomous Inland and Short Sea Shipping Conference</title>
      <cover>duepublico_derivate_00078385/aiss_cover.png</cover>
      <description>
        <p>
          The Autonomous Inland and Short Sea Shipping Conference was established in 2019 as an annual conference.
          ...
        </p>...
      </description>
    </series> 
   -->
  <xsl:template match="series">
    <div class="card card-default">
      <a name="{@alias}" />
      <xsl:apply-templates select="title" />
      <div class="card-body">
        <xsl:apply-templates select="cover" />
        <xsl:copy-of select="description/node()" />
      </div>
    </div>
  </xsl:template>
  
  <xsl:template match="series/title">
    <div class="card-header">
      <h3>
        <a href="/go/{../@alias}" target="_blank">
          <xsl:value-of select="text()" />
        </a>
      </h3>
    </div>
  </xsl:template>
  
  <xsl:template match="series/cover">
    <a href="/go/{../@alias}" target="_blank">
      <img class="float-right ml-2 mb-1" width="150" src="{$ServletsBaseURL}MCRFileNodeServlet/{text()}" />
    </a>
  </xsl:template>

</xsl:stylesheet>
