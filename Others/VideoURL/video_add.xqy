xquery version "1.0-ml";

import module namespace constants = "http://www.TheIET.org/constants"   at "/Utils/constants.xqy"; 
import module namespace spell     = "http://marklogic.com/xdmp/spell"   at "/MarkLogic/spell.xqy";
import module namespace mem       = "http://xqdev.com/in-mem-update"    at "/MarkLogic/appservices/utils/in-mem-update.xqy";

declare variable $inputSearchDetails as xs:string external;

let $VideoXML  			:= xdmp:unquote($inputSearchDetails)
let $VideoID 			:= $VideoXML/Video/@ID/string()
let $VideoCurrentStatus := $VideoXML//VideoStatus/string()
let $VideoStatus 		:= if($VideoXML//VideoType/string()="Promo") then () else concat($constants:VIDEO_STATUS, $VideoXML//VideoStatus/string())
let $VideoType 			:= concat($constants:VIDEO_TYPE, $VideoXML//VideoType/string())
let $VideoURI 			:= fn:concat($constants:VIDEO_DIRECTORY,$VideoID,".xml")
let $PHistoryUri		:= fn:concat($constants:PCOPY_DIRECTORY,$VideoID,".xml")
let $IsVideoAvailable 	:= fn:doc-available($VideoURI)
let $constantPath 		:= "http://localhost/IETTVportal/?videoid="
let $VideoNumber        := if($VideoCurrentStatus != "Draft")
						   then
						   (
								xdmp:eval("
									   import module namespace constants = 'http://www.TheIET.org/constants'   at '/Utils/constants.xqy';
									   declare variable $IsVideoAvailable external;
									   declare variable $VideoURI external;
									   if($IsVideoAvailable = fn:true())
									   then
											let $VideoNumber := doc($VideoURI)/Video/VideoNumber/text()
											return
											if($VideoNumber)
											then $VideoNumber
											else
											   let $AppendSequence := sum(xs:integer(doc($constants:VideoSequenceUri)/Counter/text()) + 1)
											   return
											   (
												   $AppendSequence
												   ,
												   xdmp:document-insert($constants:VideoSequenceUri, <Counter>{$AppendSequence}</Counter>)
											   )
									   else
									   let $AppendSequence := sum(xs:integer(doc($constants:VideoSequenceUri)/Counter/text()) + 1)
									   return
									   (
										   $AppendSequence
										   ,
										   xdmp:document-insert($constants:VideoSequenceUri, <Counter>{$AppendSequence}</Counter>)
									   )
									"
									,
										(xs:QName('IsVideoAvailable'), $IsVideoAvailable, xs:QName('VideoURI'), $VideoURI)
									  ,
										<options xmlns='xdmp:eval'>
										  <isolation>different-transaction</isolation>
										  <prevent-deadlocks>false</prevent-deadlocks>
										</options>
									)
							)
							else ""

let $VideoXML           :=	if($VideoCurrentStatus != "Draft")
							then
							   if($VideoXML/Video/VideoNumber)
							   then mem:node-replace($VideoXML/Video/VideoNumber, <VideoNumber>{$VideoNumber}</VideoNumber>)
							   else mem:node-insert-after($VideoXML/Video/HomePageVideo, <VideoNumber>{$VideoNumber}</VideoNumber>)
							else $VideoXML
							
let $VideoXML           :=	if( $VideoCurrentStatus != "Draft")
							then mem:node-insert-after($VideoXML/Video/VideoStatus, <VideoURL>{concat($constantPath,$VideoXML/Video/VideoNumber/text())}</VideoURL>)
							else $VideoXML
							
let $DictionaryAppend   := let $GetWords := for $EarchElement in $VideoXML//*[not(fn:contains(name(), 'Date')) and
																			  not(fn:contains(name(), 'Time')) and
																			  not(fn:contains(name(), 'URL')) and
																			  not(fn:contains(name(), 'Path')) and
																			  name()!='UploadPrice' and
																			  name()!='Streamid' and
																			  name()!='EmailID' and
																			  name()!='FileName' and
																			  name()!="Duration" and
																			  name()!='Password' and
																			  name()!='Rate' and
																			  name()!='Width' and
																			  name()!='Height'
																			 ]/text()
											let $UniqueWords :=   distinct-values( for $token in cts:tokenize($EarchElement)
																				   return
																					   typeswitch ($token)
																					   case $token as cts:punctuation return ""
																					   case $token as cts:word return $token
																					   case $token as cts:space return $token
																					   default return ()
																				 )
											return for $Word in $UniqueWords return <word>{$Word}</word>
						  return
							  for $EachWord in $GetWords
							  return try{spell:add-word($constants:DictionaryFile, $EachWord/text())} catch($e){}
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
	  concat("SUCCESS", ' ', $VideoNumber)
	  ,
	  xdmp:log(concat("[ VideoIngestion ][ SUCCESS ][ Video has been inserted successfully!!! ID: ",$VideoURI, "][ VideoNumber : ", $VideoNumber," ]"))
  )}
  catch($e){(
	  xdmp:log(concat("[ VideoIngestion ][ ERROR ][ ", $VideoID, " ]"))
	  ,
	  xdmp:log($e)
	  ,
	  "FAIL! Check ML log file for more details."
  )}
