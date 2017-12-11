xquery version "1.0-ml";

import module namespace constants = "http://www.TheIET.org/constants"   at "/Utils/constants.xqy"; 
import module namespace spell     = "http://marklogic.com/xdmp/spell"   at "/MarkLogic/spell.xqy";
import module namespace VIDEOS   = "http://www.TheIET.org/ManageVideos"   at  "/Utils/ManageVideos.xqy";

declare variable $inputSearchDetails as xs:string external;
(:let $inputSearchDetails := "<VideoId>23e46260-3e73-4cc0-a1e0-800395503b02</VideoId>":)
let $InputXml := xdmp:unquote($inputSearchDetails) 
let $VideoID := $InputXml/VideoId/text()
let $VideoCount := VIDEOS:VideoCount()
let $VideoXML := fn:doc(concat($constants:PCOPY_DIRECTORY,$VideoID,".xml"))/Video
let $GetWords := for $EachElement in $VideoXML//*[not(fn:contains(name(), 'Date')) and
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
																			  name()!='Height'and
                                                                                name()!='LiveViewCount' and
                                                                                name()!='LiveLikeCount' and
                                                                                name()!='LiveDislikeCount' and
                                                                                name()!='InspecAbstract' and
                                                                                name()!='CaptionStart' and
                                                                                name()!='CaptionEnd'
																			 ]/text()
											let $UniqueWords :=   distinct-values( for $token in cts:tokenize($EachElement)
																				   return
																					   typeswitch ($token)
																					   case $token as cts:word return $token
																					   default return ()
																				 )
          						return for $Word in $UniqueWords return <word xmlns="http://marklogic.com/xdmp/spell">{$Word}</word>
return
(
                   (try{xdmp:node-insert-child(doc($constants:DictionaryFile)/*:dictionary,$GetWords)} catch($e){},
                   xdmp:log(concat(" [ IET-TV ][ Dictionary ] :"," Words Appended In Dictionary Successfully!!! "))),
                   
                    xdmp:document-insert('/VideosCount.xml',$VideoCount,(),'TotalVideosCount') 
                 
 )