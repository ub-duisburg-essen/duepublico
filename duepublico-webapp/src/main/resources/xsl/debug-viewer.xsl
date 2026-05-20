<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<!--
  Debug Viewer for text and XML elements.
  Usage: 
  
  <xsl:call-template name="debug-viewer">
    <xsl:with-param name="headline">Some useful headline</xsl:with-param>
    <xsl:with-param name="xml" select="document($uri)/*" />
  </xsl:call-template>

  <xsl:call-template name="debug-viewer.css" />
  <xsl:call-template name="debug-viewer.js" />
-->

  <xsl:template name="debug-viewer">
    <xsl:param name="headline" />
    <xsl:param name="text" /> <!-- provide either plain text to output... -->
    <xsl:param name="xml" />  <!-- ... or an xml element node -->

    <h3 class="mt-4">
      <xsl:value-of select="$headline" />
      <xsl:text>:</xsl:text>
    </h3>
    <div class="debug-viewer-box">
      <div class="debug-scroll-container">
        <xsl:if test="$text">
          <xsl:attribute name="style">white-space: pre-wrap;</xsl:attribute>
          <xsl:copy-of select="$text" />
        </xsl:if>
        <xsl:if test="$xml">
          <xsl:apply-templates select="$xml" mode="pretty-print-xml" />
        </xsl:if>
      </div>
      <button class="copy-btn" onclick="copyXmlToClipboard(this)">
        <i class="far fa-copy" />
      </button>
    </div>
  </xsl:template>
  
  <xsl:template name="debug-viewer.css">
    <style>
      .debug-viewer-box { background-color: #fafafa; border: 1px solid #ddd; border-radius: 4px; position: relative; padding: 0; margin: 10px 0; }
      .debug-scroll-container { max-height: 400px; overflow: auto; padding: 15px; scrollbar-width: auto; }
      .xml-element { margin: 2px 0; position: relative; padding-left: 15px; font-family: 'Courier New', monospace; font-size: 14px; line-height: 1.4; }
      .xml-content { margin-left: 20px; }
      details summary { cursor: pointer; outline: none; display: list-item; list-style: none; }
      details summary::-webkit-details-marker { display: none; }
      details summary::marker { display: none; content: ""; }
      details summary::before { content: "▼"; color: #999; font-size: 10px; position: absolute; left: 0; top: 2px; width: 12px; text-align: center; }
      details:not([open]) summary::before { content: "▶"; }
      details summary .xml-placeholder { display: none; color: #999; }
      details:not([open]) summary .xml-placeholder { display: inline; }
      .xml-tag { color: #000080; font-weight: bold; }
      .xml-attr { color: #f60; }
      .xml-val { color: #008000; }
      .xml-text { color: #333; font-family: 'Courier New', monospace; font-size: 14px; }
      .debug-scroll-container::-webkit-scrollbar { width: 14px; height: 14px; }
      .debug-scroll-container::-webkit-scrollbar-thumb { background: #ccc; border-radius: 7px; border: 3px solid #fafafa; }
      .copy-btn { position: absolute; bottom: 15px; right: 15px; z-index: 10; background: #ffffff; border: 1px solid #ccc; width: 32px; height: 32px; padding: 0; border-radius: 4px; cursor: pointer; box-shadow: 0 2px 4px rgba(0,0,0,0.1); transition: all 0.2s; display: flex; align-items: center; justify-content: center; font-size: 14px; color: #555; }
      .copy-btn:hover { background: #f0f0f0; }
    </style>
  </xsl:template>

  <xsl:template name="debug-viewer.js">
    <script>
      function copyXmlToClipboard(buttonElement) {
        const viewerBox = buttonElement.parentElement;
        let xmlText = viewerBox.innerText.trim();
            
        navigator.clipboard.writeText(xmlText).then(function() {
          // find copy icon
          const icon = buttonElement.querySelector('i');
                
          // save icon state
          const originalClasses = icon.className;
                
          // mark icon as checked
          icon.className = "fas fa-check";
          buttonElement.style.borderColor = "#008000";
          buttonElement.style.color = "#008000";
                
          // reset icon after 2 sec
          setTimeout(function() {
            icon.className = originalClasses;
            buttonElement.style.borderColor = "#ccc";
            buttonElement.style.color = "#555";
          }, 2000);
        }).catch(function(err) {
          console.error('Error copying viewer content: ', err);
        });
      }
    </script>
  </xsl:template>

  <!-- pretty-print xml element -->
  <xsl:template match="*" mode="pretty-print-xml">
    <div class="xml-element">
      <xsl:choose>
          
        <!-- .. with child elements: prepare for expand/collapse -->
        <xsl:when test="*">
          <details open="open">
            <summary>
              <xsl:call-template name="pretty-print-element-start" />
              <span class="xml-tag">&gt;</span>
              <span class="xml-placeholder">...</span>
            </summary>
            <div class="xml-content">
              <xsl:apply-templates select="node()" mode="pretty-print-xml" />
            </div>
            <span class="xml-tag">
              <xsl:value-of select="concat('&lt;/',name(),'&gt;')" />
            </span>
          </details>
        </xsl:when>

        <!-- ... with text content -->
        <xsl:when test="text()">
          <xsl:call-template name="pretty-print-element-start" />
          <span class="xml-tag">&gt;</span>
          <xsl:apply-templates select="text()" mode="pretty-print-xml" />
          <span class="xml-tag">
            <xsl:value-of select="concat('&lt;/',name(),'&gt;')" />
          </span>
        </xsl:when>

        <!-- ... otherwise: empty element -->
        <xsl:otherwise>
          <xsl:call-template name="pretty-print-element-start" />
          <span class="xml-tag">&#160;/&gt;</span>
        </xsl:otherwise>

      </xsl:choose>
    </div>
  </xsl:template>

  <!-- pretty-print xml text node -->
  <xsl:template match="text()" mode="pretty-print-xml">
    <xsl:if test="normalize-space(.)">
      <span class="xml-text">
        <xsl:value-of select="normalize-space(.)" />
      </span>
    </xsl:if>
  </xsl:template>
  
  <xsl:template name="pretty-print-element-start">
    <!-- element start tag -->
    <span class="xml-tag">
      <xsl:value-of select="concat('&lt;',name())" />
    </span>
    
    <!-- attributes -->
    <xsl:for-each select="@*">
      <xsl:text>&#160;</xsl:text>
      <span class="xml-attr">
        <xsl:value-of select="name()" />
      </span>
      <xsl:text>="</xsl:text>
      <span class="xml-val">
        <xsl:value-of select="." />
      </span>
      <xsl:text>"</xsl:text>
    </xsl:for-each>
  </xsl:template>

</xsl:stylesheet>
