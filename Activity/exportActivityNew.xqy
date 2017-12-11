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
	  </w:document>
		,
		xdmp:log("[ IET-TV ][ GetAllActivity ][ Success ][ Get All Activity result sent ]") 
	)