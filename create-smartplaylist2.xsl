<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:output method="xml"/>

  <xsl:template match="/">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="smart-playlists">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates mode="in-root"/>
    </xsl:copy>
  </xsl:template>


  <xsl:template match="*" mode="in-root">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates mode="in-root"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="filter|filter-in|filter-out" mode="in-root">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates select="*[1]" mode="in-root"/>
      <xsl:apply-templates select="*[position()>1]"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="or" mode="in-root">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates mode="in-and"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="and" mode="in-root">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates mode="in-query"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="id|query" mode="in-root">
    <xsl:apply-templates select="." mode="in-and"/>
  </xsl:template>


  <xsl:template match="id|query" mode="in-and">
    <and>
      <xsl:apply-templates select="." mode="in-query"/>
    </and>
  </xsl:template>

  <xsl:template match="and" mode="in-and">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates select="." mode="in-query"/>
    </xsl:copy>
  </xsl:template>


  <xsl:template match="query" mode="in-query">
    <xsl:apply-templates select="."/>
  </xsl:template>

  <xsl:template match="id" mode="in-query">
    <query type="artist">
      <xsl:apply-templates/>
    </query>
  </xsl:template>


  <xsl:template match="paren" mode="in-root">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates mode="in-root"/>
    </xsl:copy>
  </xsl:template>
  <xsl:template match="paren" mode="in-or">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates mode="in-root"/>
    </xsl:copy>
  </xsl:template>
  <xsl:template match="paren" mode="in-and">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates mode="in-root"/>
    </xsl:copy>
  </xsl:template>
  <xsl:template match="paren" mode="in-query">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates mode="in-root"/>
    </xsl:copy>
  </xsl:template>


  <xsl:template match="*">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>

