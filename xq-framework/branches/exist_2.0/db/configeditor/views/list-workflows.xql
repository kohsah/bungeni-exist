xquery version "1.0";

import module namespace request="http://exist-db.org/xquery/request";
import module namespace session="http://exist-db.org/xquery/session";
import module namespace util="http://exist-db.org/xquery/util";
import module namespace transform = "http://exist-db.org/xquery/transform";

declare option exist:serialize "method=xhtml media-type=text/xml";

(: creates the output for all tasks matching the query :)
declare function local:main() as node() * {
    for $workflow in local:getMatchingTasks()
        return
            <tr>
                <td class="selectorCol"><input type="checkbox" dojotype="dijit.form.CheckBox" value="{data($workflow/@document-name)}" /></td>
                <td>{data($workflow/@title)}</td>
                <td>{data($workflow/@description)}</td>
                <td>{count($workflow/tags/tag)}</td>
                <td><div class="col-count">{count($workflow/state)}</div>(<a href="javascript:dojo.publish('/wf_states/edit',['{data($workflow/@document-name)}']);">edit</a>)</td>
                <td><div class="col-count">{count($workflow/transition)}</div>(<a href="javascript:dojo.publish('/wf_transitions/edit',['{data($workflow/@document-name)}']);">edit</a>)</td>
                <td>{count($workflow/grant)}</td>
                <td><a href="javascript:dojo.publish('/wf/edit',['{data($workflow/@document-name)}']);">edit</a></td>
                <td><a href="javascript:dojo.publish('/wf/delete',['{data($workflow/@document-name)}']);">delete</a></td>
            </tr>
};

(: fetch all tasks matching the query params passed from the search submission :)
declare function local:getMatchingTasks() as node() * {
    let $from := request:get-parameter("from", "1970-01-01")
    let $to := request:get-parameter("to", "2020-01-01")
    let $project := request:get-parameter("project","")
    let $billable := request:get-parameter("billable","")
    let $billed := request:get-parameter("billed","")

    for $workflow in collection('/db/configeditor/configs/workflows')/workflow
        let $workflow-project := data($workflow/@title)
        let $xsl := doc('/db/configeditor/xsl/wf_split_attrs.xsl')
        order by $workflow-project ascending
        return transform:transform($workflow, $xsl, <parameters>
                                                        <param name="docname" value="{util:document-name($workflow)}" />
                                                    </parameters>)

};

(: convert all hours to minutes :)
declare function local:hours-in-minutes($workflows as node()*) as xs:integer
{
  let $sum := sum($workflows//duration/@hours)
  return  $sum * 60
};

let $contextPath := request:get-context-path()
return
<html   xmlns="http://www.w3.org/1999/xhtml"
        xmlns:ev="http://www.w3.org/2001/xml-events">
   <head>
      <title>All Tasks</title>
      <link rel="stylesheet" type="text/css"
                href="{$contextPath}/rest/db/configeditor/styles/configeditor.css"/>

    </head>
    <body>
        <div id="contextTitle">
            <span id="durationLabel">
                <span id="durationLabel-value" class="xfValue">Workflows</span>
            </span>
        </div>     
    	<div id="dataTable">
    	   <div id="checkBoxSelectors">
    	        Select: <a href="javascript:selectAll();">All</a> | <a href="javascript:selectNone();">None</a>
    	        <!--<button onclick="passValuesToXForms();" value="setSelected"/>-->
    	   </div>
		   <table id="listingTable">
			 <tr>
				<th></th>
				<th>Doctype</th>
				<th>Description</th>
				<th>Tags</th>
				<th>States</th>
				<th>Transitions</th>
				<th>Role Grants</th>
				<th colspan="2"> </th>
			 </tr>
			 {local:main()}
		 </table>
	 </div>
    </body>
</html>
