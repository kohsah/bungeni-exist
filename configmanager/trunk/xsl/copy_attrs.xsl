<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
    <xsl:template name="copy-attrs">
        <!-- exclude empty attributes -->
        <xsl:copy-of select="@*[. ne '']"/>
        <xsl:copy-of select="@title"/>
    </xsl:template>
</xsl:stylesheet>