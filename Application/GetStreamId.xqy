xquery version "1.0-ml";

declare variable $inputSearchDetails as xs:string external ;
let $Log 	   := xdmp:log("[ IET-TV ][ Extract General Element ][ Call ][ Service call ]")
(:let $inputSearchDetails := "<Root>
                                  <VideoID>17186</VideoID>
                            </Root>":)
let $InputXml  := xdmp:unquote($inputSearchDetails)
let $VideoID  := $InputXml/Root/VideoID/text()
let $ElementName  := $InputXml/Root/ElementName/text()
return
       <Video>
              <StreamID>{/Video[@ID=$VideoID][contains(base-uri(),'/PCopy/')]/UploadVideo/File/@streamID/string()}</StreamID>
              <LiveEntryID>{/Video[@ID=$VideoID][contains(base-uri(),'/PCopy/')]/PublishInfo/LivePublish/LiveEntryID/string()}</LiveEntryID>             
			  <FinalPubYear>{/Video[@ID=$VideoID][contains(base-uri(),'/PCopy/')]/PublishInfo/VideoPublish/FinalStartDate/string()}</FinalPubYear>
              <LiveFinalPubYear>{/Video[@ID=$VideoID][contains(base-uri(),'/PCopy/')]/PublishInfo/LivePublish/LiveFinalStartDate/string()}</LiveFinalPubYear>
       </Video>
