xquery version "1.0-ml";

declare variable $inputSearchDetails as xs:string external;
(:let $inputSearchDetails 	:= "<Video><GUID>bf78bafc-b83c-4b6f-bd61-dbddab9b0df7</GUID><TranscriptOldFileName>English.pdf</TranscriptOldFileName><TranscriptFileName>English_11695.pdf</TranscriptFileName></Video>":)

let $InputXml  := xdmp:unquote($inputSearchDetails)
let $VideoId := $InputXml/Video/GUID/text()
let $TranscriptFileName := $InputXml/Video/TranscriptFileName/text()
let $TranscriptOldFileName := $InputXml/Video/TranscriptOldFileName/text()
let $PCopyUri := concat("/PCopy/",$VideoId,'.xml')
let $VideoUri := concat("/Video/",$VideoId,'.xml')

return 
        if ((doc-available($PCopyUri)) or (doc-available($VideoUri)))
        then
             (
             (xdmp:node-replace(doc(concat("/PCopy/",$VideoId,'.xml'))/Video/AdvanceInfo/Transcripts/Transcript[@active='yes'][Language/text()='English']/FileName[text()=$TranscriptOldFileName],<FileName>{$TranscriptFileName}</FileName>)),
             (xdmp:node-replace(doc(concat("/Video/",$VideoId,'.xml'))/Video/AdvanceInfo/Transcripts/Transcript[@active='yes'][Language/text()='English']/FileName[text()=$TranscriptOldFileName],<FileName>{$TranscriptFileName}</FileName>)),
              (xdmp:log(concat("Video Id: ",$VideoId," -- FileName Element Updated Successfully!!!"))),
              "Success"
             )
       else ("Failed")
