xquery version "1.0-ml";

import module namespace VIDEOS     = "http://www.TheIET.org/ManageVideos"      at "/Utils/ManageVideos.xqy";
import module namespace constants = "http://www.TheIET.org/constants"   at "/Utils/constants.xqy";

declare variable $inputSearchDetails as xs:string external; 

(:let $inputSearchDetails := "<Video>
                                    <GUID>fcb986a2-eea5-4bbf-952b-62b7e59799a2</GUID>
                                    <Subtitle active='yes'>
                                    <Language>English</Language>
                                    <Text>Ritesh</Text>
                                    <DownloadLink>/Upload/iettv_21bfb488-624c-4bc2-96d9-1ea2dd5919d5/VideoSubtitleAndTranscriptImage/</DownloadLink>
                                    <FileName>example.srt</FileName>
                                    <FilePath>/Upload/iettv_21bfb488-624c-4bc2-96d9-1ea2dd5919d5/VideoSubtitleAndTranscriptImage/</FilePath>
                                    <CreatedDate>2017-01-05T00:00:00.0000</CreatedDate>
                                    </Subtitle>
                           </Video>":)

let $VideoChunk := xdmp:unquote($inputSearchDetails)
let $VideoId    := $VideoChunk/Video/GUID/text()
let $PCopyUri := fn:concat($constants:PCOPY_DIRECTORY,$VideoId,".xml")
let $DraftUri := fn:concat($constants:VIDEO_DIRECTORY,$VideoId,".xml")

return 
if( (fn:doc-available($PCopyUri)) or (fn:doc-available($DraftUri)) )
then
    (VIDEOS:AddSubtitleTranscript($VideoChunk))
else (xdmp:log(concat("[ IET-TV ][ AddSubtitleTranscript ][ INFO ][ GUID Not Available ] VideoId: ",$VideoId)),"Failed")