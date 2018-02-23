<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:mcr="xalan://org.mycore.common.xml.MCRXMLFunctions"
  xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  exclude-result-prefixes="i18n mcr mods xlink"
>
  <xsl:import href="xslImport:modsmeta:duepublico-workflow.xsl" />
  
  <xsl:param name="WebApplicationBaseURL" />
  
  <xsl:template match="/">
    <div id="mir-message">
      <xsl:apply-templates select="mycoreobject" mode="duepublico.workflow" />
    </div>
    <xsl:apply-imports />
  </xsl:template>

  <xsl:template match="mycoreobject" mode="duepublico.workflow">
    <xsl:variable name="objectID" select="@ID" />

    <xsl:choose>
      <xsl:when test="not(service/servstates/servstate[@categid='submitted'])" /> 
      <xsl:when test="not(rights/right[@id=$objectID]/@write)" />
      <xsl:otherwise>
        <div class="row">
          <div class="col-md-12">

            <div class="alert alert-info" role="alert">
              <ul style="list-style-type:none; padding:0;">
              
                <xsl:call-template name="duepublico.workflow.step">
                  <xsl:with-param name="step">3</xsl:with-param>
                  <xsl:with-param name="icon">check-square-o</xsl:with-param>
                  <xsl:with-param name="link" select="concat($WebApplicationBaseURL,'content/diss/form.xed?id=',$objectID)" />
                </xsl:call-template>
             
                <xsl:if test="not(structure/derobjects/derobject)">
                  <xsl:call-template name="duepublico.workflow.step">
                    <xsl:with-param name="step">4</xsl:with-param>
                    <xsl:with-param name="icon">square-o</xsl:with-param>
                    <xsl:with-param name="link" select="concat($WebApplicationBaseURL,'servlets/derivate/create?id=',$objectID)" />
                  </xsl:call-template>
                </xsl:if>
  
                <xsl:for-each select="structure/derobjects/derobject[1]">
                  <xsl:call-template name="duepublico.workflow.step">
                    <xsl:with-param name="step">4</xsl:with-param>
                    <xsl:with-param name="icon">check-square-o</xsl:with-param>
                    <xsl:with-param name="link" select="concat($WebApplicationBaseURL,'servlets/derivate/update?objectid=',$objectID,'&amp;id=',@xlink:href)" />
                  </xsl:call-template>
                </xsl:for-each>
  
                <xsl:if test="structure/derobjects/derobject">
                  <xsl:call-template name="duepublico.workflow.step">
                    <xsl:with-param name="step">5</xsl:with-param>
                    <xsl:with-param name="icon">square-o</xsl:with-param>
                    <xsl:with-param name="link" select="concat($WebApplicationBaseURL,'receive/',$objectID,'?XSL.Transformer=formblatt-ediss')" />
                  </xsl:call-template>
                </xsl:if>

              </ul>
            </div>

          </div>
        </div>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="duepublico.workflow.step">
    <xsl:param name="step" />
    <xsl:param name="icon" />
    <xsl:param name="link" />
    
    <li>
      <i class="fa fa-{$icon}" aria-hidden="true" style="margin-right:1ex;" />
      <div style="display:inline-block; vertical-align:top;">
        <xsl:value-of select="i18n:translate(concat('duepublico.workflow.step.',$step))" />:
        <a class="alert-link" href="{$link}">
          <xsl:value-of select="i18n:translate(concat('duepublico.workflow.step.',$step,'.link.',$checked))" />
        </a>
      </div>
    </li>
  </xsl:template>

</xsl:stylesheet>
