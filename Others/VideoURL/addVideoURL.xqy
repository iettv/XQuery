import module namespace constants = "http://www.TheIET.org/constants"   at "/Utils/constants.xqy";

(: This script will add VideoURL and DOI element in all the existing Videos :)

for $eachVideo in /Video[VideoNumber]
let $VideoNumber 		:= $eachVideo/VideoNumber/text()
let $constantURL 		:= concat("http://localhost/IETTVportal/?videoid=",$VideoNumber)
let $constantDOI		:= concat("10.1049/iet-tv.vn.",$VideoNumber)
return
let $VideoURL := 	if($eachVideo/VideoURL)
					then
					(
						xdmp:log("=======VideoURL Replace======"),
						xdmp:node-replace($eachVideo/VideoURL, <VideoURL>{$constantURL}</VideoURL>)
					)
					else
					(
						xdmp:log("======= VideoURL Insert======"),
						xdmp:node-insert-after($eachVideo/VideoStatus, <VideoURL>{$constantURL}</VideoURL>)
					)
					
let $DOI := 		if($eachVideo/PublishInfo/VideoPublish/DOI)
					then
					(
						xdmp:log("=======DOI Replace======"),
						xdmp:node-replace($eachVideo/PublishInfo/VideoPublish/DOI, <DOI>{$constantDOI}</DOI>)
					)
					else
					(
						xdmp:log("=======DOI Insert======"),
						xdmp:node-insert-after($eachVideo/PublishInfo/VideoPublish/FinalExpiryTime, <DOI>{$constantDOI}</DOI>)
					)
return "SUCCESS"