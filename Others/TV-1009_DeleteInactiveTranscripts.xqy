xquery version "1.0-ml";

let $Results :=  for $i in (/Video[@ID][AdvanceInfo/Transcripts/Transcript[contains(FileName,'.doc')][@active='no']])
                
                  for $j in $i/AdvanceInfo/Transcripts/Transcript[contains(FileName,'.doc')][@active='no']

                  return 
                          
                           (xdmp:node-delete($j),
                           $i/@ID/string())

return $Results 