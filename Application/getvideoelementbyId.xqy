xquery version "1.0-ml";
import module namespace VIDEOS = "http://www.TheIET.org/ManageVideos"   at  "/Utils/ManageVideos.xqy";

declare variable $inputSearchDetails as xs:string external;
let $InputXML  	:= xdmp:unquote($inputSearchDetails) 
let $Log 		:= xdmp:log("[ IET-TV ][ GetVideoElementByID ][ Call ][ Service call ]")
let $VideoId	:= $InputXML//VideoID/string()
let $RequiredElement	:= $InputXML//RequiredElement/string()
let $videoXML := VIDEOS:getvideoElementById($VideoId,$RequiredElement)
return
	(
		$videoXML,
		xdmp:log("[ IET-TV ][ GetVideoElementByID ][ Success ][ Service result sent ]")
	)
