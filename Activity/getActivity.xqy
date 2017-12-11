xquery version "1.0-ml";

import module namespace ActivityReport = "http://www.TheIET.org/ActivityReport"   at "ActivityReport.xqy";
import module namespace functx         = "http://www.functx.com"                  at "/MarkLogic/functx/functx-1.0-doc-2007-01.xqy";


(: 
	To get activity list = <Activity><TermToSearch>Action:Play</TermToSearch><Type></Type><StartDate>2014-01-01</StartDate><EndDate>2015-12-31</EndDate><StartPage>1</StartPage><PageLength>10</PageLength></Activity>"
	To get graph data = <Activity><TermToSearch>Action:Play</TermToSearch><Type>Graph</Type><StartDate>2014-01-01</StartDate><EndDate>2015-12-31</EndDate><StartPage>1</StartPage><PageLength>10</PageLength></Activity>"
	<Activity><Type>Graph</Type><TextToSearch>x</TextToSearch><Dates><Date><StartDate>2015-01-14</StartDate><EndDate>2015-01-14</EndDate></Date><Date><StartDate>2015-01-13</StartDate><EndDate>2015-01-13</EndDate></Date></Dates><PlatformID>IET-TV</PlatformID>
	<StartPage>1</StartPage><PageLength>10</PageLength><TermToSearch>(((Action:AttachmentDownload) OR (Action:Dislike) OR (Action:Download) OR (Action:Like))) </TermToSearch></Activity>
:)

declare variable $inputSearchDetails as xs:string external; 
let $ActivityXml  	:= xdmp:unquote($inputSearchDetails)
let $TermToSearch 	:= $ActivityXml/Activity/TermToSearch/text()
let $Type 			:= if($ActivityXml/Activity/Type/text()="Graph") then "Graph" else "NONE"
let $Actions        := $ActivityXml/Activity/Action/text()
let $TextToSearch   := $ActivityXml/Activity/TextToSearch/text()

return
 	if( $Type = 'Graph' )
	then
		<Graph>
			{
				let $Log 			:= xdmp:log("[ IET-TV ][ GetActivity ][ Call ][ Get Activity to call graph data ]")
				let $Is365Days		:= $ActivityXml/Activity/Is365Days/string()
				for $EachDate in $ActivityXml/Activity/Dates/Date
				let $StartDate 		:= xs:date($EachDate/StartDate/text())
				let $EndDate 		:= xs:date($EachDate/EndDate/text())
				let $PageLength 	:= xs:integer($ActivityXml/Activity/PageLength/text())
				let $StartPage 		:= xs:integer($ActivityXml/Activity/StartPage/text())
				let $MonthName 		:= 	if($Is365Days eq "True") then
											<Name>{fn:concat(' (', $StartDate, ' - ', $EndDate, ')')}</Name>
										else 
											<Name>{fn:concat(functx:month-abbrev-en($StartDate),'&apos;',year-from-date($StartDate), ' (', $StartDate, ' - ', $EndDate, ')')}</Name>
				let $Result := ActivityReport:GetGraphData($TermToSearch,$PageLength,$StartPage,$StartDate,$EndDate,$Actions,$TextToSearch)
				return
					(
					<Month>{$MonthName, $Result/*}</Month>,
					xdmp:log("[ IET-TV ][ GetActivity ][ Success ][ Graph data result sent ]")
					)
			}
		</Graph>
	else
		let $Log 			:= xdmp:log("[ IET-TV ][ GetActivity ][ Call ][ Get Activity to call Activity data ]")
		let $TextToSearch 	:= "NONE"
		let $StartDate 		:= xs:date($ActivityXml/Activity/StartDate/text())
		let $EndDate 		:= xs:date($ActivityXml/Activity/EndDate/text())
		let $PageLength 	:= xs:integer($ActivityXml/Activity/PageLength/text())
		let $StartPage 		:= xs:integer($ActivityXml/Activity/StartPage/text())
		let $SortBy         := if($ActivityXml/Activity/SortBy/text()) then $ActivityXml/Activity/SortBy/text() else "NONE"
		return
			(
				ActivityReport:GetActivity($TermToSearch,$PageLength,$StartPage,$StartDate,$EndDate,$Type,$TextToSearch,$SortBy),
				xdmp:log("[ IET-TV ][ GetActivity ][ Success ][ Activity data result sent ]")
			)
