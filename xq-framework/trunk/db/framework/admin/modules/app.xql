xquery version "3.0";

module namespace app="http://exist-db.org/apps/frameworkadmin/templates";
declare namespace xhtml="http://www.w3.org/1999/xhtml" ;
declare namespace xf="http://www.w3.org/2002/xforms";
declare namespace ev="http://www.w3.org/2001/xml-events" ;
declare namespace bf="http://betterform.sourceforge.net/xforms" ;
declare namespace bu="http://portal.bungeni.org/1.0/";
declare namespace i18n="http://exist-db.org/xquery/i18n";

import module namespace templates="http://exist-db.org/xquery/templates" at "templates.xql";
import module namespace appconfig = "http://exist-db.org/apps/frameworkadmin/appconfig" at "appconfig.xqm";
import module namespace config = "http://exist-db.org/apps/frameworkadmin/config" at "config.xqm";
import module namespace functx = "http://www.functx.com" at "functx.xqm";

declare variable $app:CXT := request:get-context-path();
declare variable $app:REST-CXT-APP :=  $app:CXT || $appconfig:REST-APP-ROOT;
declare variable $app:REST-FW-ROOT :=  $app:CXT || $appconfig:REST-FRAMEWORK-ROOT;

declare variable $app:MENU := xs:string(request:get-parameter("menu","views"));
declare variable $app:VIEWS := xs:string(request:get-parameter("views",""));
declare variable $app:VIEWID := xs:string(request:get-parameter("viewid",""));
declare variable $app:CHAMBER-TYPE := xs:string(request:get-parameter("type","lower_house"));
declare variable $app:MAINNAV := xs:string(request:get-parameter("mainnav","business"));
declare variable $app:SUBMENU := xs:string(request:get-parameter("submenu",""));

(:~
 : This is a sample templating function. It will be called by the templating module if
 : it encounters an HTML element with a class attribute: class="app:test". The function
 : has to take exactly 3 parameters.
 : 
 : @param $node the HTML node with the class attribute which triggered this call
 : @param $model a map containing arbitrary data - used to pass information between template calls
 :)
declare function app:test($node as node(), $model as map(*)) {
    <p>Template output generated by function app:test at {current-dateTime()}.</p>
};

declare %templates:wrap function app:user($node as node(), $model as map(*)) {
    let $user := request:get-attribute("org.exist.login.user")
    return
        if ($user) then
            $user
        else
            "Not logged in"
};

declare function app:user-status($node as node(), $model as map(*)) as xs:boolean {
    let $user := request:get-attribute("org.exist.login.user")
    return
        if ($user) then
            true()
        else
            false()
};

(:~
 : This returns the legislature information / chambers in teh current parliament
 : 
 : @param $node the HTML node with the class attribute which triggered this call
 : @param $model a map containing arbitrary data - used to pass information between template calls
 :)
declare function app:get-legislature($node as node(), $model as map(*)) {
    <ul>
    {
        for $chamber in doc($appconfig:LEGISLATURE-FILE)/parliaments/parliament
        return
            <li><a href="chamber.html?menu=nav&amp;type={$chamber/type}" title="{$chamber/identifier}">{data($chamber/type/@displayAs)}</a></li>                
    }
    </ul>
};

declare 
    %templates:default("level", "0") 
function app:path-title($node as node(), $model as map(*), $level as xs:string?) {

    switch($app:MENU)
    case "views" return
        <xhtml:h1>
            <a href="viewgroups.html">Views</a>
            
            {   
                switch($level) 
                case "1" return 
                    (" / ", <a href="views.html?menu={$app:MENU}&amp;views={$app:VIEWS}">{$app:VIEWS}</a>)
                case "2" return 
                    (" / ", <a href="views.html?menu={$app:MENU}&amp;views={$app:VIEWS}">{$app:VIEWS}</a>,
                     " / ", <a href="view.html?menu={$app:MENU}&amp;views={$app:VIEWS}&amp;viewid={$app:VIEWID}">{$app:VIEWID}</a>)                
                default return     
                    ()
            }
        </xhtml:h1>    
    case "nav" return
        <xhtml:h1>
            <a href="chamber.html?type={$app:CHAMBER-TYPE}">{data(doc($appconfig:LEGISLATURE-FILE)/parliaments/parliament/type[. eq $app:CHAMBER-TYPE]/@displayAs)}</a>
            
            {   
                switch($level) 
                case "1" return 
                    (" / ", <a href="mainnav.html?menu={$app:MENU}&amp;type={$app:CHAMBER-TYPE}&amp;mainnav={$app:MAINNAV}">{$app:MAINNAV}</a>)
                case "2" return 
                    (" / ", <a href="mainnav.html?menu={$app:MENU}&amp;type={$app:CHAMBER-TYPE}&amp;mainnav={$app:MAINNAV}">{$app:MAINNAV}</a>,
                     " / ", <a href="{$app:SUBMENU}.html?menu={$app:MENU}&amp;type={$app:CHAMBER-TYPE}&amp;mainnav={$app:SUBMENU}">{$app:SUBMENU}</a>)                
                default return     
                    ()
            }
        </xhtml:h1>
    default return
        ()
};

declare function app:view-groups($node as node(), $model as map(*)) {

    <ul>
    {
        for $views in doc($appconfig:CONFIG-FILE)/ui/viewgroups/views
        return
            <li><a href="views.html?menu=views&amp;views={data($views/@name)}">{data($views/@name)}</a></li>                
    }
    </ul>    
};


declare
    %templates:default("tmpl", "") 
function app:menu-groups($node as node(), $model as map(*), $tmpl as xs:string) {

    <ul class="unstyled">
    {
        for $menu in doc($appconfig:CONFIG-FILE)/ui/menugroups/menu[@name eq $tmpl]/xhtml:ul/xhtml:li/xhtml:a[@href eq $app:CHAMBER-TYPE]/following-sibling::xhtml:ul/xhtml:li
        let $trimmed := functx:replace-first($menu/xhtml:a/@name,"/","")
        let $chamber := substring-before($trimmed,'/')
        let $name := substring-after($trimmed,'/')
        let $_tmpl := if($tmpl eq "") then $name else $tmpl
        return
            <li><a href="{$_tmpl}.html?menu={$app:MENU}&amp;type={$chamber}&amp;mainnav={$name}" title="{$menu/identifier}">{$name}</a></li>                
    }
    </ul>    
};

declare function app:sub-menus($node as node(), $model as map(*)) {

    <ul class="unstyled">
    {
        for $menu in doc($appconfig:CONFIG-FILE)/ui/menugroups/menu[@name eq $app:MAINNAV]/xhtml:div/xhtml:ul/xhtml:li
        let $trimmed := functx:replace-first($menu/xhtml:a/@name,"/","")
        let $chamber := substring-before($trimmed,'/')
        let $name := substring-after($trimmed,'/')
        return
            <li><a href="{$app:MAINNAV}.html?menu={$app:MENU}&amp;type={$chamber}&amp;mainnav={$app:MAINNAV}&amp;submenu={$name}" title="{$menu/identifier}">{$name}</a></li>                
    }
    </ul>    
};

(:~
 : This returns all the catalogues currently in the framework i18n folder
 : 
 : @param $node the HTML node with the class attribute which triggered this call
 : @param $model a map containing arbitrary data - used to pass information between template calls
 :)
declare function app:get-catalogues($node as node(), $model as map(*)) {
    <ul>
    {
        for $catalogue in collection($appconfig:i18n-catalogues)/catalogue
        return
            <li><a target="_blank" class="templates:load-source" href="{util:document-name($catalogue)}">{data($catalogue/@xml:lang)}</a></li>                
    }
    </ul>
};