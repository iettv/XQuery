xquery version "1.0-ml";

import module namespace ActivityReport = "http://www.TheIET.org/ActivityReport"   at "ActivityReport.xqy";

(: 
	This service is useful to provide titles for auto suggest on the basis of search combination 
	<Activity><Type>Title</Type><TextToSearch>x</TextToSearch><TermToSearch>User:1 AND Action:Play</TermToSearch><StartDate>2014-10-07</StartDate><EndDate>2015-01-05</EndDate></Activity>
:)

declare variable $inputSearchDetails as xs:string external ; 
let $Log 			:= xdmp:log("[ IET-TV ][ Activity-GetTitles ][ Call ][ To get Activity Titles call ]")
let $ActivityXml	:= xdmp:unquote($inputSearchDetails)
let $Type 			:= $ActivityXml/Activity/Type/text()
let $TermToSearch 	:= $ActivityXml/Activity/TermToSearch/text()
let $TextToSearch 	:= $ActivityXml/Activity/TextToSearch/text()
let $StartDate 		:= if(string-length(xs:string($ActivityXml/Activity/StartDate/text())) gt 1) then xs:date($ActivityXml/Activity/StartDate/text()) else xs:date("2014-10-01")
let $EndDate 		:=  if(string-length(xs:string($ActivityXml/Activity/EndDate/text())) gt 1) then xs:date($ActivityXml/Activity/EndDate/text()) else xs:date(substring(xs:string(fn:current-date()),0,11))
let $PageLength 	:= xs:integer(1000)
let $StartPage 		:= xs:integer(1)
let $SortBy         := if($ActivityXml/Activity/SortBy/text()) then $ActivityXml/Activity/SortBy/text() else "NONE"
return
	if($Type = 'Title')
	then
		let $Result := ActivityReport:GetActivity($TermToSearch,$PageLength,$StartPage,$StartDate,$EndDate,$Type,$TextToSearch,$SortBy)
		return
			(
				<Result>{$Result/Activities/*}</Result>,
				xdmp:log("[ IET-TV ][ Activity-GetTitles ][ Success ][ Activity Titles result sent ]")
			)
	else
		(
			"ERROR! Invalid 'Type' value.",
			xdmp:log("[ IET-TV ][ Activity-GetTitles ][ Error ][ Invalid 'Type' value. ]")
		)