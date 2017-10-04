xquery version "1.0-ml";

import module namespace constants = "http://www.TheIET.org/constants"   at "/Utils/constants.xqy";

declare variable $inputSearchDetails as xs:string external;

(:let $inputSearchDetails := "<Video><VideoId>e0d150af-6dff-4812-b4db-24b39e02de93</VideoId>
                              <VideoId>19975</VideoId>
                            </Video>":)
                            
let $InputXml  := xdmp:unquote($inputSearchDetails)
return 
      <Videos>
            {
                for $VideoId in $InputXml/Video/VideoId
                let $VideoUri := fn:concat("/PCopy/",$VideoId,".xml")
                let $VideoXml := fn:doc($VideoUri)
                return
                        if (fn:doc-available($VideoUri))
                        then 
                                <Video>
                                      <VideoId>{$VideoId/text()}</VideoId>
                                      <VideoNumber>{$VideoXml//VideoNumber/text()}</VideoNumber>
                                      <VideoTitle>{$VideoXml//BasicInfo/Title/text()}</VideoTitle>
                                </Video>

                        else "NONE"
           }
          </Videos>