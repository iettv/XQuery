xquery version "1.0-ml";

module namespace CAROUSEL = "http://www.TheIET.org/ManageCarousel";

import module namespace VIDEOS     = "http://www.TheIET.org/ManageVideos" at  "/Utils/ManageVideos.xqy";
import module namespace constants  = "http://www.TheIET.org/constants"    at  "/Utils/constants.xqy";
import module namespace mem        = "http://xqdev.com/in-mem-update"     at  "/MarkLogic/appservices/utils/in-mem-update.xqy";

(:<CarouselConfiguration><Video><PositionId>1</PositionId><VideoId>11111</VideoId><Type>VideoId</Type></Video><Video><PositionId>2</PositionId><VideoId>0</VideoId><Type>LatestVideo</Type></Video>-<Video><PositionId>3</PositionId><VideoId>0</VideoId><Type>MostPopularVideo</Type></Video></CarouselConfiguration> :)

declare function checkCarouselConfigurationType($CarouselXml as item())
{
  let $CheckVideoType :=  for $VideoType in $CarouselXml/CarouselConfiguration/Video/Type/text()
                          return
                           if( $VideoType = 'MostPopularVideo' or $VideoType = 'VideoId' or $VideoType ='LatestVideo' ) then fn:true() else fn:false()
  return
    if( $CheckVideoType eq fn:false() )
    then fn:false()
    else fn:true()
};


declare function checkVideoIDPresent($UpdatedCarouselXml as item())
{
  let $CheckID := for $VideoID in $UpdatedCarouselXml//VideoId return if(string-length($VideoID) ge 1) then fn:true() else fn:false()
  return
    if($CheckID eq fn:false()) then "ERROR" else "SUCCESS"
};


declare function isVideoIDExists($CarouselXml as item()) (: 11111#3333 :)
{
	let $Result := string-join(
							   for $VideoID in $CarouselXml//Video/VideoId[.!='']
							   let $Position := $VideoID/preceding-sibling::PositionId/text()
							   let $VideoDoc := fn:doc(concat($constants:PCOPY_DIRECTORY ,$VideoID/text(),'.xml'))
							   let $IsVideoAvailable := doc-available(concat($constants:PCOPY_DIRECTORY ,$VideoID/text(),'.xml'))
							   let $IsVideoActive := if($VideoDoc/Video/PublishInfo/VideoPublish/@active/string() = "yes") then VIDEOS:isVideoActive($VideoDoc) else VIDEOS:isLiveVideoActive($VideoDoc)
							   return
									if($IsVideoAvailable eq fn:false() or $IsVideoActive eq fn:false()) then $Position else ()
							  ,"#")
	return $Result
};

declare function VideoIDList($CarouselXml as item())
{
let $VideoIDList := for $VideoID in $CarouselXml//Video[Type='VideoId']/VideoId[.!=''] return concat($VideoID,"")
let $VideoIDList := fn:string-join($VideoIDList, " ")
return $VideoIDList
};

declare function ConfigureCarouselVideos($CarouselXml as item(), $Flag as xs:string) (: $Flag: Admin/Scheduler:)
{
	let $UpdatedCarouselVideoWithID := $CarouselXml
	let $SkipChannel  := $CarouselXml/CarouselConfiguration/SkipChannel
	let $CurrentMostPopularList := if($Flag='Scheduler') then VIDEOS:GeneratePopularListAndGetPopularIdByCount($SkipChannel,25) else VIDEOS:GetVideoPopularByCount(25)
	let $LatestVideoList := VIDEOS:GenerateLatestListAndGetLatestIdByCount($SkipChannel,25)
	let $VideoIDList := ""
	let $ForthComingVideos := VIDEOS:GenerateForthComingList($SkipChannel)
	let $ProcessToUpdagteCarouselXml := for $VideoFile  at $Pos in  $CarouselXml//Video
										let $Log  := xdmp:log(fn:concat("[ VideoTypeText ][ ", $VideoFile/Type/text(), " ]"))
										return
										(: To set Carousel configuration for those video where VideoID is provided :)
										if( $VideoFile/Type/text() eq "VideoId" )
										then 
											let $VideoID := $VideoFile/VideoId/text()
											let $VideoUri := concat($constants:PCOPY_DIRECTORY ,$VideoID,'.xml')
											let $IsVideoAvailable := doc-available($VideoUri)
											let $VideoDoc := doc($VideoUri)
											let $IsVideoActive := if($VideoDoc/Video/PublishInfo/VideoPublish/@active/string() = "yes") then VIDEOS:isVideoActive($VideoDoc) else VIDEOS:isLiveVideoActive($VideoDoc)
											let $IsSkipChannelVideo  := VIDEOS:isVideoRelatedToSkipChannel($SkipChannel,$VideoDoc)
											return
												if(($IsSkipChannelVideo eq fn:true()) or ($IsVideoAvailable eq fn:false()) or ($IsVideoActive eq fn:false()))
												then xdmp:set($UpdatedCarouselVideoWithID, mem:node-replace($UpdatedCarouselVideoWithID/CarouselConfiguration/Video[$Pos]/VideoId, <VideoId>This video is not active </VideoId>))
												else xdmp:set($VideoIDList, concat($VideoIDList, " ",$VideoID))
										else
										(: To set Carousel configuration for those video where Type=LatestVideo :)
										if( $VideoFile/Type/text() eq "LatestVideo" )
										then
											let $set := fn:true()
											return
												if(count($LatestVideoList/VideoID) eq 0)
												then
													xdmp:set($UpdatedCarouselVideoWithID, mem:node-replace($UpdatedCarouselVideoWithID/CarouselConfiguration/Video[$Pos]/VideoId, <VideoId>Latest Video is unavailable</VideoId>))
												else
													(
														for $EachLatestVideoID in $LatestVideoList/VideoID/string()
														return
															if(not($EachLatestVideoID) and ($set))
															then 
																(
																	xdmp:set($UpdatedCarouselVideoWithID, mem:node-replace($UpdatedCarouselVideoWithID/CarouselConfiguration/Video[$Pos]/VideoId, <VideoId>Latest Video is unavailable</VideoId>)),
																	xdmp:set($set,fn:false())
																)
															else
															if(not(fn:contains($VideoIDList,$EachLatestVideoID)) and ($set))
															then
															  (
																  xdmp:set($VideoIDList, concat($VideoIDList, " ",$EachLatestVideoID)),
																  xdmp:set($set,fn:false()),
																  xdmp:set($UpdatedCarouselVideoWithID, mem:node-replace($UpdatedCarouselVideoWithID/CarouselConfiguration/Video[$Pos]/VideoId, <VideoId>{$EachLatestVideoID}</VideoId>))
															  )
															else ()
													)
										else
										(: To set Carousel configuration for those video where Type=MostPopularVideo :)
										if( $VideoFile/Type/text() eq "MostPopularVideo" )
										then
												if(count($CurrentMostPopularList/VideoID) eq 0)
												then
													xdmp:set($UpdatedCarouselVideoWithID, mem:node-replace($UpdatedCarouselVideoWithID/CarouselConfiguration/Video[$Pos]/VideoId, <VideoId>Popular Video is unavailable</VideoId>))
												else
													(
														let $EachPopularVideoID := (for $x in $CurrentMostPopularList/VideoID/string()
														                           return if( not(fn:contains($VideoIDList,$x)) ) then $x else ())[1]
														return
															if( not($EachPopularVideoID) )
															then
																xdmp:set($UpdatedCarouselVideoWithID, mem:node-replace($UpdatedCarouselVideoWithID/CarouselConfiguration/Video[$Pos]/VideoId, <VideoId>Popular Video is unavailable</VideoId>))
															else
															if( not(fn:contains($VideoIDList,$EachPopularVideoID)) )
															then
															  (
																  xdmp:set($VideoIDList, concat($VideoIDList, " ",$EachPopularVideoID)),
																  xdmp:set($UpdatedCarouselVideoWithID, mem:node-replace($UpdatedCarouselVideoWithID/CarouselConfiguration/Video[$Pos]/VideoId, <VideoId>{$EachPopularVideoID}</VideoId>))
															  )
															else ()
													)
										  else
											xdmp:log(concat("[ CarouselVideoReading ][ ERROR ][ Type value must be match to 'MostPopularVideo|LatestVideo|VideoId][ Currently it is :", $VideoFile/Type/text(), ' ]'))
											return
	  (: This validation is finally to check that whenever we are committing carousel XML in ML it must contain all the video ID to set :)
	  if( checkVideoIDPresent($UpdatedCarouselVideoWithID) = "SUCCESS" )
	  then $UpdatedCarouselVideoWithID
	  else
	  (
		xdmp:log("[ CarouselConfiguration ][ ERROR ][ Some Video ID is not present to set configuration ]")
		,
		"ERROR"
	  )
};


declare function GetVideoCarousel( $carouselCount as xs:integer)
{
   if( fn:doc-available($constants:CarouselFile) )
   then
    <Carousel>
      {
        for $EachVideo in fn:doc($constants:CarouselFile)//Video
		let $VideoID := $EachVideo/VideoId/text()
		return
			if( contains($VideoID, 'unavailable') )
			then <Video>{$VideoID}</Video>
			else
			if( contains($VideoID, 'not active') )
			then <Video>{$VideoID}</Video>
			else
				let $VideoXML := fn:doc(fn:concat($constants:PCOPY_DIRECTORY , $VideoID, '.xml'))
				let $VideoDetails := VIDEOS:GetVideoElementForHomePage($VideoXML/Video)
				return
				(: in case when video is not available into published collection // hide video :)
				if($VideoDetails) then $VideoDetails  else <Video>Video is unavailable</Video>
      }
    </Carousel>
   else ( xdmp:log("[ CarouselConfig ][ No configuration file is available to send ]"), "ERROR")
};


