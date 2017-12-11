xquery version "1.0-ml";
import module namespace VIDEOS = "http://www.TheIET.org/ManageVideos"   at "/Utils/ManageVideos.xqy";

(: Input Params : "<Videos><Video ID="3d600ba1-0ee6-4708-adc3-da8dbc42052f"><Duration>00:00:00</Duration><StreamId streamID="0_oju9itod"/></Video></Videos>" :)

declare variable $inputSearchDetails as xs:string external; 

let $InputXML 	 := xdmp:unquote($inputSearchDetails)
let $Log 		:= xdmp:log("[ IET-TV ][ SetVideoDuration ][ Call ][ Service call ]")
let $CheckVideoParameter := VIDEOS:checkVideoIDAndDuration($InputXML)
let $isVideoIDValid := VIDEOS:IsVideoIDValid($InputXML)

return
	if($CheckVideoParameter eq fn:false())
	then
	(
		xdmp:log("[ IET-TV ][ SetVideoDuration ][ Info ][ Some VideoID or Duration is empty ]"),
		"Some VideoID or Duration is empty"
	)
	else
	(
		VIDEOS:SetVideoDuration($InputXML),
		xdmp:log("[ IET-TV ][ SetVideoDuration ][ Success ][ Result sent ]"),
		$isVideoIDValid
	)
	
