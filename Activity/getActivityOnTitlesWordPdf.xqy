
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
			
			<w:document xmlns:w='http://schemas.openxmlformats.org/wordprocessingml/2006/main'>
				<w:body>
					<w:tbl>	
					 <w:tblPr>
					<w:tblBorders>
								<w:top w:val="thick" w:color="505050" />
								<w:bottom w:val="thick" w:color="505050" />
								<w:right w:val="thick" w:color="505050" />
								<w:left w:val="thick" w:color="505050" />
								<w:insideH w:val="thick" w:color="505050" />
								<w:insideV w:val="thick" w:color="505050" />
							</w:tblBorders>							
							<w:rPr><w:rFonts w:ascii="Times New Roman" /><w:b /><w:sz w:val="16" /></w:rPr>
							</w:tblPr>
							<w:tcPr><w:shd w:val="clear" w:color="auto" w:fill="505050" /><w:gridSpan w:val="15" /></w:tcPr>

							<w:tblPr><w:tblLayout w:type="fixed" /></w:tblPr><w:tblGrid><w:gridCol w="125" /><w:gridCol w="125" /><w:gridCol w="125" /><w:gridCol w="125" /><w:gridCol w="125" /><w:gridCol w="125" /><w:gridCol w="125" /><w:gridCol w="125" /><w:gridCol w="125" /><w:gridCol w="125" /><w:gridCol w="125" /><w:gridCol w="125" /><w:gridCol w="125" /><w:gridCol w="125" /><w:gridCol w="125" /><w:gridCol w="125" /><w:gridCol w="125" /><w:gridCol w="125" /><w:gridCol w="125" /><w:gridCol w="125" /><w:gridCol w="125" /><w:gridCol w="125" /><w:gridCol w="125" /><w:gridCol w="125" /><w:gridCol w="125" /><w:gridCol w="125" /><w:gridCol w="125" /><w:gridCol w="125" /><w:gridCol w="125" /><w:gridCol w="125" /><w:gridCol w="125" /><w:gridCol w="125" /><w:gridCol w="125" /><w:gridCol w="125" /><w:gridCol w="125" /><w:gridCol w="125" /><w:gridCol w="125" /><w:gridCol w="125" /><w:gridCol w="125" /><w:gridCol w="125" /><w:gridCol w="125" /><w:gridCol w="125" /><w:gridCol w="125" /><w:gridCol w="125" /><w:gridCol w="125" /><w:gridCol w="125" /><w:gridCol w="125" /><w:gridCol w="125" /><w:gridCol w="125" /><w:gridCol w="125" /><w:gridCol w="125" /><w:gridCol w="125" /><w:gridCol w="125" /><w:gridCol w="125" /><w:gridCol w="125" /><w:gridCol w="125" /><w:gridCol w="125" /><w:gridCol w="125" /><w:gridCol w="125" /><w:gridCol w="125" /><w:gridCol w="125" /><w:gridCol w="125" /><w:gridCol w="125" /><w:gridCol w="125" /><w:gridCol w="125" /><w:gridCol w="125" /><w:gridCol w="125" /><w:gridCol w="125" /><w:gridCol w="125" /><w:gridCol w="125" /><w:gridCol w="125" /><w:gridCol w="125" /><w:gridCol w="125" /><w:gridCol w="125" /><w:gridCol w="125" /><w:gridCol w="125" /><w:gridCol w="125" /><w:gridCol w="125" /><w:gridCol w="125" /><w:gridCol w="125" /><w:gridCol w="125" /><w:gridCol w="125" /><w:gridCol w="125" /><w:gridCol w="125" /></w:tblGrid>		
						
						<w:tr>
						{
						if($IsAccountColumn eq "True") then <w:tc><w:p><w:rPr><w:t>Account</w:t></w:rPr></w:p><w:tcPr><w:shd w:val="clear" w:color="auto" w:fill="D4D4D4" /><w:gridSpan w:val="12" /></w:tcPr></w:tc> else ()
						}
						{
						if($IsUserColumn eq "True") then <w:tc><w:p><w:rPr><w:t>User</w:t></w:rPr></w:p><w:tcPr><w:shd w:val="clear" w:color="auto" w:fill="D4D4D4" /><w:gridSpan w:val="12" /></w:tcPr></w:tc> else ()
						}
						<w:tc><w:p><w:rPr><w:t>Activity</w:t></w:rPr></w:p><w:tcPr><w:shd w:val="clear" w:color="auto" w:fill="D4D4D4" /><w:gridSpan w:val="11" /></w:tcPr></w:tc>
						<w:tc><w:p><w:rPr><w:t>Date</w:t></w:rPr></w:p><w:tcPr><w:shd w:val="clear" w:color="auto" w:fill="D4D4D4" /><w:gridSpan w:val="8" /></w:tcPr></w:tc>
						<w:tc><w:p><w:rPr><w:t>Title</w:t></w:rPr></w:p><w:tcPr><w:shd w:val="clear" w:color="auto" w:fill="D4D4D4" /><w:gridSpan w:val="14" /></w:tcPr></w:tc>
						<w:tc><w:p><w:rPr><w:t>Type</w:t></w:rPr></w:p><w:tcPr><w:shd w:val="clear" w:color="auto" w:fill="D4D4D4" /><w:gridSpan w:val="9" /></w:tcPr></w:tc>
						<w:tc><w:p><w:rPr><w:t>Length</w:t></w:rPr></w:p><w:tcPr><w:shd w:val="clear" w:color="auto" w:fill="D4D4D4" /><w:gridSpan w:val="9" /></w:tcPr></w:tc>
						<w:tc><w:p><w:rPr><w:t>Play Duration</w:t></w:rPr></w:p><w:tcPr><w:shd w:val="clear" w:color="auto" w:fill="D4D4D4" /><w:gridSpan w:val="11" /></w:tcPr></w:tc>
						<w:tc><w:p><w:rPr><w:t>Attachment</w:t></w:rPr></w:p><w:tcPr><w:shd w:val="clear" w:color="auto" w:fill="D4D4D4" /><w:gridSpan w:val="10" /></w:tcPr></w:tc>
						<w:tc><w:p><w:rPr><w:t>Device</w:t></w:rPr></w:p><w:tcPr><w:shd w:val="clear" w:color="auto" w:fill="D4D4D4" /><w:gridSpan w:val="9" /></w:tcPr></w:tc></w:tr>
						
						{
							for $Activity in $ActivityResult/Activities/Activity
							let $AdditionalInfo := $Activity/Action/AdditionalInfo
							let $Actor := $Activity/Actor	
							let $IsAccountColumn := if($IsAccountColumn eq "True") then <w:tc><w:p><w:rPr><w:t>{$Activity/Actor/CorporateAccountName/text()}</w:t></w:rPr></w:p><w:tcPr><w:gridSpan w:val="12" /></w:tcPr></w:tc> else ()
							let $IsUserColumn := if($IsUserColumn eq "True") then <w:tc><w:p><w:rPr><w:t>{$Actor/UserName/text()}</w:t></w:rPr></w:p><w:tcPr><w:gridSpan w:val="12" /></w:tcPr></w:tc> else ()
							return
																
								
								<w:tr>{$IsAccountColumn, $IsUserColumn}							
								<w:tc><w:p><w:rPr><w:t>{$Activity/Action/Type/text()}</w:t></w:rPr></w:p><w:tcPr><w:gridSpan w:val="11" /></w:tcPr></w:tc>
								<w:tc><w:p><w:rPr><w:t>{$Activity/ActivityDate/text()}</w:t></w:rPr></w:p><w:tcPr><w:gridSpan w:val="8" /></w:tcPr></w:tc>
								<w:tc><w:p><w:rPr><w:t>{$AdditionalInfo/NameValue[Name='VideoTitle']/Value/text()}</w:t></w:rPr></w:p><w:tcPr><w:gridSpan w:val="14" /></w:tcPr></w:tc>
								<w:tc><w:p><w:rPr><w:t>{$AdditionalInfo/NameValue[Name='SubscriptionType']/Value/text()}</w:t></w:rPr></w:p><w:tcPr><w:gridSpan w:val="9" /></w:tcPr></w:tc>
								<w:tc><w:p><w:rPr><w:t>{$AdditionalInfo/NameValue[Name='Duration']/Value/text()}</w:t></w:rPr></w:p><w:tcPr><w:gridSpan w:val="9" /></w:tcPr></w:tc>
								<w:tc><w:p><w:rPr><w:t>{$AdditionalInfo/NameValue[Name='VideoLength']/Value/text()}</w:t></w:rPr></w:p><w:tcPr><w:gridSpan w:val="11" /></w:tcPr></w:tc>
								<w:tc><w:p><w:rPr><w:t>{$AdditionalInfo/NameValue[Name='VideoAttachment']/Value/text()}</w:t></w:rPr></w:p><w:tcPr><w:gridSpan w:val="10" /></w:tcPr></w:tc>
								<w:tc><w:p><w:rPr><w:t>{$Actor/Device/text()}</w:t></w:rPr></w:p><w:tcPr><w:gridSpan w:val="9" /></w:tcPr></w:tc></w:tr>													
								
				}
					</w:tbl>
				</w:body>
			</w:document>,
			xdmp:log("[ IET-TV ][ GetActivityOnTitles ][ Success ][ Get Activity as per Title result sent ]")
		)
	else
		(
			"ERROR! Invalid 'Type' value.",
			xdmp:log("[ IET-TV ][ GetActivityOnTitles ][ Error ][ Invalid 'Type' value. ]")
		)
