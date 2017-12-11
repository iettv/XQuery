xquery version "1.0-ml";

module namespace comment = "http://www.TheIET.org/comment";

import module namespace constants  = "http://www.TheIET.org/constants"    at  "/Utils/constants.xqy";


declare function getCommentByVideoId($VideoID as xs:string, $CommentCount as xs:integer)
{
	let $CommentCollection := fn:concat($constants:COMMENT, $VideoID)
	let $GetComments := (getAllCommentsByVideoId($VideoID)/Comment)[position() le $CommentCount]
	return
		<Comments>{$GetComments}</Comments>
};

declare function getAllCommentsByVideoId($VideoID as xs:string)
{
	<Comments>
		{
			let $CommentCollection := fn:concat($constants:COMMENT, $VideoID)
			for $EachComment in fn:collection($CommentCollection)
			order by xs:dateTime($EachComment/Comment/CommentDetail/CommentDate) descending
			return $EachComment
		}
	</Comments>
};