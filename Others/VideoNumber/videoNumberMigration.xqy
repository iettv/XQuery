xquery version "1.0-ml";

import module namespace constants = "http://www.TheIET.org/constants"   at "/Utils/constants.xqy";


let $UpdatedCounter := 0
let $Counter := doc($constants:VideoSequenceUri)/Counter/text()
return
(
  for $Video at $Pos in collection($constants:VIDEO_COLLECTION)/Video
  let $VideoUri   := xdmp:node-uri($Video)
  let $NewCounter := sum(xs:integer($Counter) + $Pos)
  let $SetCounter := xdmp:set($UpdatedCounter, $NewCounter)
  return
   (
      xdmp:node-insert-after(doc($VideoUri)/Video/HomePageVideo, <VideoNumber>{$NewCounter}</VideoNumber>)
    ,
      let $PCopyUri := concat($constants:PCOPY_DIRECTORY, substring-after($VideoUri, '/Video/'))
      return
        if(doc-available($PCopyUri))
        then xdmp:node-insert-after(doc($PCopyUri)/Video/HomePageVideo, <VideoNumber>{$NewCounter}</VideoNumber>)
        else ()
   )
   ,
   xdmp:document-insert($constants:VideoSequenceUri, <Counter>{$UpdatedCounter}</Counter>)
)