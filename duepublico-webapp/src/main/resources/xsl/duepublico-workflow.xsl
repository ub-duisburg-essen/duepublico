<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:mcr="xalan://org.mycore.common.xml.MCRXMLFunctions"
  xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:actionmapping="xalan://org.mycore.wfc.actionmapping.MCRURLRetriever"
  exclude-result-prefixes="i18n mcr mods xlink actionmapping"
>
  <xsl:import href="xslImport:modsmeta:duepublico-workflow.xsl" />
  <xsl:include href="coreFunctions.xsl"/>

  <xsl:param name="WebApplicationBaseURL" />

  <xsl:template match="/">
    <xsl:apply-templates select="mycoreobject" mode="duepublico.workflow" />
    <xsl:apply-imports />
  </xsl:template>

  <xsl:template match="mycoreobject" mode="duepublico.workflow">
    <xsl:variable name="objectID" select="@ID" />
    <xsl:variable name="collection" select="substring-after(//mods:classification[contains(@valueURI,'/collection')]/@valueURI,'#')" />

    <xsl:choose>
      <xsl:when test="not(service/servstates/servstate[@categid='submitted'])" />
      <xsl:when test="not(rights/right[@id=$objectID]/@write)" />
      <xsl:otherwise>

        <div id="duepublico-workflow">
          <div class="alert alert-info" role="alert">
            <ul style="list-style-type:none; padding:0;">

              <xsl:call-template name="duepublico.workflow.step">
                <xsl:with-param name="label" select="i18n:translate('duepublico.workflow.step.3.checked')" />
                <xsl:with-param name="icon">check-square</xsl:with-param>
                <xsl:with-param name="link">
                  <xsl:call-template name="UrlSetParam">
                    <xsl:with-param name="url" select="actionmapping:getURLforCollection('update',$collection,true())" />
                    <xsl:with-param name="par" select="'id'" />
                    <xsl:with-param name="value" select="$objectID" />
                  </xsl:call-template>
                </xsl:with-param>
              </xsl:call-template>

              <xsl:if test="not(structure/derobjects/derobject)">
                <xsl:call-template name="duepublico.workflow.step">
                  <xsl:with-param name="label" select="i18n:translate('duepublico.workflow.step.4.unchecked')" />
                  <xsl:with-param name="icon">square</xsl:with-param>
                </xsl:call-template>
              </xsl:if>

              <xsl:if test="structure/derobjects/derobject">
                <xsl:call-template name="duepublico.workflow.step">
                  <xsl:with-param name="label" select="i18n:translate('duepublico.workflow.step.4.checked')" />
                  <xsl:with-param name="icon">check-square</xsl:with-param>
                </xsl:call-template>
              </xsl:if>

              <xsl:variable name="collection" select="substring-after(//mods:classification[contains(@valueURI,'/collection')]/@valueURI,'#')" />
              <xsl:variable name="config" select="document('resource:xfdf-config.xml')/xfdf-config" />
              <xsl:variable name="form" select="$config/collection[@id=$collection]/form[lang($CurrentLang)]" />

              <xsl:if test="$form/info">
                <xsl:call-template name="duepublico.workflow.step">
                  <xsl:with-param name="label" select="$form/info" />
                  <xsl:with-param name="icon">square</xsl:with-param>
                  <xsl:with-param name="link" select="concat($WebApplicationBaseURL,'receive/',$objectID,'?XSL.Transformer=publication-form')" />
                </xsl:call-template>
              </xsl:if>
            </ul>
          </div>
        </div>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="duepublico.workflow.step">
    <xsl:param name="label" />
    <xsl:param name="icon" />
    <xsl:param name="link" />

    <li class="workflow-step with-icon">
      <i class="fas fa-{$icon}" aria-hidden="true" />
      <div>
        <xsl:choose>
          <xsl:when test="string-length($link) &gt; 0">
            <a class="alert-link" href="{$link}">
              <xsl:value-of select="$label" />
            </a>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$label" />
          </xsl:otherwise>
        </xsl:choose>
      </div>
    </li>
  </xsl:template>

</xsl:stylesheet>
