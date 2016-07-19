import module namespace constants = "http://www.TheIET.org/constants"   at "/Utils/constants.xqy"; 
import module namespace dls       = "http://marklogic.com/xdmp/dls"     at "/MarkLogic/dls.xqy";
import module namespace spell     = "http://marklogic.com/xdmp/spell"   at "/MarkLogic/spell.xqy";

(: This script will take Video XML(s) files from a folder and put them into IET.tv MarkLogic database :)
for $x in xdmp:filesystem-directory("C:/IETTV/XMLForMarlLogic-10022015")//dir:entry
let $ActualUri := $x/dir:pathname/text()
let $VideoUri := fn:tokenize($x/dir:pathname/text(),'/')[last()]
let $VideoXML := xdmp:document-get($ActualUri)

let $VideoID 			:= $VideoXML/Video/@ID/string()
let $VideoCurrentStatus := $VideoXML//VideoStatus/string()
let $VideoStatus 		:= if($VideoXML//VideoType/string()="Promo") then () else concat($constants:VIDEO_STATUS, $VideoXML//VideoStatus/string())
let $VideoType 			:= concat($constants:VIDEO_TYPE, $VideoXML//VideoType/string())
let $VideoURI 			:= fn:concat($constants:VIDEO_DIRECTORY,$VideoID,".xml")
let $PHistoryUri		:= fn:concat($constants:PCOPY_DIRECTORY,$VideoID,".xml")
let $IsVideoAvailable 	:= fn:doc-available($VideoURI)
(:let $DictionaryAppend   := let $GetWords := for $EarchElement in $VideoXML//*[not(fn:contains(name(), 'Date')) and
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
                                return
                                  if(string-length(normalize-space($EachWord/text()))!=0)
                                  then try{spell:add-word($constants:DictionaryFile, $EachWord/text())} catch($e){fn:concat("SpellAppend", '========', $EachWord/text())}
                                  else ():)
    
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
      "SUCCESS"
      ,
      xdmp:log(concat("[ VideoIngestion ][ SUCCESS ][ Video has been inserted successfully!!! ID: ",$VideoURI, "]"))
  )}
  catch($e){(
      xdmp:log(concat("[ VideoIngestion ][ ERROR ][ ", $VideoID, " ]"))
	  ,
	  xdmp:log($e)
      ,
      "FAIL! Check ML log file for more details."
  )}