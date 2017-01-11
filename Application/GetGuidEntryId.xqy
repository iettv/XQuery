xquery version "1.0-ml";

import module namespace VIDEOS     = "http://www.TheIET.org/ManageVideos"      at "/Utils/ManageVideos.xqy";
import module namespace constants = "http://www.TheIET.org/constants"   at "/Utils/constants.xqy";

declare variable $inputSearchDetails as xs:string external; 

(:let $inputSearchDetails := "<Records><VideoId>490000004</VideoId><VideoId>6000049</VideoId></Records>":)

let $InputXml  	:= xdmp:unquote($inputSearchDetails)
let $VideoId  	:=  for $VideoId in $InputXml/Records/VideoId/text() return $VideoId
let $GuIdEntryId := VIDEOS:GetGuIdEntryId($VideoId)

return <Videos>{ $GuIdEntryId }</Videos>
