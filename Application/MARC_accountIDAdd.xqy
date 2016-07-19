xquery version "1.0-ml";

import module namespace MARC_Constants  = "http://www.TheIET.org/MARCConstants"   at "/MARCUtils/MARCConstants.xqy";

(: 
	Save Video IDs Where MARC XML downloaded lastime -  Same XQuery is for Update and Insert
:)
(:
<AccountInfo>
<AccountID>Rave1234</AccountID>
<DownloadDate>2002-05-30T05:30:00</DownloadDate>
<Videos>
<VideoID>1234</VideoID>
<VideoID>5678</VideoID>
</Videos>
</AccountInfo>
:)

declare variable $inputSearchDetails as xs:string external ;

let $MarcXML		:= xdmp:unquote($inputSearchDetails)
let $AccountID 		:= $MarcXML//AccountID/string()
let $DownloadDate := $MarcXML//DownloadDate/text()
let $AccountIDURI 	:= fn:concat($MARC_Constants:MARC_ADMIN_VIDEO,$AccountID,"/",$DownloadDate,".xml")

return
	if($AccountID)
	then
	(
		try
		{(
			xdmp:document-insert($AccountIDURI,$MarcXML,(),fn:concat($MARC_Constants:MARCACCOUNT_COLLECTION,$AccountID))
			,
			"SUCCESS"
			,
			xdmp:log(concat("[  AccountID ][ SUCCESS ][ AccountID  has been inserted/updated successfully!!! ID: ",$AccountIDURI, "]"))
		)}
		catch($e)
		{(
			xdmp:log(concat("[ AccountID ][ ERROR ][ ", $AccountID, " ]"))
			,
			xdmp:log($e)
			,
			"FAIL! Check ML log file for more details."
		)}
	)
	else
	(
		xdmp:log("Account is Empty")
		,
		"AccountID is empty"
	)
