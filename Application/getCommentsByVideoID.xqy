xquery version "1.0-ml";

import module namespace comment = "http://www.TheIET.org/comment" at  "/Utils/ManageComment.xqy"; 

(: To get video related comments by count :)
(: <Comment><VideoID>1234</VideoID><Count>5</Count></Comment> :)

declare variable $inputSearchDetails as xs:string external ;

let $InputXML  := xdmp:unquote($inputSearchDetails)
let $VideoID := $InputXML/Comment/VideoID/string()
let $CommentCount := xs:integer($InputXML/Comment/Count/text())
return
	if( $VideoID )
	then
		let $Comments := if($CommentCount) then comment:getCommentByVideoId($VideoID,$CommentCount) else comment:getAllCommentsByVideoId($VideoID)
		return
			if( $Comments/Comment )
			then <Comments><VideoID>{$VideoID}</VideoID>{$Comments/Comment}</Comments>
			else "Related comments are not available."
	else
		(
			xdmp:log(concat("[ ERROR ][ GET-COMMENT ][ Provided VideoID is ",  $VideoID, " ]")),
			"ERROR!!! Required value for VideoID Count is missing."
		)