<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:an="http://www.akomantoso.org/1.0" xmlns:i18n="http://exist-db.org/xquery/i18n" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:bu="http://portal.bungeni.org/1.0/" exclude-result-prefixes="xs" version="2.0">
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" scope="stylesheet">
        <xd:desc>
            <xd:p>
                <xd:b>Created on:</xd:b> Nov 9, 2011</xd:p>
            <xd:p>
                <xd:b>Author:</xd:b> anthony</xd:p>
            <xd:p> MP Personal Information from Bungeni</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:output method="xml"/>
    <xsl:include href="context_tabs.xsl"/>
    <xsl:template match="doc">
        <xsl:variable name="doc-type" select="bu:ontology/bu:membership/bu:docType/bu:value"/>
        <xsl:variable name="doc-uri" select="bu:ontology/bu:membership/bu:referenceToUser/@uri"/>
        <div id="main-wrapper">
            <div id="title-holder" class="theme-lev-1-only">
                <h1 id="doc-title-blue">
                    <xsl:value-of select="concat(bu:ontology/bu:membership/bu:firstName,' ', bu:ontology/bu:membership/bu:lastName)"/>
                </h1>
            </div>
            <xsl:call-template name="mem-tabs">
                <xsl:with-param name="tab-group">
                    <xsl:value-of select="$doc-type"/>
                </xsl:with-param>
                <xsl:with-param name="tab-path">activities</xsl:with-param>
                <xsl:with-param name="uri" select="$doc-uri"/>
                <xsl:with-param name="excludes" select="exclude/tab"/>
            </xsl:call-template>
            <div id="doc-downloads">
                <ul class="ls-downloads">
                    <li>
                        <a href="#" title="get as RSS feed" class="rss">
                            <em>RSS</em>
                        </a>
                    </li>
                    <li>
                        <a href="#" title="print this document" class="print">
                            <em>PRINT</em>
                        </a>
                    </li>
                    <li>
                        <a href="#" title="get as ODT document" class="odt">
                            <em>ODT</em>
                        </a>
                    </li>
                    <li>
                        <a href="#" title="get as RTF document" class="rtf">
                            <em>RTF</em>
                        </a>
                    </li>
                    <li>
                        <a href="#" title="get as PDF document" class="pdf">
                            <em>PDF</em>
                        </a>
                    </li>
                </ul>
            </div>
            <div id="region-content" class="rounded-eigh tab_container" role="main">
                <div id="doc-main-section">
                    <div class="mem-table-wrapper">
                        <xsl:choose>
                            <xsl:when test="ref/bu:ontology">
                                <table class="tbl-tgl">
                                    <tr>
                                        <td class="fbtd">
                                            <i18n:text key="tab-type">type(nt)</i18n:text>
                                        </td>
                                        <td class="fbtd">
                                            <i18n:text key="relation">relation(nt)</i18n:text>
                                        </td>
                                        <td class="fbtd">
                                            <i18n:text key="title">title(nt)</i18n:text>
                                        </td>
                                        <td class="fbtd">
                                            <i18n:text key="status">status(nt)</i18n:text>
                                        </td>
                                        <td class="fbtd">
                                            <i18n:text key="submit-date">submission date(nt)</i18n:text>
                                        </td>
                                    </tr>
                                    <xsl:for-each select="ref/bu:ontology">
                                        <xsl:sort select="bu:document/bu:statusDate" order="descending"/>
                                        <tr class="items">
                                            <td class="fbt bclr">
                                                <xsl:value-of select="bu:document/bu:docType/bu:value"/>
                                            </td>
                                            <td class="fbt bclr">
                                                <xsl:choose>
                                                    <xsl:when test="$doc-uri = data(bu:document/bu:owner/bu:person/@href)">
                                                        owner
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        sponsor
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                            </td>
                                            <td class="fbt bclr">
                                                <xsl:variable name="eventOf" select="bu:document/bu:eventOf/bu:type/bu:value"/>
                                                <xsl:variable name="doc-uri">
                                                    <xsl:choose>
                                                        <xsl:when test="bu:document/@uri">
                                                            <xsl:value-of select="bu:document/@uri"/>
                                                        </xsl:when>
                                                        <xsl:otherwise>
                                                            <xsl:value-of select="bu:document/@internal-uri"/>
                                                        </xsl:otherwise>
                                                    </xsl:choose>
                                                </xsl:variable>
                                                <xsl:variable name="doc-type" select="bu:document/bu:docType/bu:value"/>
                                                <xsl:choose>
                                                    <xsl:when test="$doc-type = 'Event'">
                                                        <xsl:variable name="event-href" select="bu:document/@uri"/>
                                                        <a href="{lower-case($eventOf)}/event?uri={$event-href}">
                                                            <xsl:value-of select="bu:document/bu:shortTitle"/>
                                                        </a>
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        <a href="{lower-case($doc-type)}/text?uri={$doc-uri}">
                                                            <xsl:value-of select="bu:document/bu:shortTitle"/>
                                                        </a>
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                            </td>
                                            <td class="fbt bclr">
                                                <xsl:value-of select="bu:document/bu:status/bu:value"/>
                                            </td>
                                            <td class="fbt bclr">
                                                <xsl:value-of select="format-dateTime(bu:document/bu:statusDate,$datetime-format,'en',(),())"/>
                                            </td>
                                        </tr>
                                    </xsl:for-each>
                                </table>
                            </xsl:when>
                            <xsl:otherwise>
                                <i18n:text key="none">none(nt)</i18n:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </div>
                </div>
            </div>
        </div>
    </xsl:template>
</xsl:stylesheet>