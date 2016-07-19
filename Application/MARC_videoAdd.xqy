xquery version "1.0-ml";

import module namespace MARC_Constants  = "http://www.TheIET.org/MARCConstants"   at "/MARCUtils/MARCConstants.xqy";

(: 
	Save MarcXML -  Same XQuery is for Update and Insert
:)

declare variable $inputSearchDetails as xs:string external ;

let $MarcXML  		:= xdmp:unquote($inputSearchDetails)
let $MarcVideoID 	:= $MarcXML/*:collection/*:record/*:controlfield[@tag eq "001"]/string()
let $MarcVideoURI 	:= fn:concat($MARC_Constants:MARC_DIRECTORY,$MarcVideoID,".xml")

return
	if($MarcVideoID)
	then
	(
		try
		{(
			xdmp:document-insert($MarcVideoURI,$MarcXML,(),$MARC_Constants:MARCVIDEO_COLLECTION)
			,
			"SUCCESS"
			,
			xdmp:log(concat("[ MarcVideoIngestion ][ SUCCESS ][ MarcVideo has been inserted successfully!!! ID: ",$MarcVideoURI, "]"))
		)}
		catch($e)
		{(
			xdmp:log(concat("[ MarcVideoIngestion ][ ERROR ][ ", $MarcVideoID, " ]"))
			,
			xdmp:log($e)
			,
			"FAIL! Check ML log file for more details."
		)}
	)
	else
	(
		xdmp:log("VideoID is Empty")
		,
		"VideoID is empty"
	)
