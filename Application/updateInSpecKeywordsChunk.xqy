xquery version "1.0-ml";

import module namespace constants = "http://www.TheIET.org/constants"   at "/Utils/constants.xqy"; 

(:~ This service supports window application to update 'InSpec Keywords' element of already existing videos.
	: @VideoID     - Video ID of the Video.
	: @VideoInSpec - InSpec Keywords chunk
	: <Video><VideoID>1456</VideoID><VideoInSpec>..</VideoInSpec></Video>
:)

declare variable $inputSearchDetails as xs:string external;

let $InputParam  	:= xdmp:unquote($inputSearchDetails)
let $Log         	:= xdmp:log("[ VideoInSpecChunk ][ CALL ][ Service called successfully!!! ]")
(:let $Log            := xdmp:log($InputParam):)
let $VideoID		:= $InputParam/Video/VideoID/text()
let $VideoInSpec  		:= $InputParam/Video/VideoInspec
let $VideoURI 		:= fn:concat($constants:VIDEO_DIRECTORY,$VideoID,".xml")
let $PHistoryUri	:= fn:concat($constants:PCOPY_DIRECTORY,$VideoID,".xml")
let $IsVideoAvailable 	:= doc-available($VideoURI)
return
	if( $IsVideoAvailable = fn:true() )
	then
		try{(
		if(doc($VideoURI)/Video/VideoInspec)
		then xdmp:node-replace(doc($VideoURI)/Video/VideoInspec,$VideoInSpec)
		else xdmp:node-insert-after(doc($VideoURI)/Video/Attachments,$VideoInSpec)
		,
		if(doc-available($PHistoryUri))
		then
			if(doc($PHistoryUri)/Video/VideoInspec)
			then xdmp:node-replace(doc($PHistoryUri)/Video/VideoInspec, $VideoInSpec)
			else xdmp:node-insert-after(doc($PHistoryUri)/Video/Attachments, $VideoInSpec)
		else () 
		,
		"SUCCESS"
		)} catch($e){("ERROR", xdmp:log($e))}
	else
		(
		"ERROR: Video ID does not exist for InSpec",
		xdmp:log(concat("[ VideoInSpecChunk ][ ERROR ][ Invalid Video ID: ",$VideoID, "]"))
		)
