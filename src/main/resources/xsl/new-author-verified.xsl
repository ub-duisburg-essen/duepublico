<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:xlink="http://www.w3.org/1999/xlink" 
  xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
  exclude-result-prefixes="i18n xlink"
>

  <xsl:include href="MyCoReLayout.xsl" />

  <xsl:variable name="PageTitle" select="i18n:translate('selfRegistration.step.verified.title')" />

  <xsl:template match="/new-author-verified">
    <h1>
      <xsl:value-of select="i18n:translate('selfRegistration.step.verified.title')" />
    </h1>
    <p>
      <xsl:variable name="parameters">
        <xsl:value-of select="user/@name" />
        <xsl:text>;</xsl:text>
        <xsl:value-of select="concat($WebApplicationBaseURL, 'authorization/login.xed')" />
      </xsl:variable>
      <xsl:value-of select="i18n:translate('selfRegistration.step.verified.info', $parameters)" disable-output-escaping="yes" />
    </p>
  </xsl:template>

</xsl:stylesheet>
