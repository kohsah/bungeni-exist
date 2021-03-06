<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:an="http://www.akomantoso.org/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:i18n="http://exist-db.org/xquery/i18n" xmlns:bu="http://portal.bungeni.org/1.0/" exclude-result-prefixes="xs" version="2.0">
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" scope="stylesheet">
        <xd:desc>
            <xd:p>
                <xd:b>Created on:</xd:b> May 18, 2012</xd:p>
            <xd:p>
                <xd:b>Author:</xd:b> anthony</xd:p>
            <xd:p> Popout for Event Document from Bungeni</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:output method="xml"/>
    <xsl:include href="context_tabs.xsl"/>
    <xsl:template match="doc">
        <xsl:variable name="chamber" select="bu:ontology/bu:chamber/bu:type/bu:value"/>
        <xsl:variable name="event-uri" select="event"/>
        <xsl:variable name="doc-type" select="bu:ontology/bu:document/bu:docType/bu:value"/>
        <xsl:variable name="eventof">
            <xsl:choose>
                <xsl:when test="bu:ontology/bu:event/bu:eventOf/bu:head/bu:type/bu:value">
                    <xsl:value-of select="bu:ontology/bu:event/bu:eventOf/bu:head/bu:type/bu:value"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="bu:ontology/bu:eventResponse/bu:eventOf/bu:head/bu:type/bu:value"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="doc-uri">
            <xsl:choose>
                <xsl:when test="bu:ontology/bu:document/@uri">
                    <xsl:value-of select="bu:ontology/bu:document/@uri"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="bu:ontology/bu:document/@internal-uri"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="moevent-uri" select="bu:ontology/bu:document/bu:owner/bu:person/@href"/>
        <div id="popout-wrapper">
            <div id="popout-content" role="main">
                <div id="doc-main-section">
                    <h1 class="title">
                        <b>
                            <i18n:text key="acronym">acronym(nt)</i18n:text>:&#160;</b>
                        <xsl:value-of select="bu:ontology/bu:document/bu:acronym/bu:value"/>
                    </h1>
                    <div class="doc-status">
                        <span>
                            <b>
                                <i18n:text key="last-event">Last Event(nt)</i18n:text>:</b>
                        </span>
                        &#160;
                        <span>
                            <xsl:value-of select="bu:ontology/bu:document/bu:status/bu:value"/>
                        </span>
                        &#160;
                        <span>
                            <b>
                                <i18n:text key="status">Status(nt)</i18n:text>&#160;<i18n:text key="date-on">Date(nt)</i18n:text>:</b>
                        </span>
                        &#160;
                        <span>
                            <xsl:value-of select="format-dateTime(bu:ontology/bu:document/bu:statusDate,$datetime-format,'en',(),())"/>
                        </span>
                    </div>
                    <div id="doc-content-area">
                        <xsl:choose>
                            <xsl:when test="bu:ontology/bu:document/bu:summary">
                                <h2>summary</h2>
                                <xsl:copy-of select="bu:ontology/bu:document/bu:summary/child::node()"/>
                            </xsl:when>
                            <xsl:when test="bu:ontology/bu:document/bu:description">
                                <h2>description</h2>
                                <xsl:copy-of select="bu:ontology/bu:document/bu:description/child::node()"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <i18n:text key="no summary">no summary(nt)</i18n:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </div>
                    <div class="full-width txt-right">
                        <a class="link-external" href="{lower-case($eventof)}-{lower-case($doc-type)}?uri={$doc-uri}">
                            <i18n:text key="from-popout">view as document(nt)</i18n:text>
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </xsl:template>
</xsl:stylesheet>