xquery version "3.0";

module namespace pproc = "http://exist.bungeni.org/pproc";
import module namespace kwic="http://exist-db.org/xquery/kwic";
import module namespace cmn = "http://exist.bungeni.org/cmn" at "../common.xqm";

declare namespace util="http://exist-db.org/xquery/util";
declare namespace transform="http://exist-db.org/xquery/transform";
declare namespace xh = "http://www.w3.org/1999/xhtml";
declare namespace bu="http://portal.bungeni.org/1.0/";

(:
Library to do Post Process and validation of references especially on:
    ~Signatory->Users/Person
    ~ParliamentaryItems->Events, 
    ~Groupsittings->ParliamentaryItems
:)

(: Default Variables :)
declare variable $xup:PARL-ID := 2;

(:~
    This method inserts <bu:person/> node in the bu:signatory based on bu:userId provided by each 
    signatory node in a parliamentary document.
    
    @return nothing or <response type="error">
                            <code/>
                            <desc/>
                        </response>
:)
declare function pproc:update-signatories() {

    try {
        (: iterate through all documents with bu:signatory nodes and update with retrived Person's URI :)
        for $signatory in collection(cmn:get-lex-db())/bu:ontology[@for='document']/bu:signatories/bu:signatory
        let $user := collection(cmn:get-lex-db())/bu:ontology/bu:user[bu:userId eq $signatory/bu:userId]
        let $user-uri := $user/@uri
        let $user-name := concat($user/bu:lastName,", ",$user/bu:firstName)
        return 
            (: safe-guarding multiple <bu:person/> nodes since 2012! :)
            if (empty($signatory/bu:person)) then
                update insert <bu:person isA="TLCPerson" href="{$user-uri}" showAs="{$user-name}" /> into $signatory
            else
                ()
    } catch * {
        <response type="error">
           <code>{$err:code}</code>
           <desc>{$err:description}</desc>
        </response>
    }

};

(:~
    This method replaces place-holder for referenced document within an Event: First get all non-Event documents, if 
    they contain workflowEvents, we use the docIds to locate the Event documents being referred to and update 
    the refersTo href attributes. Consequently, workflowEvents in the non-Event documents are also updated with 
    the URI of the gotten Event.
:)
declare function pproc:update-events() {

    try {
        for $wfe in collection(cmn:get-lex-db())/bu:ontology/bu:document/bu:docType[bu:value ne 'Event']/ancestor::bu:document/bu:workflowEvents/bu:workflowEvent
        let $doc-node := $wfe/ancestor::bu:document
        let $docuri := if ($doc-node/@uri) then data($doc-node/@uri) else data($doc-node/@internal-uri)
        let $event := collection(cmn:get-lex-db())/bu:ontology/bu:document/bu:docType[bu:value eq 'Event']/ancestor::bu:document[bu:docId eq $wfe/bu:docId]
        return (
                update replace $event/bu:eventOf/bu:refersTo/@href with $docuri,
                update replace $doc-node/bu:workflowEvents/bu:workflowEvent[bu:docId=$wfe/bu:docId]/@href with $event/@uri
               )
    } catch * {
        <response type="error">
           <code>{$err:code}</code>
           <desc>{$err:description}</desc>
        </response>
    }
    
};


(:
    !+FIX_THIS (ao, 11-May-2012) currently some discrepancy exists with the groupsitting bungeni output.
    
    This method updates itemSchedules with with item URI as reference to the 
    actual document. Iterates through all the groupsitting documents' itemSchedules, and then using 
    the itemId==docId condition to retrieve a URI which is injected to itemSchedule as bu:document node 
    with a TLCReference attribute.
:)
declare namespace pproc:update-groupsittings() {

    try {
        for $anItem in collection(cmn:get-lex-db())/bu:ontology/bu:groupsitting/bu:itemSchedules/bu:itemSchedule
        let $doc-node := collection(cmn:get-lex-db())/bu:ontology/bu:document[bu:docId eq $anItem/bu:itemId]
        let $docId := $doc-node/bu:docId
        let $docuri := if ($doc-node/@uri) then data($doc-node/@uri) else data($doc-node/@internal-uri)
        return 
            concat($anItem/bu:itemId,'-',$doc-node/bu:docType/bu:value)
           (:update insert <bu:document isA="TLCReference" href="{$docuri}" id="bungeniDocument" /> into $anItem[bu:itemId eq $docId]:)
    }
    catch * {
        <response type="error">
           <code>{$err:code}</code>
           <desc>{$err:description}</desc>
        </response>
    }

};