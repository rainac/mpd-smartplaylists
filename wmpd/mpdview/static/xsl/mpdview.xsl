<?xml version="1.0"?>
<!--
Copyright © 2014 Johannes Willkomm
-->
<xsl:stylesheet version="1.0"
    xmlns:cx='http://johannes-willkomm.de/xml/code-xml/'
    xmlns:ca='http://johannes-willkomm.de/xml/code-xml/attributes/'
    xmlns:worg='http://johannes-willkomm.de/xml/web/'
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="http://www.w3.org/1999/xhtml"
    >

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
    <div id="wmpc-div-status-txt">
    </div>
    <div id="wmpc-div-status">
    </div>
  </xsl:template>

  <xsl:template match="log">
    <div id="wmpc-div-log">
    </div>
  </xsl:template>

</xsl:stylesheet>
