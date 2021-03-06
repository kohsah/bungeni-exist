<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:an="http://www.akomantoso.org/1.0" xmlns:i18n="http://exist-db.org/xquery/i18n" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:bu="http://portal.bungeni.org/1.0/" exclude-result-prefixes="xs" version="2.0">
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" scope="stylesheet">
        <xd:desc>
            <xd:p>
                <xd:b>Created on:</xd:b> Oct 31, 2011</xd:p>
            <xd:p>
                <xd:b>Author:</xd:b> anthony</xd:p>
            <xd:p> Bill changes from Bungeni</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:output method="xml"/>
    <xsl:include href="context_tabs.xsl"/>
    <xsl:include href="context_downloads.xsl"/>
    <xsl:param name="serverport"/>
    <xsl:template match="doc">
        <xsl:variable name="doc-type" select="bu:ontology/bu:document/bu:docType/bu:value"/>
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
        <div id="main-wrapper">
            <div id="title-holder" class="theme-lev-1-only">
                <h1 id="doc-title-blue">
                    <xsl:value-of select="bu:ontology/bu:document/bu:shortTitle"/>
                </h1>
            </div>
            <xsl:call-template name="doc-tabs">
                <xsl:with-param name="tab-group">
                    <xsl:value-of select="$doc-type"/>
                </xsl:with-param>
                <xsl:with-param name="tab-path">timeline</xsl:with-param>
                <xsl:with-param name="uri" select="$doc-uri"/>
                <xsl:with-param name="excludes" select="exclude/tab"/>
            </xsl:call-template>
            <!-- Renders the document download types -->
            <xsl:call-template name="doc-formats">
                <xsl:with-param name="render-group">parl-doc</xsl:with-param>
                <xsl:with-param name="doc-type" select="$doc-type"/>
                <xsl:with-param name="uri" select="$doc-uri"/>
            </xsl:call-template>
            <div id="region-content" class="rounded-eigh tab_container" role="main">
                <div id="doc-main-section">
                    <div class="doc-table-wrapper">
                        <table class="listing timeline tbl-tgl">
                            <tr>
                                <th>
                                    <i18n:text key="tab-type">type(nt)</i18n:text>
                                </th>
                                <th>
                                    <i18n:text key="tab-desc">description(nt)</i18n:text>
                                </th>
                                <th>
                                    <i18n:text key="tab-date">date(nt)</i18n:text>
                                </th>
                                <!-- !+FIX_THIS not-implemented
                                <th>
                                    <i18n:text key="tab-user">user(nt)</i18n:text>
                                </th-->
                            </tr>
                            <xsl:for-each select="ref/timeline">
                                <xsl:sort select="bu:statusDate" order="descending"/>
                                <tr>
                                    <td>
                                        <span>
                                            <xsl:value-of select="bu:type/bu:value"/>
                                        </span>
                                    </td>
                                    <td>
                                        <span>
                                            <xsl:choose>
                                                <xsl:when test="bu:type/bu:value eq 'event'">
                                                    <a href="{lower-case($doc-type)}/event?uri={@href}">
                                                        <xsl:value-of select="(bu:shortTitle, bu:title)"/>
                                                    </a>
                                                </xsl:when>
                                                <xsl:when test="bu:type/bu:value eq 'annex'">
                                                    <xsl:value-of select="(bu:shortTitle, bu:title)"/>:
                                                    <i18n:text key="download">download(nt)</i18n:text>&#160;<a href="download?uri={$doc-uri}&amp;att={bu:attachmentId}">
                                                        <xsl:value-of select="bu:name"/>
                                                    </a>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:value-of select="(bu:shortTitle, bu:title)"/>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </span>
                                    </td>
                                    <td>
                                        <span>
                                            <xsl:value-of select="format-dateTime(bu:statusDate,'[D1o] [MNn,*-3], [Y] - [h]:[m]:[s] [P,2-2]','en',(),())"/>
                                        </span>
                                    </td>
                                    <!--td>
                                        <span>
                                            <xsl:value-of select="bu:auditId"/>
                                        </span>
                                    </td-->
                                </tr>
                            </xsl:for-each>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </xsl:template>
</xsl:stylesheet>