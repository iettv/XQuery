xquery version "1.0-ml";

import module namespace MARC_Constants  = "http://www.TheIET.org/MARCConstants"   at "/MARCUtils/MARCConstants.xqy";
import module namespace MARCVIDEOS = "http://www.TheIET.org/MARCManageVideos" at "/MARCUtils/MARCManageVideos.xqy";
(:
<Video><TermToSearch> </TermToSearch><StartDate>2015-01-01T00:00:00</StartDate><EndDate>2015-03-13T00:00:00</EndDate><PageLength>10</PageLength><StartPage>1</StartPage></Video>
:)

declare variable $inputSearchDetails as xs:string external; 
let $InputXml  	:= xdmp:unquote($inputSearchDetails)
let $TermToSearch 	:= $InputXml/Video/TermToSearch/text()
let $StartDate 		:= xs:dateTime($InputXml/Video/StartDate/text())
let $EndDate 		:= xs:dateTime($InputXml/Video/EndDate/text())
let $PageLength 	:= xs:integer($InputXml/Video/PageLength/text())
let $StartPage 		:= xs:integer($InputXml/Video/StartPage/text())
let $StartPage		:= if($StartPage=0) then xs:integer(1) else $StartPage
let $PageLength :=if ($PageLength=0) then count(fn:collection("PublishedCopy")) else $PageLength
let $VideoXML := MARCVIDEOS:GetVideoDetailsForMARCXML($TermToSearch,$PageLength,$StartPage,$StartDate,$EndDate)
return ($VideoXML)
		
