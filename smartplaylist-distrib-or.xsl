<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:ca='http://johannes-willkomm.de/xml/code-xml/attributes/'
                >

  <xsl:import href="copy.xsl"/>

  <xsl:output method="xml"/>

  <xsl:template match="/">
    <xsl:if test=".//and//filter">
      <xsl:message terminate="yes">A FILTER applied to just one operand of an AND is not allowed</xsl:message>
    </xsl:if>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="smart-playlists">
    <smart-playlists>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates/>
    </smart-playlists>
  </xsl:template>

  <xsl:template match="paren">
    <paren>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates/>
    </paren>
  </xsl:template>

  <xsl:template match="or">
    <or>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates mode="in-or"/>
    </or>
  </xsl:template>

  <xsl:template match="and">
    <and>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates mode="in-and"/>
    </and>
  </xsl:template>

  <xsl:template match="and" mode="in-or">
    <and>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates mode="in-and"/>
    </and>
  </xsl:template>

  <xsl:template match="and[paren/or]">
    <or>
      <xsl:apply-templates select="." mode="in-or"/>
    </or>
  </xsl:template>

  <xsl:template match="*" mode="in-or">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates mode="in-or"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="and[paren/or]" mode="in-or">
    <xsl:variable name="this" select="."/>
    <xsl:for-each select="(paren/or)[1]/*">
      <xsl:variable name="mypos" select="count(../../preceding-sibling::*)+1"/>
      <and mode="auto">
        <xsl:copy-of select="$this/@*"/>
        <xsl:copy-of select="@*"/>
        <xsl:apply-templates select="../../../*[position() &lt; $mypos]" mode="in-and"/>
        <xsl:apply-templates select="." mode="in-and"/>
        <xsl:apply-templates select="../../../*[position() &gt; $mypos]" mode="in-and"/>
      </and>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="and[paren/and]" mode="in-or">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="paren/paren" mode="in-or">
    <xsl:apply-templates mode="in-or"/>
  </xsl:template>

  <xsl:template match="and" mode="in-and">
    <xsl:apply-templates mode="in-and"/>
  </xsl:template>

  <xsl:template match="paren[paren]" mode="in-and">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="and/paren[and]" mode="in-and">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="paren" mode="in-or">
    <xsl:apply-templates mode="in-or"/>
  </xsl:template>

  <xsl:template match="paren" mode="in-and">
    <paren>
      <xsl:apply-templates/>
    </paren>
  </xsl:template>

  <xsl:template match="*" mode="in-and">
    <xsl:apply-templates select="."/>
  </xsl:template>

</xsl:stylesheet>

