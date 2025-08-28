<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:param name="WebApplicationBaseURL" />

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
      <xsl:apply-templates select="title" />
      <div class="card-body">
        <a href="/go/{@alias}" target="_blank">
          <img class="float" width="100" align="right" vspace="10" hspace="10" src="{$WebApplicationBaseURL}servlets/MCRFileNodeServlet/{cover}" />
        </a>
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
      <img class="float" width="100" align="right" vspace="10" hspace="10" src="../../servlets/MCRFileNodeServlet/{text()}" />
    </a>
  </xsl:template>

</xsl:stylesheet>
