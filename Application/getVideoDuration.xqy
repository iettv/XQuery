xquery version "1.0-ml";
import module namespace VIDEOS = "http://www.TheIET.org/ManageVideos"   at "/Utils/ManageVideos.xqy";

(: Output Params : "<Videos><Video><VideoID>06d0fd24-7650-4c7d-b2bb-c09d97da6c8e</VideoID><Duration>00:00:00</Duration></Video></Videos>" :)

declare variable $inputSearchDetails as xs:string external;

let $Video 	:= VIDEOS:GetVideoDuration()
let $Log 	:= xdmp:log("[ IET-TV ][ GetVideoDuration ][ Call ][ Service call ]")
return        
      if($Video)
      then 
		(
			<Videos>{$Video}</Videos>,
			xdmp:log("[ IET-TV ][ GetVideoDuration ][ Success ][ Service result sent ]")
		)
      else
	  (
		"No Video Found",
		xdmp:log("[ IET-TV ][ GetVideoDuration ][ INFO ][ No videos are available to send ]")
	  )