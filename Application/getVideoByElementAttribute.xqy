xquery version "1.0-ml";

import module namespace VIDEOS = "http://www.TheIET.org/ManageVideos"   at  "/Utils/ManageVideos.xqy";

(: <Root><SearchElement>Event</SearchElement><SearchElementAttr>eventID</SearchElementAttr><SearchValue>1001</SearchValue><UserID></UserID></Root> :)

declare variable $inputSearchDetails as xs:string external; 
let $InputXML  := xdmp:unquote($inputSearchDetails) 
let $UserId := $InputXML//UserID
let $SearchElement :=$InputXML//SearchElement
let $SearchElementAttr := $InputXML//SearchElementAttr
let $SearchValue := $InputXML//SearchValue
let $videoXML := VIDEOS:GetVideoByElementAttribute($UserId,$SearchElement,$SearchElementAttr,$SearchValue)
return <Videos>{$videoXML}</Videos>
