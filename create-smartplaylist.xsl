<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:cx='http://johannes-willkomm.de/xml/code-xml/'
                xmlns:ca='http://johannes-willkomm.de/xml/code-xml/attributes/'
                >

  <xsl:output method="xml"/>
  
  <xsl:template match="/">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="cx:root">
    <smart-playlists version="1.0">
      <xsl:apply-templates/>
    </smart-playlists>
  </xsl:template>

  <xsl:template match="text()" mode="get-text"/>
  <xsl:template match="ca:t" mode="get-text">
    <xsl:value-of select="."/>
  </xsl:template>

  <xsl:template match="cx:colon">
    <playlist>
      <xsl:attribute name="name">
        <xsl:apply-templates select="cx:*[1]" mode="get-text"/>
      </xsl:attribute>
      <xsl:apply-templates select="cx:*[2]"/>
    </playlist>
  </xsl:template>

  <xsl:template match="cx:greater|cx:filter-out|cx:filter">
    <filter>      
      <xsl:apply-templates select="cx:*[1]"/>
      <xsl:apply-templates select="cx:*[position()>1]"/>
    </filter>
  </xsl:template>

  <xsl:template match="cx:less|cx:filter-in">
    <filter-in>      
      <xsl:apply-templates select="cx:*[1]"/>
      <xsl:apply-templates select="cx:*[position()>1]"/>
    </filter-in>
  </xsl:template>

  <xsl:template match="cx:or">
    <or>
      <xsl:apply-templates/>
    </or>
  </xsl:template>
  
  <xsl:template match="cx:and">
    <and>
      <xsl:apply-templates/>
    </and>
  </xsl:template>

  <xsl:template match="cx:equal">
    <query>
      <xsl:attribute name="type">
        <xsl:apply-templates select="cx:*[1]"/>
      </xsl:attribute>
      <xsl:apply-templates select="cx:*[2]"/>
    </query>
  </xsl:template>

  <xsl:template match="cx:l_paren">
    <paren>
      <xsl:apply-templates/>
    </paren>
  </xsl:template>

  <xsl:template match="cx:*">
    <xsl:apply-templates select="cx:*|ca:t"/>
  </xsl:template>

  <xsl:template match="cx:id">
    <id>
      <xsl:apply-templates select="cx:*|ca:t"/>
    </id>
  </xsl:template>

  <xsl:template match="ca:ignore"/>

</xsl:stylesheet>

