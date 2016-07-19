xquery version "1.0-ml";

(: This service is useful to get Video Details by ID :)
(: <VideoAction><VideoID>c371cb3e-18c1-41cb-9b84-39dc59f684d3</VideoID><UserID></UserID><UserIP>::1</UserIP><Email></Email></VideoAction>  :)

import module namespace VIDEOS = "http://www.TheIET.org/ManageVideos" at  "/Utils/ManageVideos.xqy";
import module namespace common = "http://www.TheIET.org/common"       at  "/Utils/common.xqy";


declare variable $inputSearchDetails as xs:string external;
let $Log 		:= xdmp:log("[ IET-TV ][ VideoDeatailByID ][ Call ][ Service call ]")
let $InputXML 	:= xdmp:unquote($inputSearchDetails) 
let $VideoID 	:= $InputXML/VideoAction/VideoID
let $UserIP 	:= $InputXML/VideoAction/UserIP
let $UserEmail 	:= $InputXML/VideoAction/Email
let $UserID 	:= $InputXML/VideoAction/UserID
let $Videos 	:= VIDEOS:GetVideoDetailsByID($VideoID,$UserID,$UserEmail,$UserIP)

return
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
