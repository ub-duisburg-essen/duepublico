<?xml version="1.0" encoding="UTF-8"?>

<!-- Removes the "@generator" flag and duplicates from SDNB classifcation categories. Use "xslt [ID] with file .../remove-sdnb-generator-flag.xsl" command -->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mcr="xalan://org.mycore.common.xml.MCRXMLFunctions"
  xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation" xmlns:mods="http://www.loc.gov/mods/v3" xmlns:xlink="http://www.w3.org/1999/xlink"
  exclude-result-prefixes="i18n mcr mods xlink">

  <xsl:include href="copynodes.xsl" />

  <xsl:template match="mods:classification[@authority='sdnb']">
    <xsl:if test="not(preceding-sibling::mods:classification[@authority='sdnb'][text()=current()/text()])">
      <xsl:copy>
        <xsl:copy-of select="@authority" />
        <xsl:value-of select="text()" />
      </xsl:copy>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
