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
    <xsl:apply-templates/>
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


  <xsl:template match="*" mode="in-and">
    <xsl:apply-templates select="."/>
  </xsl:template>

  <xsl:template match="and" mode="in-and">
    <xsl:apply-templates mode="in-and"/>
  </xsl:template>

  <xsl:template match="paren" mode="in-and">
    <xsl:apply-templates/>
  </xsl:template>



  <xsl:template match="*" mode="in-or">
    <xsl:apply-templates select="."/>
  </xsl:template>

  <xsl:template match="or" mode="in-or">
    <xsl:apply-templates mode="in-or"/>
  </xsl:template>

  <xsl:template match="paren" mode="in-or">
    <xsl:apply-templates/>
  </xsl:template>


  <xsl:template match="and[or]">
    <xsl:variable name="this" select="."/>
    <xsl:variable name="mypos" select="count(or[1]/preceding-sibling::*)+1"/>
    <or>
      <xsl:for-each select="or[1]/*">
        <and>
          <xsl:copy-of select="$this/@*"/>
          <xsl:apply-templates select="$this/*[position() &lt; $mypos]" mode="in-and"/>
          <xsl:apply-templates select="." mode="in-and"/>
          <xsl:apply-templates select="$this/*[position() &gt; $mypos]" mode="in-and"/>
        </and>
      </xsl:for-each>
    </or>
  </xsl:template>

</xsl:stylesheet>

