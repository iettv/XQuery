xquery version "1.0-ml";

import module namespace MARC_Constants  = "http://www.TheIET.org/MARCConstants"   at "/MARCUtils/MARCConstants.xqy";

(: 
	To retreive all Download date for given AccountID
:)
(:
<AccountInfo>
<AccountID>Rave1234</AccountID>
<DownloadDate></DownloadDate>
</AccountInfo>
:)

declare variable $inputSearchDetails as xs:string external ;

let $MarcXML		:= xdmp:unquote($inputSearchDetails)
let $AccountID 		:= $MarcXML//AccountID/string()
let $DownloadDate := $MarcXML//DownloadDate//text()
let $AccountIDURI 	:= fn:concat($MARC_Constants:MARC_ADMIN_VIDEO,$AccountID,"/",$DownloadDate,".xml")

return
	if($AccountID)
	then
	(
		if($DownloadDate)
		then
		(
			if( fn:doc-available($AccountIDURI) )
			then 
				fn:doc($AccountIDURI)
			else
			(
				"No Such File Available",
				xdmp:log("*********No Such File Available**********")
			)
		)
		else
		(
			let $AllDownloadDate := for $each in collection(fn:concat($MARC_Constants:MARCACCOUNT_COLLECTION,$AccountID))
									return
									<DownloadDate>{$each/AccountInfo/DownloadDate/text()}</DownloadDate>
													
			return 
			if($AllDownloadDate) 
			then <AccountInfo><AccountID>{$AccountID}</AccountID>{$AllDownloadDate}</AccountInfo> 
			else
			(
				"No Such File Available"
				,
				xdmp:log("*********No Such File Available**********")
			)
		)
	)
	else
	(
		xdmp:log("Account is Empty")
		,
		"AccountID is empty"
	)
