<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">
    <xsl:template match="@*|*|processing-instruction()|comment()">
        <xsl:copy>
            <xsl:apply-templates select="@*|*|text()|processing-instruction()|comment()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:variable name="allpermissions" select="data(/workflow/permActions/permAction)"/>
    
    <!-- injects blank templates for permissions which havent been set, 
        this allows the grid-ui to populate correctly based on the xml model -->
    <xsl:template name="missing-permission-template-injector">
        <xsl:param name="for-role"/>
        <!-- look for all permissions where the role is applied to the permission -->
        <xsl:variable name="facet-perms" select="data(./allow[roles/role[. eq $for-role]]/@permission)"/>
        <!-- take a difference product between all valid permissions and all applicable permissions -->
        <xsl:variable name="missing-perms" select="distinct-values($allpermissions[not(. = $facet-perms)])"/>
        <xsl:for-each select="$missing-perms">
            <allow permission="{.}">
                <roles originAttr="roles">
                    <role/>
                </roles>
            </allow>
        </xsl:for-each>
    </xsl:template>
    <xsl:template match="workflow">
        <xsl:element name="workflow">
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates select="permActions"/>
            <!-- process global permission facet -->
            <xsl:for-each-group select="facet[starts-with(@name, 'global_')]" group-by="@name">
                <xsl:variable name="facet-name" select="current-grouping-key()"/>
                <facet name="{$facet-name}">
                    <xsl:for-each select="current-group()">
                        <xsl:apply-templates/>
                    </xsl:for-each>
                    <!-- inject missing permissions -->
                    <xsl:call-template name="missing-permission-template-injector"/>
                </facet>
            </xsl:for-each-group>
            
            <!-- process all other facets -->
            <xsl:for-each select="facet[parent::workflow and not(starts-with(@name, 'global_'))]">
                
                <!-- we split each facet by role so a facet for a state becomes a facet per role 
                this allows easier grid editing of facet permissions -->
                <xsl:variable name="facet-name" select="@name"/>
                
                <!-- get all permissions except all -->
                <xsl:for-each-group select="." group-by="allow/roles/role[. ne 'ALL']">
                    <xsl:variable name="role-name" select="current-grouping-key()"/>
                    <facet name="{concat($facet-name, '_', $role-name)}" role="{$role-name}" original-name="{@name}">
                        <xsl:for-each select="current-group()">
                            <xsl:for-each select="allow[roles/role[. = $role-name]]">
                                <allow permission="{@permission}">
                                    <roles originAttr="roles">
                                        <role>
                                            <xsl:value-of select="$role-name"/>
                                        </role>
                                    </roles>
                                </allow>
                            </xsl:for-each>
                            <!-- inject missing permissions -->
                            <xsl:call-template name="missing-permission-template-injector">
                                <xsl:with-param name="for-role" select="$role-name"/>
                            </xsl:call-template>
                        </xsl:for-each>
                    </facet>
                </xsl:for-each-group>
            </xsl:for-each>
            <!-- we dont want to match permActions in the workflow element again -->
            <xsl:apply-templates select="                                  *[not(self::permActions[parent::workflow])] |                                   text() |                                   processing-instruction() |                                   comment()                 "/>
        </xsl:element>
    </xsl:template>
    
    <!-- suppress the global and state facets, it has been handled using the for_each above -->
    <xsl:template match="facet[parent::workflow and starts-with(@name, 'global_')]"/>
    <xsl:template match="facet[parent::workflow and not(starts-with(@name, 'global_'))]"/>
</xsl:stylesheet>