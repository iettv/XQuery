xquery version "1.0-ml";

import module namespace constants = "http://www.TheIET.org/constants"   at "/Utils/constants.xqy";

(: New and existing chunk update :)
let $Videos := 
<videos>
<video ID="61974f4e-3647-4610-a607-39648ff0ce48">
<VideoPublish active="yes">
<RecordStartDate>1900-01-01T00:00:00.0000</RecordStartDate>
<RecordStartTime>00:00:00.0000</RecordStartTime>
<FinalStartDate>2011-01-03T16:04:00.0000</FinalStartDate>
<FinalStartTime>16:04:00.0000</FinalStartTime>
<FinalExpiryDate>1900-01-01T00:00:00.0000</FinalExpiryDate>
<FinalExpiryTime>00:00:00.0000</FinalExpiryTime>
<URL>
</URL>
<DOI>10.1049/iet-tv.vn.10182</DOI>
</VideoPublish>
</video>
</videos>


for $eachVideo in $Videos//video

let $VideoID        := $eachVideo/@ID/string() 
let $VideoURI 			:= fn:concat($constants:VIDEO_DIRECTORY,$VideoID,".xml")
let $LivePublish  		:= $eachVideo/VideoPublish
return
  (
    if(fn:doc-available($VideoURI))
    then
      let $doc := fn:doc($VideoURI)
      return
        if($doc/Video/PublishInfo/VideoPublish)
        then xdmp:node-replace(doc($VideoURI)/Video/PublishInfo/VideoPublish,$LivePublish)
        else xdmp:node-insert-after(doc($VideoURI)/Video/SeriesList,$LivePublish)
      else xdmp:log(("======document not available=============", $VideoURI))
   )  