xquery version "3.0";

import module namespace request="http://exist-db.org/xquery/request";
import module namespace session="http://exist-db.org/xquery/session";
import module namespace util="http://exist-db.org/xquery/util";
import module namespace transform = "http://exist-db.org/xquery/transform";

import module namespace appconfig = "http://exist-db.org/apps/configmanager/config" at "../modules/appconfig.xqm";

declare option exist:serialize "method=xhtml media-type=text/xml";

(: creates the output for all document features :)
declare function local:features($doctype) as node() * {
    let $form-id := request:get-parameter("doc", "workflow.xml")
    
    let $count := count(local:get-workflow($form-id)/feature)
    for $feature at $pos in local:get-workflow($form-id)/feature
        return
            <tr>
                <td><a href="javascript:dojo.publish('/view',['feature','{$doctype}','none','{data($feature/@name)}']);">{data($feature/@name)}</a></td>
                <td>{data($feature/@enabled)}</td>
                <td><a href="javascript:dojo.publish('/feature/delete',['{$doctype}','{data($feature/@name)}']);">delete</a></td>
            </tr>
};

declare function local:get-workflow($DOCNAME as xs:string) as node() * {
    doc($appconfig:WF-FOLDER || '/' || $DOCNAME)
};

let $CXT := request:get-context-path()
let $DOCNAME := xs:string(request:get-parameter("doc","none"))
let $REST-CXT-MODELTMPL := $CXT || "/rest" || $appconfig:ROOT || "/model_templates"
let $REST-CXT-CONFIGWF := $CXT || "/rest" || $appconfig:WF-FOLDER
let $NODENAME := xs:string(request:get-parameter("node","nothing"))
let $ATTR := xs:string(request:get-parameter("attr","nothing"))
let $SHOWING := xs:string(request:get-parameter("tab","fields"))
return
<html   xmlns="http://www.w3.org/1999/xhtml"
        xmlns:xf="http://www.w3.org/2002/xforms"
        xmlns:exist="http://exist.sourceforge.net/NS/exist"
        xmlns:ev="http://www.w3.org/2001/xml-events" 
        xmlns:zope="http://namespaces.zope.org/zope"
        xmlns:db="http://namespaces.objectrealms.net/rdb">
   <head>
      <title>Edit Database</title>
    </head>
    <body class="nihilo InlineBordersAlert">
    	<div id="xforms">
            <div style="display:none">
                 <xf:model>
                    <xf:instance id="i-workflowui" src="{$REST-CXT-CONFIGWF}/{$DOCNAME}"/>                   

                    <xf:bind nodeset="./feature">
                        <xf:bind nodeset="@name" type="xf:string" required="true()" constraint="string-length(.) &gt; 3" />
                        <xf:bind nodeset="@enabled" type="xf:boolean" required="true()" />
                    </xf:bind>

                    <xf:instance id="i-controller" src="{$REST-CXT-MODELTMPL}/controller.xml"/>

                    <xf:instance id="tmp">
                        <data xmlns="">
                            <wantsToClose>false</wantsToClose>
                        </data>
                    </xf:instance>

                    <xf:submission id="s-add"
                                   method="put"
                                   replace="none"
                                   ref="instance()">
                        <xf:resource value="'{$REST-CXT-CONFIGWF}/{$DOCNAME}'"/>
    
                        <xf:header>
                            <xf:name>username</xf:name>
                            <xf:value>admin</xf:value>
                        </xf:header>
                        <xf:header>
                            <xf:name>password</xf:name>
                            <xf:value></xf:value>
                        </xf:header>
                        <xf:header>
                            <xf:name>realm</xf:name>
                            <xf:value>exist</xf:value>
                        </xf:header>
    
                        <xf:action ev:event="xforms-submit-done">
                            <xf:message level="ephemeral">Workflow changes updated successfully</xf:message>
                            <script type="text/javascript" if="instance('tmp')/wantsToClose">
                                dijit.byId("formsDialog").hide();
                                dojo.publish('/workflow/view',['{$DOCNAME}','workflow','featuresDiv']);  
                            </script>
                        </xf:action>
    
                        <xf:action ev:event="xforms-submit-error" if="instance('i-controller')/error/@hasError='true'">
                            <xf:setvalue ref="instance('i-controller')/error/@hasError" value="'true'"/>
                            <xf:setvalue ref="instance('i-controller')/error" value="event('response-reason-phrase')"/>
                        </xf:action>
    
                        <xf:action ev:event="xforms-submit-error" if="instance('i-controller')/error/@hasError='false'">
                            <xf:message>The workflow information have not been filled in correctly</xf:message>
                        </xf:action>
                    </xf:submission>

                    <xf:action ev:event="xforms-ready" >
                        <script type="text/javascript" if="'{$SHOWING}' != 'none'">
                            dijit.byId("switchDiv").selectChild("{$SHOWING}");                        
                        </script>   
                    </xf:action>
            </xf:model>
            
            </div>    	
            <div style="width: 100%; height: 100%;">
                <h1>Types / {$DOCNAME} / workflow / feature</h1>
                <br/>
                <a href="javascript:dojo.publish('/workflow/view',['{$DOCNAME}','workflow','featuresDiv']);">
                    <img src="images/back_arrow.png" title="back to workflow features" alt="back to workflow features"/>
                </a>
                <div style="width: 100%;">
                    <br/>
                    <div style="width: 100%;">
                        <div style="width:80%;">
                            <div style="float:left;width:40%;">
                                <xf:group ref="./feature[{$ATTR}]" appearance="bf:verticalTable">   
                                    <xf:output ref="@name" incremental="true">
                                        <xf:label>name:</xf:label>
                                    </xf:output>                                
                                    <xf:input id="feat-name" ref="@name">
                                        <xf:label>Name</xf:label>
                                        <xf:hint>edit name of the workflow</xf:hint>
                                        <xf:alert>enter more than 3 characters</xf:alert>
                                    </xf:input>      
                                    <xf:input id="feat-title" ref="@enabled">
                                        <xf:label>Enabled</xf:label>
                                        <xf:hint>Check to enabled feature</xf:hint>
                                    </xf:input>
                                    <xf:trigger>
                                        <xf:label>Save</xf:label>
                                        <xf:action>
                                            <xf:setvalue ref="instance('tmp')/wantsToClose" value="'true'"/>
                                            <xf:send submission="s-add"/>
                                        </xf:action>                                
                                    </xf:trigger>                            
                                </xf:group>
                            </div>
                            <div style="float:right">
                                <table border="1">
                                    <thead>
                                        <tr>
                                            <th>facet name</th>
                                            <th>.View</th>
                                            <th>.Edit</th>
                                            <th>.Add</th>
                                            <th>.Delete</th>
                                            <th>Action</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <tr>
                                            <td>
                                                draft_Clerk
                                            </td>
                                            <td>
                                                <a href="#">add role</a>
                                            </td>
                                            <td>
                                                <a href="#">add role</a>
                                            </td>
                                            <td>
                                                <a href="#">add role</a>
                                            </td>
                                            <td>
                                                <a href="#">add role</a>
                                            </td>
                                            <td style="color:red;">
                                                <input type="button" value="delete facet"/>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                draft_Owner
                                            </td>
                                            <td>
                                                <a href="#">add role</a>
                                            </td>
                                            <td>
                                                <a href="#">add role</a>
                                            </td>
                                            <td>
                                                <a href="#">add role</a>
                                            </td>
                                            <td>
                                                <a href="#">add role</a>
                                            </td>
                                            <td style="color:red;">
                                                <input type="button" value="delete facet"/>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                internal
                                            </td>
                                            <td>
                                                <a href="#">add role</a>
                                            </td>
                                            <td>
                                                <a href="#">add role</a>
                                            </td>
                                            <td>
                                                <a href="#">add role</a>
                                            </td>
                                            <td>
                                                <a href="#">add role</a>
                                            </td>
                                            <td style="color:red;">
                                                <input type="button" value="delete facet"/>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                internal_Speaker
                                            </td>
                                            <td>
                                                <a href="#">add role</a>
                                            </td>
                                            <td>
                                                <a href="#">add role</a>
                                            </td>
                                            <td>
                                                <a href="#">add role</a>
                                            </td>
                                            <td>
                                                <a href="#">add role</a>
                                            </td>
                                            <td style="color:red;">
                                                <input type="button" value="delete facet"/>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td colspan="8">
                                                <input type="button" value="add facet" onclick="showEditForm();"/>
                                            </td>
                                        </tr>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>              
            </div>                    
        </div>
    </body>
</html>