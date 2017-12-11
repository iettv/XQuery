xquery version "1.0-ml";

import module namespace VIDEOS    = "http://www.TheIET.org/ManageVideos"   at  "/Utils/ManageVideos.xqy";
import module namespace constants = "http://www.TheIET.org/constants"      at  "/Utils/constants.xqy";

(: To get Series by Video Number:

	<VideoNumber>100</VideoNumber>
:)
declare variable $inputSearchDetails as xs:string external;
 
let $InputXML  	:= xdmp:unquote($inputSearchDetails)
let $Log 		:= xdmp:log("[ IET-TV ][ GetSeriesByVideoNumber ][ Call ][ Service call ]") 
let $VideoNumber  := $InputXML//text()
return
	if( not($VideoNumber) )
	then
	(
	  xdmp:log(concat("[ IET-TV ][ GetSeriesByVideoNumber ][ ERROR ][ Empty Video Number - VideoNumber : ", $VideoNumber, " ]")),
	  "ERROR! Please provide Video Number. Currently it is empty."
	)
	else
		let $Video := VIDEOS:GetVideoIdByVideoNumber($VideoNumber)
		return
			if($Video)
			then
				let $Series := doc(fn:concat($constants:PCOPY_DIRECTORY,$Video,".xml"))/Video/SeriesList
				return if($Series) then $Series else <SeriesList>No Series available!!!</SeriesList>
			else
			(
			  xdmp:log(concat("[ IET-TV ][ GetSeriesByVideoNumber ][ ERROR ][ Invalid Video Number : ", $VideoNumber, " ]")),
			  "ERROR! Invalid Video Number."
			)