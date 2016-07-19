xquery version "1.0-ml";

import module namespace VIDEOS = "http://www.TheIET.org/ManageVideos"   at "/Utils/ManageVideos.xqy";

(: <Root><CollectionName>Video-Type-Promo</CollectionName></Root> :)

declare variable $inputSearchDetails as xs:string external; 
let $InputXML  := xdmp:unquote($inputSearchDetails) 
let $CollectionName := $InputXML//CollectionName
let $videoXML := VIDEOS:GetVideoByCollection($CollectionName)
return <Videos>{$videoXML}</Videos>
