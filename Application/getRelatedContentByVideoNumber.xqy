xquery version "1.0-ml";

import module namespace comment = "http://www.TheIET.org/comment"      at  "/Utils/ManageComment.xqy"; 
import module namespace VIDEOS  = "http://www.TheIET.org/ManageVideos" at  "/Utils/ManageVideos.xqy";

(: To get video related content by VideoNumber :)
(: <VideoNumber>1234</VideoNumber> :)

declare variable $inputSearchDetails as xs:string external;

let $InputXML     := xdmp:unquote($inputSearchDetails)
let $VideoNumber  := $InputXML//text()
return
	if( not($VideoNumber) )
	then
		(
			xdmp:log(concat("[ ERROR ][ GET-RELATED-CONTENT ][ Provided Video Number is ",  $VideoNumber, " ]")),
			"ERROR!!! Required Video Number is missing."
		)
	else
		let $VideoID := VIDEOS:GetVideoIdByVideoNumber($VideoNumber)
		let $RelatedContent := if($VideoID) then VIDEOS:GetRelatedContent($VideoID) else ""
		return
			if( $RelatedContent )
			then $RelatedContent
			else "ERROR!! No Video is available with this Video Number"