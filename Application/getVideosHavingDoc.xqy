xquery version "1.0-ml";

let $VideoDetails := 
                      <Videos>
                      {
                      for $Video in /Video[((contains(base-uri(),'/PCopy/')) or ( (contains(base-uri(),'/Video/')) and ((VideoStatus='Draft') or (VideoStatus='Withdrawn')) ))]
                        [AdvanceInfo/Transcripts/Transcript[@active='yes']/FileName[((contains(text(),'.docx')) or (contains(text(),'.doc'))  or (contains(text(),'.pdf')) )]]
                        [AdvanceInfo/Subtitles/Subtitle[@active='yes'][Language/text()='English']/FileName/text()]
                                              let $Title := $Video/BasicInfo/Title/text()
                                              let $TranscriptFilePath := ($Video/AdvanceInfo/Transcripts/Transcript[@active='yes'][Language/text()='English']/FilePath/text())[1]
                                              let $TranscriptFileName := ($Video/AdvanceInfo/Transcripts/Transcript[@active='yes'][Language/text()='English']/FileName/text())[1]
                                              let $FilePath := ($Video/AdvanceInfo/Subtitles/Subtitle[@active='yes'][Language/text()='English']/FilePath/text())[1]
                                              let $FileName :=  ($Video/AdvanceInfo/Subtitles/Subtitle[@active='yes'][Language/text()='English']/FileName/text())[1]
                                              let $SrtFilePath := concat($FilePath,$FileName)
                                              let $TranscriptSrtFilePath := concat($TranscriptFilePath,$TranscriptFileName)
                                              let $VideoStatus      := $Video/VideoStatus/text()
                                    return
                                            <Video VideoId="{$Video/@ID}" VideoNo="{$Video/VideoNumber}" Language="English" Title="{$Title}"
                                            VideoType="{$VideoStatus}" SrtFilePath="{$SrtFilePath}" TranscriptFilePath="{$TranscriptSrtFilePath}" />
                        }
                      </Videos>
let $CountVideos := count($VideoDetails//Video)
 return 
            (($VideoDetails),(xdmp:log(concat($CountVideos," Videos Having Doc Or Docx In Transcript"))))    
 
         