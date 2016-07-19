xquery version "1.0-ml";
import module namespace VIDEOS = "http://www.TheIET.org/ManageVideos"   at  "/Utils/ManageVideos.xqy";

(:
	: @SkipChannel  - Keeps Channel ID - Private/Staff-Channel so that script may ignore those Channels from search. And if any log in user has access on
	:                 Private Channel, it must be excluded from the list. And front-end team will exclude this when call this function.
	:                 If there is no Private/Staff-Channel, it must be <SkipChannel>NONE</SkipChannel>
	:
	: <Events><SkipChannel><ID>1</ID><ID>2</ID><ID>3</ID></SkipChannel><EventID>18</EventID><StartDate>2015-01-02T00:00:00.0000</StartDate><EndDate>2015-01-02T23:59:59.0000</EndDate></Events>
:)

declare variable $inputSearchDetails as xs:string external; 

let $InputXML	:= xdmp:unquote($inputSearchDetails)
let $Log  		:= xdmp:log("[ IET-TV ][ GetVideoDetailByEvent ][ Call ][ Service call ]")
let $EventID 	:= $InputXML/Events/EventID/text()
let $StartDate 	:= $InputXML/Events/StartDate/text()
let $EndDate 	:= $InputXML/Events/EndDate/text()
let $SkipChannel  := $InputXML/Events/SkipChannel
return
	if( not($SkipChannel//text()) )
	then
	(
	  xdmp:log(concat("[ IET-TV ][ GetVideoDetailByEvent ][ ERROR ][ Invalid skip channel list - SkipChannel : ", $SkipChannel, " ]")),
	  "ERROR! Please provide skip channel list. Currently it is empty."
	)
	else
	if(not($EventID))
	then
		(
			"EventID is empty",
			xdmp:log("[ IET-TV ][ GetVideoDetailByEvent ][ INFO ][ Parameter of EventID is empty ]")
		)
	else
	if(not($StartDate))
	then
		(
			"StartDate is empty",
			xdmp:log("[ IET-TV ][ GetVideoDetailByEvent ][ INFO ][ Parameter of StartDate is empty ]")
		)
	else	
	if(not($EndDate))
	then
		(
			"EndDate is empty",
			xdmp:log("[ IET-TV ][ GetVideoDetailByEvent ][ INFO ][ Parameter of EndDate is empty ]")
		)
	else
		(
			<EventDetails>{VIDEOS:GetVideoDetailsByEvent($SkipChannel,$EventID,$StartDate,$EndDate)}</EventDetails>,
			xdmp:log("[ IET-TV ][ GetVideoDetailByEvent ][ Success ][ Service result sent ]")
		)