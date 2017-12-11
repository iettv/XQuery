xquery version "1.0-ml";

import module namespace constants = "http://www.TheIET.org/constants"   at "/Utils/constants.xqy"; 

(: Save Comment -  Same XQuery is for Update and Insert :)
(:<Comment show='yes' abuse='no'><VideoID>06adac22-2735-484e-91e2-554a1bd101fe</VideoID><CommentID></CommentID><CommentDetail><UserID>1</UserID><CommentDate>2014-12-09T11:53:35.604</CommentDate><CommentText>This video is good to watch.</CommentText></CommentDetail></Comment>:)
declare variable $inputSearchDetails as xs:string external ;

let $CommentXML  := xdmp:unquote($inputSearchDetails)
let $VideoID := $CommentXML/Comment/VideoID/text()
let $CommentID := $CommentXML/Comment/CommentID/text()
let $CommentCollection := concat($constants:COMMENT,$VideoID)
let $CommentURI := fn:concat($constants:COMMENT_DIRECTORY,$CommentID,".xml")
	 
return
	if($VideoID)
	then
		let $CommentIDCheck := if($CommentID) then "SUCCESS" else "FAIL"
		return
			if($CommentIDCheck eq "SUCCESS")
			then
				try{(
					  xdmp:document-insert($CommentURI,$CommentXML,(), $CommentCollection)
					  ,
					  "SUCCESS"
					  ,
					  xdmp:log(concat("[ CommentIngestion ][ SUCCESS ][ Comment has been inserted successfully!!! ID: ",$CommentURI, "]"))
					)}
				catch($e)
					  {(
						  xdmp:log(concat("[ CommentIngestion ][ ERROR ][ ", $CommentID, " ]"))
						  ,
						  "FAIL"
					  )}
			else
				(
				xdmp:log(concat("Provide Proper CommentID-",$CommentID))
				,
				"Provide Proper CommentID"
				)
	else
		(
		xdmp:log(concat("Provide Proper VideoID-",$VideoID))
		,
		"Provide Proper VideoID"
		)
