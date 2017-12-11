
xquery version "1.0-ml";

import module namespace ActivityReport = "http://www.TheIET.org/ActivityReport"   at "ActivityReport.xqy";

(: 
	This service is useful to get those Activities where title matches the <TextToSearch> text
	<Activity><Type>ActivityOnTitle</Type><TextToSearch>x</TextToSearch><StartDate>2014-10-09</StartDate><EndDate>2015-01-07</EndDate><PlatformID>IET-TV</PlatformID>
	<StartPage>1</StartPage><PageLength>10</PageLength><AccountTypes></AccountTypes><ChannelId>15</ChannelId><TermToSearch>(((Action:View))) </TermToSearch>
	<SortBy>UserID, Action, Actor, UserIP, UserType, Device, AccountType, CID</SortBy>
	</Activity>
:)

declare variable $inputSearchDetails as xs:string external; 
let $Log 			:= xdmp:log("[ IET-TV ][ GetActivityOnTitles ][ Call ][ Get Activity as per Title call ]")
let $ActivityXml	:= xdmp:unquote($inputSearchDetails)
let $Type 			:= $ActivityXml/Activity/Type/text()
let $TermToSearch 	:= $ActivityXml/Activity/TermToSearch/text()
let $TextToSearch 	:= $ActivityXml/Activity/TextToSearch/text()
let $StartDate 		:= xs:date($ActivityXml/Activity/StartDate/text())
let $EndDate 		:=  xs:date($ActivityXml/Activity/EndDate/text())
let $IsAccountColumn := $ActivityXml/Activity/IsAccountColumn/text()
let $IsUserColumn := $ActivityXml/Activity/IsUserColumn/text()
let $PageLength 	:= if(xs:integer($ActivityXml/Activity/PageLength/text()) eq 0) then xdmp:estimate(fn:collection("IET-TV")) else xs:integer($ActivityXml/Activity/PageLength/text())
let $StartPage 		:= if(xs:integer($ActivityXml/Activity/StartPage/text()) eq 0) then xs:integer(1) else xs:integer($ActivityXml/Activity/StartPage/text())
let $SortBy         := if($ActivityXml/Activity/SortBy/text()) then $ActivityXml/Activity/SortBy/text() else "NONE"
return
	if($Type = 'ActivityOnTitle')
	then
		(
			let $ActivityResult := ActivityReport:GetActivity($TermToSearch,$PageLength,$StartPage,$StartDate,$EndDate,$Type,$TextToSearch,$SortBy)
			return 
			<root>
				
				{
							for $Activity in $ActivityResult/Activities/Activity
							let $AdditionalInfo := $Activity/Action/AdditionalInfo
							let $Actor := $Activity/Actor
							let $IsAccountColumn := if($IsAccountColumn eq "True") then <Account>{$Activity/Actor/CorporateAccountName/text()}</Account> else ()
							let $IsUserColumn := if($IsUserColumn eq "True") then <User>{$Actor/UserName/text()}</User> else ()
							return
																
							<row>
								{$IsAccountColumn, $IsUserColumn}														
								<Activity>{$Activity/Action/Type/text()}</Activity>
								<Date>{$Activity/ActivityDate/text()}</Date>
								<Title>{$AdditionalInfo/NameValue[Name='VideoTitle']/Value/text()}</Title>
								<Type>{$AdditionalInfo/NameValue[Name='SubscriptionType']/Value/text()}</Type>
								<Length>{$AdditionalInfo/NameValue[Name='Duration']/Value/text()}</Length>
								<PlayDuration>{$AdditionalInfo/NameValue[Name='VideoLength']/Value/text()}</PlayDuration>
								<Attachment>{$AdditionalInfo/NameValue[Name='VideoAttachment']/Value/text()}</Attachment>
								<Device>{$Actor/Device/text()}</Device>													
							</row>
				}
	
		</root>,
			xdmp:log("[ IET-TV ][ GetActivityOnTitles ][ Success ][ Get Activity as per Title result sent ]")
		)
	else
		(
			"ERROR! Invalid 'Type' value.",
			xdmp:log("[ IET-TV ][ GetActivityOnTitles ][ Error ][ Invalid 'Type' value. ]")
		)
