xquery version "1.0-ml";

import module namespace constants     = "http://www.TheIET.org/constants"      at "/Utils/constants.xqy"; 
import module namespace CAROUSEL      = "http://www.TheIET.org/ManageCarousel" at "/Utils/ManageCarousel.xqy";

(:~ This service will consume external parameter to evaluate output.
	: @PositionId - The Carousel position where Admin wants to set a Video.
	: @VideoId - VideoID of the Video
	: @Type  - The type value must be MostPopularVideo|LatestVideo|VideoId.
	: @SkipChannel - Keeps Channel ID - Inactive/Private/Staff-Channel so that script may ignore those Channels.
	: <CarouselConfiguration><SkipChannel><ID>1</ID><ID>2</ID><ID>3</ID></SkipChannel><Video><PositionId>11111</PositionId><VideoId>4567</VideoId><Type>VideoId</Type></Video></CarouselConfiguration>
:)

declare variable $inputSearchDetails as xs:string external;

let $CarouselXml  := xdmp:unquote($inputSearchDetails)
let $Log          := xdmp:log("[ CarouselVideoIngestion ][ Call ][ Carousel Set service call successfully!!! ]")
let $SkipChannel  := $CarouselXml/CarouselConfiguration/SkipChannel//text()
return
	if($SkipChannel)
	then
		let $CarouselDirectory := $constants:ADMIN_DIRECTORY
		let $CheckVideoID := CAROUSEL:isVideoIDExists($CarouselXml)
		let $CheckType := CAROUSEL:checkCarouselConfigurationType($CarouselXml)
		let $CheckConfigVideoCount := count($CarouselXml/CarouselConfiguration/Video)
		return
		   (: To check invalid Video ID -- # is the delimiter of invalid Video ID, which are not in ML Database, hide, expired, or not Published videos  :)
		  if( contains($CheckVideoID,'#') or $CheckVideoID!='' )
		  then
			(
			  xdmp:log(("[ CarouselVideoIngestion ][ ERROR ][ Some Video ID(s) does not exists or not a active video ]", $CheckVideoID)),
			  $CheckVideoID
			)
		  else
		  (: To check Type value it should be match to 'MostPopularVideo|LatestVideo|VideoId :)
		  if( $CheckType eq  fn:false() )
		  then
			(
			  xdmp:log(("[ CarouselVideoIngestion ][ ERROR ][ Some provided type does not match with the required. It must be match to 'MostPopularVideo|LatestVideo|VideoId'", $CarouselXml)),
			  "ERROR: SOME PROVIDED TYPE DOES NOT MATCH"
			)
		  else
		  if( $CheckConfigVideoCount lt 18 )
		  then
			(
			  xdmp:log(("[ CarouselVideoIngestion ][ ERROR ][ Needs to provide 18 videos for carousel configuration ]", $CarouselXml)),
			  "ERROR: Please provide 18 videos to set carousel configuration"
			)
		  else
			let $ConfigureCarousel := CAROUSEL:ConfigureCarouselVideos($CarouselXml, "Admin")
			return
				if($ConfigureCarousel != "ERROR")
				then
				  (
					xdmp:document-insert($constants:CarouselFile, $ConfigureCarousel),
					xdmp:log("[ CarouselConfiguration ][ SUCCESS ][ Configuration has been set successfully ]"),
					"SUCCESS"
				  )
				else "ERROR"
	else
		(
			xdmp:log("[ CarouselConfiguration ][ ERROR ][ Skip Channel List is absent. ]"),
			"ERROR: Skip Channel List is absent"
		)