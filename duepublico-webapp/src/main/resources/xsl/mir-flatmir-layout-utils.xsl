<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:mcrver="xalan://org.mycore.common.MCRCoreVersion"
    xmlns:mcrxsl="xalan://org.mycore.common.xml.MCRXMLFunctions"
    exclude-result-prefixes="mcrver mcrxsl">

  <xsl:import href="resource:xsl/layout/mir-common-layout.xsl" />
  <xsl:template name="mir.navigation">

    <div id="header_box" class="clearfix container" style='background-color: rgb(0, 76, 147); background-image: url("{$WebApplicationBaseURL}images/wolken_2015.jpg");'>
      <div id="project_logo_box">
        <a href="{concat($WebApplicationBaseURL,substring($loaded_navigation_xml/@hrefStartingPage,2),$HttpSession)}" class="">
          <h3>DuEPublico - <small>Duisburg-Essen Publications Online</small></h3>
        </a>
      </div>
      <a id="ude-logo" href="https://www.uni-due.de/">
        <img src="{$WebApplicationBaseURL}images/ude-logo.png" alt="Logo Universität Duisburg-Essen" />
      </a>
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
            <li>
              <a href="https://www.uni-due.de/ub/">UB</a>
            </li>
            <li>
              <a href="{$WebApplicationBaseURL}">DuEPublico</a>
            </li>
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
          <ul class="nav navbar-nav pull-right" style="margin-right:2ex;">
            <xsl:call-template name="mir.loginMenu" />
            <xsl:call-template name="mir.languageMenu" />
          </ul>
        </nav>

      </div><!-- /container -->
    </div>
  </xsl:template>

  <xsl:template name="mir.footer">
    <div class="container">
      <div class="row">
        <div class="col-xs-12 col-sm-7 col-md-9">
          <p>
            <strong>DuEPublico</strong> ist der Dokumenten- und Publikationsserver der Universität Duisburg-Essen.
            DuEPublico wird von der Universitätsbibliothek betrieben und 
            basiert auf dem Repository-Framework MyCoRe und weiteren Open Source Komponenten.
            <span class="read_more">
              <a href="http://mycore.de/generated/mir/">Mehr erfahren ...</a>
            </span>
          </p>
        </div>
        <div class="col-xs-6 col-sm-3 col-md-2">
          <xsl:call-template name="mir.powered_by" />
        </div>
        <div class="col-xs-6 col-sm-2 col-md-1">
          <ul class="internal_links">
            <xsl:apply-templates select="$loaded_navigation_xml/menu[@id='brand']/*" />
          </ul>
        </div>
      </div>
    </div>
  </xsl:template>

  <xsl:template name="mir.powered_by">
    <xsl:variable name="mcr_version" select="concat('MyCoRe ',mcrver:getCompleteVersion())" />
    <a href="http://www.mycore.de">
      <img src="{$WebApplicationBaseURL}mir-layout/images/mycore_logo_small_invert.png" title="{$mcr_version}" alt="powered by MyCoRe" />
    </a>
  </xsl:template>

</xsl:stylesheet>
