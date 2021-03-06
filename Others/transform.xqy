xquery version "1.0-ml";

module namespace example = "http://www.TheIET.org/VideoIngestion";

import module namespace constants = "http://www.TheIET.org/constants"   at "/Utils/constants.xqy"; 
import module namespace dls       = "http://marklogic.com/xdmp/dls"     at "/MarkLogic/dls.xqy";
import module namespace spell     = "http://marklogic.com/xdmp/spell"   at "/MarkLogic/spell.xqy";

(: This will run through MLCP and append Dictionary,
 : ingest video with collection
:)

 declare function example:transform($content as map:map, $context as map:map) as map:map*
{
	let $Log := xdmp:log("--------------------transform running------------------")
	let $attr-value := (map:get($context, "transform_param"), "UNDEFINED")[1]
	let $the-doc := map:get($content, "value")
	return
		if (fn:empty($the-doc/element()))
		then $content
		else
			let $VideoXML := $the-doc
			let $VideoID 			:= $VideoXML/Video/@ID/string()
			let $VideoCurrentStatus := $VideoXML//VideoStatus/string()
			let $VideoStatus 		:= if($VideoXML//VideoType/string()="Promo") then () else concat($constants:VIDEO_STATUS, $VideoXML//VideoStatus/string())
			let $VideoType 			:= concat($constants:VIDEO_TYPE, $VideoXML//VideoType/string())
			let $VideoURI 			:= fn:concat($constants:VIDEO_DIRECTORY,$VideoID,".xml")
			let $PHistoryUri		:= fn:concat($constants:PCOPY_DIRECTORY,$VideoID,".xml")
			let $IsVideoAvailable 	:= fn:doc-available($VideoURI)
			let $DictionaryAppend   := 	xdmp:eval("
											import module namespace constants = 'http://www.TheIET.org/constants'   at '/Utils/constants.xqy'; 
											import module namespace spell     = 'http://marklogic.com/xdmp/spell'   at '/MarkLogic/spell.xqy';
											declare variable $VideoXML external;
											let $GetWords := for $EarchElement in $VideoXML//*[not(fn:contains(name(), 'Date')) and
																							  not(fn:contains(name(), 'Time')) and
																							  not(fn:contains(name(), 'URL')) and
																							  not(fn:contains(name(), 'Path')) and
																							  name()!='UploadPrice' and
																							  name()!='Streamid' and
																							  name()!='EmailID' and
																							  name()!='FileName' and
																							  name()!='Duration' and
																							  name()!='Password' and
																							  name()!='Rate' and
																							  name()!='Width' and
																							  name()!='Height'
																							 ]/text()
															let $UniqueWords :=   distinct-values( for $token in cts:tokenize($EarchElement)
																								   return
																									   typeswitch ($token)
																									   case $token as cts:punctuation return ''
																									   case $token as cts:word return $token
																									   case $token as cts:space return $token
																									   default return ()
																								 )
															return for $Word in $UniqueWords return <word>{$Word}</word>
											return
											  for $EachWord in $GetWords
											  return
												if( string-length(normalize-space($EachWord/text()))!=0 )
												then try{spell:add-word($constants:DictionaryFile, $EachWord/text())} catch($e){}
												else ()
										  "
										  ,
											(xs:QName('VideoXML'), $VideoXML)
										  ,
											<options xmlns='xdmp:eval'>
											  <isolation>different-transaction</isolation>
											  <prevent-deadlocks>false</prevent-deadlocks>
											</options>
										 )
			return
			  try{(
				  if( $VideoCurrentStatus="Published" and $VideoXML//VideoType/string()!="Promo" )
				  then
					(   
						xdmp:log("************** Published Video ************"),
						xdmp:document-insert($VideoURI,$VideoXML,(), ($constants:VIDEO_COLLECTION, $VideoType, $VideoStatus)),
						xdmp:document-insert($PHistoryUri,$VideoXML,(), $constants:PCOPY),
						let $Speakers := for $Speakers in $VideoXML//Speakers/Person
										 return <Speaker>{normalize-space(fn:concat($Speakers/Title/text(), ' ', $Speakers/Name/Given-Name/text(), ' ', $Speakers/Name/Surname/text()))}</Speaker>
						return xdmp:document-set-properties($PHistoryUri, <Speakers>{$Speakers}</Speakers>)
					)
				  else
				  if( $VideoCurrentStatus="Withdrawn")
				  then
					(   
						xdmp:log("************** Withdrawn Video ************"),
						xdmp:document-insert($VideoURI,$VideoXML,(), ($constants:VIDEO_COLLECTION, $VideoType,concat($constants:VIDEO_STATUS, $VideoXML//VideoStatus/string()))),
						if(doc-available($PHistoryUri))
						then
							xdmp:document-delete($PHistoryUri)
						else()
					)
				  else
					(
						xdmp:log("************** Video Insert ************"),
						xdmp:document-insert($VideoURI,$VideoXML,(), ($constants:VIDEO_COLLECTION, $VideoType, $VideoStatus))
					)
				  ,
				  xdmp:log(concat("[ VideoIngestion ][ SUCCESS ][ Video has been inserted successfully!!! ID: ",$VideoURI, "]"))
			  )}
			  catch($e){(
				  xdmp:log(concat("[ VideoIngestion ][ ERROR ][ ", $VideoID, " ]"))
				  ,
				  xdmp:log($e)
			  )}
};
