xquery version "1.0-ml";

import module namespace common = "http://www.TheIET.org/common"     at  "/Utils/common.xqy";
import module namespace c      = "http://www.TheIET.org/constants"  at  "/Utils/constants.xqy";

declare variable $VideoID as xs:string external;

let $VideoXML := fn:doc( fn:concat($c:VIDEO_DIRECTORY, $VideoID, ".xml") )
return
	try
	{
		common:ConvertToJson($VideoXML),
		xdmp:log("[ IET-TV ][ GetVideo ][ Success ][ Videos get successfully in JSON format!!! ]")
	}
	catch($e)
	{
		xdmp:log(concat("[ IET-TV ][ GetVideo ][ Error ][ Please check 'VideoID' ][ ", $VideoID, ' ]')),
		"ERROR: No video is available"
	}