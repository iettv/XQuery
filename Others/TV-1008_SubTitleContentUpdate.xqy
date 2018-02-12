xquery version "1.0-ml";

let $Results := for $i in (/Video[@ID][AdvanceInfo/Subtitles/Subtitle[@active='yes']/SubtitleContent/Speaker])
                
                  for $j in $i/AdvanceInfo/Subtitles/Subtitle[@active='yes']
                
                  let $SubTitleContent := $j/SubtitleContent/Speaker

                  return 
                         
                         ( xdmp:node-replace($j/SubtitleContent,<SubTitleContent>{$SubTitleContent}</SubTitleContent>) ,
                         $i/@ID/string()
                         ) 

return $Results