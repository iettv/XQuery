xquery version "1.0-ml";

declare variable $inputSearchDetails as xs:string external ;

(:let $inputSearchDetails := "<Video>
                                   	<VideoID>100137</VideoID>
                                   	<DataCollection>VideoAndPcoy</DataCollection>
                           </Video>" :)

let $input := xdmp:unquote($inputSearchDetails)
let $videoId := $input/Video/VideoID/text()
let $DataCollection := $input/Video/DataCollection/text()

return

if ($DataCollection='VideoAndPcopy')
then (if(/Video[contains(base-uri(),'/PCopy/') or contains(base-uri(),'/Video/')][@ID=$videoId])
      then ("Success")
      else ("Fail"))
else if ($DataCollection='PCopy')
then (if(/Video[contains(base-uri(),'/PCopy/')][@ID=$videoId])
      then ("Success")
      else ("Fail"))
else ("DataCollection is Wrong")
