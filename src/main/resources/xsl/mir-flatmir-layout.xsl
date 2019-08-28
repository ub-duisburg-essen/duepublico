<?xml version="1.0" encoding="utf-8"?>
  <!-- ============================================== -->
  <!-- $Revision$ $Date$ -->
  <!-- ============================================== -->
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
    exclude-result-prefixes="xlink i18n">

  <xsl:output method="html" doctype-system="about:legacy-compat" indent="yes" omit-xml-declaration="yes" media-type="text/html"
    version="5" />
  <xsl:strip-space elements="*" />
  <xsl:include href="resource:xsl/mir-flatmir-layout-utils.xsl"/>
  <xsl:param name="MIR.DefaultLayout.CSS" select="'flatly'" />
  <xsl:param name="MIR.CustomLayout.CSS" select="''" />
  <xsl:param name="MIR.CustomLayout.JS" select="''" />
  <xsl:param name="MIR.Layout.Theme" select="'flatmir'" />

  <xsl:variable name="PageTitle" select="/*/@title" />

  <xsl:template match="/site">
    <html lang="{$CurrentLang}" class="no-js">
      <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <!-- The above 3 meta tags *must* come first in the head; any other head content must come *after* these tags -->
        <title>
          <xsl:value-of select="$PageTitle" />
        </title>
        <link href="{$WebApplicationBaseURL}assets/font-awesome/css/all.min.css" rel="stylesheet" />
        <script type="text/javascript" src="{$WebApplicationBaseURL}mir-layout/assets/jquery/jquery.min.js"></script>
        <script type="text/javascript" src="{$WebApplicationBaseURL}mir-layout/assets/jquery/plugins/jquery-migrate/jquery-migrate.min.js"></script>
        <xsl:copy-of select="head/*" />
        <link href="{$WebApplicationBaseURL}rsc/sass/mir-layout/scss/{$MIR.Layout.Theme}-{$MIR.DefaultLayout.CSS}.css" rel="stylesheet" />
        <xsl:if test="string-length($MIR.CustomLayout.CSS) &gt; 0">
          <link href="{$WebApplicationBaseURL}css/{$MIR.CustomLayout.CSS}" rel="stylesheet" />
        </xsl:if>
        <xsl:if test="string-length($MIR.CustomLayout.JS) &gt; 0">
          <script type="text/javascript" src="{$WebApplicationBaseURL}js/{$MIR.CustomLayout.JS}"></script>
        </xsl:if>
        <xsl:call-template name="mir.prop4js" />
        
        <link rel="stylesheet" href="{$WebApplicationBaseURL}css/duepublico.css"/>
        <link rel="icon" href="{$WebApplicationBaseURL}favicon.ico" type="image/x-icon" />
      </head>

      <body>
        <xsl:if test="//div/@class='jumbotwo'">
          <xsl:attribute name="class">
            <xsl:text>mir-start_page</xsl:text>
          </xsl:attribute>
        </xsl:if>

        <header>
          <xsl:call-template name="mir.navigation" />
          <noscript>
            <div class="mir-no-script alert alert-warning text-center" style="border-radius: 0;">
              <xsl:value-of select="i18n:translate('mir.noScript.text')" />&#160;
              <a href="http://www.enable-javascript.com/de/" target="_blank">
                <xsl:value-of select="i18n:translate('mir.noScript.link')" />
              </a>.
            </div>
          </noscript>
        </header>

        <section>
          <div class="container" id="page" style="padding-top:10px, padding-bottom:10px;">
            <div id="main_content">
              <xsl:call-template name="print.beta" />
              <xsl:call-template name="print.writeProtectionMessage" />
              <xsl:call-template name="print.statusMessage" />

              <xsl:choose>
                <xsl:when test="$readAccess='true'">
                  <xsl:if test="breadcrumb/ul[@class='breadcrumb']">
                    <div class="row detail_row bread_plus">
                      <div class="col-12">
                        <ul itemprop="breadcrumb" class="breadcrumb">
                          <li class="breadcrumb-item">
                            <a class="navtrail" href="{$WebApplicationBaseURL}"><xsl:value-of select="i18n:translate('mir.breadcrumb.home')" /></a>
                          </li>
                          <xsl:copy-of select="breadcrumb/ul[@class='breadcrumb']/*" />
                        </ul>
                      </div>
                    </div>
                  </xsl:if>
                  <xsl:copy-of select="*[not(name()='head')][not(name()='breadcrumb')] " />
                </xsl:when>
                <xsl:otherwise>
                  <xsl:call-template name="printNotLoggedIn" />
                </xsl:otherwise>
              </xsl:choose>
            </div>
          </div>
        </section>

        <footer class="flatmir-footer">
          <xsl:call-template name="mir.footer" />
        </footer>

        <script type="text/javascript">
          <!-- Bootstrap & Query-Ui button conflict workaround  -->
          if (jQuery.fn.button){jQuery.fn.btn = jQuery.fn.button.noConflict();}
        </script>
        <script type="text/javascript" src="{$WebApplicationBaseURL}assets/bootstrap/js/bootstrap.bundle.min.js"></script>
        <script type="text/javascript" src="{$WebApplicationBaseURL}assets/jquery/plugins/jquery-confirm/jquery.confirm.min.js"></script>
        <script type="text/javascript" src="{$WebApplicationBaseURL}js/mir/base.min.js"></script>
        <script>
          $( document ).ready(function() {
            $('.overtext').tooltip();
            $.confirm.options = {
              title: "<xsl:value-of select="i18n:translate('mir.confirm.title')" />",
              confirmButton: "<xsl:value-of select="i18n:translate('mir.confirm.confirmButton')" />",
              cancelButton: "<xsl:value-of select="i18n:translate('mir.confirm.cancelButton')" />",
              post: false,
              confirmButtonClass: "btn-danger",
              cancelButtonClass: "btn-secondary",
              dialogClass: "modal-dialog modal-lg" // Bootstrap classes for large modal
            }
          });
        </script>
        <!-- alco add placeholder for older browser -->
        <script src="{$WebApplicationBaseURL}assets/jquery/plugins/jquery-placeholder/jquery.placeholder.min.js"></script>
        <script>
          jQuery("input[placeholder]").placeholder();
          jQuery("textarea[placeholder]").placeholder();
        </script>
      </body>
    </html>
  </xsl:template>
  <xsl:template match="/*[not(local-name()='site')]">
    <xsl:message terminate="yes">This is not a site document, fix your properties.</xsl:message>
  </xsl:template>
  
  <xsl:param name="RequestURL" />
  
  <xsl:template name="print.beta">
    <div class="alert alert-danger" role="alert" style="padding:5px; margin-bottom:1ex;">
      <strong style="margin-right:10px;">
        DuEPublico 2
        <i class="fas fa-exclamation"></i>
      </strong>
      Dies ist unser <strong>neues Repositorium</strong>,
      derzeit für E-Dissertationen und ausgewählte weitere Publikationen.
      <xsl:if test="not(contains($RequestURL,'/content/index.xml'))">
        <a class="alert-link" href="{$WebApplicationBaseURL}" style="margin-left:2ex;">Weitere Informationen...</a>
      </xsl:if>
     </div>
  </xsl:template>
  
</xsl:stylesheet>
