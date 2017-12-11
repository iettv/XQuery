xquery version "1.0-ml";

import module namespace constants = "http://www.TheIET.org/constants"   at "/Utils/constants.xqy"; 

(: 
 :	This service is to list of Private/Public/Staff Channel list from front-end and put it into MarLogic instance
 :	so that when Common Carousel Scheduler will run, we may skip those videos which are associated with these Channel ID(s).
 :	@SkipChannel - Keeps Channel ID - Inactive/Private/Staff-Channel so that script may ignore those Channels.
 :
 : <SkipChannel><ID>1</ID><ID>2</ID><ID>3</ID></SkipChannel>
:)

declare variable $inputSearchDetails as xs:string external;
let $Log         := xdmp:log("[ SkipChannel ][ CALL ][ Ingest Skip Channel service called ]")
let $SkipChannel := xdmp:unquote($inputSearchDetails)
return
	try
	{(
		xdmp:document-insert($constants:SkipChannelUri, $SkipChannel)
	)}
	catch($e)
	{(
		xdmp:log("[ SkipChannel ][ ERROR ][ Ingest Skip Channel service error ]"),
		xdmp:log($e),
		"ERROR"
	)}
