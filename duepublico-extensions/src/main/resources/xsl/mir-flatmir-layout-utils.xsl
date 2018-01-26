<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:mcrver="xalan://org.mycore.common.MCRCoreVersion"
    xmlns:mcrxsl="xalan://org.mycore.common.xml.MCRXMLFunctions"
    exclude-result-prefixes="mcrver mcrxsl">

  <xsl:import href="resource:xsl/layout/mir-common-layout.xsl" />
  <xsl:template name="mir.navigation">

    <div id="header_box" class="clearfix container">
      <div id="options_nav_box" class="mir-prop-nav">
        <nav>
          <ul class="nav navbar-nav pull-right">
            <xsl:call-template name="mir.loginMenu" />
            <xsl:call-template name="mir.languageMenu" />
          </ul>
        </nav>
      </div>
      <div id="project_logo_box">
        <a href="{concat($WebApplicationBaseURL,substring($loaded_navigation_xml/@hrefStartingPage,2),$HttpSession)}" class="">
          <span>DuEPublico: Dissertationen</span>
        </a>
      </div>
    </div>

    <!-- Collect the nav links, forms, and other content for toggling -->
    <div class="navbar navbar-default mir-main-nav">
      <div class="container">

        <div class="navbar-header">
          <button class="navbar-toggle" type="button" data-toggle="collapse" data-target=".mir-main-nav-entries">
            <span class="sr-only"> Toggle navigation </span>
            <span class="icon-bar">
            </span>
            <span class="icon-bar">
            </span>
            <span class="icon-bar">
            </span>
          </button>
        </div>

        <div class="searchfield_box">
          <form action="{$WebApplicationBaseURL}servlets/solr/find" class="navbar-form navbar-left pull-right" role="search">
            <button type="submit" class="btn btn-primary"><i class="fa fa-search"></i></button>
            <div class="form-group">
              <input name="condQuery" placeholder="Suche" class="form-control search-query" id="searchInput" type="text" />
              <xsl:if test="not(mcrxsl:isCurrentUserGuestUser())">
                <input name="owner" type="hidden" value="createdby:{$CurrentUser}" />
              </xsl:if>
            </div>
          </form>
        </div>

        <nav class="collapse navbar-collapse mir-main-nav-entries">
          <ul class="nav navbar-nav pull-left">
            <xsl:for-each select="$loaded_navigation_xml/menu">
              <xsl:choose>
                <xsl:when test="@id='main'" /> <!-- Ignore some menus, they are shown elsewhere in the layout -->
                <xsl:when test="@id='brand'" />
                <xsl:when test="@id='below'" />
                <xsl:when test="@id='user'" />
                <xsl:otherwise>
                  <xsl:apply-templates select="." />
                </xsl:otherwise>
              </xsl:choose>
            </xsl:for-each>
            <xsl:call-template name="mir.basketMenu" />
          </ul>
        </nav>

      </div><!-- /container -->
    </div>
  </xsl:template>

  <xsl:template name="mir.footer">
    <div class="container">
      <div class="row">
        <div class="col-xs-12 col-sm-9 col-md-10">
          <h4>Über DuEPublico</h4>
          <p>
            DuEPublico ist der Dokumenten- und Publikationsserver der Universität Duisburg-Essen.
            Er basiert auf dem Repository-Framework MyCoRe und dem Metadata Object Description Schema (MODS).
            <span class="read_more">
              <a href="http://mycore.de/generated/mir/">Mehr erfahren ...</a>
            </span>
          </p>
        </div>
        <div class="col-xs-6 col-sm-3 col-md-2">
          <h4>Navigation</h4>
          <ul class="internal_links">
            <xsl:apply-templates select="$loaded_navigation_xml/menu[@id='brand']/*" />
          </ul>
        </div>
      </div>
    </div>
  </xsl:template>

  <xsl:template name="mir.powered_by">
    <xsl:variable name="mcr_version" select="concat('MyCoRe ',mcrver:getCompleteVersion())" />
    <div id="powered_by">
      <a href="http://www.mycore.de">
        <img src="{$WebApplicationBaseURL}mir-layout/images/mycore_logo_small_invert.png" title="{$mcr_version}" alt="powered by MyCoRe" />
      </a>
    </div>
  </xsl:template>

</xsl:stylesheet>
