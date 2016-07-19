xquery version "1.0-ml";

import module namespace VIDEOS     = "http://www.TheIET.org/ManageVideos"      at "/Utils/ManageVideos.xqy";
import module namespace constants = "http://www.TheIET.org/constants"   at "/Utils/constants.xqy";
(:
let $$inputSearchDetails := "<Video><TermToSearch>Given-Name:Peter</TermToSearch><StartDate>2015-01-01T00:00:00
</StartDate><EndDate>2015-03-13T00:00:00</EndDate><TextToSearch> </TextToSearch> <Status> </Status>
<PageLength>10</PageLength><StartPage>1</StartPage><IncludeBlankSpeakerFlag>No</IncludeBlankSpeakerFlag></Video>"
:)

declare variable $inputSearchDetails as xs:string external; 
(: let $log :=xdmp:log(fn:concat("IET TV:Start:GetVideoDetailsReport:",xs:string(fn:current-dateTime())))  :)
let $InputXml  	:= xdmp:unquote($inputSearchDetails)
let $TermToSearch 	:= $InputXml/Video/TermToSearch/text()
let $StartDate 		:= xs:dateTime($InputXml/Video/StartDate/text())
let $EndDate 		:= if ($InputXml/Video/EndDate/text()!="1900-01-01T00:00:00") then xs:dateTime(fn:replace($InputXml/Video/EndDate/text(),"00:00:00","23:59:59")) else $InputXml/Video/EndDate/text()
let $PageLength 	:= xs:integer($InputXml/Video/PageLength/text())
let $StartPage 		:= xs:integer($InputXml/Video/StartPage/text())
let $TextToSearch   := $InputXml/Video/TextToSearch/text()
let $Status			:= $InputXml/Video/Status/text()
let $PageLength		:= if ($TextToSearch='') 
                          then 
                            if ($PageLength=0)
                            then 
                                 count(             
                                cts:search(fn:collection($constants:VIDEO_COLLECTION),
                                
                                cts:and-query((
                                cts:path-range-query("ModifiedInfo/Date", ">=", $StartDate),
                                cts:path-range-query("ModifiedInfo/Date", "<=", $EndDate )
                                 ))
                                 )
                                 )
                          else $PageLength
                      else count(fn:collection($constants:VIDEO_COLLECTION))
 						
let $StartPage		:= if ($StartPage=0) then 1 else $StartPage
let $IncludeBlankSpeakerFlag 	:= $InputXml/Video/IncludeBlankSpeakerFlag/text()
		return
      if ($IncludeBlankSpeakerFlag="Yes")
      then 
		let $VideoWithSpeaker := VIDEOS:GetVideoDetailsReport($TermToSearch,$PageLength,$StartPage,$StartDate,$EndDate,$TextToSearch,$Status,"No")
        let $VideoWithoutSpeaker := if (fn:contains($TermToSearch,"Given-Name")) 
                                         then 
                                          VIDEOS:GetVideoDetailsReport(" ",$PageLength,$StartPage,$StartDate,$EndDate,$TextToSearch,$Status,$IncludeBlankSpeakerFlag)
                                          else ()
			
            return (<Result><Videos>{$VideoWithSpeaker}, {$VideoWithoutSpeaker}</Videos></Result>) 
		
      else 
		let $VideoXML := VIDEOS:GetVideoDetailsReport($TermToSearch,$PageLength,$StartPage,$StartDate,$EndDate,$TextToSearch,$Status,$IncludeBlankSpeakerFlag)
		
        return (<Result><Videos>{$VideoXML}</Videos></Result>)
		
