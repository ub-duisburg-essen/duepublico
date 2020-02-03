<?xml version="1.0" encoding="ISO-8859-1"?>

<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xalan="http://xml.apache.org/xalan"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
  exclude-result-prefixes="xsl xalan i18n"
>

<xsl:include href="shelfmark-normalization.xsl" /> 

<xsl:param name="RequestURL" />

<xsl:variable name="page.title">
  <xsl:value-of select="i18n:translate('thesisList.dissertation')"/> 
  <xsl:value-of select="/thesis-list-grouped/@year" />
  <xsl:text> </xsl:text>
  <xsl:value-of select="i18n:translate(concat('thesisList.by.',/thesis-list-grouped/@by))"/> 
</xsl:variable>

<xsl:template match="thesis-list-grouped">
  <site title="{$page.title}">
      <xsl:call-template name="intro" />
      <xsl:apply-templates select="group" />
  </site>
</xsl:template>

<xsl:template match="group">
  <div class="card card-body">
    <h2>
      <xsl:value-of select="@label" />
    </h2> 
    <table class="table table-striped">
      <thead>
        <tr>
          <th scope="col" width="20%"><xsl:value-of select="i18n:translate('thesisList.author')"/></th>
          <th scope="col" width="68%"><xsl:value-of select="i18n:translate('thesisList.title')"/></th> 
          <th scope="col" width="12%"><xsl:value-of select="i18n:translate('thesisList.shelfmark')"/></th> 
         </tr>  
      </thead>
      <tbody>
        <xsl:apply-templates select="mods:mods">
          <xsl:sort select="mods:name[mods:role/mods:roleTerm='aut'][1]/mods:namePart[@type='family']" />
          <xsl:sort select="mods:name[mods:role/mods:roleTerm='aut'][1]/mods:namePart[@type='given']" />
        </xsl:apply-templates>
      </tbody>
    </table>
  </div>
</xsl:template>

<xsl:template name="intro">
  <div class="card">
    <div class="card-header">
      <h2 class="card-title">
        <xsl:value-of select="$page.title" />
      </h2>
    </div>
    <div class="card-body">
      <p>
        <xsl:value-of select="i18n:translate('thesisList.introIntro',@year)" disable-output-escaping="yes" />          
      </p>
      <p>       
        <xsl:value-of select="i18n:translate('thesisList.introDate',@today)" disable-output-escaping="yes"/>      
        <strong><xsl:value-of select="count(group/mods:mods)" /></strong> 
        <xsl:text> </xsl:text>
        <xsl:value-of select="i18n:translate('thesisList.introDiss',@year)" disable-output-escaping="yes"/> 
      </p>
      <p>      
        <xsl:value-of select="i18n:translate('thesisList.introCorr')"/>
        <a href="mailto:universitaetsbibliographie@ub.uni-due.de">universitaetsbibliographie@ub.uni-due.de</a>.
      </p>
    </div>
    <div class="card-footer">
      <form action="ThesisListServlet" onsubmit="jQuery('.diss-list').remove();" class="form-inline float-right">
        <div class="form-group">
          <label for="year" class="mr-2">
            <xsl:value-of select="i18n:translate('thesisList.dissYear')"/> 
          </label>
          <select class="form-control px-2" id="year" name="year">
            <xsl:call-template name="option.year">
              <xsl:with-param name="year">2020</xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="option.year">
              <xsl:with-param name="year">2019</xsl:with-param>
            </xsl:call-template> 
            <xsl:call-template name="option.year">
              <xsl:with-param name="year">2018</xsl:with-param>
            </xsl:call-template>     
            <xsl:call-template name="option.year">
              <xsl:with-param name="year">2017</xsl:with-param>
            </xsl:call-template>     
            <xsl:call-template name="option.year">
              <xsl:with-param name="year">2016</xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="option.year">
              <xsl:with-param name="year">2015</xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="option.year">
              <xsl:with-param name="year">2014</xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="option.year">
              <xsl:with-param name="year">2013</xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="option.year">
              <xsl:with-param name="year">2012</xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="option.year">
              <xsl:with-param name="year">2011</xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="option.year">
              <xsl:with-param name="year">2010</xsl:with-param>
            </xsl:call-template>
          </select>
        </div>
        <div class="form-group">      
          <label for="by" class="px-2">
            <xsl:value-of select="i18n:translate('thesisList.introGroup')"/>
          </label>
          <select class="form-control px-2" id="by" name="by">
            <xsl:call-template name="option.by">
              <xsl:with-param name="by">mir_institutes</xsl:with-param>
              <xsl:with-param name="label"><xsl:value-of select="i18n:translate('thesisList.faculties')"/></xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="option.by">
              <xsl:with-param name="by">subject</xsl:with-param>
              <xsl:with-param name="label"><xsl:value-of select="i18n:translate('thesisList.subjects')"/></xsl:with-param>
            </xsl:call-template>
          </select>
        </div>
        <div class="form-group">
          <label for="style" class="px-2">
            <xsl:value-of select="i18n:translate('thesisList.as')"/>
          </label>
          <select name="XSL.Style" id="style" class="form-control px-2">
            <option value="" selected="selected">
              <xsl:value-of select="i18n:translate('thesisList.as.webpage')"/>
            </option>
            <option value="pdf">
              <xsl:value-of select="i18n:translate('thesisList.as.pdf')"/>
            </option>
          </select>
        </div>      
        <button type="submit" class="btn btn-primary ml-2">
          <xsl:value-of select="i18n:translate('thesisList.show')" />
        </button>
      </form>
    </div>
  </div>
</xsl:template>

<xsl:template name="option.year">
  <xsl:param name="year" />
  <option>
    <xsl:if test="@year = $year">
      <xsl:attribute name="selected">selected</xsl:attribute>
    </xsl:if>
    <xsl:value-of select="$year" />
  </option>
</xsl:template>

<xsl:template name="option.by">
  <xsl:param name="by" />
  <xsl:param name="label" />
  <option value="{$by}">
    <xsl:if test="@by = $by">
      <xsl:attribute name="selected">selected</xsl:attribute>
    </xsl:if>
    <xsl:value-of select="$label" />
  </option>
</xsl:template>

<xsl:template match="mods:mods">
  <tr>
    <td>
      <xsl:apply-templates select="mods:name[mods:role/mods:roleTerm='aut']" />
    </td>
    <td>
      <xsl:apply-templates select="mods:titleInfo[1]" />
      <xsl:if test="mods:originInfo|mods:relatedItem[@type='series']|mods:identifier[@type='isbn']">
        <div>
          <xsl:apply-templates select="mods:originInfo" />
          <xsl:apply-templates select="mods:relatedItem[@type='series']" />
          <xsl:apply-templates select="mods:identifier[@type='isbn'][1]" />
        </div>
      </xsl:if>
      <xsl:apply-templates select="mods:identifier[@type='doi']" />
      <xsl:apply-templates select="mods:identifier[@type='urn']" />
    </td>
    <td>
      <xsl:apply-templates select="mods:location/mods:shelfLocator" />
    </td>
  </tr>
</xsl:template>

<xsl:template match="mods:name[@type='personal']">
  <div>
    <xsl:value-of select="mods:namePart[@type='family']" />
    <xsl:text>, </xsl:text>
    <xsl:value-of select="mods:namePart[@type='given']" />
  </div>
</xsl:template>

<xsl:template match="mods:titleInfo">
  <div style="margin-bottom:1ex; font-weight:bold;">
    <xsl:value-of select="mods:title" />
    <xsl:if test="mods:subTitle">
      <xsl:if test="translate(substring(mods:title,string-length(mods:title)),'?!.:,-;','.......') != '.'">
        <xsl:text> :</xsl:text>
      </xsl:if>
      <xsl:text> </xsl:text>
      <xsl:value-of select="mods:subTitle" />
    </xsl:if>
  </div>
</xsl:template>

<xsl:template match="mods:originInfo">
  <xsl:value-of select="mods:place/mods:placeTerm" />
  <xsl:apply-templates select="mods:publisher" />
  <xsl:apply-templates select="mods:dateIssued" />
</xsl:template>

<xsl:template match="mods:publisher">
  <xsl:if test="../mods:place">
    <xsl:text>: </xsl:text>
  </xsl:if>
  <xsl:value-of select="." />
</xsl:template>

<xsl:template match="mods:dateIssued">
  <xsl:text> (</xsl:text>
  <xsl:value-of select="normalize-space(text())" />
  <xsl:text>)</xsl:text>
</xsl:template>

<xsl:template match="mods:relatedItem[@type='series']">
  <xsl:text> (</xsl:text>
    <xsl:value-of select="mods:titleInfo/mods:title" />
    <xsl:apply-templates select="mods:part" />
  <xsl:text>)</xsl:text>
</xsl:template>

<xsl:template match="mods:part">
  <xsl:text> ; </xsl:text>
  <xsl:value-of select="mods:detail[@type='volume']/mods:number" />
</xsl:template>

<xsl:template match="mods:identifier[@type='isbn']">
  <xsl:if test="../mods:originInfo|../mods:relatedItem[@type='series']">
    <xsl:text>, </xsl:text>
  </xsl:if>
  <xsl:text>ISBN </xsl:text>
  <a href="http://de.wikipedia.org/w/index.php?title=Spezial%3AISBN-Suche&amp;isbn={.}">
    <xsl:value-of select="." />
  </a>
</xsl:template>

<xsl:template match="mods:identifier[@type='doi']">
  <div>
    <strong>DOI: </strong>
    <a href="https://doi.org/{text()}">
      <xsl:value-of select="text()" />
    </a>
  </div>
</xsl:template>

<xsl:template match="mods:identifier[@type='urn']">
  <div>
    <xsl:value-of select="i18n:translate('thesisList.fulltext')"/>:
    <a href="http://nbn-resolving.org/{.}">
      <xsl:value-of select="." />
    </a>
  </div>
</xsl:template>

<xsl:variable name="primo.search">
  <xsl:text>http://primo.ub.uni-due.de/primo_library/libweb/action/dlSearch.do</xsl:text>
  <xsl:text>?vid=UDE&amp;institution=UDE&amp;bulkSize=10&amp;indx=1&amp;onCampus=false&amp;query=</xsl:text>
</xsl:variable>

<xsl:template match="mods:location/mods:shelfLocator">
  <div>
    <xsl:variable name="sig">
      <xsl:apply-templates select="." mode="normalize.shelfmark" />
    </xsl:variable>
    <a target="_blank" href="{$primo.search}lsr11,contains,%22{$sig}%22">
      <xsl:value-of select="text()"/>
    </a>
  </div>
</xsl:template>

</xsl:stylesheet>
