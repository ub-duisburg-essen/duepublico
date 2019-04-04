<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xalan="http://xml.apache.org/xalan"
  xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
  exclude-result-prefixes="xsl xalan i18n"
>

  <xsl:param name="DefaultLang" />
  <xsl:param name="WebApplicationBaseURL" />
  <xsl:param name="ServletsBaseURL" />
  <xsl:param name="MCR.mir-module.NewUserMail" />
  <xsl:param name="MCR.mir-module.MailSender" />
  <xsl:variable name="newline" select="'&#xA;'" />

  <xsl:template match="/">
    <email>
      <from>
        <xsl:value-of select="$MCR.mir-module.MailSender" />
      </from>
      <xsl:apply-templates select="/*" mode="email" />
    </email>
  </xsl:template>

  <xsl:template match="user" mode="email">
    <to>
      <xsl:value-of select="$MCR.mir-module.NewUserMail" />
    </to>
    <subject>
      <xsl:value-of select="i18n:translate('duepublico.selfregistration.email.subject')" />: <xsl:value-of select="@name" />
    </subject>
    <body>
      <xsl:text>Liebe Kollegin, lieber Kollege,</xsl:text><xsl:value-of select="$newline" />
      <xsl:value-of select="$newline" />
      <xsl:text>Es wurde soeben eine neue Benutzerkennung in DuEPublico angelegt:</xsl:text><xsl:value-of select="$newline" />
      <xsl:value-of select="$newline" />
      <xsl:value-of select="concat('Benutzerkennung&#09;: ',@name,' (',@realm,')',$newline)" />
      <xsl:value-of select="concat('Name&#09;&#09;&#09;: ',realName,$newline)" />
      <xsl:value-of select="concat('E-Mail&#09;&#09;&#09;: ',eMail,$newline)" />
      <xsl:value-of select="concat('Link&#09;&#09;&#09;: ',$ServletsBaseURL,'MCRUserServlet?action=show&amp;id=',@name,'@',@realm,$newline)" />
      <xsl:value-of select="$newline" />
      <xsl:text>Ihr DuEPublico - Dokumenten- und Publikationsserver der Universität Duisburg-Essen</xsl:text><xsl:value-of select="$newline" />
      <xsl:value-of select="$newline" />
      <xsl:value-of select="$WebApplicationBaseURL" />
    </body>
  </xsl:template>
</xsl:stylesheet>
