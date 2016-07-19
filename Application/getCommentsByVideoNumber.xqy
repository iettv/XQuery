xquery version "1.0-ml";

import module namespace comment = "http://www.TheIET.org/comment"      at  "/Utils/ManageComment.xqy"; 
import module namespace VIDEOS  = "http://www.TheIET.org/ManageVideos" at  "/Utils/ManageVideos.xqy";

(: To get video related comments by count :)
(: <Comment><VideoNumber>1234</VideoNumber><Count>5</Count></Comment> :)

declare variable $inputSearchDetails as xs:string external ;

let $InputXML     := xdmp:unquote($inputSearchDetails)
let $VideoNumber  := $InputXML/Comment/VideoNumber/string()
let $CommentCount := xs:integer($InputXML/Comment/Count/text())
return
	if( not($VideoNumber) )
	then
		(
			xdmp:log(concat("[ ERROR ][ GET-COMMENT ][ Provided Video Number is ",  $VideoNumber, " ]")),
			"ERROR!!! Required Video Number is missing."
		)
	else
		let $VideoID := VIDEOS:GetVideoIdByVideoNumber($VideoNumber)
		let $Comments := if($CommentCount) then comment:getCommentByVideoId($VideoID,$CommentCount) else comment:getAllCommentsByVideoId($VideoID)
		return
			if( $Comments/Comment )
			then <Comments><VideoID>{$VideoID}</VideoID>{$Comments/Comment}</Comments>
			else "Related comments are not available."