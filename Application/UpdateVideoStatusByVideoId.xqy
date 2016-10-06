xquery version "1.0-ml";

declare variable $inputSearchDetails as xs:string external ;

(:let $inputSearchDetails := "<Video>
                              <VideoId>5589</VideoId>
                              <VideoStatus>Draft</VideoStatus>
                           </Video>":)

let $input := xdmp:unquote($inputSearchDetails)
let $VideoId := $input/Video/VideoId/text()
let $VideoStatus := $input/Video/VideoStatus/text()

return 
if (/Video[@ID/string()=$VideoId][contains(base-uri(),'/PCopy/') or contains(base-uri(),'/Video/')])
then 
      (for $i in doc()/Video[@ID/string()=$VideoId][contains(base-uri(),'/PCopy/') or contains(base-uri(),'/Video/')]
      
      return 
             if ($i/VideoStatus)
                 then ((xdmp:node-replace($i/VideoStatus, <VideoStatus>{$VideoStatus}</VideoStatus>)),"Success")
             else ((xdmp:node-insert-child($i,<VideoStatus>{$VideoStatus}</VideoStatus>)),"Success") )
             
else ("Failed")
