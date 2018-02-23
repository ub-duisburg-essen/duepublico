<?xml version="1.0" encoding="UTF-8"?>

<!-- Removes the "@generator" flag from SDNB classifcation categories. Use "xslt [ID] with xsl/remove-sdnb-generator-flag" command -->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mcr="xalan://org.mycore.common.xml.MCRXMLFunctions"
  xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation" xmlns:mods="http://www.loc.gov/mods/v3" xmlns:xlink="http://www.w3.org/1999/xlink"
  exclude-result-prefixes="i18n mcr mods xlink">

  <xsl:include href="copynodes.xsl" />

  <xsl:template match="mods:classification[@authority='sdnb']/@generator" />

</xsl:stylesheet>
