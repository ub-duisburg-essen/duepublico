<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
    xmlns:mcrver="xalan://org.mycore.common.MCRCoreVersion"
    xmlns:mcrxsl="xalan://org.mycore.common.xml.MCRXMLFunctions"
    xmlns:i="http://www.mycore.org/i18n"
    exclude-result-prefixes="i18n mcrver mcrxsl">

  <xsl:import href="resource:xsl/layout/mir-common-layout.xsl" />
  <xsl:template name="mir.navigation">

    <div class="head-bar">
      <div class="container" >
        <div class="mir-prop-nav">
          <nav>
            <ul class="navbar-nav ml-auto flex-row align-items-center">
              <li>
                <a href="https://www.uni-due.de/ub/" data-toggle="tooltip"
                  title="|de:Universitätsbibliothek Duisburg-Essen|en:Duisburg-Essen university library|">
                  <i class="fas fa-fw fa-info-circle"></i>
                  <span class="icon-label">
                    <i:de>Universitätsbibliothek</i:de>
                    <i:en>University library</i:en>
                  </span>
                </a>
              </li>
              <li>
                <a href="https://www.uni-due.de/ub/publikationsdienste/openaccess.php" data-toggle="tooltip"
                  title="|de:Open Access: Förderung und Informationen|en:Open Access: Funding and information|">
                  <i class="fas fa-fw fa-info-circle"></i>
                  <span class="icon-label">Open Access</span>
                </a>
              </li>
              <li>
                <a href="/content/brand/contact.xml" data-toggle="tooltip"
                  title="|de:Ansprechpartner und Infos für Autoren|en:Contact persons and information for authors|">
                  <i class="fas fa-fw fa-info-circle"></i>
                  <span class="icon-label">
                    <i:de>Kontakt</i:de>
                    <i:en>Contact</i:en>
                  </span>
                </a>
              </li>
              <xsl:call-template name="mir.languageMenu" />
            </ul>
          </nav>
        </div>
      </div>
    </div>

    <header>
      <div class="container">
      <div class="site-header justify-content-between">

        <a href="https://www.uni-due.de/de/index.php" id="udeLogo" class="containsimage">
          <span>
            <i:de>Universität Duisburg-Essen</i:de>
            <i:en>University of Duisburg-Essen</i:en>
          </span>
          <img src="{$WebApplicationBaseURL}images/UDE-logo-claim.svg" alt="Logo Duisburg-Essen" width="1052" height="414" />
        </a>

        <div id="orgaunitTitle">
          <a href="{$WebApplicationBaseURL}">
            <h1>DuEPublico 2</h1>
            <h2>Duisburg-Essen Publications online</h2>
          </a>
        </div>

        <form action="{$WebApplicationBaseURL}servlets/solr/find" class="searchfield_box form-inline ml-auto" role="search">
            <div class="input-group mb-3">
              <input id="searchInput" class="form-control search-query" type="search" name="condQuery"
                placeholder="{i18n:translate('mir.navsearch.placeholder')}"   />
              <xsl:choose>
                <xsl:when test="mcrxsl:isCurrentUserInRole('admin') or mcrxsl:isCurrentUserInRole('editor')">
                  <input name="owner" type="hidden" value="createdby:*" />
                </xsl:when>
                <xsl:when test="not(mcrxsl:isCurrentUserGuestUser())">
                  <input name="owner" type="hidden" value="createdby:{$CurrentUser}" />
                </xsl:when>
              </xsl:choose>
              <div class="input-group-append">
                <button class="btn btn-primary" type="submit"><i class="fas fa-search"></i></button>
              </div>
            </div>
        </form>

      </div>
      </div>
    </header>

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
        </nav>

        <nav class="user-nav">
          <ul class="navbar-nav">
            <xsl:call-template name="mir.loginMenu" />
          </ul>
        </nav>

      </div><!-- /container -->
    </div>
  </xsl:template>

  <xsl:template name="mir.footer">
    <div class="footer-menu">
      <div class="container">
        <div class="row">

          <div class="col" id="footerLogo">
            <a href="https://www.uni-due.de/de/index.php" class="containsimage">
              <img src="{$WebApplicationBaseURL}images/UDE-logo-claim-dark.svg" alt="" width="1052" height="414"/>
            </a>
          </div>
          <div class="col col-md-auto justify-content-end">
            <nav id="navigationFooter" class="navbar">
              <ul>
                <li><a href="https://www.uni-due.de/infoline/">
                  <i class="fas fa-fw fa-phone"></i>Infoline</a></li>
                <li><a href="https://www.uni-due.de/de/hilfe_im_notfall.php">
                  <i class="fas fa-fw fa-exclamation-triangle"></i>
                  <i:de>Hilfe im Notfall</i:de>
                  <i:en>Help in case of emergency</i:en>
                </a></li>
                <li><a href="/content/brand/impressum.xml">
                  <i class="fas fa-comments"></i>
                  <i:de>Impressum</i:de>
                  <i:en>Imprint</i:en>
                </a></li>
                <li><a href="/content/brand/datenschutz.xml">
                  <i class="fas fa-user-shield"></i>
                  <i:de>Datenschutz</i:de>
                  <i:en>Privacy information</i:en>
                </a></li>
              </ul>
            </nav>
            <div id="footerCopyright" class="navbar">
              <ul class="nav">
                <li>© UB DuE</li>
                <li><a href="/content/brand/contact.xml">
                  <i class="fas fa-fw fa-info-circle"></i>
                  <i:de>Kontakt</i:de>
                  <i:en>Contact</i:en>
                </a></li>
                <li><a href="mailto:duepublico@ub.uni-due.de"><i class="fas fa-fw fa-envelope"></i> duepublico@ub.uni-due.de</a></li>
              </ul>
            </div>
          </div>

        </div>
      </div>
    </div>
  </xsl:template>

  <xsl:template name="mir.powered_by">
    <xsl:variable name="mcr_version" select="concat('MyCoRe ',mcrver:getCompleteVersion())" />
    <div id="powered_by">
      <div class="container">
        <div class="row">
          <div class="col text-left">
            <p>
              <strong>DuEPublico</strong>
              <i:de>
                ist der Dokumenten- und Publikationsserver der Universität Duisburg-Essen.
                DuEPublico wird von der Universitätsbibliothek betrieben und
                basiert auf dem Repository-Framework MyCoRe und weiteren Open Source Komponenten.
              </i:de>
              <i:en>
                is the institutional repository of the University of Duisburg-Essen.
                DuEPublico is driven by the university library and 
                based on the repository framework MyCoRe and additional Open Source components. 
              </i:en>
              <span class="read_more">
                <a href="http://www.mycore.de/">
                  <i:de>Mehr erfahren...</i:de>
                  <i:en>Find out more...</i:en>
                </a>
              </span>
            </p>
          </div>
          <div class="col col-md-auto text-right">
            <a href="http://www.mycore.de">
              <img src="{$WebApplicationBaseURL}mir-layout/images/mycore_logo_small_invert.png" title="{$mcr_version}" alt="powered by MyCoRe" />
            </a>
          </div>
        </div>
      </div>
    </div>
  </xsl:template>

</xsl:stylesheet>
