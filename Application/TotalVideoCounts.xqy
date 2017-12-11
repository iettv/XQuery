xquery version "1.0-ml";

let $GetXml := doc("/VideosCount.xml")

let $VideoCount := $GetXml//VideoCount/text()

let $VideoTranscriptCount := $GetXml//VideoTranscriptCount/text()

return 
        <Video>
            <VideoCount>{$VideoCount}</VideoCount>
            <VideoTranscriptCount>{$VideoTranscriptCount}</VideoTranscriptCount>
        </Video>
        