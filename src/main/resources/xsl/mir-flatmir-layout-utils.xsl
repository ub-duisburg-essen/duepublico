<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:mcrver="xalan://org.mycore.common.MCRCoreVersion"
    xmlns:mcrxsl="xalan://org.mycore.common.xml.MCRXMLFunctions"
    xmlns:i="http://www.mycore.org/i18n"
    exclude-result-prefixes="mcrver mcrxsl">

  <xsl:import href="resource:xsl/layout/mir-common-layout.xsl" />
  <xsl:template name="mir.navigation">

    <div class="head-bar">
      <div class="container" >
        <div class="mir-prop-nav">
          <nav>
            <ul class="navbar-nav flex-row flex-wrap align-items-center">
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

    <div class="site-header">
      <div class="container">
        <div class="row">
          <div class="col-12 col-sm-6 col-md-auto">
            <a href="https://www.uni-due.de/de/index.php" id="udeLogo" class="containsimage">
              <span>
                <i:de>Universität Duisburg-Essen</i:de>
                <i:en>University of Duisburg-Essen</i:en>
              </span>
              <img src="{$WebApplicationBaseURL}images/UDE-logo-claim.svg" alt="Logo Duisburg-Essen" width="1052" height="414" />
            </a>
          </div>
          <div class="col-12 col-sm-6 col-md-auto">
            <div id="orgaunitTitle">
              <a href="{$WebApplicationBaseURL}">
                <h1>
                  <span class="text-nowrap">DuEPublico 2</span>
                </h1>
                <h2>
                  <span class="text-nowrap">Duisburg-Essen</span>
                  <xsl:comment>breaking point</xsl:comment>
                  <span class="text-nowrap">Publications online</span>
                </h2>
              </a>
            </div>
          </div>
          <div class="col-12 col-md">
            <form action="{$WebApplicationBaseURL}servlets/solr/find" class="searchfield_box form-inline my-2 my-lg-0" role="search">
                <div class="input-group mb-3">
                  <input id="searchInput" class="form-control mr-sm-2 search-query" type="search" name="condQuery"
                    placeholder="|code:mir.navsearch.placeholder|" aria-label="Search" />
                  <xsl:choose>
                    <xsl:when test="contains($isSearchAllowedForCurrentUser, 'true')">
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
      </div>
    </div>

    <!-- Collect the nav links, forms, and other content for toggling -->
    <div class="mir-main-nav bg-primary">
      <div class="container">
        <nav class="navbar navbar-expand-lg navbar-dark bg-primary">

          <button
            class="navbar-toggler"
            type="button"
            data-toggle="collapse"
            data-target="#mir-main-nav-collapse-box"
            aria-controls="mir-main-nav-collapse-box"
            aria-expanded="false"
            aria-label="Toggle navigation">
            <span class="navbar-toggler-icon"></span>
          </button>

          <div id="mir-main-nav-collapse-box" class="collapse navbar-collapse mir-main-nav__entries">
            <ul class="navbar-nav mr-auto mt-2 mt-lg-0">
              <li>
                <a class="nav-link" href="https://www.uni-due.de/ub/">UB</a>
              </li>
              <xsl:for-each select="$loaded_navigation_xml/menu">
                <xsl:choose>
                  <!-- Ignore some menus, they are shown elsewhere in the layout -->
                  <xsl:when test="@id='main'"/>
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
            <ul class="navbar-nav">
              <xsl:call-template name="mir.loginMenu" />
            </ul>
          </div>
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
              <img src="{$WebApplicationBaseURL}images/UDE-logo-claim-dark.svg" class="mb-5" alt="" width="1052" height="414"/>
            </a>
          </div>
          <div class="col col-md-auto justify-content-end">
            <nav id="navigationFooter" class="navbar">
              <ul>
                <li><a href="https://www.uni-due.de/infoline/" class="footer-menu__entry">
                  <i class="fas fa-fw fa-phone"></i>Infoline</a></li>
                <li><a href="https://www.uni-due.de/de/hilfe_im_notfall.php" class="footer-menu__entry">
                  <i class="fas fa-fw fa-exclamation-triangle"></i>
                  <i:de>Hilfe im Notfall</i:de>
                  <i:en>Help in case of emergency</i:en>
                </a></li>
                <li><a href="/content/brand/impressum.xml" class="footer-menu__entry">
                  <i class="fas fa-comments"></i>
                  <i:de>Impressum</i:de>
                  <i:en>Imprint</i:en>
                </a></li>
                <li><a href="/content/brand/datenschutz.xml" class="footer-menu__entry">
                  <i class="fas fa-user-shield"></i>
                  <i:de>Datenschutz</i:de>
                  <i:en>Privacy information</i:en>
                </a></li>
                <li><a href="/content/brand/accessibility.xml" class="footer-menu__entry">
                  <i class="fas fa-universal-access"></i>
                  <i:de>Barrierefreiheit</i:de>
                  <i:en>Accessibility</i:en>
                </a></li>
              </ul>
            </nav>
            <div id="footerCopyright" class="navbar">
              <ul class="nav">
                <li>© UB DuE</li>
                <li><a href="/content/brand/contact.xml" class="footer-menu__entry">
                  <i class="fas fa-fw fa-info-circle"></i>
                  <i:de>Kontakt</i:de>
                  <i:en>Contact</i:en>
                </a></li>
                <li><a href="mailto:duepublico@ub.uni-due.de" class="footer-menu__entry"><i class="fas fa-fw fa-envelope"></i> duepublico@ub.uni-due.de</a></li>
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
          <div class="col-12 col-md text-left">
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
          <div class="col-12 col-md-auto text-right">
            <a href="http://www.mycore.de">
              <img src="{$WebApplicationBaseURL}mir-layout/images/mycore_logo_small_invert.png" title="{$mcr_version}" alt="powered by MyCoRe" />
            </a>
          </div>
        </div>
      </div>
    </div>
  </xsl:template>

</xsl:stylesheet>
