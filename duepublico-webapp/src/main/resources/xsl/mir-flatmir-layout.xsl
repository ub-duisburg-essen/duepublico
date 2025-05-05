<?xml version="1.0" encoding="utf-8"?>
  <!-- ============================================== -->
  <!-- $Revision$ $Date$ -->
  <!-- ============================================== -->
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:i="http://www.mycore.org/i18n"
    exclude-result-prefixes="xlink">

  <xsl:strip-space elements="*" />
  <xsl:include href="resource:xsl/mir-flatmir-layout-utils.xsl"/>
  <xsl:include href="resource:xsl/mir-flatmir-layout-meta-tags.xsl"/>
  <xsl:param name="MIR.DefaultLayout.CSS" />
  <xsl:param name="MIR.CustomLayout.CSS" />
  <xsl:param name="MIR.CustomLayout.JS" />
  <xsl:param name="MIR.Layout.Theme" />

  <xsl:variable name="PageTitle" select="/*/@title" />

  <xsl:template match="/site">
    <html lang="{$CurrentLang}" class="no-js">
      <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <!-- The above 3 meta tags *must* come first in the head; any other head content must come *after* these tags -->
        <xsl:call-template name="mir-flatmir-layout-meta-tags"/>
        <title>
          <xsl:value-of select="$PageTitle" />
        </title>
        <link href="{$WebApplicationBaseURL}assets/font-awesome/css/all.min.css" rel="stylesheet" />
        <script src="{$WebApplicationBaseURL}mir-layout/assets/jquery/jquery.min.js"></script>
        <script src="{$WebApplicationBaseURL}mir-layout/assets/jquery/plugins/jquery-migrate/jquery-migrate.min.js"></script>
        <xsl:copy-of select="head/*" />
        <link href="{$WebApplicationBaseURL}rsc/sass/mir-layout/scss/duepublico-{$MIR.DefaultLayout.CSS}.css" rel="stylesheet" />
        <xsl:if test="string-length($MIR.CustomLayout.CSS) &gt; 0">
          <link href="{$WebApplicationBaseURL}css/{$MIR.CustomLayout.CSS}" rel="stylesheet" />
        </xsl:if>
        <xsl:if test="string-length($MIR.CustomLayout.JS) &gt; 0">
          <script src="{$WebApplicationBaseURL}js/{$MIR.CustomLayout.JS}"></script>
        </xsl:if>
        <xsl:call-template name="mir.prop4js" />
        <link rel="icon" href="{$WebApplicationBaseURL}favicon.ico" type="image/x-icon" />
        <link rel="meta" type="application/ld+json" href="{$WebApplicationBaseURL}/content/oer/oer-visitenkarte.json" title="Service-Description" />
      </head>

      <body class="{@class}">
        <header>
          <xsl:call-template name="mir.navigation" />
          <noscript>
            <div class="mir-no-script alert alert-warning text-center" style="border-radius: 0;">
              <i:code>mir.noScript.text</i:code>&#160;
              <a href="http://www.enable-javascript.com/de/" target="_blank">
                <i:code>mir.noScript.link</i:code>
              </a>
            </div>
          </noscript>
        </header>
        <!-- include Internet Explorer warning -->
        <xsl:call-template name="msie-note" />

        <section>
          <div class="container" id="page">
            <div id="main_content">
              <xsl:call-template name="print.writeProtectionMessage" />
              <xsl:call-template name="print.statusMessage" />

              <xsl:choose>
                <xsl:when test="$readAccess='true'">
                  <xsl:if test="breadcrumb/ul[@class='breadcrumb']">
                    <div class="row detail_row bread_plus">
                      <div class="col-12">
                        <ul itemprop="breadcrumb" class="breadcrumb">
                          <li class="breadcrumb-item">
                            <a class="navtrail" href="{$WebApplicationBaseURL}">
                              <i:code>mir.breadcrumb.home</i:code>
                            </a>
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
          <xsl:call-template name="mir.powered_by" />
          <xsl:call-template name="mir.footer" />
        </footer>

        <script>
          <!-- Bootstrap & Query-Ui button conflict workaround  -->
          if (jQuery.fn.button){jQuery.fn.btn = jQuery.fn.button.noConflict();}
        </script>
        <script src="{$WebApplicationBaseURL}assets/bootstrap/js/bootstrap.bundle.min.js"></script>
        <script src="{$WebApplicationBaseURL}assets/jquery/plugins/jquery-confirm/jquery.confirm.min.js"></script>
        <script src="{$WebApplicationBaseURL}js/mir/base.js"></script>
        <script>
          $( document ).ready(function() {
            $('.overtext').tooltip();
            $.confirm.options = {
              title: "<i:code>mir.confirm.title</i:code>",
              confirmButton: "<i:code>mir.confirm.confirmButton</i:code>",
              cancelButton: "<i:code>mir.confirm.cancelButton</i:code>",
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
</xsl:stylesheet>
