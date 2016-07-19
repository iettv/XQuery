xquery version "1.0-ml";

module namespace CHANNEL = "http://www.TheIET.org/ManageChannel";

import module namespace VIDEOS     = "http://www.TheIET.org/ManageVideos" at  "/Utils/ManageVideos.xqy";
import module namespace constants  = "http://www.TheIET.org/constants"    at  "/Utils/constants.xqy";
import module namespace mem        = "http://xqdev.com/in-mem-update"     at  "/MarkLogic/appservices/utils/in-mem-update.xqy";
import module namespace admin      = "http://marklogic.com/xdmp/admin"    at  "/MarkLogic/admin.xqy";

(: These function are to validate incoming channel configuration :) 

declare function isVideoIDExists($ChannelXml as item(), $ChannelID) (: 11111#3333 :)
{
let $Result := string-join(
                           for $VideoID in $ChannelXml/ChannelConfiguration/Channel[Type='VideoId']/VideoId[.!='']
                           let $Position := $VideoID/preceding-sibling::PositionId/text()
                           let $IsVideoAvailable := doc-available(concat($constants:PCOPY_DIRECTORY ,$VideoID/text(),'.xml'))
						   let $VideoXml := fn:doc(concat($constants:PCOPY_DIRECTORY ,$VideoID/text(),'.xml'))
                           let $IsRelatedToChannel := if($VideoXml/Video[BasicInfo/ChannelMapping/Channel[@ID=$ChannelID]])
													  then fn:true() else fn:false()
						   let $IsVideoActive := if($VideoXml/Video/PublishInfo/VideoPublish/@active/string() = "yes") then VIDEOS:isVideoActive($VideoXml) else VIDEOS:isLiveVideoActive($VideoXml)
                           return
                                if( ($IsVideoAvailable eq fn:false()) or ($IsRelatedToChannel eq fn:false()) or ($IsVideoActive eq fn:false()) ) then $Position else ()
                          ,"#")
return $Result
};

declare function checkChannelConfigurationType($ChannelXml as item())
{
  let $CheckVideoType :=  for $VideoType in $ChannelXml/ChannelConfiguration/Channel/Type/text()
                          return
                           if( $VideoType = 'MostPopularVideo' or $VideoType = 'VideoId' or $VideoType ='LatestVideo' ) then fn:true() else fn:false()
  return
    if( $CheckVideoType eq fn:false() )
    then fn:false()
    else fn:true()
};


(: These function are to upload channel landing page :)
declare function getChannelMostPopular($ChannelID, $PopularCount as xs:integer)
{
	let $MostPopularXml := 	GetChannelMostPopularFile($ChannelID)
	let $PopularVideos := 	<Videos>
								{
									(
										for $CurrentVideo in $MostPopularXml//Video
										let $VideoID := $CurrentVideo/VideoID/string()
										let $VideoDoc := fn:doc(concat($constants:PCOPY_DIRECTORY , $VideoID, ".xml"))
										let $isVideoActive := if($VideoDoc/Video/PublishInfo/VideoPublish/@active/string() = "yes") then VIDEOS:isVideoActive($VideoDoc) else VIDEOS:isLiveVideoActive($VideoDoc)
										return
											if( $isVideoActive != fn:false() )
											then
												VIDEOS:GetVideoElementForHomePage($VideoDoc/Video)
											else ""
									)[position() le xs:integer($PopularCount)]
								}
							</Videos>
	let $FilterPopulrVideo := 	for $VideoCount in (1 to $PopularCount)
								let $CurrentVideo := $PopularVideos//Video[$VideoCount]
								return
									if($CurrentVideo)
									then $CurrentVideo
									else <Video>Popular Video is unavailable</Video>
	return
		<MostPopular>{$FilterPopulrVideo}</MostPopular>
};

declare function getChannelPopularByCount($PopularCount as xs:integer,$ChannelID)
{
	let $MostPopularXml := 	GetChannelMostPopularFile($ChannelID)
	let $PopularVideos := 	<ChannelMostPopular>
								{
									(
										for $CurrentVideo in $MostPopularXml//Video
										return	<VideoID>{$CurrentVideo/VideoID/string()}</VideoID>
									)[position() le xs:integer($PopularCount)]
								}
							</ChannelMostPopular>
	return	$PopularVideos
};


declare function getChannelMostPopularByCount($ChannelID, $PopularCount as xs:integer)
{
	let $MostPopularXml := 	CHANNEL:GetChannelMostPopularFile($ChannelID)
	let $TotalPopularCount:= count($MostPopularXml//Video)
	return
		if($TotalPopularCount eq xs:integer(0))
		then
			(
				let $Videos := 	<Videos>
							   {
								  (
									  let $LatestXmlFile := fn:doc(fn:concat($constants:ChannelLatest, $ChannelID, ".xml"))
									  for $EachLatestId in $LatestXmlFile//VideoID/text()
									  let $VideoDoc := fn:doc(concat($constants:PCOPY_DIRECTORY , $EachLatestId, ".xml"))
									  order by $VideoDoc/Video/BasicInfo/Title ascending
									  return VIDEOS:GetVideoElementForHomePage($VideoDoc/Video)
								  )[position() le xs:integer($PopularCount)]
							   }
							   </Videos>
				return
					<MostPopular>{$Videos/Video}</MostPopular>
			)
			else
			(
				let $PopularVideos := 	<Videos>
											{
												(
													for $CurrentVideo in $MostPopularXml//Video
													let $VideoID := $CurrentVideo/VideoID/string()
													let $VideoDoc := fn:doc(concat($constants:PCOPY_DIRECTORY, $VideoID, ".xml"))
													let $isVideoActive := if($VideoDoc/Video/PublishInfo/VideoPublish/@active/string() = "yes") then VIDEOS:isVideoActive($VideoDoc) else VIDEOS:isLiveVideoActive($VideoDoc)
													return
														if( $isVideoActive != fn:false() )
														then
															VIDEOS:GetVideoElementForHomePage($VideoDoc/Video)
														else ""
												)[position() le xs:integer($PopularCount)]
											}
										</Videos>
				return
					<MostPopular>{$PopularVideos/Video}</MostPopular>
			)
};
declare function GetChannelForthComing($ChannelID, $ForthComingCount as xs:integer)
{
	let $ForthcomingVideos :=  <ForthComing>{(GetChannelAllForthComing($ChannelID))/Video[position() le $ForthComingCount]}</ForthComing>
	return
		<ForthComing>
			{
				for $VideoCount in (1 to $ForthComingCount)
				let $CurrentVideo := $ForthcomingVideos//Video[$VideoCount]
				return
					if($CurrentVideo)
					then $CurrentVideo
					else <Video>Forthcoming Video is unavailable</Video>
			}
		</ForthComing>
 };
 
declare function GetChannelForthComingByCount($ChannelID, $ForthComingCount as xs:integer)
{
	<ForthComing>{(GetChannelAllForthComing($ChannelID))/Video[position() le $ForthComingCount]}</ForthComing>
};
 
declare function GetChannelLatestVideo($ChannelID, $LatestCount as xs:integer)
{
	let $LatestVideos :=    <Latest>{(GetChannelAllLatestVideo($ChannelID))/Video[position() le $LatestCount]}</Latest>
	return
		<Latest>
			{
				for $VideoCount in (1 to $LatestCount)
				let $CurrentVideo := $LatestVideos//Video[$VideoCount]
				return
					if($CurrentVideo)
					then $CurrentVideo
					else <Video>Latest Video is unavailable</Video>
			}
		</Latest>

};

declare function GetChannelLatestVideoByCount($ChannelID, $LatestCount as xs:integer)
{
	<Latest>{(GetChannelAllLatestVideo($ChannelID))/Video[position() le $LatestCount]}</Latest>
};

declare function GetChannelCarousel($ChannelID)
{
   let $ChannelUri := fn:concat($constants:ADMIN_DIRECTORY,$constants:PRE_CHANNEL_CONFIG,$ChannelID,".xml")
   return
	   if( fn:doc-available($ChannelUri) )
	   then
		<Carousel>
		  {
			for $EachVideo in fn:doc($ChannelUri)//Channel
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
					return $VideoDetails 
		  }
		</Carousel>
	   else ( xdmp:log("[ CarouselConfig ][ No configuration file is available to send ]"), "ERROR")
};


(: These functions are to get all channel related videos by category :)
declare function GetChannelAllLatestVideo($ChannelID)
{
    let $LatestXmlFile := fn:doc(fn:concat($constants:ChannelLatest, $ChannelID, ".xml"))
	return
		<Latest>
			{
				for $EachLatestId in $LatestXmlFile//VideoID/text()
				let $VideoDoc := fn:doc(concat($constants:PCOPY_DIRECTORY , $EachLatestId, ".xml"))
				return VIDEOS:GetVideoElementForHomePage($VideoDoc/Video)
			}
		</Latest>
};

declare function GetChannelAllPopularVideo($ChannelID)
{
  
  let $MostPopularXml := GetChannelMostPopularFile($ChannelID)
  let $PopularVideos := for $CurrentVideo in $MostPopularXml//Video
						let $VideoID := $CurrentVideo/VideoID/string()
						let $VideoDoc := fn:doc(concat($constants:PCOPY_DIRECTORY , $VideoID, ".xml"))
						return VIDEOS:GetVideoElementForHomePage($VideoDoc/Video)
  return
     <MostPopular>{$PopularVideos}</MostPopular>
};


declare function GenerateChannelForthComingList($ChannelID)
{
		let $ForthComingVideos := <ForthComing>
									{
										
											for $EachVideo in cts:search(fn:collection($constants:PCOPY)/Video[(AdvanceInfo/PermissionDetails/Permission[@type eq "HideRecord" and @status eq "no"])]
																												[not(ChannelMapping/Channel/@ID = $constants:MasterChannelXml/Channels/Channel[Status='Inactive']/ID)]
																												[(BasicInfo/ChannelMapping/Channel[@ID=$ChannelID])]
																						 ,
																			cts:or-query((	
																				cts:and-query((
																						cts:and-query((
																							cts:element-range-query(xs:QName("RecordStartDate"), "<=",fn:current-dateTime()),
																							cts:element-range-query(xs:QName("RecordStartDate"), "!=",xs:dateTime("1900-01-01T00:00:00.0000"))
																									 )),
																						cts:element-range-query(xs:QName("FinalStartDate"), ">=",fn:current-dateTime())
																							  )),
																				cts:and-query((
																						cts:and-query((
																							cts:element-range-query(xs:QName("RecordStartDate"), "<=",fn:current-dateTime()),
																							cts:element-range-query(xs:QName("RecordStartDate"), "!=",xs:dateTime("1900-01-01T00:00:00.0000"))
																									 )),
																						cts:element-range-query(xs:QName("FinalStartDate"), "=",xs:dateTime("1900-01-01T00:00:00.0000"))
																							  )),
																				cts:and-query((
																						cts:and-query((
																							cts:element-range-query(xs:QName("LiveRecordStartDate"), "<=",fn:current-dateTime()),
																							cts:element-range-query(xs:QName("LiveRecordStartDate"), "!=",xs:dateTime("1900-01-01T00:00:00.0000"))
																									 )),
																						cts:element-range-query(xs:QName("LiveFinalStartDate"), ">=",fn:current-dateTime())
																							  )),
																				cts:and-query((
																						cts:and-query((
																							cts:element-range-query(xs:QName("LiveRecordStartDate"), "<=",fn:current-dateTime()),
																							cts:element-range-query(xs:QName("LiveRecordStartDate"), "!=",xs:dateTime("1900-01-01T00:00:00.0000"))
																									 )),
																						cts:element-range-query(xs:QName("LiveFinalStartDate"), "=",xs:dateTime("1900-01-01T00:00:00.0000"))
																							  ))
																						))
								                                          )
											order by ( if($EachVideo/PublishInfo/VideoPublish/@active="yes") then xs:dateTime($EachVideo/PublishInfo/VideoPublish/RecordStartDate) else xs:dateTime($EachVideo/PublishInfo/LivePublish/LiveRecordStartDate) ) descending
											return <VideoID>{fn:data($EachVideo/@ID)}</VideoID>
									}
									</ForthComing>
		return
				(
					xdmp:document-insert(concat($constants:ChannelForthComing, $ChannelID, '.xml'), $ForthComingVideos),
					xdmp:log("****************ForthComing Video File generated and saved successfully****************")
				)
	    
 };

declare function GetChannelAllForthComing($ChannelID)
{
    let $ForthComingXmlFile := fn:doc(fn:concat($constants:ChannelForthComing, $ChannelID, ".xml"))
	return
		<ForthComing>
			{
				for $EachForthComingId in $ForthComingXmlFile//VideoID/text()
				let $VideoDoc := fn:doc(concat($constants:PCOPY_DIRECTORY , $EachForthComingId, ".xml"))
				return VIDEOS:GetVideoElementForHomePage($VideoDoc/Video)
			}
		</ForthComing>
};


declare function GetChannelMostPopularFile($ChannelID)
{
	let $Config := admin:get-configuration()
	let $CurrentDBName := admin:database-get-name($Config, xdmp:database())
	let $PopularFile := xdmp:eval(	"xquery version '1.0-ml';
										import module namespace constants  = 'http://www.TheIET.org/constants'    at  '/Utils/constants.xqy';
										declare variable $CurrentDBName as xs:string external;
										declare variable $ChannelID external;
										doc(fn:concat($constants:PopularByChannel, $ChannelID, '.xml'))
									"
									, 
									(xs:QName("CurrentDBName"), $CurrentDBName, xs:QName("ChannelID"), $ChannelID)
									,
									<options xmlns="xdmp:eval">
										<database>{if($CurrentDBName = $constants:ApplicationDatabase) then xdmp:database($constants:ActivityDatabase) else xdmp:database($constants:QAActivityDatabase)}</database>
									</options>
									)
	return
		$PopularFile
};

declare function VideoIDList($ChannelXml as item())
{
let $VideoIDList := for $VideoID in $ChannelXml//Channel[Type='VideoId'] return concat($VideoID/VideoId/text(),"")
let $VideoIDList := fn:string-join($VideoIDList, " ")
return $VideoIDList
};

(:=====================================================:)

declare function ConfigureChannelCarouselVideos($ChannelXml as item(),$ChannelID, $Flag as xs:string) (: $Flag: Admin/Scheduler:)
{
	let $UpdatedChannelCarouselVideoWithID := $ChannelXml
	let $VideoIDList := VideoIDList($UpdatedChannelCarouselVideoWithID)
	let $PopularVideos := if($Flag='Scheduler') then GenerateChannelPopularListAndGetPopularIdByCount(15,$ChannelID) else getChannelPopularByCount(15,$ChannelID)
	let $LatestVideos := GenerateChannelLatestListAndGetLatestIdByCount(15,$ChannelID)
	let $ForthComingVideos := GenerateChannelForthComingList($ChannelID)
	let $ProcessToUpdagteChannelXml :=  for $VideoFile  at $Pos in  $ChannelXml//Channel
										let $Log  := xdmp:log(fn:concat("[ VideoTypeText ][ ", $VideoFile/Type/text(), " ]"))
										return
										(: To set Carousel configuration for those video where VideoID is provided :)
										if( $VideoFile/Type/text() eq "VideoId" )
										then
											let $VideoID := $VideoFile/VideoId/text()
											let $VideoDoc := fn:doc(concat($constants:PCOPY_DIRECTORY ,$VideoID,'.xml'))
											let $IsVideoActive := if($VideoDoc/Video/PublishInfo/VideoPublish/@active="yes") then VIDEOS:isVideoActive($VideoDoc) else VIDEOS:isLiveVideoActive($VideoDoc)
											let $IsInactiveChannel  := VIDEOS:isVideoRelatedToInactiveChannel($VideoDoc)
											return
												if( ($IsVideoActive eq fn:false()) or ($IsInactiveChannel eq fn:true()) )
												then xdmp:set($UpdatedChannelCarouselVideoWithID, mem:node-replace($UpdatedChannelCarouselVideoWithID//Channel[$Pos]/VideoId, <VideoId>This video is not active</VideoId>))
												else ""
										
										(: To set Carousel configuration for those video where Type=LatestVideo :)
										else
										if( $VideoFile/Type/text() eq "LatestVideo" )
										then
											let $set := fn:true()
											return
												if(count($LatestVideos/VideoID/text()) eq 0)
												then
													xdmp:set($UpdatedChannelCarouselVideoWithID, mem:node-replace($UpdatedChannelCarouselVideoWithID//Channel[$Pos]/VideoId, <VideoId>Latest Video is unavailable</VideoId>))
												else
													(
														for $EachLatestVideoID at $pos in $LatestVideos/VideoID/text()
														return
															if(not($EachLatestVideoID) and ($set))
															then 
																(
																	xdmp:set($UpdatedChannelCarouselVideoWithID, mem:node-replace($UpdatedChannelCarouselVideoWithID//Channel[$Pos]/VideoId, <VideoId>Latest Video is unavailable</VideoId>)),
																	xdmp:set($set,fn:false())
																)
															else
															if(not(fn:contains($VideoIDList,$EachLatestVideoID)) and ($set))
															then
																(
																	xdmp:set($VideoIDList, concat($VideoIDList, " ",$EachLatestVideoID)),
																	xdmp:set($set,fn:false()),
																	xdmp:set($UpdatedChannelCarouselVideoWithID, mem:node-replace($UpdatedChannelCarouselVideoWithID//Channel[$Pos]/VideoId, <VideoId>{$EachLatestVideoID}</VideoId>))
																)
															else
															if((count($LatestVideos/VideoID/text()) eq $pos) and ($set))
															then
																(
																	xdmp:set($UpdatedChannelCarouselVideoWithID, mem:node-replace($UpdatedChannelCarouselVideoWithID//Channel[$Pos]/VideoId, <VideoId>Latest Video is unavailable</VideoId>)),
																	xdmp:set($set,fn:false())
																)
															else()
													)
										(: To set Carousel configuration for those video where MostPopularVideo ="Yes" :)
										else
										if( $VideoFile/Type/text() eq "MostPopularVideo" )
										then
											let $set := fn:true()
											return
												if(count($PopularVideos/VideoID/text()) eq 0)
												then
													xdmp:set($UpdatedChannelCarouselVideoWithID, mem:node-replace($UpdatedChannelCarouselVideoWithID//Channel[$Pos]/VideoId, <VideoId>Popular Video is unavailable</VideoId>))
												else
												(
													for $EachPopularVideoID at $pos in $PopularVideos/VideoID/text()
													return
														if(not($EachPopularVideoID) and ($set))
														then 
															(
																xdmp:set($UpdatedChannelCarouselVideoWithID, mem:node-replace($UpdatedChannelCarouselVideoWithID//Channel[$Pos]/VideoId, <VideoId>Popular Video is unavailable</VideoId>)),
																xdmp:set($set,fn:false())
															)
														else
														if(not(fn:contains($VideoIDList,$EachPopularVideoID)) and ($set))
														then
															(
																xdmp:set($VideoIDList, concat($VideoIDList, " ",$EachPopularVideoID)),
																xdmp:set($set,fn:false()),
																xdmp:set($UpdatedChannelCarouselVideoWithID, mem:node-replace($UpdatedChannelCarouselVideoWithID//Channel[$Pos]/VideoId, <VideoId>{$EachPopularVideoID}</VideoId>))
															)
														else
														if((count($PopularVideos/VideoID) eq $pos) and ($set))
														then
															(
																xdmp:set($UpdatedChannelCarouselVideoWithID, mem:node-replace($UpdatedChannelCarouselVideoWithID//Channel[$Pos]/VideoId, <VideoId>Popular Video is unavailable</VideoId>)),
																xdmp:set($set,fn:false())
															)
													else()
												)
										else
											xdmp:log(concat("[ ChannelCarouselVideoReading ][ ERROR ][ Type value must be match to 'MostPopularVideo|LatestVideo|VideoId][ Currently it is :", $VideoFile/Type/text(), ' ]'))
	return
	  (: This validation is finally to check that whenever we are committing carousel XML in ML it must contain all the video ID to set :)
	  if( checkVideoIDPresent($UpdatedChannelCarouselVideoWithID) = "SUCCESS" )
	  then $UpdatedChannelCarouselVideoWithID
	  else
	  (
		xdmp:log("[ ChannelConfiguration ][ ERROR ][ Some Video ID is not present to set configuration ]")
		,
		"ERROR",
		xdmp:log($UpdatedChannelCarouselVideoWithID)
	  )
};

(: This function will run Most Popular script on Activity Database and save generated XML on Activity Database, it will check Popular ID(s) are active or not and if active will return its VideoID :)
declare function GenerateChannelPopularListAndGetPopularIdByCount($popularCount as xs:integer,$ChannelID)
{ 
	
	let $Config := admin:get-configuration()
	let $CurrentDBName := admin:database-get-name($Config, xdmp:database())
	return
		if( xs:integer($popularCount) != number(0) )
		then
			let $MostPopularList	:=  xdmp:eval(	" 	xquery version '1.0-ml';
															import module namespace constants  = 'http://www.TheIET.org/constants'    at  '/Utils/constants.xqy';
															declare variable $CurrentDBName as xs:string external;
															declare variable $ChannelID external;															
															<ChannelMostPopular>
																{
																	let $ChannelCollection := fn:concat('Channel-',$ChannelID)
																	for $EachVideoID in cts:collections()[not(fn:starts-with(., 'Channel-')) and
																										 not(fn:starts-with(., 'IET-TV')) and
																										 not(fn:starts-with(., 'WebPortal')) and
																										 not(fn:starts-with(., 'Admin'))
																										]
																	let $VideoResult := collection($ChannelCollection)/Activity[EntityID=$EachVideoID][Action[Type='Play']]/EntityID
																	let $Count := count($VideoResult)
																	order by $Count descending
																	return if($Count!=0) then <Video><VideoID>{$EachVideoID}</VideoID><Count>{$Count}</Count></Video> else ''
																}
															</ChannelMostPopular>
														"
														, 
														(xs:QName("CurrentDBName"), $CurrentDBName, xs:QName("ChannelID"), $ChannelID)
														,
														<options xmlns="xdmp:eval">
															<database>{if($CurrentDBName = $constants:ApplicationDatabase) then xdmp:database($constants:ActivityDatabase) else xdmp:database($constants:QAActivityDatabase)}</database>
														</options>
													)
			let $CurrentMostPopularList		:= 	let $UpdatePopuarList := $MostPopularList
												let $UpdateList := 	for $EachVideo in $MostPopularList/Video
																	let $VideoID := $EachVideo/VideoID/text()
																	let $VideoDoc := doc(concat($constants:PCOPY_DIRECTORY ,$VideoID,'.xml'))
																	let $IsVideoActive := if($VideoDoc/Video/PublishInfo/VideoPublish/@active/string() = "yes") then VIDEOS:isVideoActive($VideoDoc) else VIDEOS:isLiveVideoActive($VideoDoc)
																	let $IsChannelIDExists :=  if($VideoDoc/Video/BasicInfo/ChannelMapping/Channel/@ID eq $ChannelID) then fn:true() else fn:false()
																	let $IsVideoAvailable := doc-available(concat($constants:PCOPY_DIRECTORY ,$VideoID,'.xml'))
																	let $IsInactiveChannel  := VIDEOS:isVideoRelatedToInactiveChannel($VideoDoc)
																	return
																		if( ($IsVideoActive eq fn:false()) or ($IsInactiveChannel eq fn:true()) or ($IsVideoAvailable eq fn:false()) or ($IsChannelIDExists eq fn:false()) ) then xdmp:set($UpdatePopuarList, mem:node-delete($UpdatePopuarList/Video[VideoID = $VideoID])) else ()
												return $UpdatePopuarList
												
												
			let $SavePopularXML := 	xdmp:eval(	" 	xquery version '1.0-ml';
													import module namespace constants  = 'http://www.TheIET.org/constants' at '/Utils/constants.xqy';
													declare variable $CurrentMostPopularList as item() external;
													declare variable $ChannelID external;
													xdmp:document-insert(concat($constants:PopularByChannel, $ChannelID, '.xml'), <ChannelMostPopular ChannelID='{$ChannelID}'>{$CurrentMostPopularList/Video}</ChannelMostPopular>)
												"
												, 
												(xs:QName("CurrentMostPopularList"), $CurrentMostPopularList, xs:QName("ChannelID"), $ChannelID)
												,
												<options xmlns="xdmp:eval">
												  <database>{if($CurrentDBName = $constants:ApplicationDatabase) then xdmp:database($constants:ActivityDatabase) else xdmp:database($constants:QAActivityDatabase)}</database>
												</options>
											)
			let $Log := xdmp:log("****************Scheduler Channel Popular Video File generated and saved successfully****************")
			return
				<ChannelMostPopular>
					{(
						for $Video in $CurrentMostPopularList/Video
						let $VideoID := $Video/VideoID/string()
						let $VideoDoc := fn:doc(fn:concat($constants:PCOPY_DIRECTORY, $VideoID, ".xml"))
						let $isVideoActive := if($VideoDoc/Video/PublishInfo/VideoPublish/@active/string() = "yes") then VIDEOS:isVideoActive($VideoDoc) else VIDEOS:isLiveVideoActive($VideoDoc)
						return
							if( $isVideoActive != fn:false() )
							then
								<VideoID>{$VideoID}</VideoID>
							else ""
					)[position() le $popularCount ]}
				</ChannelMostPopular>
			
		else
			xdmp:log(concat("[ ChannelVideoPopular ][ Fail ][ Invalid popular-count ][ POPULAR-COUNT: ", $popularCount, " ]"))
			
};

declare function GenerateChannelLatestListAndGetLatestIdByCount($latestCount as xs:integer,$ChannelID)
{
  if( xs:integer($latestCount) != number(0) )
  then
	let $LatestVideos :=      <Latest>
							  {
									for $EachVideo in (cts:search(fn:collection($constants:PCOPY)/Video[(AdvanceInfo/PermissionDetails/Permission[@type eq "HideRecord" and @status eq "no"])]
																										[not(ChannelMapping/Channel/@ID = $constants:MasterChannelXml/Channels/Channel[Status='Inactive']/ID)]
																										[(BasicInfo/ChannelMapping/Channel[@ID=$ChannelID])]
																										,
																		cts:and-query((
																				cts:and-query((
																								cts:element-range-query(xs:QName("FinalStartDate"), "<=",fn:current-dateTime()),
																								cts:element-range-query(xs:QName("FinalStartDate"), "!=",xs:dateTime("1900-01-01T00:00:00.0000"))
																							 )),
																				cts:or-query((
																								cts:element-range-query(xs:QName("FinalExpiryDate"), ">=",fn:current-dateTime()),
																								cts:element-range-query(xs:QName("FinalExpiryDate"), "=",xs:dateTime("1900-01-01T00:00:00.0000"))
																							))
																					 ))
																  )
													  )
								   order by xs:dateTime($EachVideo/PublishInfo/FinalStartDate) descending
								   return
								   (: let $Log := xdmp:log($EachVideo):)
									let $VideoID := fn:data($EachVideo/@ID)
									let $VideoDoc := fn:doc(fn:concat($constants:PCOPY_DIRECTORY, $VideoID, ".xml"))
									let $isVideoActive := VIDEOS:isVideoActive($VideoDoc)
										return
											if( $isVideoActive != fn:false() )
											then <VideoID>{$VideoID}</VideoID>
											else ""
							  }
							</Latest>
	let $SaveLatest := 	(xdmp:document-insert(fn:concat($constants:ChannelLatest, $ChannelID, '.xml'), $LatestVideos),
						xdmp:log("****************Scheduler Channel Latest Video File generated and saved successfully****************"))
	return <Latest>{($LatestVideos/VideoID)[ position() le $latestCount ]}</Latest>
  else
	xdmp:log(concat("[ ChannelVideoLatest ][ Fail ][ Invalid latest-count ][ LATEST-COUNT: ", $latestCount, " ]"))
};

declare function checkVideoIDPresent($UpdatedChannelCarouselXml as item())
{
  let $CheckID := for $VideoID in $UpdatedChannelCarouselXml//VideoId return if(string-length($VideoID) ge 1) then fn:true() else fn:false()
  return
    if($CheckID eq fn:false()) then "ERROR" else "SUCCESS"
};