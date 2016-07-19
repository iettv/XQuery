xquery version "1.0-ml";

import module namespace VIDEOS = "http://www.TheIET.org/ManageVideos"   at  "/Utils/ManageVideos.xqy";

(: <Root><SpeakerId>37</SpeakerId></Root> :)

declare variable $inputSearchDetails as xs:string external;
let $Log 		:= xdmp:log("[ IET-TV ][ GetVideoBySpeaker ][ Call ][ Service call ]") 
let $InputXML  	:= xdmp:unquote($inputSearchDetails) 
let $SpeakerId 	:= $InputXML//SpeakerId
let $videoXML 	:= VIDEOS:GetVideoBySpeaker($SpeakerId)
return
	(
		<Videos>{$videoXML}</Videos>,
		xdmp:log("[ IET-TV ][ GetVideoBySpeaker ][ Success ][ Service result sent ]")
	)