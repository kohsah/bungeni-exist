<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xqcfg="http://bungeni.org/xquery/config" xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:an="http://www.akomantoso.org/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:i18n="http://exist-db.org/xquery/i18n" xmlns:bu="http://portal.bungeni.org/1.0/" exclude-result-prefixes="xs" version="2.0">
    <!-- IMPORTS -->
    <xsl:import href="config.xsl"/>
    <xsl:import href="paginator.xsl"/>

    <!-- DOCUMENTATION -->
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" scope="stylesheet">
        <xd:desc>
            <xd:p>
                <xd:b>Created on:</xd:b> Oct 5, 2011</xd:p>
            <xd:p>
                <xd:b>Author:</xd:b> anthony</xd:p>
            <xd:p>
                
                Search legislative items from Bungeni

                    
            </xd:p>
        </xd:desc>
    </xd:doc>
    
    <!--
        
        THE INPUT DOCUMENT LOOKS LIKE THIS 
        
    <docs>
    <paginator>
        
        <count>3</count>
        <documentType>bill</documentType>
        <listingUrlPrefix>bill/text</listingUrlPrefix>
        <offset>3</offset>
        <limit>3</limit>
    </paginator>
    <alisting>
        <doc>
            <bu:ontology .../>
            <ref/>
         </doc>
    </alisting>
    </docs>
    -->
    <!-- INPUT PARAMETERS -->

    <!-- +SORT_ORDER(ah,nov-2011) pass the sort ordr into the XSLT-->
    <xsl:param name="sortby"/>

    <!-- CONVENIENCE VARIABLES -->
    <xsl:variable name="input-document-type" select="/docs/paginator/documentType"/>
    <xsl:variable name="listing-url-prefix" select="/docs/paginator/listingUrlPrefix"/>

    <!--
        MAIN RENDERING TEMPLATE
        -->
    <xsl:template match="docs">
        <div id="main-wrapper">
            <div id="title-holder" class="theme-lev-1-only">
                <h1 id="doc-title-blue-center">
                    <i18n:text key="search-results">search results(nt)</i18n:text>&#160;
                    <i18n:text key="for">for(nt)</i18n:text>&#160;
                    <!-- Capitalize the first letter -->
                    <xsl:value-of select="concat(upper-case(substring($input-document-type, 1, 1)), substring($input-document-type, 2))"/>s</h1>
            </div>
            <div id="tab-menu" class="ls-tabs">
                <ul class="ls-doc-tabs">
                    <li class="active">
                        <a href="#">
                            <i18n:text key="search-results">search results(nt)</i18n:text>
                            <xsl:text> (</xsl:text>
                            <xsl:value-of select="paginator/count"/>
                            <xsl:text>)</xsl:text>
                        </a>
                    </li>
                </ul>
            </div>
            <div id="doc-downloads">
                <ul class="ls-downloads">
                    <li>
                        <a href="{$input-document-type}s/rss" title="get as RSS feed" class="rss">
                            <em>RSS</em>
                        </a>
                    </li>
                    <li>
                        <a href="#" title="print this page listing" class="print">
                            <em>PRINT</em>
                        </a>
                    </li>
                </ul>
            </div>
            <div id="region-content" class="rounded-eigh tab_container" role="main">
                <!-- container for holding listings -->
                <div id="doc-listing" class="acts">
                    <div class="list-header">
                        <!-- call the paginator -->
                        <xsl:apply-templates select="paginator"/>
                        <div id="search-n-sort" class="search-bar struct-i">
                            <xsl:variable name="searchins" select="xqcfg:get_searchin($input-document-type)"/>
                            <xsl:variable name="orderbys" select="xqcfg:get_orderby($input-document-type)"/>
                            <xsl:if test="$searchins and $orderbys">
                                <div id="search-form"/>
                            </xsl:if>
                        </div>
                    </div>
                    <div id="toggle-wrapper" class="clear toggle-wrapper">
                        <div id="toggle-i18n" class="hide">
                            <span id="i-compress">
                                <i18n:text key="compress">- compress all(nt)</i18n:text>
                            </span>
                            <span id="i-expand">
                                <i18n:text key="expand">+ expand all(nt)</i18n:text>
                            </span>
                        </div>
                        <div class="toggler-list" id="expand-all">-&#160;<i18n:text key="compress">compress all(nt)</i18n:text>
                        </div>
                    </div>                    
                    <!-- 
                    !+LISTING_GENERATOR
                    render the actual listing
                    -->
                    <xsl:apply-templates select="alisting"/>
                </div>
            </div>
        </div>
    </xsl:template>


    <!-- 
    !+LISTING_GENERATOR
    Listing generator template 
    -->
    <xsl:template match="alisting">
        <ul id="list-toggle" class="ls-row clear">
            <xsl:apply-templates mode="renderui"/>
        </ul>
    </xsl:template>
    <xsl:template match="doc" mode="renderui">
        <xsl:variable name="docIdentifier" select="bu:ontology/bu:legislativeItem/@uri"/>
        <li>
            <a href="{$listing-url-prefix}?uri={$docIdentifier}" id="{$docIdentifier}">
                <xsl:value-of select="bu:ontology/bu:legislativeItem/bu:shortName"/>
            </a>
            <span>-</span>
            <div class="doc-toggle">
                <table class="doc-tbl-details">
                    <tr>
                        <td class="labels">id:</td>
                        <td>
                            <xsl:value-of select="bu:ontology/bu:legislativeItem/bu:registryNumber"/>
                        </td>
                    </tr>
                    <tr>
                        <td class="labels">primary sponsor:</td>
                        <td>
                            <a href="member?uri={bu:ontology/bu:legislativeItem/bu:owner/@href}" id="{bu:ontology/bu:legislativeItem/bu:owner/@href}">
                                <xsl:value-of select="bu:ontology/bu:legislativeItem/bu:owner/@showAs"/>
                            </a>
                        </td>
                    </tr>
                    <tr>
                        <td class="labels">last event:</td>
                        <td>
                            <xsl:value-of select="bu:ontology/bu:legislativeItem/bu:status"/>
                            &#160;&#160;<b>on:</b>&#160;&#160;
                            <xsl:value-of select="format-dateTime(bu:ontology/bu:legislativeItem/bu:statusDate,$datetime-format,'en',(),())"/>
                        </td>
                    </tr>
                    <tr>
                        <td class="labels">submission date:</td>
                        <td>
                            <xsl:value-of select="format-date(bu:ontology/bu:bungeni/bu:parliament/@date,$date-format,'en',(),())"/>
                        </td>
                    </tr>
                    <tr>
                        <td class="labels">ministry:</td>
                        <td>
                            <xsl:value-of select="ref/bu:ministry/bu:shortName"/>
                        </td>
                    </tr>
                </table>
            </div>
        </li>
    </xsl:template>
</xsl:stylesheet>