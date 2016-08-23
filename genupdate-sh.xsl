<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:param name="format" select="''"/>
  <xsl:param name="mpc" select="'mpc'"/>

  <xsl:variable name="format-flag">
    <xsl:if test="$format">-f "<xsl:value-of select="$format"/>"</xsl:if>
  </xsl:variable>

  <xsl:output method="text"/>
  <xsl:template match="text()"/>
  
  <xsl:template match="/">
    <xsl:if test="//playlist">
      mpc rm tmp-update-pls
      mpc save tmp-update-pls
    </xsl:if>
    <xsl:apply-templates/>
    <xsl:if test="//playlist">
      mpc clear
      mpc load tmp-update-pls
    </xsl:if>
    <xsl:text>&#xa;</xsl:text>
  </xsl:template>

  <xsl:template match="smart-playlists">
    <xsl:for-each select="*">
      <xsl:apply-templates select="."/>
      <xsl:text>&#xa;</xsl:text>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="playlist">
    mpc clear
    <xsl:apply-templates/> | mpc add
    mpc rm <xsl:value-of select="@name"/>
    mpc save <xsl:value-of select="@name"/>
    <xsl:text>&#xa;</xsl:text>
  </xsl:template>

  <xsl:template match="filter|filter-out">
    <xsl:apply-templates select="*[1]"/>
    <xsl:for-each select="*[position()>1]">
      <xsl:text> | grep -i -v "</xsl:text>
      <xsl:value-of select="."/>
      <xsl:text>"</xsl:text>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="filter-in">
    <xsl:apply-templates select="*[1]"/>
    <xsl:for-each select="*[position()>1]">
      <xsl:text> | grep -i "</xsl:text>
      <xsl:value-of select="."/>
      <xsl:text>"</xsl:text>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="or[count(*)=1]">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="/" mode="indent-"/>
  <xsl:template match="/*" mode="indent-"/>
  <xsl:template match="/*/*" mode="indent-"/>

  <xsl:template match="*" name="indent-" mode="indent-">
    <xsl:text> </xsl:text>
    <xsl:apply-templates select=".." mode="indent-"/>
  </xsl:template>

  <xsl:template match="*" name="indent" mode="indent">
    <xsl:apply-templates select=".." mode="indent-"/>
  </xsl:template>

  <xsl:template match="or">
    <xsl:call-template name="indent"/>
    <xsl:text>(</xsl:text>
    <xsl:text>&#xa;</xsl:text>
    <xsl:for-each select="*">
      <xsl:apply-templates select="."/>
      <xsl:text>&#xa;</xsl:text>
    </xsl:for-each>
    <xsl:call-template name="indent"/>
    <xsl:text>)</xsl:text>
  </xsl:template>

  <xsl:template match="and">
    <xsl:call-template name="indent"/>
    <xsl:text>mpc </xsl:text>
    <xsl:value-of select="$format-flag"/> search <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="query">
    <xsl:text> </xsl:text>
    <xsl:value-of select="@type"/>
    <xsl:text> </xsl:text>
    <xsl:value-of select="."/>
  </xsl:template>

  <xsl:template match="paren">
    <xsl:message>warning: paren encountered</xsl:message>
  </xsl:template>

</xsl:stylesheet>

