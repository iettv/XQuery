xquery version "1.0-ml";

let $Count := <Videos>
                  {
                  for $i in /Video[AdvanceInfo/Subtitles/Subtitle[@active='yes']/FileName][VideoStatus='Published' or VideoStatus='Draft'][ModifiedInfo/Date/text() le '2017-11-22T12:58:30.3215' ][CreationInfo//Given-Name[text()='Sushree'] or CreationInfo//Surname[text()='Mansingh'] or CreationInfo//Given-Name[text()='Sayali'] or CreationInfo//Surname[text()='Kachare']]

                        for $k in $i/AdvanceInfo/Subtitles/Subtitle[@active='yes'][CreatedDate/text()]
                              let $SubtitleText :=  $k/Text/text()
                              let $TranscriptText := ($k/../../Transcripts/Transcript[Language/text()='English']/Text/text())[1]
                              let $TranscriptFilePath := ($k/../../Transcripts/Transcript[Language/text()='English']/FilePath/text())[1]
                              let $TranscriptFileName := ($k/../../Transcripts/Transcript[Language/text()='English']/FileName/text())[1]
                              let $TranscriptCreatedDate := ($k/../../Transcripts/Transcript[Language/text()='English']/CreatedDate/text())[1]
                              let $FilePath := $k/FilePath/text()
                              let $FileName :=  $k/FileName/text()
                              let $CreatedDate :=  $k/CreatedDate/text()
                              let $SrtFilePath := concat($FilePath,$FileName)
                              let $TranscriptSrtFilePath := concat($TranscriptFilePath,$TranscriptFileName)
                    return
                            <Video VideoId="{$i/@ID}" VideoNo="{$i/VideoNumber}" Title="{$i/BasicInfo/Title}" Language="English" 
                            SrtFilePath="{$SrtFilePath}" TranscriptFilePath="{$TranscriptSrtFilePath}" VideoType="{$i/VideoStatus}" SubtitleText="{$SubtitleText}" TranscriptText="{$TranscriptText}"
                            SubtitleCreatedOn="{$CreatedDate}" TranscriptCreatedOn="{$TranscriptCreatedDate}"/>
                  }
                  </Videos>

return $Count

