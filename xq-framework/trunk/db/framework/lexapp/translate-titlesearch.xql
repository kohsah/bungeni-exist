xquery version "1.0";

import module namespace config = "http://bungeni.org/xquery/config" at "../config.xqm";

declare namespace request="http://exist-db.org/xquery/request";
declare namespace transform="http://exist-db.org/xquery/transform";

(:

Transforms an AkomaNtoso document into a HTML snapshot

This is invoked by controller.xql

:)

declare option exist:serialize "method=xml media-type=application/xml";

(: stylesheet to transform :)
let $stylesheet := doc(fn:concat($config:fw-app-root,"actsnapshot.xsl"))

(: input ANxml document in request :)
let $doc := request:get-attribute("titlesearch.doc")

return 
    transform:transform($doc, $stylesheet, ())

