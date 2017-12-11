xquery version "1.0-ml";

import module namespace VideoActivityReport = "http://www.TheIET.org/VideoActivityReport"   at "VideoActivityReport.xqy";

(: 
	This service is useful to provide all the Video Management related activity
	<Activity><TermToSearch>( ((Type:Permissions) OR (Type:Upload)) AND (UserName:Ashwini.Gawade) AND (PriceType:Free) AND (VideoID:30d73795-db87-40a6-8214-fcd16171ddf5))</TermToSearch><StartDate>2015-03-20</StartDate><EndDate>2015-04-05</EndDate></Activity>
	:)

declare variable $inputSearchDetails as xs:string external ;

let $Log 			:= xdmp:log("[ IET-TV ][ Activity-Video Management ][ Call ][ To get Video Management Activities ]")
let $ActivityXml	:= xdmp:unquote($inputSearchDetails)
let $TermToSearch 	:= $ActivityXml/Activity/TermToSearch/text()
let $StartDate 		:= $ActivityXml/Activity/StartDate/text()
let $EndDate 		:= $ActivityXml/Activity/EndDate/text()
let $PageLength 	:= xs:integer(count(collection("Admin")))
let $StartPage 		:= xs:integer(1)
return	

	if($StartDate)
	then
	(
		if($EndDate)
		then
		(
			VideoActivityReport:GetVideoActivityReport($TermToSearch, xs:date($StartDate), xs:date($EndDate), $PageLength, $StartPage)
		)
		else
		(
			"VideoActivityReport-EndDate is empty",
			xdmp:log("VideoActivityReport-EndDate is empty")
		)
	)
	else
	(
		"VideoActivityReport-StartDate is empty",
		xdmp:log("VideoActivityReport-StartDate is empty")
	)

	