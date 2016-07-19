xquery version "1.0-ml";

import module namespace constants = "http://www.TheIET.org/constants"   at "/Utils/constants.xqy"; 
import module namespace spell     = "http://marklogic.com/xdmp/spell"   at "/MarkLogic/spell.xqy";
import module namespace mem       = "http://xqdev.com/in-mem-update"    at "/MarkLogic/appservices/utils/in-mem-update.xqy";

for $VideoXML in collection("Video-Status-Published")
let $VideoID 			:= $VideoXML/Video/@ID/string()
let $VideoCurrentStatus := $VideoXML//VideoStatus/string()
let $VideoStatus 		:= if($VideoXML//VideoType/string()="Promo") then () else concat($constants:VIDEO_STATUS, $VideoXML//VideoStatus/string())
let $VideoType 			:= concat($constants:VIDEO_TYPE, $VideoXML//VideoType/string())
let $VideoURI 			:= fn:concat($constants:VIDEO_DIRECTORY,$VideoID,".xml")
let $PHistoryUri		:= fn:concat($constants:PCOPY_DIRECTORY,$VideoID,".xml")
let $IsVideoAvailable 	:= fn:doc-available($VideoURI)
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
(: to preserve VideoNumber:)
let $VideoXML           := if($VideoCurrentStatus != "Draft")
						   then
							   if($VideoXML/Video/VideoNumber)
							   then mem:node-replace($VideoXML/Video/VideoNumber, <VideoNumber>{$VideoNumber}</VideoNumber>)
							   else mem:node-insert-after($VideoXML/Video/HomePageVideo, <VideoNumber>{$VideoNumber}</VideoNumber>)
						   else $VideoXML
(: To Preserve already inserted <VideoCount> element :)
let $VideoXML           := if($VideoCurrentStatus != "Draft")
						   then
							   let $ViewCount := if(fn:doc-available($PHistoryUri)) then doc($PHistoryUri)/Video/ViewCount/text() else doc(concat($constants:ACTION_DIRECTORY, $VideoID, $constants:SUF_ACTION,'.xml'))/VideoAction/Views/text()
							   return mem:node-insert-child($VideoXML/Video,  <ViewCount>{if($ViewCount) then $ViewCount else 0}</ViewCount>)
						   else $VideoXML
(: To Preserve already inserted LikeCount element :)
let $VideoXML           := if($VideoCurrentStatus != "Draft")
						   then
							   let $LikeCount := count(doc(concat($constants:ACTION_DIRECTORY, $VideoID, $constants:SUF_ACTION,'.xml'))/VideoAction/User/Action[.='Like'])
							   return mem:node-insert-child($VideoXML/Video,  <LikeCount>{if($LikeCount) then $LikeCount else 0}</LikeCount>)
						   else $VideoXML
(: To Preserve already inserted FilteredPubDate element :)
let $VideoXML           := if($VideoCurrentStatus != "Draft")
						   then
							   let $PDate :=   if(data($VideoXML/Video/PublishInfo/VideoPublish/@active)='yes')
											   then
												 if($VideoXML/Video/PublishInfo/VideoPublish/FinalStartDate/text()='1900-01-01T00:00:00.0000')
												 then $VideoXML/Video/PublishInfo/VideoPublish/RecordStartDate/text()
												 else $VideoXML/Video/PublishInfo/VideoPublish/FinalStartDate/text()
											   else
												if($VideoXML/Video/PublishInfo/LivePublish/LiveFinalStartDate/text()='1900-01-01T00:00:00.0000')
												then $VideoXML/Video/PublishInfo/LivePublish/LiveRecordStartDate/text()
												else $VideoXML/Video/PublishInfo/LivePublish/LiveFinalStartDate/text()
							   return mem:node-insert-child($VideoXML/Video,  <FilteredPubDate>{$PDate}</FilteredPubDate>)
						   else $VideoXML							   
(: To Preserve already inserted <VideoURL> element :)						   
let $VideoXML           :=	if( ($VideoCurrentStatus != "Draft") and ($IsVideoAvailable = fn:true()) )
							then
								let $VideoURL := let $URL := doc($VideoURI)/Video/VideoURL/text()
												 return
												 if(string-length(substring-after($URL,$constants:VideoURL)) gt 0)
												 then $URL
												 else concat($constants:VideoURL, $VideoNumber)
								return
								   if($VideoXML/Video/VideoURL)
								   then mem:node-replace($VideoXML/Video/VideoURL, <VideoURL>{$VideoURL}</VideoURL>)
								   else mem:node-insert-after($VideoXML/Video/VideoStatus, <VideoURL>{$VideoURL}</VideoURL>)
							else
							if( ($VideoCurrentStatus != "Draft") and ($IsVideoAvailable = fn:false()) )
							then
							   if($VideoXML/Video/VideoURL)
							   then mem:node-replace($VideoXML/Video/VideoURL, <VideoURL>{concat($constants:VideoURL, $VideoNumber)}</VideoURL>)
							   else mem:node-insert-after($VideoXML/Video/VideoStatus, <VideoURL>{concat($constants:VideoURL, $VideoNumber)}</VideoURL>)
							else $VideoXML
(: To Preserve already inserted <DOI> element :)
let $VideoXML           :=	if( ($VideoCurrentStatus != "Draft") and ($IsVideoAvailable = fn:true()) )
							then
								let $VideoDOI := let $DOI := let $PubInfo := doc($VideoURI)/Video/PublishInfo
															 return if($PubInfo/VideoPublish[@active="yes"])
																	then $PubInfo/VideoPublish/DOI/text()
																	else $PubInfo/LivePublish/DOI/text()
												 return
												  if(string-length(substring-after($DOI,$constants:VideoDOI)) gt 0)
												  then $DOI
												  else concat($constants:VideoDOI, $VideoNumber)
								return
								   if($VideoXML/Video/PublishInfo/VideoPublish[@active="yes"])
								   then
									  if($VideoXML/Video/PublishInfo/VideoPublish/DOI)
									  then mem:node-replace($VideoXML/Video/PublishInfo/VideoPublish/DOI, <DOI>{$VideoDOI}</DOI>)
									  else mem:node-insert-child($VideoXML/Video/PublishInfo/VideoPublish, <DOI>{$VideoDOI}</DOI>)
								   else
									  if($VideoXML/Video/PublishInfo/LivePublish/DOI)
									  then mem:node-replace($VideoXML/Video/PublishInfo/LivePublish/DOI, <DOI>{$VideoDOI}</DOI>)
									  else mem:node-insert-child($VideoXML/Video/PublishInfo/LivePublish, <DOI>{$VideoDOI}</DOI>)
							else
							if( ($VideoCurrentStatus != "Draft") and ($IsVideoAvailable = fn:false()) )
							then
							   if($VideoXML/Video/PublishInfo/VideoPublish[@active="yes"])
							   then
								  if($VideoXML/Video/PublishInfo/VideoPublish/DOI)
								  then mem:node-replace($VideoXML/Video/PublishInfo/VideoPublish/DOI, <DOI>{concat($constants:VideoDOI, $VideoNumber)}</DOI>)
								  else mem:node-insert-child($VideoXML/Video/PublishInfo/VideoPublish, <DOI>{concat($constants:VideoDOI, $VideoNumber)}</DOI>)
							   else
								  if($VideoXML/Video/PublishInfo/LivePublish/DOI)
								  then mem:node-replace($VideoXML/Video/PublishInfo/LivePublish/DOI, <DOI>{concat($constants:VideoDOI, $VideoNumber)}</DOI>)
								  else mem:node-insert-child($VideoXML/Video/PublishInfo/LivePublish, <DOI>{concat($constants:VideoDOI, $VideoNumber)}</DOI>)
							else $VideoXML							
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
