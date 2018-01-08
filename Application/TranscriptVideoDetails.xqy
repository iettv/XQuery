xquery version "1.0-ml";

<Videos>
{
    for $VideoId in distinct-values(/Video[VideoStatus='Published' or VideoStatus='Draft'  or VideoStatus='Withdrawn'][AdvanceInfo/Subtitles/Subtitle[@active='yes'][Language/text()='English']/FileName/text()]/@ID/string())
  
        let $Video := (/Video[VideoStatus='Published' or VideoStatus='Draft'  or VideoStatus='Withdrawn'][AdvanceInfo/Subtitles/Subtitle[@active='yes'][Language/text()='English']/FileName/text()][@ID=$VideoId])[1]
        let $VideoDetails :=                 let $SubtitleText :=  ($Video/AdvanceInfo/Subtitles/Subtitle[Language/text()='English']/Text/text())[1]
                                              let $TranscriptText := ($Video/AdvanceInfo/Transcripts/Transcript[Language/text()='English']/Text/text())[1]
                                              let $TranscriptFilePath := ($Video/AdvanceInfo/Transcripts/Transcript[Language/text()='English']/FilePath/text())[1]
                                              let $TranscriptFileName := ($Video/AdvanceInfo/Transcripts/Transcript[Language/text()='English']/FileName/text())[1]
                                              let $TranscriptCreatedDate := ($Video/AdvanceInfo/Transcripts/Transcript[Language/text()='English']/CreatedDate/text())[1]
                                              let $FilePath := ($Video/AdvanceInfo/Subtitles/Subtitle[Language/text()='English']/FilePath/text())[1]
                                              let $FileName :=  ($Video/AdvanceInfo/Subtitles/Subtitle[Language/text()='English']/FileName/text())[1]
                                              let $CreatedDate := ($Video/AdvanceInfo/Subtitles/Subtitle[Language/text()='English']/CreatedDate/text())[1]
                                              let $SrtFilePath := concat($FilePath,$FileName)
                                              let $TranscriptSrtFilePath := concat($TranscriptFilePath,$TranscriptFileName)
                                    return
                                            <Video VideoId="{$Video/@ID}" VideoNo="{$Video/VideoNumber}" Title="{$Video/BasicInfo/Title}" Language="English" 
                                            SrtFilePath="{$SrtFilePath}" TranscriptFilePath="{$TranscriptSrtFilePath}" VideoType="{$Video/VideoStatus}" SubtitleText="{$SubtitleText}" TranscriptText="{$TranscriptText}"
                                            SubtitleCreatedOn="{$CreatedDate}" TranscriptCreatedOn="{$TranscriptCreatedDate}"/>
                                

        return 
               $VideoDetails
}
</Videos>  