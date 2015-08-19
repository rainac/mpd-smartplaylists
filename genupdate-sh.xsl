<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

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

  <xsl:template match="playlist">
    mpc clear
    <xsl:apply-templates/> | mpc add
    mpc rm <xsl:value-of select="@name"/>
    mpc save <xsl:value-of select="@name"/>
    <xsl:text>&#xa;</xsl:text>
  </xsl:template>

  <xsl:template match="or">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="and">
    mpc search <xsl:apply-templates/>
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

