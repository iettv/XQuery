xquery version "1.0-ml";

import module namespace constants = "http://www.TheIET.org/constants"   at "/Utils/constants.xqy"; 

(:~ This service supports window application to update 'Event' element of already existing videos.
	: @VideoID     - Video ID of the Video.
	: @Event - Upload Video chunk
	: <Video><VideoID>1456</VideoID><UploadVideo>...</UploadVideo></Video>
:)

declare variable $inputSearchDetails as xs:string external;

let $InputParam  	:= xdmp:unquote($inputSearchDetails)
let $Log         	:= xdmp:log("[ VideoUploadChunk ][ CALL ][ Service called successfully!!! ]")
(:let $Log              := xdmp:log($InputParam):)
let $VideoID		:= $InputParam/Video/VideoID/text()
let $UploadVideo        := $InputParam/Video/UploadVideo
let $VideoURI 		:= fn:concat($constants:VIDEO_DIRECTORY,$VideoID,".xml")
let $PHistoryUri	:= fn:concat($constants:PCOPY_DIRECTORY,$VideoID,".xml")
let $IsVideoAvailable 	:= doc-available($VideoURI)
return
	if( $IsVideoAvailable = fn:true() )
	then
		try{(
		if(doc($VideoURI)/Video/UploadVideo)
		then xdmp:node-replace(doc($VideoURI)/Video/UploadVideo,$UploadVideo)
		else xdmp:node-insert-after(doc($VideoURI)/Video/ClientInfo,$UploadVideo)
		,
		if(doc-available($PHistoryUri))
		then
			if(doc($PHistoryUri)/Video/UploadVideo)
			then xdmp:node-replace(doc($PHistoryUri)/Video/UploadVideo, $UploadVideo)
			else xdmp:node-insert-after(doc($PHistoryUri)/Video/ClientInfo, $UploadVideo)
		else ()
		,
		"SUCCESS"
		)} catch($e){("ERROR", xdmp:log($e))}
	else
		(
		"ERROR: Video ID does not exist",
		xdmp:log(concat("[ VideoUploadChunk ][ ERROR ][ Invalid Video ID: ",$VideoID, "]"))
		)
