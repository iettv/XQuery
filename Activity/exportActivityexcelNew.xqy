import module namespace ActivityReport = "http://www.TheIET.org/ActivityReport"   at "ActivityReport.xqy";
(: let $InputXML := ActivityReport:GetActivity("CID:20",10,1,xs:date("2014-12-01"),xs:date("2015-02-02")," "," "," ") :)

declare variable $inputSearchDetails as xs:string external;
let $Log 			:= xdmp:log("[ IET-TV ][ GetAllActivity ][ Call ][ Get All Activity call ]") 
let $ActivityXml  	:= xdmp:unquote($inputSearchDetails)
let $TermToSearch 	:= $ActivityXml/Activity/TermToSearch/text()
let $TextToSearch 	:= "NONE"
let $Type 			:= if($ActivityXml/Activity/Type/text()="Graph") then "Graph" else "NONE"
let $Actions        := $ActivityXml/Activity/Action/text()
let $StartDate 		:= xs:date($ActivityXml/Activity/StartDate/text())
let $EndDate 		:= xs:date($ActivityXml/Activity/EndDate/text())
let $PageLength 	:= xs:integer($ActivityXml/Activity/PageLength/text())
let $StartPage 		:= xs:integer($ActivityXml/Activity/StartPage/text())
let $IsAccountColumn := $ActivityXml/Activity/IsAccountColumn/text()
let $IsUserColumn := $ActivityXml/Activity/IsUserColumn/text()
let $SortBy         := if($ActivityXml/Activity/SortBy/text()) then $ActivityXml/Activity/SortBy/text() else "NONE"
let $TotalRecord 	:=  xdmp:estimate(fn:collection("IET-TV")) 
let $ActivityResult := ActivityReport:GetActivity($TermToSearch,$TotalRecord,1,$StartDate,$EndDate,$Type,$TextToSearch,$SortBy)
return
	(	
	
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
	
		</root>
		,
		xdmp:log("[ IET-TV ][ GetAllActivity ][ Success ][ Get All Activity result sent ]") 
	)