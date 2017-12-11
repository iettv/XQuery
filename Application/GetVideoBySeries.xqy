xquery version "1.0-ml";

import module namespace VIDEOS = "http://www.TheIET.org/ManageVideos"   at  "/Utils/ManageVideos.xqy";
(:
	: @SkipChannel  - Keeps Channel ID - Private/Staff-Channel so that script may ignore those Channels from search. And if any log in user has access on
	:                 Private Channel, it must be excluded from the list. And front-end team will exclude this when call this function.
	:                 If there is no Private/Staff-Channel, it must be <SkipChannel>NONE</SkipChannel>
	:
	: <Root><SkipChannel><ID>1</ID><ID>2</ID><ID>3</ID></SkipChannel><Series>SeriesID:55</Series><PageLength>10</PageLength><StartPage>1</StartPage><SortBy>Recent</SortBy></Root>

:)
declare variable $inputSearchDetails as xs:string external;
 
let $InputXML  	:= xdmp:unquote($inputSearchDetails)
let $Log 		:= xdmp:log("[ IET-TV ][ VideoBySeries ][ Call ][ Service call ]") 
let $SeriesID 	:= $InputXML/Root/Series/text()
let $StartPage 	:= xs:integer($InputXML/Root/StartPage/text())
let $PageLength := xs:integer($InputXML/Root/PageLength/text())
let $SortBy 	:= $InputXML/Root/SortBy/text()
let $SkipChannel  := $InputXML/Root/SkipChannel
return
	if( not($SkipChannel//text()) )
	then
	(
	  xdmp:log(concat("[ IET-TV ][ VideoBySeries ][ ERROR ][ Invalid skip channel list - SkipChannel : ", $SkipChannel, " ]")),
	  "ERROR! Please provide skip channel list. Currently it is empty."
	)
	else 
	if($SeriesID)
	then
		VIDEOS:GetVideoBySeries($SkipChannel,$SeriesID,$StartPage,$PageLength,$SortBy) 
	else
	(
	  xdmp:log(concat("[ IET-TV ][ VideoBySeries ][ ERROR ][ Invalid Series ID - SeriesID : ", $SeriesID, " ]")),
	  "SeriesID is empty"
	)	