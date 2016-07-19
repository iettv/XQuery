xquery version "1.0-ml";

(: This service is useful to get Video Details by ID :)
(: <VideoAction><VideoNumber>5</VideoNumber><UserID></UserID><UserIP>::1</UserIP><Email></Email></VideoAction>  :)

import module namespace VIDEOS = "http://www.TheIET.org/ManageVideos" at  "/Utils/ManageVideos.xqy";
import module namespace constants = "http://www.TheIET.org/constants" at "/Utils/constants.xqy";

declare variable $inputSearchDetails as xs:string external;
let $Log 		:= xdmp:log("[ IET-TV ][ VideoDeatailByID ][ Call ][ Service call ]")
let $InputXML 	:= xdmp:unquote($inputSearchDetails) 
let $VideoNumber := $InputXML/VideoAction/VideoNumber
let $UserIP 	:= $InputXML/VideoAction/UserIP
let $UserEmail 	:= $InputXML/VideoAction/Email
let $UserID 	:= $InputXML/VideoAction/UserID
let $VideoID	:= data(xdmp:directory($constants:VIDEO_DIRECTORY)/Video[VideoNumber=$VideoNumber]/@ID)
let $Videos 	:= VIDEOS:GetVideoDetailsByID($VideoID,$UserID,$UserEmail,$UserIP)

return
  if( not($VideoID) )
  then "ERROR!!! Provided sequence ID not available."
  else
  if( not($UserID) and not($UserIP) and not($UserEmail) )
  then
	"ERROR!!! Please provide minimum one value from UserID, UserIP, or Email."
  else
  if( $Videos != "NONE" )
  then
     (
		$Videos,
		xdmp:log("[ IET-TV ][ VideoDeatailByID ][ Call ][ Service result sent ]")
     )
  else
    (
		xdmp:log(concat("[ IET-TV ][ VideoDeatailByID ][ Error ] Invalid video ID - VIDEO-ID ", $VideoID, " ]")),
		"ERROR!! Video ID is invalid"
	)
