xquery version "3.0";

module namespace app="http://exist-db.org/apps/configmanager/templates";
declare namespace xhtml="http://www.w3.org/1999/xhtml" ;

import module namespace templates="http://exist-db.org/xquery/templates" at "templates.xql";
import module namespace appconfig = "http://exist-db.org/apps/configmanager/config" at "appconfig.xqm";
import module namespace config = "http://exist-db.org/xquery/apps/config" at "config.xqm";

(:~
 : This is a sample templating function. It will be called by the templating module if
 : it encounters an HTML element with a class attribute: class="app:test". The function
 : has to take exactly 3 parameters.
 : 
 : @param $node the HTML node with the class attribute which triggered this call
 : @param $model a map containing arbitrary data - used to pass information between template calls
 :)
declare function app:test($node as node(), $model as map(*)) {
    <p>Dummy template output generated by function app:test at {current-dateTime()}. The templating
        function was triggered by the class attribute <code>class="app:test"</code>.</p>
};

declare 
    %templates:wrap %templates:default("active", "search") 
function app:get-types-menu($node as node(), $model as map(*), $active as xs:string) {
     <xhtml:div dojoType="dijit.PopupMenuItem"> 
        <xhtml:span>
            Types            
        </xhtml:span>
        <xhtml:div dojoType="dijit.Menu" id="submenu">       
            <xhtml:div dojoType="dijit.MenuItem" onClick="alert('new!');">add new</xhtml:div>
            <xhtml:div dojoType="dijit.MenuSeparator"/>
            {
                for $docu in doc(concat($appconfig:CONFIGS-FOLDER,'/types.xml'))/types/*
                return    
                    <xhtml:div dojoType="dijit.PopupMenuItem">
                        <xhtml:span>{data($docu/@name)}</xhtml:span>
                        <xhtml:div dojoType="dijit.Menu" id="formsMenu{data($docu/@name)}">
                            <xhtml:div dojoType="dijit.MenuItem" onclick="javascript:dojo.publish('/form/view',['{data($docu/@name)}','details']);">form</xhtml:div>
                            <xhtml:div dojoType="dijit.MenuItem" onclick="javascript:dojo.publish('/workflow/view',['{data($docu/@name)}.xml','workflow','documentDiv']);">workflow</xhtml:div>
                            <xhtml:div dojoType="dijit.MenuItem">workspace</xhtml:div>
                        </xhtml:div>
                    </xhtml:div>
            }      
        </xhtml:div>
     </xhtml:div>      
};

(:

This is the main XFOrms declaration in index.html 

:)
declare function app:xforms-declare($node as node(), $model as map(*)) {
     let $contextPath := request:get-context-path()
     return      
        <div style="display:none;" 
            xmlns="http://www.w3.org/1999/xhtml"  
            xmlns:xf="http://www.w3.org/2002/xforms"
            xmlns:ev="http://www.w3.org/2001/xml-events" 
            >
             <xf:model id="modelone">
                    <xf:instance>
                        <data xmlns="">
                            <lastupdate>2000-01-01</lastupdate>
                            <user>admin</user>
                        </data>
                    </xf:instance>

                    <xf:instance id="i-vars">
                        <data xmlns="">
                            <default-duration>120</default-duration>
                            <currentTask/>
                            <currentView/>
                            <currentDoc/>
                            <currentNode/>
                            <currentField/>
                            <showTab/>
                            <selectedTasks/>
                        </data>
                    </xf:instance>
                    <xf:bind nodeset="instance('i-vars')/default-duration" type="xf:integer"/>

                    <xf:action ev:event="xforms-ready">
                        <xf:message level="ephemeral">Default: show about</xf:message>
                        <!--<xf:action ev:event="xforms-value-changed">
                            <xf:dispatch name="DOMActivate" targetid="overviewTrigger"/>
                        </xf:action>-->
                    </xf:action>
                </xf:model>
                <!--
                <xf:trigger id="overviewTrigger">
                    <xf:label>Overview</xf:label>
                    <xf:send submission="s-query-workflows"/>
                </xf:trigger>                  
                -->
                <xf:trigger id="viewForm">
                    <xf:label>new</xf:label>
                    <xf:action>
                        <xf:load show="embed" targetid="embedInline">
                            <xf:resource value="concat('{$contextPath}/rest/db/config_editor/views/get-form.xql#xforms?doc=',instance('i-vars')/currentDoc,'&amp;tab=',instance('i-vars')/showTab)"/>
                        </xf:load>
                    </xf:action>
                </xf:trigger>        
                
                <xf:trigger id="view">
                    <xf:label>new</xf:label>
                    <xf:action>
                        <xf:load show="embed" targetid="embedInline">
                            <xf:resource value="concat('{$contextPath}/rest/db/config_editor/views/get-',instance('i-vars')/currentView,'.xql#xforms?node=',instance('i-vars')/currentNode,'&amp;tab=',instance('i-vars')/showTab)"/>
                        </xf:load>
                    </xf:action>
                </xf:trigger>                  
                
                <xf:trigger id="addField">
                    <xf:label>new</xf:label>
                    <xf:action>
                        <xf:load show="embed" targetid="embedDialog">
                            <xf:resource value="concat('{$contextPath}/rest/db/config_editor/views/add-field.xql#xforms?doc=',instance('i-vars')/currentDoc,'&amp;field=',instance('i-vars')/currentField,'&amp;mode=new')"/>
                        </xf:load>
                    </xf:action>
                </xf:trigger>                

                <xf:trigger id="editField">
                    <xf:label>new</xf:label>
                    <xf:action>
                        <xf:load show="embed" targetid="embedDialog">
                            <xf:resource value="concat('{$contextPath}/rest/db/config_editor/views/get-field.xql#xforms?doc=',instance('i-vars')/currentDoc,'&amp;field=',instance('i-vars')/currentField)"/>
                        </xf:load>
                    </xf:action>
                </xf:trigger>
                
                <xf:trigger id="editRole">
                    <xf:label>new</xf:label>
                    <xf:action>
                        <xf:load show="embed" targetid="embedDialog">
                            <xf:resource value="concat('{$contextPath}/rest/db/config_editor/views/edit-role.xql#xforms?doc=',instance('i-vars')/currentDoc,'&amp;role=',instance('i-vars')/currentNode)"/>
                        </xf:load>
                    </xf:action>
                </xf:trigger>                
                
                <xf:trigger id="moveFieldUp">
                    <xf:label>new</xf:label>
                    <xf:action>
                        <xf:load show="embed" targetid="embedInline">
                            <xf:resource value="concat('{$contextPath}/rest/db/config_editor/edit/move-node.xql#xforms?doc=',instance('i-vars')/currentDoc,'&amp;move=up&amp;field=',instance('i-vars')/currentField)"/>
                        </xf:load>
                    </xf:action>
                </xf:trigger> 
                
                <xf:trigger id="moveFieldDown">
                    <xf:label>new</xf:label>
                    <xf:action>
                        <xf:load show="embed" targetid="embedInline">
                            <xf:resource value="concat('{$contextPath}/rest/db/config_editor/edit/move-node.xql#xforms?doc=',instance('i-vars')/currentDoc,'&amp;move=down&amp;field=',instance('i-vars')/currentField)"/>
                        </xf:load>
                    </xf:action>
                </xf:trigger>  
                
                <xf:trigger id="deleteField">
                    <xf:label>delete</xf:label>
                    <xf:action>
                        <xf:load show="embed" targetid="embedInline">
                            <xf:resource value="concat('{$contextPath}/rest/db/config_editor/edit/delete-node.xql#xforms?doc=',instance('i-vars')/currentDoc,'&amp;field=',instance('i-vars')/currentField)"/>
                        </xf:load>
                    </xf:action>
                </xf:trigger>   
                
                <xf:trigger id="deleteRole">
                    <xf:label>delete</xf:label>
                    <xf:action>
                        <xf:load show="embed" targetid="embedInline">
                            <xf:resource value="concat('{$contextPath}/rest/db/config_editor/edit/delete-role.xql#xforms?doc=',instance('i-vars')/currentDoc,'&amp;field=',instance('i-vars')/currentField)"/>
                        </xf:load>
                    </xf:action>
                </xf:trigger>                    

                <xf:trigger id="deleteTask">
                    <xf:label>delete</xf:label>
                    <xf:send submission="s-delete-workflow"/>
                </xf:trigger>

                <xf:input id="currentTask" ref="instance('i-vars')/currentTask">
                    <xf:label>This is just a dummy used by JS</xf:label>
                </xf:input>
                <xf:input id="currentView" ref="instance('i-vars')/currentView">
                    <xf:label>This is just a hidden used by JS</xf:label>
                </xf:input>                
                <xf:input id="currentDoc" ref="instance('i-vars')/currentDoc">
                    <xf:label>This is just an ephemeral used by JS</xf:label>
                </xf:input>
                <xf:input id="currentNode" ref="instance('i-vars')/currentNode">
                    <xf:label>This is just a dummy placeholder by JS</xf:label>
                </xf:input>
                <xf:input id="currentField" ref="instance('i-vars')/currentField">
                    <xf:label>This is just a random placeholder by JS</xf:label>
                </xf:input>
                <xf:input id="showTab" ref="instance('i-vars')/showTab">
                    <xf:label>This is just a renderlook placeholder by JS</xf:label>
                </xf:input>                 
            </div>
};

declare function app:inject-footer($node as node(), $model as map(*)) {
        <script type="text/javascript" defer="defer">
            <!--
            var xfReadySubscribers;

            function embed(targetTrigger,targetMount){
                console.debug("embed",targetTrigger,targetMount);
                if(targetMount == "embedDialog"){
                    dijit.byId("taskDialog").show();
                } else if(targetMount == "embedDialogDB") {
                    dijit.byId("dbDialog").show();
                } else if(targetMount == "embedDialogForms") {
                    dijit.byId("formsDialog").show();
                }
                var targetMount =  dojo.byId(targetMount);

                fluxProcessor.dispatchEvent(targetTrigger);

                if(xfReadySubscribers != undefined) {
                    dojo.unsubscribe(xfReadySubscribers);
                    xfReadySubscribers = null;
                }

                xfReadySubscribers = dojo.subscribe("/xf/ready", function(data) {
                    dojo.fadeIn({
                        node: targetMount,
                        duration:100
                    }).play();
                });
                dojo.fadeOut({
                    node: targetMount,
                    duration:100,
                    onBegin: function() {
                        fluxProcessor.dispatchEvent(targetTrigger);
                    }
                }).play();

            }
            
            var editSubscriber = dojo.subscribe("/form/view", function(doc,tab){
                fluxProcessor.setControlValue("currentDoc",doc);                
                fluxProcessor.setControlValue("showTab",tab);
                embed('viewForm','embedInline');
            }); 
            
            var editSubscriber = dojo.subscribe("/workflow/view", function(doc,node,tab){
                fluxProcessor.setControlValue("currentDoc",doc);       
                fluxProcessor.setControlValue("currentNode",node);  
                fluxProcessor.setControlValue("showTab",tab);
                embed('viewWorkflow','embedInline');
            });             
            
            var editSubscriber = dojo.subscribe("/view", function(view,doc,node,attr,tab){
                fluxProcessor.setControlValue("currentView",view);  // ~/views/get-{view}.xql  
                fluxProcessor.setControlValue("currentDoc",doc);    // document in the query                
                fluxProcessor.setControlValue("currentNode",node);  // parent node in the query
                fluxProcessor.setControlValue("currentAttr",attr);  // attribute selector for node in the query                
                fluxProcessor.setControlValue("showTab",tab);       // tab to switch to, if any, in the view
                embed('view','embedInline');
            });            
            
            var addSubscriber = dojo.subscribe("/field/add", function(form,field){
                fluxProcessor.setControlValue("currentDoc",form);
                fluxProcessor.setControlValue("currentField",field);
                embed('addField','embedDialog');
            });
            
            var editSubscriber = dojo.subscribe("/field/edit", function(form,field){
                fluxProcessor.setControlValue("currentDoc",form);
                fluxProcessor.setControlValue("currentField",field);
                embed('editField','embedDialog');
            });            
            
            var moveUpSubscriber = dojo.subscribe("/field/up", function(form,field){
                fluxProcessor.setControlValue("currentDoc",form);
                fluxProcessor.setControlValue("currentField",field);
                fluxProcessor.dispatchEvent('moveFieldUp');
            });
            
            var moveDownSubscriber = dojo.subscribe("/field/down", function(form,field){
                fluxProcessor.setControlValue("currentDoc",form);
                fluxProcessor.setControlValue("currentField",field);
                fluxProcessor.dispatchEvent('moveFieldDown');
            });   
            
            var deleteSubscriber = dojo.subscribe("/field/delete", function(form,field){
                var check = confirm("Really delete this field?");
                if (check == true){
                    fluxProcessor.setControlValue("currentDoc",form);
                    fluxProcessor.setControlValue("currentField",field);
                    fluxProcessor.dispatchEvent('deleteField');
                }            
            }); 
            
            var deleteSubscriber = dojo.subscribe("/role/delete", function(form,field){
                var check = confirm("Really delete this role?");
                if (check == true){
                    fluxProcessor.setControlValue("currentDoc",form);
                    fluxProcessor.setControlValue("currentField",field);
                    fluxProcessor.dispatchEvent('deleteRole');
                }            
            });            

            var editSubscriber = dojo.subscribe("/role/edit", function(form,node){
                fluxProcessor.setControlValue("currentDoc",form);
                fluxProcessor.setControlValue("currentNode",node);
                embed('editRole','embedDialog');
            }); 

            var refreshSubcriber = dojo.subscribe("/wf/refresh", function(){
                fluxProcessor.dispatchEvent("overviewTrigger");
            });           

            function passValuesToXForms(){
                var result="";
                dojo.query("input",dojo.byId("listingTable")).forEach(
                function (node){
                    if(dijit.byId(node.id).checked && node.value != undefined){
                        result = result + " " + node.value;
                    }
                });
                fluxProcessor.setControlValue("selectedTaskIds",result);
            }
            
            dojo.addOnLoad(function(){
                dojo.subscribe("/xf/ready", function() {
                    fluxProcessor.skipshutdown=true;
                });
            });            

            // -->
        </script>

};