xquery version "1.0-ml";

import module namespace constants = "http://www.TheIET.org/constants" at "/Utils/constants.xqy";

(: <XMLMigration><Video><VID>1</VID><Result>|Pass|Fail</Result><Sent>Yes|No</Sent></Video> :)
(:
import module namespace constants = "http://www.TheIET.org/constants" at "/Utils/constants.xqy";

let $XmlChunk := for $Video in collection($constants:PCOPY)
                  return  <Video><VID>{data($Video/Video/@ID)}</VID><Result></Result><Sent>No</Sent></Video>
return xdmp:document-insert($constants:MURI,<XMLMigration>{$XmlChunk}</XMLMigration>)

:)
(:
let $Video 				:= (doc($constants:MURI)/XMLMigration/Video[Sent='No' and (Result!="Pass" and Result!="Fail") and VID != ""])[1]
let $Log                := xdmp:log("[ IET-TV ][ GetVideoMetadata ][ Service Call!!! ]")
let $VideoID 			:= $Video/VID/text()
let $VideoURI 			:= fn:concat($constants:VIDEO_DIRECTORY,$VideoID,".xml")
let $PHistoryUri		:= fn:concat($constants:PCOPY_DIRECTORY,$VideoID,".xml")
let $IsVideoAvailable 	:= fn:doc-available($PHistoryUri)
return
	if( $Video )
	then
		if($IsVideoAvailable = fn:true())
		then
			(
				doc($PHistoryUri),
				xdmp:node-replace($Video/Sent, <Sent>Yes</Sent>)
			)
		else
			xdmp:log(concat('[ IET-TV ][ GetVideoMetadata ][ ', 'Error while sending document. Please check log file for more details ]'))
	else "Task Completed!!!"
	
:)

let $Video 				:= (doc($constants:MURI)/XMLMigration/Video[Sent='No' and (Result!="Pass" and Result!="Fail") and VID != ""])[1]
let $Log                := xdmp:log(concat('[ IET-TV ][ GetVideoMetadata ][ Service Call!!! ][ ', $Video/VID/text(), ' ]'))
let $VideoID 			:= $Video/VID/text()
let $PHistoryUri		:= fn:concat($constants:PCOPY_DIRECTORY,$VideoID,".xml")
let $IsVideoAvailable 	:= fn:doc-available($PHistoryUri)
return
	if( $Video[self::Video] )
	then
		if($IsVideoAvailable = fn:true())
		then
			(
			(: To send published video without 'ViewCount' element which is not available in XSD and it is used internally only :)
			let $Video := doc($PHistoryUri)
			return <Video xsi:noNamespaceSchemaLocation="{data($Video/Video/@xsi:noNamespaceSchemaLocation)}" ID="{data($Video/Video/@ID)}" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">{$Video/Video/child::*[not(name()='ViewCount')]}</Video>
			,
			xdmp:node-replace($Video/Sent, <Sent>Yes</Sent>)
			)
		else
			xdmp:log(concat('[ IET-TV ][ GetVideoMetadata ][ This is not in Published Copy collection ][ ', $PHistoryUri, ' ]'))
	else (xdmp:log('[ IET-TV ][ GetVideoMetadata ][ **********Task Completed!!!************* ]'),"Task Completed!!!")