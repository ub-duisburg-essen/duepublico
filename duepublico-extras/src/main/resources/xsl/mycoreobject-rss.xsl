<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:xalan="http://xml.apache.org/xalan"
  xmlns:isoDate="xalan://org.mycore.datamodel.common.MCRISO8601Date"
  xmlns:sdf="xalan://java.text.SimpleDateFormat" 
  xmlns:date="xalan://java.util.Date"
  xmlns:locale="xalan://java.util.Locale"
  xmlns:mods="http://www.loc.gov/mods/v3" 
  exclude-result-prefixes="xalan isoDate sdf date locale xlink mods">
  
  <xsl:output method="xml" encoding="UTF-8" media-type="application/rss+xml" indent="yes" xalan:indent-amount="2" />
  
  <xsl:param name="WebApplicationBaseURL" />
  <xsl:param name="DuEPublico.RSS.Generator" />
  
  <xsl:template match="/">
    <rss version="2.0">
      <xsl:apply-templates select="mycoreobject" mode="channel" />
    </rss>
  </xsl:template>
  
  <xsl:template match="mycoreobject" mode="channel">
    <channel>
      <xsl:apply-templates select="metadata/def.modsContainer/modsContainer/mods:mods/mods:titleInfo[1]" />
      <xsl:apply-templates select="@ID" mode="link" />
      <xsl:apply-templates select="metadata/def.modsContainer/modsContainer/mods:mods/mods:abstract[string-length(text()) &gt; 0][1]" />
      <xsl:apply-templates select="metadata/def.modsContainer/modsContainer/mods:mods/mods:language[mods:languageTerm[@type='code']][1]" />
      <generator><xsl:value-of select="$DuEPublico.RSS.Generator" /></generator>
      <docs>http://blogs.law.harvard.edu/tech/rss</docs>
      <xsl:call-template name="items" />
    </channel>
  </xsl:template>
  
  <xsl:template match="mods:titleInfo">
    <title>
      <xsl:apply-templates select="mods:nonSort" />
      <xsl:apply-templates select="mods:title" />
      <xsl:apply-templates select="mods:subTitle" />
    </title>
  </xsl:template>

  <xsl:template match="mods:nonSort">
    <xsl:value-of select="text()" />
    <xsl:text> </xsl:text>
  </xsl:template>

  <xsl:template match="mods:title">
    <xsl:value-of select="text()" />
  </xsl:template>

  <xsl:template match="mods:subTitle">
    <xsl:variable name="lastCharOfTitle" select="substring(../mods:title,string-length(../mods:title))" />
    <!-- Falls Titel nicht mit Satzzeichen endet, trenne Untertitel durch : -->
    <xsl:if test="translate($lastCharOfTitle,'?!.:,-;','.......') != '.'">
      <xsl:text>:</xsl:text>
    </xsl:if>
    <xsl:text> </xsl:text>
    <xsl:value-of select="text()" />
  </xsl:template>
  
  <xsl:template match="mycoreobject/@ID" mode="link">
    <link>
      <xsl:value-of select="concat($WebApplicationBaseURL,'receive/',.)" />
    </link>
  </xsl:template>
  
  <xsl:template match="mods:abstract">
    <description>
      <xsl:value-of select="text()" />
    </description>
  </xsl:template>
  
  <xsl:template match="mods:language">
    <language>
      <xsl:value-of select="mods:languageTerm[@type='code'][1]" />
    </language>
  </xsl:template>
  
  <xsl:template name="items">
    <xsl:variable name="uri">
      <xsl:text>solr:</xsl:text>
      <xsl:text>fl=id&amp;</xsl:text>
      <xsl:text>rows=20&amp;</xsl:text>
      <xsl:text>sort=mods.dateIssued+desc,+mods.dateIssued.host+desc&amp;</xsl:text>
      <xsl:text>q=root:</xsl:text>
      <xsl:value-of select="@ID" />
    </xsl:variable>
    <xsl:apply-templates select="document($uri)/response/result/doc" />    
  </xsl:template>
  
  <xsl:template match="doc">
    <xsl:variable name="uri" select="concat('mcrobject:',str[@name='id'])" />
    <xsl:apply-templates select="document($uri)/mycoreobject" mode="item" />
  </xsl:template>
  
  <xsl:template match="mycoreobject" mode="item">
    <item>
      <xsl:apply-templates select="metadata/def.modsContainer/modsContainer/mods:mods/mods:titleInfo[1]" />
      <xsl:apply-templates select="@ID" mode="link" />
      <xsl:apply-templates select="metadata/def.modsContainer/modsContainer/mods:mods/mods:abstract[string-length(text()) &gt; 0][1]" />
      <xsl:apply-templates select="service/servdates/servdate[@type='modifydate']" />
      <xsl:apply-templates select="@ID" mode="guid" />
    </item>
  </xsl:template>

  <xsl:template match="mycoreobject/@ID" mode="guid">
    <guid>
      <xsl:value-of select="concat($WebApplicationBaseURL,'receive/',.)" />
    </guid>
  </xsl:template>
  
  <xsl:template match="servdate">
    <pubDate>
      <xsl:variable name="isoDate" select="isoDate:new(text())" />
      <xsl:variable name="date" select="isoDate:getDate($isoDate)" />
      <xsl:variable name="en" select="locale:new('en')" />
      <xsl:variable name="targetFormat">EEE, dd MMM yyyy HH:mm:ss Z</xsl:variable>
      <xsl:variable name="targetFormatter" select="sdf:new($targetFormat,$en)"  />
      <xsl:value-of select="sdf:format($targetFormatter,$date)" />
    </pubDate>
  </xsl:template>
  
</xsl:stylesheet>