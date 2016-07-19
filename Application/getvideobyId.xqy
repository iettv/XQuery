xquery version "1.0-ml";

import module namespace VIDEOS = "http://www.TheIET.org/ManageVideos"   at  "/Utils/ManageVideos.xqy";

declare variable $inputSearchDetails as xs:string external ;
let $videoXML := VIDEOS:getvideobyId($inputSearchDetails)
return $videoXML