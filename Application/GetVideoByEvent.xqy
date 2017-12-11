xquery version "1.0-ml";

import module namespace VIDEOS = "http://www.TheIET.org/ManageVideos"   at  "/Utils/ManageVideos.xqy";

declare variable $inputSearchDetails as xs:string external;
 
let $InputXML  := xdmp:unquote($inputSearchDetails) 
let $EventId := $InputXML//Event
let $videoXML := VIDEOS:GetVideoByEvent($EventId)
return <Videos>{$videoXML}</Videos>