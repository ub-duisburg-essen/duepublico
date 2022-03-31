<?xml version="1.0" encoding="UTF-8"?>

<!-- Output statistics for multiple selected documents, e.g. use command -->
<!-- select objects with solr query objectType:mods AND category:"collection:Diss" AND state:published AND category:"mir_institutes:09.01" in core main -->
<!-- for months 2020-01 to 2021-12 file statistics.xml  -->
<!-- Move that file to the webapp directory -->
<!-- Invoke that file using http://.../statistics.xml?XSL.Style=doc-year -->
<!-- Displays number of file access per year, and total sum -->

<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:mods="http://www.loc.gov/mods/v3">

  <xsl:output method="html" />

  <xsl:template match="/statistics">
    <html>
      <body>
        <table border="1">
          <tr>
            <th />
            <th>Summe</th>
            <xsl:for-each select="loggedMonth[@month='01']">
              <xsl:sort select="@year" order="descending" />
              <th>
                <xsl:value-of select="@year" />
              </th>
            </xsl:for-each>
          </tr>
          <xsl:for-each select="object[@type='document']">
            <xsl:sort select="@id" order="descending" />
            <xsl:variable name="doc" select="." />
            <tr>
              <td width="50%">
                <a href="receive/{@id}">
                  <xsl:for-each select="document(concat('mcrobject:',@id))">
                    <xsl:value-of select="concat('(',//mods:mods//mods:dateOther[@type='accepted'],') ')" />
                    <xsl:value-of select="//mods:mods/mods:name[1]//mods:namePart[@type='family']" />
                    <xsl:text>: </xsl:text>
                    <xsl:value-of select="//mods:mods/mods:titleInfo/mods:title[1]" />
                  </xsl:for-each>
                </a>
              </td>
              <td>
                <xsl:value-of
                  select="translate(format-number(sum($doc/descendant::object[@type='file']/num),'###,##0'),',','.')" />
              </td>
              <xsl:for-each select="/statistics/loggedMonth[@month='01']">
                <xsl:sort select="@year" order="descending" />
                <xsl:variable name="year" select="@year" />
                <td align="right">
                  <xsl:value-of
                    select="translate(format-number(sum($doc/descendant::object[@type='file']/num[@year=$year]),'###,##0'),',','.')" />
                </td>
              </xsl:for-each>
            </tr>
          </xsl:for-each>
        </table>
      </body>
    </html>
  </xsl:template>

</xsl:stylesheet>
