xquery version "1.0-ml";

import module namespace VIDEOS = "http://www.TheIET.org/ManageVideos" at  "/Utils/ManageVideos.xqy";
import module namespace constants = "http://www.TheIET.org/constants"   at "/Utils/constants.xqy"; 

(:~ This service supports window application to update 'InSpec Keywords' element of already existing videos.
	: @VideoID     - Video ID of the Video.
	: @VideoInSpec - InSpec Keywords chunk
	: <Video><VideoID>1456</VideoID><VideoInSpec>..</VideoInSpec></Video>
:)

declare variable $inputSearchDetails as xs:string external;

let $InputParam  	    := xdmp:unquote($inputSearchDetails)
let $Log         	    := xdmp:log("[ VideoInSpecChunk ][ CALL ][ Service called successfully!!! ]")
let $VideoID		    := $InputParam/Video/VideoID/text()
let $VideoInSpec  		:= $InputParam/Video/IETTV-Inspec
let $VideoURI 		    := fn:concat($constants:VIDEO_DIRECTORY,$VideoID,".xml")
let $PHistoryUri	    := fn:concat($constants:PCOPY_DIRECTORY,$VideoID,".xml")
let $IsVideoAvailable   := doc-available($VideoURI)
let $Result             := (VIDEOS:VideoInSpec($VideoURI,$VideoInSpec,$VideoID),
                          VIDEOS:VideoInSpec($PHistoryUri,$VideoInSpec,$VideoID))
return
       ($Result)[1]
        