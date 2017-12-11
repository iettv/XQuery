xquery version "1.0-ml";
import module namespace VIDEOS = "http://www.TheIET.org/ManageVideos"   at  "/Utils/ManageVideos.xqy";

declare variable $inputSearchDetails as xs:string external;
let $InputXML  := xdmp:unquote($inputSearchDetails) 
let $UserId := $InputXML//UserID
let $TopList:= $InputXML//TopList
let $SortKey :=$InputXML//SortKey
let $VideoType :=$InputXML//VideoType
let $videoXML := VIDEOS:get-recent-video($UserId,$TopList,$SortKey,$VideoType)
return <Videos>{$videoXML}</Videos>