<?xml version="1.0"?>
<!--
Copyright © 2014 Johannes Willkomm
-->
<xsl:stylesheet version="1.0"
    xmlns:cx='http://johannes-willkomm.de/xml/code-xml/'
    xmlns:ca='http://johannes-willkomm.de/xml/code-xml/attributes/'
    xmlns:worg='http://johannes-willkomm.de/xml/web/'
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:s='http://johannes-willkomm.de/xml/wmpc/status'
    xmlns:p='http://johannes-willkomm.de/xml/wmpc/playlist'
    xmlns="http://www.w3.org/1999/xhtml"
    >

  <xsl:variable name="statusns" select="'http://johannes-willkomm.de/xml/wmpc/status'"/>

  <xsl:output method="xml" indent="yes"/>

  <xsl:template match="/">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="mpdview">
    <h1>MPDView</h1>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="actions">
    <div>
      <xsl:apply-templates mode="action"/>
    </div>
  </xsl:template>

  <xsl:template match="break" mode="action"><br/></xsl:template>

  <xsl:template match="*" mode="action">
    <form action="javascript: wmpc.{name()}()" style="display: inline-block" name="{name()}">
      <fieldset style="border: none">
        <legend style="display: none"><xsl:value-of select="."/></legend>
        <input class="action {name()}" type="submit" value="{.}"/>
      </fieldset>
    </form>
  </xsl:template>

  <xsl:template match="status">
    <div class="wmpc-status">
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <xsl:template match="text-status">
    <div id="wmpc-div-status-txt">
    </div>
  </xsl:template>

  <xsl:template match="text-playlist">
    <div id="wmpc-div-playlist-txt">
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <xsl:template match="fancy-playlist">
    <div id="wmpc-div-playlist-fancy">
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <xsl:template match="log">
    <div id="wmpc-div-log">
    </div>
  </xsl:template>

  <xsl:template match="fancy-status">
    <div id="wmpc-div-status-fancy">
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <xsl:template match="cx:root">
    <s:status>
      <xsl:text>&#xa;</xsl:text>
      <xsl:apply-templates mode="status-xml"/>
    </s:status>
  </xsl:template>

  <xsl:template match="text()" mode="status-xml"/>
  <xsl:template match="text()" mode="status-xml-line1"/>
  <xsl:template match="text()" mode="status-xml-line2"/>
  <xsl:template match="text()" mode="status-xml-line3"/>
  <xsl:template match="text()" mode="pos"/>
  <xsl:template match="text()" mode="timepos"/>

  <xsl:template match="cx:op[@type = 'NEWLINE']/cx:*" mode="status-xml-line1">
    <s:title><xsl:value-of select="normalize-space(.)"/></s:title>
    <xsl:text>&#xa;</xsl:text>
  </xsl:template>
  <xsl:template match="cx:op[@type = 'NEWLINE']/cx:*" mode="status-xml-line2">
    <xsl:apply-templates mode="status-xml-line2"/>
  </xsl:template>
  <xsl:template match="cx:op[@type = 'NEWLINE']/cx:*" mode="status-xml-line3">
    <xsl:apply-templates mode="status-xml-line3"/>
  </xsl:template>

  <xsl:template match="cx:op[@type = 'NEWLINE']/cx:*[1]" mode="status-xml">
    <xsl:apply-templates select="." mode="status-xml-line1"/>
  </xsl:template>

  <xsl:template match="cx:op[@type = 'NEWLINE']/cx:op[@type = 'NEWLINE']/cx:*[1]" mode="status-xml">
    <xsl:apply-templates select="." mode="status-xml-line2"/>
  </xsl:template>

  <xsl:template match="cx:op[@type = 'NEWLINE']/cx:op[@type = 'NEWLINE']/cx:*[2]" mode="status-xml">
    <s:flags>
      <xsl:apply-templates select="." mode="status-xml-line3"/>
    </s:flags>
  </xsl:template>

  <xsl:template match="cx:op[@type = 'MOD']" mode="status-xml-line2">
    <s:percentage index="{cx:*[1]}"/>
    <xsl:text>&#xa;</xsl:text>
  </xsl:template>

  <xsl:template match="cx:op[@type = 'DIV']" mode="status-xml-line2">
    <s:tpos>
      <s:index>
        <xsl:apply-templates select="cx:*[1]" mode="status-xml-line2"/>
      </s:index>/<s:max>
        <xsl:apply-templates select="cx:*[2]" mode="status-xml-line2"/>
      </s:max>
    </s:tpos>
    <xsl:text>&#xa;</xsl:text>
  </xsl:template>

  <xsl:template match="cx:op[@type = 'COLON']" mode="status-xml-line2">
    <s:time>
      <s:min><xsl:value-of select="cx:*[1]"/></s:min>:<s:sec><xsl:value-of select="cx:*[2]/ca:text"/></s:sec>
    </s:time>
  </xsl:template>

  <xsl:template match="cx:op[@type = 'HASH']" mode="status-xml-line2">
    <s:lpos>
      <s:index><xsl:value-of select="cx:*/cx:*[1]"/></s:index>/<s:max><xsl:value-of select="normalize-space(cx:*/cx:*[2])"/></s:max>
    </s:lpos>
    <xsl:text>&#xa;</xsl:text>
  </xsl:template>

  <xsl:template match="cx:op[@type = 'COLON']" mode="status-xml-line3">
    <xsl:element name="{cx:*[1]}" namespace="{$statusns}">
      <xsl:value-of select="cx:*[2]/ca:text"/>
    </xsl:element>
  </xsl:template>


  <xsl:template match="s:status">
    <div id="wmpc-status">
      <xsl:apply-templates select="s:title"/>
      <table class="wmpc-display">
        <tr>
          <td>
            <xsl:apply-templates select="s:lpos"/>
          </td>
          <td>
            <xsl:apply-templates select="s:tpos"/>
          </td>
          <td>
            <xsl:apply-templates select="s:flags"/>
          </td>
        </tr>
        <tr>
          <th>Position</th>
          <th>Time</th>
          <th>Flags</th>
        </tr>
      </table>
      <xsl:apply-templates select="s:percentage"/>
    </div>
  </xsl:template>

  <xsl:template match="s:*">
    <span class="wmpc-status-{local-name()}">
      <xsl:apply-templates/>
    </span>
  </xsl:template>


  <xsl:template match="s:flags">
    <span class="wmpc-status-{local-name()}">
      <xsl:for-each select="s:*">
        <xsl:apply-templates select="."/>
        <xsl:text> </xsl:text>
      </xsl:for-each>
    </span>
  </xsl:template>

  <xsl:template match="s:volume|s:random|s:single|s:consume|s:repeat">
    <span onclick="wmpc.{local-name()}()" class="wmpc-status-{local-name()}">
      <span class="wmpc-status-flag"><xsl:value-of select="local-name()"/></span>
      <xsl:text>: </xsl:text>
      <xsl:apply-templates/>
    </span>
  </xsl:template>

  <xsl:template match="s:percentage">
    <span class="wmpc-status-{local-name()}" onclick="wmpc.seek_click(this, event)">
      <span class="wmpc-status-{local-name()}-passed" style="width: {@index}%"> </span>
    </span>
  </xsl:template>


  <xsl:template match="p2xplaylist">
    <p:list>
      <xsl:apply-templates mode="playlist-xml"/>
    </p:list>
  </xsl:template>

  <xsl:template match="text()" mode="playlist-xml"/>

  <xsl:template match="cx:op[@type = 'NEWLINE']/cx:*[1]" mode="playlist-xml">
    <p:item><xsl:value-of select="normalize-space(.)"/></p:item>
    <xsl:text>&#xa;</xsl:text>
  </xsl:template>


  <xsl:template match="p:list">
    <ol>
      <xsl:apply-templates select="p:item"/>
    </ol>
  </xsl:template>

  <xsl:template match="p:item">
    <li>
      <span onclick="wmpc.evh(this, event, wmpc.play, {position()});">
        <xsl:apply-templates/>
      </span>
    </li>
  </xsl:template>


</xsl:stylesheet>
