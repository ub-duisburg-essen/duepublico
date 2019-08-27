<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
    xmlns:mcrver="xalan://org.mycore.common.MCRCoreVersion"
    xmlns:mcrxsl="xalan://org.mycore.common.xml.MCRXMLFunctions"
    exclude-result-prefixes="i18n mcrver mcrxsl">

  <xsl:import href="resource:xsl/layout/mir-common-layout.xsl" />
  <xsl:template name="mir.navigation">

    <div id="header_box" class="clearfix container" style='background-color: rgb(0, 76, 147); background-image: url("{$WebApplicationBaseURL}images/wolken_2015.jpg");'>
      <div id="project_logo_box">
        <a href="{concat($WebApplicationBaseURL,substring($loaded_navigation_xml/@hrefStartingPage,2),$HttpSession)}" class="">
          <h3>DuEPublico 2 - <small>Duisburg-Essen Publications online</small></h3>
        </a>
      </div>
      <a id="ude-logo" href="https://www.uni-due.de/">
        <img src="{$WebApplicationBaseURL}images/ude-logo.png" alt="Logo Universität Duisburg-Essen" />
      </a>
    </div>

    <!-- Collect the nav links, forms, and other content for toggling -->
    <div class="navbar navbar-expand-lg mir-main-nav">
      <div class="container">

        <div class="navbar-header">
          <button class="navbar-toggler" type="button" data-toggle="collapse" data-target=".mir-main-nav-entries">
            <span class="navbar-toggler-icon"></span>
          </button>
        </div>

        <nav class="collapse navbar-collapse mir-main-nav-entries">
          <ul class="navbar-nav mr-auto">
            <li class="nav-item">
              <a class="nav-link" href="https://www.uni-due.de/ub/">UB</a>
            </li>
            <xsl:for-each select="$loaded_navigation_xml/menu">
              <xsl:choose>
                <xsl:when test="@id='main'"/> <!-- Ignore some menus, they are shown elsewhere in the layout -->
                <xsl:when test="@id='brand'"/>
                <xsl:when test="@id='below'"/>
                <xsl:when test="@id='user'"/>
                <xsl:otherwise>
                  <xsl:apply-templates select="."/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:for-each>
            <xsl:call-template name="mir.basketMenu" />
          </ul>
          <ul class="navbar-nav ml-auto" style="margin-right:2ex;">
            <xsl:call-template name="mir.loginMenu" />
            <xsl:call-template name="mir.languageMenu" />
          </ul>
        </nav>

        <form action="{$WebApplicationBaseURL}servlets/solr/find" class="searchfield_box form-inline my-2" role="search">
          <div class="form-group">
            <input name="condQuery" placeholder="{i18n:translate('mir.navsearch.placeholder')}" class="form-control search-query" id="searchInput" type="text" />
            <xsl:choose>
              <xsl:when test="mcrxsl:isCurrentUserInRole('admin') or mcrxsl:isCurrentUserInRole('editor')">
                <input name="owner" type="hidden" value="createdby:*" />
              </xsl:when>
              <xsl:when test="not(mcrxsl:isCurrentUserGuestUser())">
                <input name="owner" type="hidden" value="createdby:{$CurrentUser}" />
              </xsl:when>
            </xsl:choose>
          </div>
          <button type="submit" class="btn btn-primary"><i class="fas fa-search"></i></button>
        </form>

      </div><!-- /container -->
    </div>
  </xsl:template>

  <xsl:template name="mir.footer">
    <div class="container">
      <div class="row">
        <div class="col-8">
          <p>
            <strong>DuEPublico</strong> ist der Dokumenten- und Publikationsserver der Universität Duisburg-Essen.
            DuEPublico wird von der Universitätsbibliothek betrieben und 
            basiert auf dem Repository-Framework MyCoRe und weiteren Open Source Komponenten.
            <span class="read_more">
              <a href="http://www.mycore.de/">Mehr erfahren ...</a>
            </span>
          </p>
        </div>
        <div class="col-2">
          <xsl:call-template name="mir.powered_by" />
        </div>
        <div class="col-2">
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
