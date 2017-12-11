xquery version "1.0-ml";

import module namespace MARC_Constants  = "http://www.TheIET.org/MARCConstants"   at "/MARCUtils/MARCConstants.xqy";

(: To get Marc AccountID Videos  <MarcVideos><AccountID>TEXT</AccountID></MarcVideos> :)

declare variable $inputSearchDetails as xs:string external;

let $MarcVideo  := xdmp:unquote($inputSearchDetails)
let $AccountID   := $MarcVideo//AccountID/text()

return
	if($AccountID)
	then
	(
		if( fn:doc-available(fn:concat($MARC_Constants:MARC_ADMIN_VIDEO,$AccountID,".xml")) )
		then 
			fn:doc(fn:concat($MARC_Constants:MARC_ADMIN_VIDEO,$AccountID,".xml"))
		else
		(
			"No Such File Available",
			xdmp:log("*********No Such File Available**********")
		)
	)
	else 
	(
		"AccountID is empty"
		,
		xdmp:log("******AccountID is empty*******")
	)
