xquery version "1.0-ml";

import module namespace constants = "http://www.TheIET.org/constants" at "/Utils/constants.xqy";
import module namespace mem       = "http://xqdev.com/in-mem-update"  at "/MarkLogic/appservices/utils/in-mem-update.xqy";

(: This script could get two elements
   1. To update Migration XML on ML : <Migration><VID>1</VID><Status>Pass|Fail</Status><Message>dsfdsfds</Message></Migration> 
   2. Or actual video to update : <Video>...</Video>
:)

declare variable $inputSearchDetails as xs:string external;

let $VideoXML  			:= xdmp:unquote($inputSearchDetails)
let $Log                := xdmp:log("[ IET-TV ][ SetVideoMetadata ][ Service Call!!! ]")
(:let $Log 				:= xdmp:log($VideoXML):)
return
	if($VideoXML/Video)
	then
		(: In this case Video was invalid with the XSD and application is correcting it and sending it into ML :)
		let $Log                := xdmp:log(concat("[ IET-TV ][ SetVideoMetadata ][ Modified as per XSD!!! ][ ", data($VideoXML/Video/@ID), " ]"))
		let $VideoID 			:= data($VideoXML/Video/@ID)
		let $MChunk 			:= doc($constants:MURI)/XMLMigration/Video[VID=$VideoID]
		let $PHistoryUri		:= fn:concat($constants:PCOPY_DIRECTORY,$VideoID,".xml")
		let $View 				:= doc(concat($constants:ACTION_DIRECTORY, $VideoID, $constants:SUF_ACTION,'.xml'))//Views/text()
		let $AppendViewCount    := mem:node-insert-child($VideoXML/Video, <ViewCount>{if($View) then $View else 0}</ViewCount>)
		let $LikeCount 			:= count(doc(concat($constants:ACTION_DIRECTORY, $VideoID, $constants:SUF_ACTION,'.xml'))/VideoAction/User/Action[.='Like'])
		let $AppendLikeCount    := mem:node-insert-child($AppendViewCount/Video, <LikeCount>{if($LikeCount) then $LikeCount else 0}</LikeCount>)
		let $FilteredPubDate 	:= if(data($VideoXML/Video/PublishInfo/VideoPublish/@active)='yes')
								   then
									 if($VideoXML/Video/PublishInfo/VideoPublish/FinalStartDate/text()='1900-01-01T00:00:00.0000')
									 then $VideoXML/Video/PublishInfo/VideoPublish/RecordStartDate/text()
									 else $VideoXML/Video/PublishInfo/VideoPublish/FinalStartDate/text()
								   else
									if($VideoXML/Video/PublishInfo/LivePublish/LiveFinalStartDate/text()='1900-01-01T00:00:00.0000')
									then $VideoXML/Video/PublishInfo/LivePublish/LiveRecordStartDate/text()
									else $VideoXML/Video/PublishInfo/LivePublish/LiveFinalStartDate/text()
		let $AppendFilteredPubDate    := mem:node-insert-child($AppendViewCount/Video, <FilteredPubDate>{$FilteredPubDate}</FilteredPubDate>)
		let $UpdatedMChunk      := <Video info='Corrected' time='{substring(xs:string(current-dateTime()),0,24)}'><VID>{$VideoID}</VID><Result>Pass</Result><Sent>Yes</Sent><Message></Message></Video>
		return
			try{(
			xdmp:document-insert($PHistoryUri,$AppendFilteredPubDate,(), $constants:PCOPY)
			,
			xdmp:log(concat("[ IET-TV ][ SetVideoMetadata ][ Video Updated ][ ", $PHistoryUri, " ]"))
			,
			let $Speakers := for $Speakers in $AppendFilteredPubDate//Speakers/Person
							 return <Speaker>{normalize-space(fn:concat($Speakers/Title/text(), ' ', $Speakers/Name/Given-Name/text(), ' ', $Speakers/Name/Surname/text()))}</Speaker>
			return xdmp:document-set-properties($PHistoryUri, <Speakers>{$Speakers}</Speakers>)
			,
			xdmp:node-replace($MChunk, $UpdatedMChunk)
			,
			xdmp:log("Success")
			,
			"Success"
			)}
			catch($e){ ("Fail",xdmp:log($e)) }
	else
		(: This is the case when Video was OK with the XSD, and we just want to record it in our looping file to skip it further :)
		let $Log                := xdmp:log(concat("[ IET-TV ][ SetVideoMetadata ][ Already Correct as per XSD!!! ][ ", $VideoXML/Migration/VID/string(), " ]"))
		let $VideoID 			:= $VideoXML/Migration/VID/string()
		let $MChunk 			:= doc($constants:MURI)/XMLMigration/Video[VID=$VideoID]
		let $UpdatedMChunk      := <Video info='WasCorrect' time='{substring(xs:string(current-dateTime()),0,24)}'><VID>{$VideoID}</VID><Result>{$VideoXML/Migration/Status/string()}</Result><Sent>Yes</Sent><Message>{$VideoXML/Migration/Message/string()}</Message></Video>
		return
			try
			{
				xdmp:node-replace($MChunk, $UpdatedMChunk),
				"Success",
				xdmp:log("Success")
			}
			catch($e){ ("Fail",xdmp:log($e)) }
