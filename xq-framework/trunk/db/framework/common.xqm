module namespace cmn = "http://exist.bungeni.org/cmn";

declare namespace xh = "http://www.w3.org/1999/xhtml";

declare namespace util="http://exist-db.org/xquery/util";
declare namespace request="http://exist-db.org/xquery/request";
import module namespace config = "http://bungeni.org/xquery/config" at "config.xqm";
import module namespace fw = "http://bungeni.org/xquery/fw" at "fw.xqm";
declare namespace i18n = "http://exist-db.org/xquery/i18n";
declare namespace bu="http://portal.bungeni.org/1.0/";


(:
Library for common functions used in the Application.

Some of the APIs here should eventually be factored int a framework level library 
rather than an Application level library

:)


(:~
Get the path to the bungeni collection
:)
declare function cmn:get-lex-db() as xs:string {
    $config:XML-COLLECTION
 };
 
 (:~
Get the path to the attachments collection
:)
declare function cmn:get-att-db() as xs:string {
    $config:ATT-COLLECTION
 };

(:~
Get the path to the vocabularies collection
:)
declare function cmn:get-vdex-db() as xs:string {
    $config:VDEX
 };

(:~
Get the UI configuraton document
:)
declare function cmn:get-ui-config() as document-node() {
  local:__get_app_doc__($config:UI-CONFIG)
  (: fn:doc(fn:concat($config:fw-app-root, $config:UI-CONFIG)) :)
};

(:~
Get the PARLIAMENT configuraton document
:)
declare function cmn:get-parl-config() as document-node()? {
    doc($config:PARLIAMENT-CONFIG)
};

(:~
Get the LANGUAGES configuraton document
:)
declare function cmn:get-langs-config() as document-node()? {
    doc($config:LANGUAGES-CONFIG)
};

(:~
Get a menu by name from the UI configuration document 
:)
declare function cmn:get-menu($menu-name as xs:string) as node() {
    let $doc := cmn:get-ui-config()/ui/menugroups/menu[@name=$menu-name]  
    return $doc
}; 

(:~
Get a route configuration from the exist path.
The exist-path is passed from the appcontroller
:)
declare function cmn:get-route($exist-path as xs:string) {
    let $doc := cmn:get-ui-config()/ui/routes/route[@href eq $exist-path]      
       return $doc
};

(:~
Get a viewgroups configuration from the --------.
:)
declare function cmn:get-tabgroups($exist-path as xs:string) as node() {
    let $doc := cmn:get-ui-config()/ui/viewgroups/views[@name eq $exist-path]     
        return $doc
};

(:~
Get a viewgroups listing parameters from the --------.
:)
declare function cmn:get-view-listing-parts($doctype as xs:string, $default-view as xs:string) as node() {
    let $views := cmn:get-ui-config()/ui/viewgroups/views[@name eq $doctype]
    let $listing-view := $views/view[@id eq 'listing']
    let $current-path := data($listing-view/@path)
    let $default-path := data($views/view[@id eq $default-view]/@path)
        return  <listing>
                    <doctype>{$doctype}</doctype>
                    {$listing-view}
                    <current-view>{$current-path}</current-view>
                    <default-view>{$default-path}</default-view>
                </listing>
};

(:~
    Get a views path configuration as per given context.
:)
declare function cmn:get-views-for-type($type as xs:string) as node()* {
        cmn:get-ui-config()/ui/viewgroups/views[@name eq $type]
};

(:~
    Get a tabs/view path configuration as per context. Currently 
    returns a template and stylesheet for document transformations
:)
declare function cmn:get-view-parts($exist-path as xs:string) as node()* {
    let $rel-path := substring-after($exist-path,'/'),
        $doc := cmn:get-ui-config()/ui/viewgroups/views/view[@path eq $rel-path]
        return $doc
};

(:~
:   Get the user ui-config file
:)
(:
declare function cmn:user-preferences() as document-node() {
    
    $config:UI-USER-CONFIG
    
};
:)

(:~
Get the applicable menu for a route
:)
declare function cmn:get-menu-from-route($exist-path as xs:string) as node()? {
    let $doc := cmn:get-route($exist-path)
      return cmn:get-ui-config()//menu[@for eq $doc/navigation/text()]
};

(:~
Build navigation template nodes for a request path 
The mainnav is provided by default.
The subnavigation is rendered based on the incoming request path
The app-tmpl parameter is the final page template to be processed.
:)
declare function cmn:build-nav-tmpl($exist-path as xs:string, $app-tmpl as xs:string) as node()+ {
     let $main-nav := cmn:get-menu("mainnav")
     let $sub-nav := cmn:get-menu-from-route($exist-path)
     let $tmpl := fw:app-tmpl($app-tmpl)
     let $out := ($main-nav, $sub-nav, $tmpl)      
     return $out
};

(:~
 Builds a content template nodes
 The mainnav is provided by default.
 The subnavigation is rendered based on the incoming request path
 The app-tmpl parameter is a node that has been rewritten as final page template to be processed.
:)
declare function cmn:rewrite-tmpl($exist-path as xs:string, $app-tmpl as node()+) as node()+ {
     let $main-nav := cmn:get-menu("mainnav")
     let $sub-nav := cmn:get-menu-from-route($exist-path)
     let $out := ($main-nav, $sub-nav, $app-tmpl)
     return $out
};

(:~
Build navigation template nodes for a request path 
The mainnav is provided by default.
The subnavigation is rendered based on the incoming request path
The node parameter is the "cooked" page as a node
:)
declare function cmn:build-nav-node($controller-data as node(), $node as node()) as node()+ {
    let $main-menu := cmn:get-menu("mainnav")
    let $main-nav := cmn:get-chambers-menu($main-menu,$controller-data)   
    let $sub-nav := cmn:get-menu-from-route($controller-data/exist-path/text())      
    let $crumb := <crumb>
                        <div id="portal-breadcrumbs" xmlns="http://www.w3.org/1999/xhtml">
                        <span id="breadcrumbs-you-are-here">You are here: </span>
                        {local:build-breadcrumbs($controller-data)}
                        </div>
                    </crumb>
     let $out := ($main-nav, $sub-nav,$crumb, $node ) 
     return $out
};

(:
    For rendering the main-menu from ui-config
    @param main-menu node() <menu name="mainnav"/>   
    @param bicameral boolen true if bicameral

    @return
     regenerates main-menu omitting senate navigation if its unicameral parliament
        <menu>
            <ul>
                <li/>
                ...
            </ul>
        </menu>
:)
declare function cmn:get-chambers-menu($main-menu as node(), $controller as node()) {
    
    let $main-ul := $main-menu
    return 
        element {node-name($main-ul)} {
            $main-ul/@*,
            element {node-name($main-ul/xh:ul)} {
            $main-ul/xh:ul/@*,
                for $li at $pos in $main-ul/xh:ul/xh:li
                let $type := cmn:get-parl-config()/parliaments/parliament[status = 'active'][1]/type/text()              
                order by $li/@data-order ascending
                return 
                    if(not(xs:boolean($controller/bicameral/text()))) then 
                        $li[data(xh:a/@href) eq $type]
                    else
                        $li
            }
        }
    
};

(: accumulates path strings :)
declare function local:build($prefix, $tokens)
{
    if (fn:exists($tokens)) then
        let $str := fn:concat($prefix, $tokens[1])
        let $display-name := replace($str,fn:concat('^.*','/'),'')
        let $home-substr := substring-before($str, '/')
        let $home := if ($home-substr eq "") then () else concat($home-substr,"/")
        return ( 
            <xh:a href="{$home}{$display-name}">
                <i18n:text key="{$display-name}">{$display-name}(nt)</i18n:text>
            </xh:a>,
            local:build($str, fn:subsequence($tokens, 2))
        )
    else 
        ()
};

(:~ 
:   Builds the breadcrumbs
:)
declare function local:build-breadcrumbs($controller-data as node()?) {
    let $route := cmn:get-route($controller-data/exist-path/text()) 
    let $tokenize-route := tokenize($route/navigation, '/')
    let $append := insert-before($tokenize-route,count($tokenize-route)+1,$route/subnavigation/text())
    let $join-with-delimiter := string-join($append, ">/")
    (:removing the first occurence of '>/' so that the built paths are relative to the framework's root :)
    let $breadcrumb-tree := fn:replace($join-with-delimiter, fn:concat('(^.*?)', ">/"),fn:concat('$1',""))
    return (
        local:build("", fn:tokenize($breadcrumb-tree, ">"))
        (:<xh:a href="{$controller-data/parliament/type/text()}/{$controller-data/exist-res/text()}?{request:get-query-string()}">
            <i18n:text key="texts">{$route/title/text()}</i18n:text>
        </xh:a>:)
        )
};

(:~ 
:   Get the config for maximum range retrievable
:)
declare function cmn:whatson-range-limit() {
    cmn:get-ui-config()//listings/max-range
};

(:~ 
:   Retrieves the corresponding title for the route from <menugroups/>
:)
declare function local:route-title($navroute as xs:string) {
    
    cmn:get-ui-config()//menugroups/menu//xh:a[@name eq $navroute]/i18n:text
    
};

declare function cmn:get-doctype-config($doctype as xs:string) {
   let $config := cmn:get-ui-config()
   let $dc-config := $config/ui/doctypes/doctype[lower-case(@name) eq lower-case($doctype)]
   return 
    if ($dc-config) then (
        $dc-config
      )
    else
        ()
};

(:
 : return <whatsonview/> nodes
 :)
declare function cmn:get-whatsonviews() {
    cmn:get-ui-config()/ui/custom/whatsonviews
};

(:
 : return <doctype/> nodes
 :)
declare function cmn:get-doctypes() {
   cmn:get-ui-config()/ui/doctypes/doctype
};

declare function cmn:get-orderby-config($doctype as xs:string)  {
    let $dc-config := cmn:get-doctype-config($doctype)
    return
    if ($dc-config) then (
       $dc-config/orderbys/orderby
       )
    else
        ()
};

declare function cmn:get-orderby-config-name($doctype as xs:string, $orderby_name as xs:string)  {
    let $dc-config := cmn:get-doctype-config($doctype)
    return
    if ($dc-config and ($orderby_name eq "none")) then (
        $dc-config/orderbys/orderby[@default eq "true"]
    )    
    else if ($dc-config and not(empty($orderby_name))) then (
       $dc-config/orderbys/orderby[@value eq $orderby_name]
       )
    else
        ()
};

declare function cmn:get-searchins-config($doctype as xs:string)  {
    let $dc-config := cmn:get-doctype-config($doctype)
    return 
    if ($dc-config) then (
       $dc-config/searchins/searchin
       )
    else
        ()
};

declare function cmn:get-listings-config($doctype as xs:string)  {
    let $dc-config := cmn:get-doctype-config($doctype)
    return 
    if ($dc-config) then (
       $dc-config/listingfilters/listingfilter
       )
    else
        ()
};

declare function cmn:get-listings-config() {
    cmn:get-ui-config()/ui/listings
};

declare function cmn:get-listings-config-limit() as xs:string {
    data(cmn:get-listings-config()/limit)
};

declare function cmn:get-listings-config-limit() as xs:integer {
    xs:integer(data(cmn:get-listings-config()/limit))
};

declare function cmn:get-listings-config-visiblepages() as xs:integer {
    xs:integer(data(cmn:get-listings-config()/visiblePages))
};



(:~

Retrieve the permissinos for a filter name 'public-view', 'authenticated-view'
   <acl-groups>
        <acl name="public-view" condition="@name='zope.View' and @role='bungeni.Anonymous' and @setting='Allow'" />
        <acl name="authenticated-view" condition="@name='zope.View' and @role='bungeni.Authenticated' and @setting='Allow'" />
    </acl-groups>

:)

declare function cmn:get-acl-group($filter-name as xs:string) {
      let $acl-group := cmn:get-ui-config()/ui/acl-groups/acl[@name eq $filter-name]
      return 
        if ($acl-group) then (
            $acl-group
          )
        else
            ()
};

(:
declare function cmn:get-acl-filter($filter-name as xs:string) as xs:string {
    let $acl-group := cmn:get-acl-group($filter-name)
    return 
        if ($acl-group) then 
            (: Axis not used currently :)
            (: concat($acl-group/@axis, '[', $acl-group/@condition, ']') :)
            data($acl-group/@condition)
         else
            xs:string("")
};
:)


(:~

Retrieve the permissinos for a filter name 'public-view', 'authenticated-view'
   <acl-groups>
        <acl name="public-view"  />
        <acl name="authenticated-view" condition="@name='zope.View' and @role='bungeni.Authenticated' and @setting='Allow'" />
    </acl-groups>

:)

declare function cmn:get-acl-group($filter-name as xs:string) {
      let $acl-group := cmn:get-ui-config()/ui/acl-groups/acl[@name eq $filter-name]
      return 
        if ($acl-group) then (
            $acl-group
          )
        else
            ()
};

declare function cmn:get-acl-filter($filter-name as xs:string) as xs:string {
    let $acl-group := cmn:get-acl-group($filter-name)
    return 
        if ($acl-group) then 
            (: Axis not used currently :)
            (: concat($acl-group/@axis, '[', $acl-group/@condition, ']') :)
            data($acl-group/@condition)
         else
            xs:string("")
};


(:~
:Gets the permission nodes for a named acl
:)
declare function cmn:get-acl-permissions($filter-name as xs:string) as node()+{
    let $acl-group := cmn:get-acl-group($filter-name)
    return
        if ($acl-group) then
            $acl-group/bu:control
        else
            ()
};


(:~
:Gets the permission nodes for a named acl
:)
declare function cmn:get-acl-doctype-permissions($doctype as xs:string, $filter-name as xs:string) as node()+{
    let $acl-doctype := cmn:get-doctype-config($doctype)/acl[@name eq $filter-name]
    return
        if ($acl-doctype) then
            $acl-doctype/bu:control
        else
            ()
};

(:~
: Returns the permission node as a attributed string
:)
declare function cmn:get-acl-permission-attr($permission as node()) {
    fn:concat("@name='",$permission/@name, "' and ", "@role='", $permission/@role, "' and ", "@setting='",$permission/@setting, "'")             
};  


(:~
: Returns the input filters corresponding permission as a attribute condition string
:)
declare function cmn:get-acl-permission-as-attr($filter-name as xs:string) {
    let $acl-perm := cmn:get-acl-permissions($filter-name)
    return cmn:get-acl-permission-attr($acl-perm)
};

(:~
: Returns the input filters corresponding permission as a attribute condition string
: @param $doctype
: @param $filter-name
:)
declare function cmn:get-acl-permission-as-attr($doctype as xs:string, $filter-name as xs:string) {
    let $acl-perm := cmn:get-acl-doctype-permissions($doctype,$filter-name)
    return cmn:get-acl-permission-attr($acl-perm)
};

(:
    similar to cmn:get-acl-permission-as-attr() only that it returns a node
:)
declare function cmn:get-acl-permission-as-node($doctype as xs:string, $filter-name as xs:string) {
    let $acl-perm := cmn:get-acl-doctype-permissions($doctype,$filter-name)
    return $acl-perm
};

(:~
: Returns the input filters corresponding permission as a attribute condition string
: given the @role
:)
declare function cmn:get-acl-permission-as-attr-for-role($role-name as xs:string) {
    let $perm := cmn:get-acl-permissions("role-view")
    return 
        fn:concat("@name='",$perm/@name, "' and ", "@role='", $role-name, "' and ", "@setting='",$perm/@setting, "'")
};

(:~
: Returns the input filters as attribute(s) condition string given the @role(s) only
: Used by the RESTXQ search API to return documents by specified roles(s)
:)
declare function cmn:get-attr-for-role($role-name as xs:string) {
    let $perm := cmn:get-acl-permissions("role-view")
    return 
        fn:concat("@role='", $role-name, "' and ", "@setting='",$perm/@setting, "'")
};

(:~
: Returns the node permissions node condition string given the @role
:)
declare function cmn:get-acl-permission-as-node-for-role($role-name as xs:string) {
    let $perm := cmn:get-acl-permissions("role-view")
    return 
        element {name($perm)} {
             $perm/@name,
             attribute role {$role-name},             
             $perm/@setting
          }
};

(:~
Loads an XSLT file 
:)
declare function cmn:get-xslt($value as xs:string) as document-node()? {
    (: doc(fn:concat($config:fw-app-root, $value)) :)
    local:__get_app_doc__($value)
};

(:~
Generic api to load a document from the application folder
:)
declare function local:__get_app_doc__($value as xs:string) as document-node() {
    doc(fn:concat($config:fw-app-root, $value))
};


(:~
Parses request parameters and returns them as a XML structure
:)
declare function cmn:get-parameters($value as xs:string, $delimiter as xs:string) as node() {
         let $parsed-tokens := tokenize($value ,$delimiter)
         return 
         <tokens>
         {for $parsed-token in $parsed-tokens 
               where string-length($parsed-token) > 0
               return <token name="{$parsed-token}" />
               }
         </tokens>          
};

(:
Returns the server running the current scripts
:)
declare function cmn:get-server() as xs:string {
    let $url := concat("http://" , request:get-server-name(),":" ,request:get-server-port())
    return $url

};
