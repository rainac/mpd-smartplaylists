<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:ca='http://johannes-willkomm.de/xml/code-xml/attributes/'
                >

  <xsl:output method="text"/>

  <xsl:template match="/">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="paren">
    <xsl:message terminate="yes">paren!</xsl:message>
  </xsl:template>

</xsl:stylesheet>

