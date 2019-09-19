<?xml version="1.0" encoding="utf-8"?>
<!-- ============================================== -->
<!-- $Revision$ $Date$ -->
<!-- ============================================== -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation" xmlns:xalan="http://xml.apache.org/xalan"
  exclude-result-prefixes="xalan i18n">

  <xsl:include href="duepublico-series-panel.xsl" />
  <xsl:include href="copynodes.xsl" />

  <xsl:param name="WebApplicationBaseURL" />
  <xsl:param name="MCRObjectID" />
  <xsl:param name="MCRDerivateID" />

  <xsl:template match="/site">
    <xsl:copy>
      <xsl:copy-of select="@*" />
      <div class="row detail_row">
        <div class="col-xs-12 col-sm-8" id="main_col">
          <xsl:copy-of select="*|text()" />
        </div>
        <div class="col-xs-12 col-sm-4" id="aux_col">
          <xsl:variable name="uri" select="concat('notnull:mcrfile:',$MCRDerivateID,'/navigation.xml')" />
          <xsl:apply-templates select="document($uri)/item" mode="seriesLayout">
            <xsl:with-param name="rootID" select="$MCRObjectID" />
          </xsl:apply-templates>
        </div>
      </div>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>