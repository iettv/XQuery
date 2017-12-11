xquery version "1.0-ml";

import module namespace VIDEOS = "http://www.TheIET.org/ManageVideos"   at  "/Utils/ManageVideos.xqy";

declare variable $inputSearchDetails as xs:string external ;
let $videoXML := VIDEOS:getvideobyId($inputSearchDetails)
return if ($videoXML='NONE')
       then ("NONE")
       else 
      <Video>
<VideoNumber>{$videoXML//VideoNumber/text()}</VideoNumber>
<VideoTitle>{$videoXML//BasicInfo/Title/text()}</VideoTitle>
<SubscriptionType>{$videoXML//PricingDetails/@type/string()}</SubscriptionType>
<Duration>{$videoXML//UploadVideo/File/Duration/text()}</Duration>
</Video>
