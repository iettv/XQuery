xquery version "1.0-ml";

declare variable $inputSearchDetails as xs:string external ;

(:let $inputSearchDetails := "<Video>
                                   	<VideoID>759ffc7f-bdd6-45aa-aa2a-d5cbedd17b04</VideoID>
                                   	<DataCollection>PCopy</DataCollection>
                           </Video>" :)

let $input := xdmp:unquote($inputSearchDetails)
let $videoId := $input/Video/VideoID/text()
let $DataCollection := $input/Video/DataCollection/text()

return

        if ($DataCollection='VideoAndPcopy')
        then (if(/Video[contains(base-uri(),'/PCopy/') or contains(base-uri(),'/Video/')][@ID=$videoId])
              then ("Success")
              else (concat("Fail-",/Video[@ID=$videoId]/VideoStatus/text()))
              )
        else if ($DataCollection='PCopy')
        then (if(/Video[contains(base-uri(),'/PCopy/')][@ID=$videoId])
              then ("Success")
              else (concat("Fail-",/Video[@ID=$videoId]/VideoStatus/text()))
              )
        else ("DataCollection is Wrong")
