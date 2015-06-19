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

  <xsl:template match="cx:colon">
    <playlist name="{cx:*[1]}">
      <xsl:apply-templates select="cx:*[2]" mode="in-playlist"/>
    </playlist>
  </xsl:template>

  <xsl:template match="cx:or" mode="in-playlist">
    <xsl:apply-templates select="."/>
  </xsl:template>
  <xsl:template match="cx:*" mode="in-playlist">
    <or>
      <xsl:apply-templates select="." mode="in-or"/>
    </or>
  </xsl:template>
  
  <xsl:template match="cx:and">
    <or>
      <and>
        <xsl:apply-templates/>
      </and>
    </or>
  </xsl:template>

  <xsl:template match="cx:and">
    <and>
      <xsl:apply-templates mode="in-and"/>
    </and>
  </xsl:template>

  <xsl:template match="cx:and" mode="in-or">
    <xsl:apply-templates select="."/>
  </xsl:template>
  <xsl:template match="cx:*" mode="in-or">
    <and>
      <xsl:apply-templates select="." mode="in-and"/>
    </and>
  </xsl:template>

  <xsl:template match="cx:or">
    <or>
      <xsl:apply-templates mode="in-or"/>
    </or>
  </xsl:template>

  <xsl:template match="cx:*" mode="in-and">
    <query type="artist">
      <xsl:apply-templates select="."/>
    </query>
  </xsl:template>
  <xsl:template match="cx:eq" mode="in-and">
    <xsl:apply-templates select="."/>
  </xsl:template>
  
  <xsl:template match="cx:eq">
    <query type="{cx:*[1]}">
      <xsl:apply-templates select="cx:*[2]"/>
    </query>
  </xsl:template>

</xsl:stylesheet>

