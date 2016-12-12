xquery version "1.0-ml";

module namespace VIDEOS = "http://www.TheIET.org/ManageVideos";

import module namespace constants = "http://www.TheIET.org/constants"   at "/Utils/constants.xqy";
import module namespace admin     = "http://marklogic.com/xdmp/admin"   at "/MarkLogic/admin.xqy";
import module namespace search    = "http://marklogic.com/appservices/search" at "/MarkLogic/appservices/search/search.xqy";
import module namespace mem       = "http://xqdev.com/in-mem-update"     at  "/MarkLogic/appservices/utils/in-mem-update.xqy";


(: It requires one element range query as dataType xs:dateTime to get forth coming videos
   Program will go from current date and check RecordStartDate if it is previous date, fatch out the result.
:)

declare function GetVideoIdByVideoNumber($VideoNumber as xs:string)
{
  data(collection($constants:PCOPY)/Video[VideoNumber=$VideoNumber]/@ID)
};
 
 
declare function GetVideoForthComingByCount($forthComingCount as xs:integer)
{
  if( xs:integer($forthComingCount) != number(0) )
  then
	<ForthComing>
		{
			for $EachVideo in fn:doc($constants:CommonForthComingVideo)//VideoID[position() le $forthComingCount]
			let $PHistoryUri := fn:concat($constants:PCOPY_DIRECTORY,$EachVideo,".xml")
			let $VideoXML := fn:doc($PHistoryUri)/Video
			return GetVideoElementForHomePage($VideoXML)
		}
	</ForthComing>
  else
    xdmp:log(concat("[ VideoForthComing ][ Fail ][ Invalid forth coming count ][ FORTH-COMMING-COUNT: ", $forthComingCount, " ]"))
 };

declare function GetRelatedContent($VideoID as xs:string)
{
  let $RelatedUri := fn:concat($constants:DirectoryRelated, $VideoID, '.xml')
  return
	if( fn:doc-available($RelatedUri) )
	then fn:doc($RelatedUri)
	else <Matched>Related contents are not available.</Matched>
 };
 
declare function GetLatestVideoByCount($LatestCount as xs:integer)
{
  if( xs:integer($LatestCount) != number(0) )
  then
	<Latest>
		{
			for $EachVideo in fn:doc($constants:CommonLatestVideo)//VideoID[position() le $LatestCount]
			let $PHistoryUri := fn:concat($constants:PCOPY_DIRECTORY,$EachVideo,".xml")
			let $VideoXML := fn:doc($PHistoryUri)/Video
			return GetVideoElementForHomePage($VideoXML)
		}
	</Latest>
  else
    xdmp:log(concat("[ LatestCount ][ Fail ][ Invalid forth coming count ][ LATEST-COUNT: ", $LatestCount, " ]"))
 };
 

 declare function isVideoRelatedToSkipChannel($SkipChannel as item(), $Video as item())
 {
	if( $Video/Video/BasicInfo/ChannelMapping/Channel[@ID = $SkipChannel//text()] ) then fn:true() else fn:false()
 };
  
 
 declare function isVideoRelatedToStaffChannel($Video as item())
 {
	if( $Video/Video/BasicInfo/ChannelMapping/Channel[@ID = $constants:StaffChannelXml/Channels/Channel] ) then fn:true() else fn:false()
 };
 
declare function isVideoRelatedToInactiveChannel($Video as item())
 {
	if( $Video/Video/BasicInfo/ChannelMapping/Channel[@ID = $constants:MasterChannelXml/Channels/Channel[Status='Inactive']/ID] ) then fn:true() else fn:false()
 };

declare function isVideoActive($Video as item())
{
	let $isHide := if($Video/Video/AdvanceInfo/PermissionDetails[Permission[@type eq "HideRecord" and @status eq "no"]]) then fn:false() else fn:true()
	(:let $Log := xdmp:log(fn:concat("[ CarouselSet ] Is Current video hidden = ", $isHide, " Video ID : ", fn:data($Video/Video/@ID))):)
	let $isPublished := if($Video/Video/VideoStatus[.="Published"]) then fn:true() else fn:false()
	(:let $Log := xdmp:log(fn:concat("[ CarouselSet ] Is Current video Published = ", $isPublished, " Video ID : ", fn:data($Video/Video/@ID))):)
	let $isExpired := if($Video/Video/PublishInfo/VideoPublish/FinalExpiryDate[(.="1900-01-01T00:00:00.0000") or (. ge fn:current-dateTime())]) then fn:false() else fn:true()
	(:let $Log := xdmp:log(fn:concat("[ CarouselSet ] Is Current video Expired = ", $isExpired, " Video ID : ", fn:data($Video/Video/@ID))):)
	let $CheckPublishDateExpired :=    let $FinalStartDate := $Video/Video/PublishInfo/VideoPublish/FinalStartDate
									   let $RecordStartDate := $Video/Video/PublishInfo/VideoPublish/RecordStartDate
									   return
										 if($FinalStartDate='1900-01-01T00:00:00.0000' and $RecordStartDate='1900-01-01T00:00:00.0000') then fn:true() else
										 if($FinalStartDate=xs:dateTime('1900-01-01T00:00:00.0000') and $RecordStartDate!=xs:dateTime('1900-01-01T00:00:00.0000'))
										 then if($RecordStartDate ge fn:current-dateTime()) then fn:true() else fn:false()
										 else
										 if($FinalStartDate!='1900-01-01T00:00:00.0000' and $RecordStartDate='1900-01-01T00:00:00.0000')
										 then if($FinalStartDate[. ge fn:current-dateTime()]) then fn:true() else fn:false()
										 else
										 if($FinalStartDate!='1900-01-01T00:00:00.0000' and $RecordStartDate!='1900-01-01T00:00:00.0000')
										 then
										   if($FinalStartDate[. ge fn:current-dateTime()] and $RecordStartDate[. ge fn:current-dateTime()]) then fn:true() else fn:false()
										 else fn:true()
	(:let $Log := xdmp:log(fn:concat("[ CarouselSet ] Is Current video CheckPublishDateExpired = ", $CheckPublishDateExpired, " Video ID : ", fn:data($Video/Video/@ID))):)
	return if($isHide = fn:true() or $isPublished = fn:false() or $isExpired = fn:true() or $CheckPublishDateExpired = fn:true())
		   then fn:false()
		   else fn:true()
};

declare function isLiveVideoActive($Video as item())
{
	let $isHide := if($Video/Video/AdvanceInfo/PermissionDetails[Permission[@type eq "HideRecord" and @status eq "no"]]) then fn:false() else fn:true()
	(:let $Log := xdmp:log(fn:concat("[ CarouselSet ] Is Current Live video hidden = ", $isHide, " Video ID : ", fn:data($Video/Video/@ID))):)
	let $isPublished := if($Video/Video/VideoStatus[.="Published"]) then fn:true() else fn:false()
	(:let $Log := xdmp:log(fn:concat("[ CarouselSet ] Is Current Live video Published = ", $isPublished, " Video ID : ", fn:data($Video/Video/@ID))):)
	let $isExpired := if($Video/Video/PublishInfo/LivePublish/LiveFinalExpiryDate[(.="1900-01-01T00:00:00.0000") or (. ge fn:current-dateTime())]) then fn:false() else fn:true()
	(:let $Log := xdmp:log(fn:concat("[ CarouselSet ] Is Current Live video Expired = ", $isExpired, " Video ID : ", fn:data($Video/Video/@ID))):)
	let $CheckPublishDateExpired :=    	let $LiveFinalStartDate := $Video/Video/PublishInfo/LivePublish/LiveFinalStartDate
										let $LiveRecordStartDate := $Video/Video/PublishInfo/LivePublish/LiveRecordStartDate
										return
										if($LiveFinalStartDate='1900-01-01T00:00:00.0000' and $LiveRecordStartDate='1900-01-01T00:00:00.0000') then fn:true() else
										if($LiveFinalStartDate=xs:dateTime('1900-01-01T00:00:00.0000') and $LiveRecordStartDate!=xs:dateTime('1900-01-01T00:00:00.0000'))
										then if($LiveRecordStartDate ge fn:current-dateTime()) then fn:true() else fn:false()
										else
										if($LiveFinalStartDate!='1900-01-01T00:00:00.0000' and $LiveRecordStartDate='1900-01-01T00:00:00.0000')
										then if($LiveFinalStartDate[. ge fn:current-dateTime()]) then fn:true() else fn:false()
										else
										if($LiveFinalStartDate!='1900-01-01T00:00:00.0000' and $LiveRecordStartDate!='1900-01-01T00:00:00.0000')
										then
										if($LiveFinalStartDate[. ge fn:current-dateTime()] and $LiveRecordStartDate[. ge fn:current-dateTime()]) then fn:true() else fn:false()
										else fn:true()
	(:let $Log := xdmp:log(fn:concat("[ CarouselSet ] Is Current Live video CheckPublishDateExpired = ", $CheckPublishDateExpired, " Video ID : ", fn:data($Video/Video/@ID))):)
	return if($isHide = fn:true() or $isPublished = fn:false() or $isExpired = fn:true() or $CheckPublishDateExpired = fn:true())
		   then fn:false()
		   else fn:true()
}; 

declare function ExcludeMostPopular($Video as item())
{
    if($Video/Video/AdvanceInfo/PermissionDetails/Permission[@type="ExcludeMostPopular" and @status = "yes"])  then fn:true() else fn:false()
};

declare function GetVideoElementForHomePage( $videos ) as item()*
{
  for $VideoXml in $videos
  let $UserIP := "::1"
  let $UserEmail := ""
  let $UserID := ""
  let $VideoNumber 	:= $VideoXml/VideoNumber
  let $VideoTitle := $VideoXml/BasicInfo/Title
  let $CreationInfo := $VideoXml/CreationInfo
  let $VideoAbstract := $VideoXml/BasicInfo/Abstract
  let $Pricing := $VideoXml/BasicInfo/PricingDetails
  let $VideoCreatedDate := $VideoXml/BasicInfo/VideoCreatedDate
  let $Copyright := $VideoXml/BasicInfo/CopyrightDetails
  let $Promo := $VideoXml/BasicInfo/PromoDetails
  let $ChannelMapping := $VideoXml/BasicInfo/ChannelMapping
  let $ChannelName := let $Channel := $VideoXml/BasicInfo/ChannelMapping/Channel[@default="true"]
                      return <ChannelName channelID="{data($Channel/@ID)}">{$Channel/ChannelName/text()}</ChannelName>
  let $PromoDetails := $VideoXml/BasicInfo/PromoDetails
  let $hasAccess := "True"
  let $ThumbnailFilepath := $VideoXml//ThumbnailFilepath
  let $StreamThumbnailUrl := $VideoXml//URL
  let $Copyright := $VideoXml/BasicInfo/CopyrightDetails
  let $UKStream  := <UKStreamID>{if(data($VideoXml/UploadVideo/File/@streamID)) then data($VideoXml/UploadVideo/File/@streamID) else $VideoXml/PublishInfo/LivePublish/UserName/text()}</UKStreamID>
  let $ShortDescription  := $VideoXml/BasicInfo/ShortDescription
  let $PublishInfo := $VideoXml/PublishInfo
  let $Events := $VideoXml/Events
  let $Speakers := $VideoXml/Speakers
  let $Duration := $VideoXml//Duration
  let $PermissionDetails := $VideoXml/AdvanceInfo/PermissionDetails
  let $SeriesList := $VideoXml/SeriesList
  return
    <Video ID="{fn:data($VideoXml/@ID)}">
    {
      (
        GetRelatedContent(fn:data($VideoXml/@ID)),$VideoNumber,$CreationInfo,$SeriesList,$VideoCreatedDate,$ChannelMapping, <BasicInfo>{$Pricing,$Promo,$Copyright}</BasicInfo>, $VideoTitle,$VideoAbstract,$ChannelName,$PromoDetails,$PermissionDetails,<HasAccess>True</HasAccess>, $Events, $Speakers, $Duration, $ThumbnailFilepath, $StreamThumbnailUrl, $Copyright, $UKStream, $ShortDescription, $PublishInfo
        ,
		GetVideoActionProperty(fn:concat($constants:ACTION_DIRECTORY,$VideoXml/@ID/string(),$constants:SUF_ACTION,".xml"),$UserID,$UserEmail,$UserIP)
		,
              let $PubDate := $VideoXml/PublishInfo/VideoPublish/RecordStartDate/text()
              let $PubTime := $VideoXml/PublishInfo/VideoPublish/RecordStartTime/text()
              return
                if($PubDate and $PubTime)
                then
                  <VideoPublishDate>{concat($PubDate, ' ', $PubTime)}</VideoPublishDate>
                else
                 <HasPublishDate>False</HasPublishDate>
         ,
              let $FinalDate := $VideoXml/PublishInfo/VideoPublish/FinalStartDate/text()
              let $FinalTime := $VideoXml/PublishInfo/VideoPublish/FinalStartTime/text()
              return
                if($FinalDate and $FinalTime)
                then
                  <VideoFinalDate>{concat($FinalDate, ' ', $FinalTime)}</VideoFinalDate>
                else
                 <HasFinalDate>False</HasFinalDate>
      )
    }
    </Video>
};

declare function GetVideoDetailsByID( $videoID as xs:string, $UserID as xs:string, $UserEmail as xs:string, $UserIP as xs:string )
{
  let $VideoXml 	:= fn:doc(fn:concat($constants:PCOPY_DIRECTORY,$videoID,'.xml'))/Video
  let $VideoNumber 	:= $VideoXml/VideoNumber
  let $BasicInfo 	:= $VideoXml/BasicInfo
  let $Pricing		:= $BasicInfo/PricingDetails
  let $Copyright 	:= $BasicInfo/CopyrightDetails
  let $Promo 		:= $BasicInfo/PromoDetails
  let $Permission 	:= $VideoXml/AdvanceInfo/PermissionDetails
  let $PublishInfo 	:= $VideoXml/PublishInfo
  let $Duration 	:= $VideoXml/UploadVideo/File/Duration
  let $Attachment 	:= $VideoXml/Attachments
  let $ChannelName 	:= let $Channel := $VideoXml/BasicInfo/ChannelMapping/Channel[@default="true"]
						return <ChannelName ID="{data($Channel/@ID)}">{$Channel/ChannelName/text()}</ChannelName>
  let $VideoKeyWordInspec    	:= $VideoXml/VideoInspec
  let $Events := $VideoXml/Events
  let $SeriesList := $VideoXml/SeriesList
  let $Transcripts := <Transcripts>{$VideoXml/AdvanceInfo/Transcripts/Transcript[@active eq "yes"]}</Transcripts>
  let $IETDigitalLibrary := <IETDigitalLibrary>{$VideoXml/IETDigitalLibrary/DOI}</IETDigitalLibrary>
  return
  if( $VideoXml )
      then
        <Video ID="{fn:data($VideoXml/@ID)}">{$VideoNumber}
        <BasicInfo>{$Pricing,$Promo,$Copyright}</BasicInfo>
         <ThumbnailFilepath></ThumbnailFilepath>
            {
              $VideoXml/Speakers,
              $BasicInfo/Title,
              $BasicInfo/Abstract,
              $VideoXml//URL,
              $BasicInfo/ShortDescription,
              $PublishInfo,
			  $Duration,
              $BasicInfo/ChannelMapping,
              $ChannelName,
              $Attachment,
			  $BasicInfo/VideoCategory,
			  $BasicInfo/VideoCreatedDate,
			  GetVideoActionProperty(fn:concat($constants:ACTION_DIRECTORY,$videoID,$constants:SUF_ACTION,".xml"),$UserID,$UserEmail,$UserIP),
			  GetRelatedContent(fn:data($VideoXml/@ID))
            }
            <VideoDescription>{$BasicInfo/ShortDescription/text()}</VideoDescription>
            {$BasicInfo/PromoDetails}
            <LastViewedDate></LastViewedDate>
            <UKstreamID>{data($VideoXml//UploadVideo/File/@streamID)}</UKstreamID>
            <Keywords>{for $EachKeyWord in $VideoXml//DefaultKeyword return $EachKeyWord}</Keywords>
			<CustomKeywords>{for $EachKeyWord in $VideoXml//CustomKeyword return $EachKeyWord}</CustomKeywords>
            {$Permission,$VideoKeyWordInspec,$Events,$SeriesList,$Transcripts,$IETDigitalLibrary}
			
        </Video>
      else
        "NONE"
};

declare function GetVideoActionProperty($ActionUri,$UserID,$UserEmail,$UserIP)
{
	let $GetActionDoc := doc($ActionUri)
	let $CurrentView := $GetActionDoc/VideoAction/Views/text()
	let $CurrentLike := count($GetActionDoc/VideoAction/User/Action[.='Like'])
	let $CurrentDisLike := count($GetActionDoc/VideoAction/User/Action[.='Dislike'])
	(:let $Log := xdmp:log($GetActionDoc):)
	let $UserAction := $GetActionDoc/VideoAction/User[UserID=$UserID][UserIP=$UserIP][Email=$UserEmail]/Action/text()
	return 
	(
		<User><Action>{$UserAction}</Action></User>,
		<Likes>{$CurrentLike}</Likes>,
		<DisLikes>{$CurrentDisLike}</DisLikes>,
		<Views>{if($CurrentView) then $CurrentView else "0"}</Views>
	)
};

declare function GenerateLatestListAndGetLatestIdByCount($SkipChannel as item(), $latestCount as xs:integer)
{
  if( xs:integer($latestCount) != number(0) )
  then
	let $LatestVideos :=    <Latest>
							  {
								for $EachVideo in cts:search(fn:collection($constants:PCOPY)/Video[not(BasicInfo/ChannelMapping/Channel/@ID = $SkipChannel//text())]
																								  [AdvanceInfo/PermissionDetails/Permission[@type eq "HideRecord" and @status eq "no"]]
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
								order by xs:dateTime($EachVideo/PublishInfo/VideoPublish/FinalStartDate) descending
								return <VideoID>{fn:data($EachVideo/@ID)}</VideoID>
							  }
							</Latest>
	let $SaveLatest := 	(xdmp:document-insert($constants:CommonLatestVideo, $LatestVideos),
						xdmp:log("****************Latest Video File generated and saved successfully****************"))
	return <Latest>{($LatestVideos//VideoID)[ position() le $latestCount ]}</Latest>
  else
	xdmp:log(concat("[ VideoLatest ][ Fail ][ Invalid latest-count ][ LATEST-COUNT: ", $latestCount, " ]"))
};

(: This function will get list of latest videos from already saved latest video file "/Admin/CommonLatestVideo.xml" :)
declare function GetAllLatestVideos()
{
	<Videos>
		{
			for $EachVideo in fn:doc($constants:CommonLatestVideo)//VideoID
			let $PHistoryUri := fn:concat($constants:PCOPY_DIRECTORY,$EachVideo,".xml")
			let $VideoXML := fn:doc($PHistoryUri)/Video
			order by xs:dateTime($VideoXML//PublishInfo/VideoPublish/FinalStartDate) descending
			return GetVideoElementForHomePage($VideoXML)
		}
	</Videos>
};

declare function GetCommonPopularFile()
{
	let $Config 		:= admin:get-configuration()
	let $CurrentDBName  := admin:database-get-name($Config, xdmp:database())
	let $PopularFile 	:= xdmp:eval(	"xquery version '1.0-ml';
										import module namespace constants  = 'http://www.TheIET.org/constants'    at  '/Utils/constants.xqy';
										declare variable $CurrentDBName as xs:string external;
										doc($constants:CommonPopular)
									"
									, 
									(xs:QName("CurrentDBName"), $CurrentDBName)
									,
									<options xmlns="xdmp:eval">
										<database>{if($CurrentDBName = $constants:ApplicationDatabase) then xdmp:database($constants:ActivityDatabase) else xdmp:database($constants:QAActivityDatabase)}</database>
									</options>
									)
	return $PopularFile
											
};

declare function GetVideoPopularByCount($popularCount as xs:integer)
{
	if( xs:integer($popularCount) != number(0) )
	then
    let $PopularCount := <CommonMostPopular></CommonMostPopular>
    let $UpdateID :=  for $VideoID in VIDEOS:GetCommonPopularFile()//Video/VideoID/text()
                      let $DocUri := fn:concat($constants:PCOPY_DIRECTORY, $VideoID, ".xml")
                      let $IsExcludeMostPopular := VIDEOS:ExcludeMostPopular(doc($DocUri))
                      let $IsVideoAvailable := doc-available($DocUri)
                      return
                      if(fn:count($PopularCount/VideoID) lt $popularCount ) 
                      then
                        if($IsVideoAvailable eq fn:true() and $IsExcludeMostPopular eq fn:false())
                        then xdmp:set($PopularCount,mem:node-insert-child($PopularCount,<VideoID IsVideoAvailable="{$IsVideoAvailable}" IsExcludeMostPopular="{$IsExcludeMostPopular}">{$VideoID}</VideoID>))
                        else ()
                      else ()
        return $PopularCount
	else
		xdmp:log(concat("[ VideoPopular ][ Fail ][ Invalid popular-count ][ POPULAR-COUNT: ", $popularCount, " ]"))
};

declare function GetVideoMostPopularByCount($popularCount as xs:integer)
{
	let $PopularFile := GetCommonPopularFile()
	let $Count := count($PopularFile//Video)
	return 
		if( xs:integer($popularCount) != number(0) and $Count eq xs:integer(0))
		then
			<MostPopular>
			{
				(
					for $VideoID in fn:doc($constants:CommonLatestVideo)//VideoID
					let $VideoDoc := fn:doc(concat($constants:PCOPY_DIRECTORY, $VideoID/text(), ".xml"))
					order by $VideoDoc/Video/BasicInfo/Title
					return
						GetVideoElementForHomePage($VideoDoc/Video)
				)[position() le xs:integer($popularCount)]
			}
			</MostPopular>
		else
		if( xs:integer($popularCount) != number(0) and $Count ne xs:integer(0))
		then
			<MostPopular>
			{
				let $TrueID := <Video></Video>
				let $UpdateID :=  for $VideoID in $PopularFile//Video/VideoID/text()
				                  let $DocUri := fn:concat($constants:PCOPY_DIRECTORY, $VideoID, ".xml")
				                  (:let $IsExcludeMostPopular := ExcludeMostPopular(doc($DocUri)):)
								  return
									if(fn:count($TrueID/VID) lt $popularCount ) 
									then
									  (:if(fn:doc-available($DocUri) and $IsExcludeMostPopular eq fn:false() ) then xdmp:set($TrueID,mem:node-insert-child($TrueID,<VID>{$VideoID}</VID>)) else () :)
									  if(fn:doc-available($DocUri)) then xdmp:set($TrueID,mem:node-insert-child($TrueID,<VID>{$VideoID}</VID>)) else ()
									else ()
				for $VideoID in $TrueID/VID/text()
				let $VideoDoc := fn:doc(concat($constants:PCOPY_DIRECTORY, $VideoID, ".xml"))
				return
					GetVideoElementForHomePage($VideoDoc/Video)
			}
			</MostPopular>
		else
			xdmp:log(concat("[ VideoPopular ][ Fail ][ Invalid popular-count ][ POPULAR-COUNT: ", $popularCount, " ]"))
};

(: This function will run Most Popular script on Activity Database and save generated XML on Activity Database, it will check Popular ID(s) are active or not and if active will return its VideoID :)
declare function GeneratePopularListAndGetPopularIdByCount($SkipChannel as item(), $popularCount as xs:integer)
{
	let $Config := admin:get-configuration()
	let $CurrentDBName := admin:database-get-name($Config, xdmp:database())
	return
		if( xs:integer($popularCount) != number(0) )
		then
			let $MostPopularList	:=  xdmp:eval(	" 	xquery version '1.0-ml';
															import module namespace constants  = 'http://www.TheIET.org/constants'    at  '/Utils/constants.xqy';
															declare variable $CurrentDBName as xs:string external;	
															doc('/Admin/CommonMostPopular.xml')
														"
														, 
														(xs:QName("CurrentDBName"), $CurrentDBName)
														,
														<options xmlns="xdmp:eval">
															<database>{if($CurrentDBName = 'IETTV-Database') then xdmp:database($constants:ActivityDatabase) else xdmp:database($constants:QAActivityDatabase)}</database>
														</options>
													)
			let $CurrentMostPopularList		:= 	let $UpdatePopuarList := $MostPopularList
												let $UpdateList := 	for $EachVideo in $MostPopularList/Video
																	let $VideoID  := $EachVideo/VideoID/text()
																	let $VideoUri := concat($constants:PCOPY_DIRECTORY ,$VideoID,'.xml')
																	let $VideoDoc := doc($VideoUri)
																	let $IsSkipChannelVideo  := isVideoRelatedToSkipChannel($SkipChannel,$VideoDoc)
																	let $IsVideoActive := if($VideoDoc/Video/PublishInfo/VideoPublish/@active/string() = "yes") then isVideoActive($VideoDoc) else isLiveVideoActive($VideoDoc)
																	let $IsVideoAvailable := doc-available($VideoUri)
																	return
																		if( ($IsSkipChannelVideo eq fn:true()) or ($IsVideoActive eq fn:false()) or ($IsVideoAvailable eq fn:false()) )
																		then xdmp:set($UpdatePopuarList, mem:node-delete($UpdatePopuarList/Video[VideoID = $VideoID]))
																		else ()
												return $UpdatePopuarList
			let $SavePopularXML := 	xdmp:eval(	" 	xquery version '1.0-ml';
													import module namespace constants  = 'http://www.TheIET.org/constants' at '/Utils/constants.xqy';
													declare variable $CurrentMostPopularList as item() external;
													xdmp:document-insert($constants:CommonPopular, $CurrentMostPopularList)
												"
												, 
												(xs:QName("CurrentMostPopularList"), $CurrentMostPopularList)
												,
												<options xmlns="xdmp:eval">
												  <database>{if($CurrentDBName = $constants:ApplicationDatabase) then xdmp:database($constants:ActivityDatabase) else xdmp:database($constants:QAActivityDatabase)}</database>
												</options>
											)
			let $Log := xdmp:log("****************Popular Video File generated and saved successfully****************")
			let $PopularCount := <CommonMostPopular></CommonMostPopular>
			let $UpdateID :=  for $VideoID in $CurrentMostPopularList//Video/VideoID/text()
							  let $DocUri := fn:concat($constants:PCOPY_DIRECTORY, $VideoID, ".xml")
							  let $IsExcludeMostPopular := ExcludeMostPopular(doc($DocUri))
							  let $IsVideoAvailable := doc-available($DocUri)
							  return
								if(fn:count($PopularCount/VideoID) lt $popularCount ) 
								then
								  if($IsVideoAvailable eq fn:true() and $IsExcludeMostPopular eq fn:false())
								  then xdmp:set($PopularCount,mem:node-insert-child($PopularCount,<VideoID>{$VideoID}</VideoID>))
								  else ()
								else ()
			return $PopularCount

			
		else
			xdmp:log(concat("[ VideoPopular ][ Fail ][ Invalid popular-count ][ POPULAR-COUNT: ", $popularCount, " ]"))
};

declare function GetAllPopularVideos()
{
     <MostPopular>
		{
			let $PopularFile := GetCommonPopularFile()
			for $Video in $PopularFile//Video
			let $VideoID := $Video/VideoID/string()
			let $VideoDoc := fn:doc(concat($constants:PCOPY_DIRECTORY, $VideoID, ".xml"))
			let $isVideoActive := if($VideoDoc/Video/PublishInfo/VideoPublish/@active/string() = "yes") then isVideoActive($VideoDoc) else isLiveVideoActive($VideoDoc)
				return
					if( $isVideoActive != fn:false() )
					then
						GetVideoElementForHomePage($VideoDoc/Video)
					else ""
		}
    </MostPopular>
};

(: Generate ForthComing List :)
declare function GenerateForthComingList($SkipChannel as item())
{
		let $ForthComingVideos := <ForthComing>
									{
										
											for $EachVideo in cts:search(fn:collection($constants:PCOPY)/Video[not(BasicInfo/ChannelMapping/Channel/@ID = $SkipChannel//text())]
																											  [AdvanceInfo/PermissionDetails/Permission[@type eq "HideRecord" and @status eq "no"]]
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
					xdmp:document-insert($constants:CommonForthComingVideo, $ForthComingVideos),
					xdmp:log("****************ForthComing Video File generated and saved successfully****************")
				)
	    
 };

declare function GetAllForthComingVideos()
{
	<ForthComing>
		{
			for $EachVideo in fn:doc($constants:CommonForthComingVideo)//VideoID
			let $PHistoryUri := fn:concat($constants:PCOPY_DIRECTORY,$EachVideo,".xml")
			let $VideoXML := fn:doc($PHistoryUri)/Video
			return GetVideoElementForHomePage($VideoXML)
		}
	</ForthComing>
};


 
(: Get Videos By Collection :)
declare function GetVideoByCollection($CollectionName as xs:string)
{
	(:let $Log   := xdmp:log("****************************************GetVideoByCollection******************"):)
	let $Video := 	cts:search(fn:collection($CollectionName),
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
	return
		if( $Video )
		then 
			for $EachVideo in $Video 
			return
				<Video ID="{fn:data($EachVideo/@ID)}">
					{
					 $EachVideo//VideoNumber,
					 $EachVideo//BasicInfo/Title,
					 $EachVideo//VideoStatus,
					 $EachVideo//UploadVideo/File,
					 $EachVideo//PublishInfo/VideoPublish/FinalExpiryDate
					}
				</Video>
		 else "NONE"
};

(:Get VideoID whose duration is '00:00:00' :)
declare function GetVideoDuration()
{
	(for $Video in cts:search(fn:collection($constants:VIDEO_COLLECTION)/Video,cts:element-range-query(xs:QName("Duration"), "=",xs:time("00:00:00")))
	order by xs:dateTime($Video//ModifiedInfo/Date) descending
	return <Video ID="{$Video/@ID}">{$Video/UploadVideo/File/Duration} <StreamId>{$Video/UploadVideo/File/@streamID}</StreamId></Video>)[1 to 100]
};


(:Set video Duration:)
declare function SetVideoDuration($VideoXml)
{
	for $EachVideo in $VideoXml//Video
	return
		  try
		  {
			(
				xdmp:node-replace(doc(concat($constants:VIDEO_DIRECTORY,$EachVideo/@ID,".xml"))/Video//Duration, <Duration>{$EachVideo/Duration/text()}</Duration>),
				if( fn:doc-available(fn:concat($constants:PCOPY_DIRECTORY,$EachVideo/@ID,".xml")) )
				then
					xdmp:node-replace(doc(fn:concat($constants:PCOPY_DIRECTORY,$EachVideo/@ID,".xml"))/Video//Duration, <Duration>{$EachVideo/Duration/text()}</Duration>)
				else ()
			)
		  }
		  catch($e)
		  {(
				xdmp:log(concat("[ DurationIngestion ][ ERROR ][ ", $EachVideo/VideoID, " ]")),
				"DurationIngestion ERROR"
		  )}
};

declare function checkVideoIDAndDuration($VideoXml as item())
{
  let $CheckVideoParameter :=  for $VideoType in $VideoXml//Video
							   return
								   if( $VideoType/@ID = '' or $VideoType/Duration = '' )
								   then fn:false() 
								   else fn:true()
  return
    if( $CheckVideoParameter eq fn:false())
    then fn:false()
    else fn:true()
}; 

declare function IsVideoIDValid($VideoXml as item())
{

	let $Result := string-join(
								for $VideoType at $position in $VideoXml//Video
								let $IsVideoIDValid := fn:doc-available(concat($constants:PCOPY_DIRECTORY,$VideoType/@ID,".xml"))
								return
									if( $IsVideoIDValid eq fn:false())
									then concat($position," - ",fn:data($VideoType/@ID)) else ()
								," # ")
	return $Result							   
  
}; 


declare function getvideobyId($id as xs:string ) as item()*
{
    (:let $Log := xdmp:log("****************************************getvideobyId******************"):)
	let $VideoUri := fn:concat($constants:VIDEO_DIRECTORY,$id,".xml")
	return
		if ( fn:doc-available($VideoUri) )
		then fn:doc($VideoUri)
		else "NONE"
};

(: <!-- TODO: replacement --> Get recent Video <---->  element-value-query("Created Person ID") needs to be done :)
(: Get recent Video :)
declare function get-recent-video($userid as xs:string,$topList as xs:integer,$SortKey as xs:string, $VideoType as xs:string) as item()*
{
	(:let $Log := xdmp:log("****************************************get-recent-video******************"):)
	let $Video :=	(: TODO: Need to update as per current collections :)
					if ($userid ne "")
					then 
						let $UserQueryCreatedBy := cts:path-range-query("CreationInfo/Person/@ID", "=", $userid)     
						let $UserQueryModifiedBy := cts:path-range-query("ModifiedInfo/Person/@ID", "=", $userid)     
						return	(for $x in cts:search(fn:collection(fn:concat($constants:VIDEO_TYPE,$VideoType)),
													cts:or-query((
														$UserQueryCreatedBy,
														$UserQueryModifiedBy
													))
										)
								order by xs:dateTime($x/Video/ModifiedInfo/Date) descending
								return $x)[1 to 10]
					else
						(for $x in fn:collection(fn:concat($constants:VIDEO_TYPE,$VideoType))
						order by xs:dateTime($x/Video/ModifiedInfo/Date) descending
						return $x)[1 to 10]
	return
		if( $Video )
		then
			let $topVideo	:=	for $EachVideo in $Video
								return 
									<Video ID="{fn:data($EachVideo/Video/@ID)}">
										{
											$EachVideo//VideoNumber,
											$EachVideo//VideoCategory,
											$EachVideo//BasicInfo/Title,
											$EachVideo//CreationInfo,
											$EachVideo//LocationDetails,
											$EachVideo//VideoStatus,
											$EachVideo//ModifiedInfo,
											$EachVideo//Speakers,
											$EachVideo//Duration,
											$EachVideo//VideoType,
											$EachVideo/Video/UploadVideo/File
										}
									</Video>
			for $Filter in $topVideo[position() <= $topList]
			return $Filter
		else "NONE"
};

(:TODO----> element-value-query("Created Person ID") needs to be done:)
declare function get-admin-video($userid as xs:string,$topList as xs:integer,$searchKey as xs:string,$searchValue as xs:string,$VideoType as xs:string) as item()*
{
(: TODO: Need to update as per current collections :)
	(:let $Log := xdmp:log("****************************************get-admin-video******************"):)
	let $Result :=	if ($userid ne "" and $searchKey ne "VideoID" )
					then 
						(:let $Log := xdmp:log("****************************************A: 1******************"):)
						let $UserQueryCreatedBy  := cts:path-range-query("CreationInfo/Person/@ID", "=", $userid)     
						let $UserQueryModifiedBy := cts:path-range-query("ModifiedInfo/Person/@ID", "=", $userid)        	
						return
							cts:search(fn:collection(fn:concat($constants:VIDEO_TYPE,$VideoType)),
													cts:and-query((
														cts:element-query(xs:QName($searchKey),$searchValue),
														cts:or-query(($UserQueryCreatedBy,$UserQueryModifiedBy))
														))
										)
					else
					if( $userid ne "" and $searchKey eq "VideoID" )
					then
						 (:let $Log := xdmp:log("****************************************A: 2******************"):)
						 let $UserQueryCreatedBy  := cts:path-range-query("CreationInfo/Person/@ID", "=", $userid)     
						 let $UserQueryModifiedBy := cts:path-range-query("ModifiedInfo/Person/@ID", "=", $userid)        
						 return cts:search(fn:collection(fn:concat($constants:VIDEO_TYPE,$VideoType)),
													cts:and-query((
														cts:element-attribute-value-query(xs:QName("Video"),
														xs:QName("ID"),$searchValue),($UserQueryCreatedBy,$UserQueryModifiedBy)
											))
										)
					else
					if( $userid eq "" and $searchKey eq "VideoID" and $VideoType ne "" )
					then
						(:let $Log := xdmp:log("****************************************A: 3******************")
						return:)
							fn:doc(fn:concat($constants:VIDEO_DIRECTORY,fn:substring-before(fn:substring-after($searchValue,'*'),'*'),".xml"))
					else
					if( $userid eq "" and $searchKey eq "VideoID" and $VideoType eq "" )
					then
						(:let $Log := xdmp:log("****************************************A: 4******************")
						return:) fn:doc(fn:concat($constants:VIDEO_DIRECTORY,$searchValue,".xml"))/Video
					else
					if( $userid  eq "" and $searchKey eq "StreamID"  and $VideoType ne "" )
					then
					(:let $Log := xdmp:log("****************************************A: 7******************")
					return:)
						cts:search(fn:collection(fn:concat($constants:VIDEO_TYPE,$VideoType)),
									cts:element-attribute-value-query(xs:QName("File"),xs:QName("streamID"),$searchValue)
									)
					else
					if( $userid  eq "" and $searchKey eq "LocationName"  and $VideoType ne "" )
					then
						(:let $Log := xdmp:log("****************************************A: 8******************")
						return:)
							fn:collection(fn:concat($constants:VIDEO_TYPE,$VideoType))[cts:contains(/Video/AdvanceInfo/LocationDetails/Location/LocationName,$searchValue)]
					else
					if( $userid  eq "" and ($searchKey ne "VideoID" and $searchKey ne "ModifiedInfo/Date")  and $VideoType ne "" )
					then
					(:let $Log := xdmp:log("****************************************A: 5******************")
					return:)
						cts:search(fn:collection(fn:concat($constants:VIDEO_TYPE,$VideoType)),
									cts:element-query(xs:QName($searchKey),$searchValue)
									)
					else
					if( $userid  eq "" and $searchKey eq "ModifiedInfo/Date" and $VideoType ne "" )
					then
					(:let $Log := xdmp:log("****************************************A: 6******************")
					return:)
		                fn:collection(fn:concat($constants:VIDEO_TYPE,$VideoType))[contains(/Video/ModifiedInfo/Date, substring-before($searchValue,"T"))]
					else ()
					
	return 
  
	if( $Result )
	then 
				(:let $Log := xdmp:log($Result)
				return:)
					for $EachVideo in $Result
									   let $VideoID :=  <VideoID>{fn:data($EachVideo/Video/@ID)}</VideoID>
									   let $IsCommentAvailable := if( collection(fn:concat($constants:COMMENT, $VideoID)) ) then fn:true() else fn:false()
									   let $IsAbuseReported := if( collection(fn:concat($constants:COMMENT, $VideoID))//Comment/@abuse='yes' ) then fn:true() else fn:false()
										return <Video ID="{$VideoID}" comment="{if($IsCommentAvailable=fn:true()) then 'yes' else 'no'}" abuse="{if($IsAbuseReported=fn:true()) then 'yes' else 'no'}">{
											 $EachVideo/Video/VideoNumber
											,$EachVideo/Video/BasicInfo/Title
											,$EachVideo/Video/CreationInfo
											,$EachVideo/Video/BasicInfo/VideoCategory
											,$EachVideo/Video/VideoStatus
											,$EachVideo/Video/ModifiedInfo
											,$EachVideo/Video/UploadVideo/File/Duration
											,$EachVideo/Video/VideoType
											,$EachVideo/Video/Events
											,$EachVideo/Video/AdvanceInfo/PermissionDetails/Permission[@type="DisplayQAndA"]
											,<StreamID>{data($EachVideo/Video/UploadVideo/File/@streamID)}</StreamID>
											,<Speakers>{normalize-space(string-join(for $EachSpeaker in $EachVideo/Video/Speakers/Person return concat($EachSpeaker/Title/string(), ' ', $EachSpeaker/Name/Given-Name/string(), ' ', $EachSpeaker/Name/Surname/string()), ','))}</Speakers>
											,<Location>{normalize-space(string-join(for $EachLocation in $EachVideo/Video/AdvanceInfo/LocationDetails/Location return $EachLocation/LocationName/string(), ','))}</Location>
										}</Video>
	else
		"NONE"			

};
(: Returns Required Elements passed in input param :)

(: Example - <Video><VideoID>055358eb-dd93-4907-a72c-ea770a1b16c7</VideoID><RequiredElement>VideoID#BasicInfo#ChannelMapping</RequiredElement></Video> :)
declare function getvideoElementById($id as xs:string,$requiredNode as xs:string) as item()*
{
	(:let $Log := xdmp:log("****************************************getvideoElementById******************"):)
	let $VideoDirectory := $constants:VIDEO_DIRECTORY
	let $videoXML:=fn:doc(fn:concat($VideoDirectory,$id,".xml"))
	return
		if( $videoXML )
		then
			for $x in  fn:tokenize($requiredNode,"#")
			return $videoXML//xdmp:unpath($x)
		else
			"NONE"
};


(: Get  Video List By passing Event
Input param : "<Root><SearchElement>Event</SearchElement><SearchElementAttr>eventID</SearchElementAttr><SearchValue>1001</SearchValue><UserID></UserID></Root>"
:)


declare function GetVideoByElementAttribute($userid as xs:string,$SearchElement as xs:string,$SearchElementAttr as xs:string,$searchValue as xs:string) as item()*
{
	(: TODO: Need to update as per current collections :)
	(:let $Log := xdmp:log("****************************************GetVideoByElementAttribute******************"):)
	let $video :=	if ($userid ne "")
					then
						(:let $Log := xdmp:log("****************************************P:1******************"):)
						(:return:)
						cts:search(fn:collection($constants:VIDEO_COLLECTION),
											cts:and-query((
												cts:element-attribute-value-query(xs:QName($SearchElement),xs:QName($SearchElementAttr),$searchValue),
												cts:element-value-query(xs:QName("VideoCreatedPersonID"),$userid)
											))
									)
					else
						(:let $Log := xdmp:log("****************************************P:2******************"):)
						(:return:)
						cts:search(fn:collection($constants:VIDEO_COLLECTION),
													cts:element-attribute-value-query(xs:QName($SearchElement),xs:QName($SearchElementAttr),$searchValue)
								) 
	return
	  if( $video )
	  then 
		for $videoByKey in $video 
		return
			<Video ID="{fn:data($videoByKey/Video/@ID)}">
				{
					(: <VideoID>{fn:data($videoByKey/@ID)}</VideoID>, :)
					$videoByKey//VideoNumber,
					$videoByKey//BasicInfo/Title,
					$videoByKey//CreationInfo,
					$videoByKey//ModifiedInfo,
					$videoByKey//Events,
					$videoByKey/AdvanceInfo/LocationDetails,
					$videoByKey//Speakers,
					$videoByKey//SeriesList,
					$videoByKey//ChannelMapping
				}
				</Video>
		else
			"NONE"
};

(:Get Related Videos 'latest and Popular':)
(:New:)

declare function GetRelatedVideos($Videos)
{
	
	if(count($Videos/Video) le 4)
	then
		for $position in 1 to 4
		let $IsAvailable := $Videos/Video[$position]
		return if($IsAvailable) then VIDEOS:GetVideoElementForHomePage($Videos/Video[$position]) else <Video>No Video Available</Video>
	else (<Video>No Video Available</Video>,<Video>No Video Available</Video>,<Video>No Video Available</Video>,<Video>No Video Available</Video>)
	
};
(:Old Code:)
(:
declare function GetRelatedVideos($Videos)
{
	let $RelatedVideos :=   <Videos>
                            {
                            let $GetID := if($Videos/Video/@ID)
                                          then
                                              
                                              let $Result := <Videos>{
                                                                      ( for $value in distinct-values($Videos/Video/@ID)
                                                                        let $count := count($Videos/Video[@ID eq $value])
                                                                        order by $count descending
                                                                        return <Video>{$value}</Video>
                                                                       ) [position() le 4]
                                                                      }
                                                            </Videos>
                                              return
                                              if(count($Result/*) le 4)
                                              then
                                                for $position in 1 to 4
                                                let $IsAvailable := $Result//Video[$position]
                                                return if($IsAvailable) then $IsAvailable else <Video>No Video Available</Video>
                                              else $Result
                                              
                                         else (<Video>No Video Available</Video>,<Video>No Video Available</Video>,<Video>No Video Available</Video>,<Video>No Video Available</Video>)
                            return $GetID
                            }
                            </Videos>

	let $VideoDetails :=
						  for $EachVideo in $RelatedVideos/Video
						  return
						  if(contains($EachVideo/text(),'No Video Available'))
						  then $EachVideo
						  else
							let $VideoDetails := VIDEOS:GetVideoElementForHomePage(doc(concat($constants:PCOPY_DIRECTORY,$EachVideo/text(),".xml"))/Video)
							return 
							if($VideoDetails) then $VideoDetails else <Video>No Video Available</Video>
						
 
		return $VideoDetails
    
};
:)
declare function GetVideoByEvent($EventId as xs:string) as item()*
{
	(:let $Log := xdmp:log("****************************************GetVideoByEvent******************"):)
	let $VideoXML := cts:search(fn:collection($constants:VIDEO_COLLECTION),
										cts:element-attribute-value-query(xs:QName("Event"),xs:QName("ID"),$EventId)
								)
	return
	if( $VideoXML)
	  then
			for $EachVideo in $VideoXML 
			return
			<Video ID="{fn:data($EachVideo/Video/@ID)}">
				{
				$EachVideo//BasicInfo/Title
				}
			</Video>
	else
		"NONE"
};

(:Old Service:)
(:
declare function GetVideoBySeries($SeriesID as xs:string,$StartPage as xs:integer,$PageLength as xs:integer,$SortBy as xs:string) as item()*
{
	let $Start := if($StartPage = 1) then $StartPage else sum(($StartPage * $PageLength) - $PageLength + 1)
	let $End   := fn:sum(xs:integer($Start) + xs:integer($PageLength) - xs:integer(1))
	(:let $Log := xdmp:log("****************************************GetVideoBySeries******************"):)
	let $VideoXML := <Videos>
						{
						cts:search(fn:collection("PublishedCopy"),cts:element-attribute-value-query(xs:QName("Series"),xs:QName("ID"),$SeriesID))
						}
					</Videos>
	let $VideoCount := count($VideoXML/Video)			
	let $VideoChunks := if( $VideoXML/Video)
						then
						(
							if($SortBy eq "TitleAscending")
							then(
								(
								for $EachVideo in $VideoXML/Video
								order by $EachVideo/BasicInfo/Title ascending
								return
								VIDEOS:GetVideoElementForHomePage($EachVideo)
								)[$Start to $End]
								)
							else
							if($SortBy eq "TitleDescending")
							then(
								(
								for $EachVideo in $VideoXML/Video
								order by $EachVideo/BasicInfo/Title descending
								return
								VIDEOS:GetVideoElementForHomePage($EachVideo)
								)[$Start to $End]
								)
							else
							if($SortBy eq "Recent")
							then(
								(
								for $EachVideo in $VideoXML/Video
								order by $EachVideo/PublishInfo/VideoPublish/FinalStartDate descending
								return
								VIDEOS:GetVideoElementForHomePage($EachVideo)
								)[$Start to $End]
								)
							else
							if($SortBy eq "Oldest")
							then(
								(
								for $EachVideo in $VideoXML/Video
								order by $EachVideo/PublishInfo/VideoPublish/FinalStartDate ascending
								return
								VIDEOS:GetVideoElementForHomePage($EachVideo)
								)[$Start to $End]
								)
							else
							if($SortBy eq "Relevance")
							then(
								(
								for $EachVideo in $VideoXML/Video
								return
								VIDEOS:GetVideoElementForHomePage($EachVideo)
								)[$Start to $End]
								)
							else
							if($SortBy eq "Popular")
							then(
								let $CurrentMostPopularList :=  VIDEOS:GetCommonPopularFile()
								let $VideoIDList := <Video>{(for $EachVideos in $VideoXML/Video	return <VideoID>{$EachVideos/@ID/string()}</VideoID>)[$Start to $End]}</Video>
								let $Videos :=  <Videos>
												  { 
												  for $EachVideoID in $CurrentMostPopularList//VideoID/text()
												  let $Videos := 
																  if($VideoIDList//VideoID[.=$EachVideoID])
																  then (xdmp:set($VideoIDList,mem:node-delete($VideoIDList//VideoID[.=$EachVideoID])),<VideoID>{$EachVideoID}</VideoID>)
																  else ()
												  return $Videos
												  }
												</Videos>
								let $PopularVideos := 	for $EachVideos in $Videos/VideoID
														return VIDEOS:GetVideoElementForHomePage(doc(concat("/PCopy/",$EachVideos/text(),".xml"))/Video)
								let $RemainingVideoID := $VideoIDList
								let $RemainingPopularVideos := 	for $EachVideos in $RemainingVideoID/VideoID
																return VIDEOS:GetVideoElementForHomePage(doc(concat("/PCopy/",$EachVideos/text(),".xml"))/Video)
								return ($PopularVideos,$RemainingPopularVideos)
								)
							else ()
						)
					else
						"NONE"
	return
		(<Videos><VideoCount>{$VideoCount}</VideoCount>{$VideoChunks}</Videos>)
};
:)


declare function GetVideoBySeries($SkipChannel as item(),$SeriesID as xs:string,$StartPage as xs:integer,$PageLength as xs:integer,$SortBy as xs:string) as item()*
{

	let $Start := if($StartPage = 1) then $StartPage else fn:sum(($StartPage * $PageLength) - $PageLength + 1)
	let $SkipChannelConstraint := if( $SkipChannel//text() ne "NONE" )
								  then
									string-join(for $StaffChannel in $SkipChannel/ID/text()
												   return concat('-ChannelType:',$StaffChannel)
										  , ' AND ')
							      else "NONE"
	let $SearchOption := <options xmlns="http://marklogic.com/appservices/search">	
							{
							  if( $SortBy eq "TitleAscending" )
                              then  <sort-order type="xs:string" collation="http://marklogic.com/collation/" direction="ascending"><field name="VideoTitle"/></sort-order>
							  else
							  if( $SortBy eq "TitleDescending" )
                              then	<sort-order type="xs:string" collation="http://marklogic.com/collation/" direction="descending"><field name="VideoTitle"/></sort-order>
							  else
							  if( $SortBy eq "Recent" )
                              then	<sort-order type="xs:string" collation="http://marklogic.com/collation/" direction="descending"><element ns="" name="FinalStartDate"/></sort-order> 
							  else
							  if( $SortBy eq "Oldest" )
                              then	<sort-order type="xs:string" collation="http://marklogic.com/collation/" direction="ascending"><element ns="" name="FinalStartDate"/></sort-order> 
							  else()
							}
							<constraint name="SeriesID">
								<value>
								  <attribute ns="" name="ID"/>
								  <element ns="" name="Series"/>
								</value>
							</constraint>
							<constraint name="ChannelType">
								<range type="xs:int" facet="true">
									<attribute ns="" name="ID"/>
									<element ns="" name="Channel"/>
									<facet-option>frequency-order</facet-option>
									<facet-option>descending</facet-option>
								</range>
							</constraint>
							<additional-query>
								{
									cts:and-query((
												cts:or-query((
															  cts:element-range-query(xs:QName("FinalExpiryDate"), ">=",fn:current-dateTime()),
															  cts:element-range-query(xs:QName("FinalExpiryDate"), "=",xs:dateTime("1900-01-01T00:00:00.0000"))
															)),
												cts:or-query((
															  cts:and-query((
																cts:element-range-query(xs:QName("RecordStartDate"), "<=",fn:current-dateTime()),
																cts:element-range-query(xs:QName("RecordStartDate"), "!=",xs:dateTime("1900-01-01T00:00:00.0000"))
																	  )),
															  cts:and-query((
																cts:element-range-query(xs:QName("FinalStartDate"), "<=",fn:current-dateTime()),
																cts:element-range-query(xs:QName("FinalStartDate"), "!=",xs:dateTime("1900-01-01T00:00:00.0000"))
																	  )),
															  cts:and-query((
																cts:element-range-query(xs:QName("RecordStartDate"), "=",xs:dateTime("1900-01-01T00:00:00.0000")),
																cts:element-range-query(xs:QName("FinalStartDate"), "=",xs:dateTime("1900-01-01T00:00:00.0000"))
																 ))    
															))
												
												))
								}
							</additional-query>
							<additional-query>{cts:collection-query($constants:PCOPY)}</additional-query>
						</options>
						
	let $SearchResponse 	:=	if( $SkipChannelConstraint != "NONE" ) 
								then search:search(fn:concat('((',$SeriesID,')', ' AND (',$SkipChannelConstraint,')') , $SearchOption, $Start, $PageLength)
								else search:search($SeriesID, $SearchOption, $Start, $PageLength)
    let $VideoCount 	:= data($SearchResponse/@total)
    let $VideoChunksList :=   for $Record in $SearchResponse/search:result
                              let $VideoXml := fn:doc($Record/@uri/string())
                              return VIDEOS:GetVideoElementForHomePage($VideoXml/Video)
    
	let $VideoChunks :=		if($SortBy eq "Popular")
							then
								(
								let $VideoChunksList := <Videos>{$VideoChunksList}</Videos>
								let $CurrentMostPopularList := VIDEOS:GetCommonPopularFile()
								let $VideoIDList := <Video>{for $EachVideos in $VideoChunksList/Video	return <VideoID>{$EachVideos/@ID/string()}</VideoID>}</Video>
								let $Videos :=  <Videos>
												  { 
												  for $EachVideoID in $CurrentMostPopularList//VideoID/text()
												  let $Videos := 
																  if($VideoIDList//VideoID[.=$EachVideoID])
																  then (xdmp:set($VideoIDList,mem:node-delete($VideoIDList//VideoID[.=$EachVideoID])),<VideoID>{$EachVideoID}</VideoID>)
																  else ()
												  return $Videos
												  }
												</Videos>
								let $PopularVideos := 	for $EachVideos in $Videos/VideoID
														return VIDEOS:GetVideoElementForHomePage(doc(concat("/PCopy/",$EachVideos/text(),".xml"))/Video)
								let $RemainingVideoID := $VideoIDList
								let $RemainingPopularVideos := 	for $EachVideos in $RemainingVideoID/VideoID
																return VIDEOS:GetVideoElementForHomePage(doc(concat("/PCopy/",$EachVideos/text(),".xml"))/Video)
								return ($PopularVideos,$RemainingPopularVideos)
								  
								)
							else ($VideoChunksList)
																			
	return <Videos><VideoCount>{$VideoCount}</VideoCount>{$VideoChunks}</Videos>
};

declare function GetVideoBySpeaker($SpeakerId as xs:string) as item()*
{
	(:let $Log := xdmp:log("****************************************GetVideoBySpeaker******************"):)
	let $SpeakerSearch := cts:path-range-query("Speakers/Person/@ID", "=", $SpeakerId)     
	let $VideoXML := cts:search(fn:collection($constants:VIDEO_COLLECTION),	$SpeakerSearch)
	return
	if( $VideoXML)
	  then
			for $EachVideo in $VideoXML 
			return
			<Video ID="{fn:data($EachVideo/Video/@ID)}">
				{
				$EachVideo//BasicInfo/Title
				}
			</Video>
	else
		"NONE"
};

declare function GetVideoDetailsByEvent($SkipChannel as item(),$EventID as xs:string,$StartDate as xs:dateTime,$EndDate as xs:dateTime)
{
	let $VideoXML := if( $SkipChannel//text() ne "NONE" )
	                 then
					 	cts:search(fn:collection($constants:PCOPY)/Video[not(BasicInfo/ChannelMapping/Channel/@ID = $SkipChannel//text())]
																	   [AdvanceInfo/PermissionDetails/Permission[@type eq "HideRecord" and @status eq "no"]]
																	   [(PublishInfo/VideoPublish/FinalExpiryDate  ge fn:current-dateTime()) or
																	   (PublishInfo/VideoPublish/FinalExpiryDate eq xs:dateTime("1900-01-01T00:00:00.0000"))]
                                                                                      ,
                                              cts:and-query(( cts:element-attribute-value-query(xs:QName("Event"),xs:QName("ID"),$EventID),
                                                              cts:element-range-query(xs:QName("StartDate"),">=",$StartDate),
                                                              cts:element-range-query(xs:QName("StartDate"),"<=",$EndDate)
                                                           ))
                               )
				     else
						cts:search(fn:collection($constants:PCOPY)/Video[AdvanceInfo/PermissionDetails/Permission[@type eq "HideRecord" and @status eq "no"]]
																	   [(PublishInfo/VideoPublish/FinalExpiryDate  ge fn:current-dateTime()) or
																	   (PublishInfo/VideoPublish/FinalExpiryDate eq xs:dateTime("1900-01-01T00:00:00.0000"))]
                                                                                      ,
                                              cts:and-query(( cts:element-attribute-value-query(xs:QName("Event"),xs:QName("ID"),$EventID),
                                                              cts:element-range-query(xs:QName("StartDate"),">=",$StartDate),
                                                              cts:element-range-query(xs:QName("StartDate"),"<=",$EndDate)
                                                           ))
                               )

	return
	if( $VideoXML)
	  then
			GetVideoElementForHomePage($VideoXML)	
	else
		"No Video Found"
};

(: local:GetVideoDetailsReport(" ",0,0,xs:dateTime("2015-01-01T00:00:00"),xs:dateTime("2015-01-23T00:00:00")) :)
(:
declare function GetVideoDetailsReport($TermToSearch as xs:string, $PageLength as xs:integer, $StartPage as xs:integer, $StartDate as xs:dateTime, $EndDate as xs:dateTime,$TextToSearch as xs:string,$Status as xs:string,$IncludeBlankSpeakerFlag as xs:string) as item()*
{
  let $Start := if($StartPage = 1) then $StartPage else fn:sum(($StartPage * $PageLength) - $PageLength + 1)
	let $SearchOption := <options xmlns="http://marklogic.com/appservices/search">
							<term>
								<term-option>case-insensitive</term-option>
								<term-option>wildcarded</term-option>
								<term-option>stemmed</term-option>
								<term-option>diacritic-insensitive</term-option>
								<term-option>punctuation-insensitive</term-option>
							</term>
							<constraint name="Video">
								<range type="xs:string" facet="true">
									<facet-option>frequency-order</facet-option>
									<facet-option>descending</facet-option>
                  <path-index>Video/@ID</path-index>
								</range>
							</constraint>
              <constraint name="PricingDetails">
								<range type="xs:string" facet="true">
									<facet-option>frequency-order</facet-option>
									<facet-option>descending</facet-option>
								 <path-index>PricingDetails/@type</path-index>
								</range>
							</constraint>
              <!-- Created By Constraint -->
              <constraint name="CreationInfo">
								<range type="xs:string" facet="true">
									<facet-option>frequency-order</facet-option>
									<facet-option>descending</facet-option>
								 <path-index>CreationInfo/Person/@ID</path-index>
								</range>
							</constraint>
              <!-- ModifiedInfo constraint -->
              <constraint name="ModifiedInfo">
								<range type="xs:string" facet="true">
									<facet-option>frequency-order</facet-option>
									<facet-option>descending</facet-option>
								 <path-index>ModifiedInfo/Person/@ID</path-index>
								</range>
							</constraint>
			
      <constraint name="Given-Name">
								<range type="xs:string" facet="true" collation="http://marklogic.com/collation/en/S1">
									<facet-option>frequency-order</facet-option>
									<facet-option>descending</facet-option>
								 <path-index>Speakers/Person/Name/Given-Name</path-index>
								</range>
				</constraint>
       <constraint name="Surname">
								<range type="xs:string" facet="true" collation="http://marklogic.com/collation/en/S1">
									<facet-option>frequency-order</facet-option>
									<facet-option>descending</facet-option>
								 <path-index>Speakers/Person/Name/Surname</path-index>
								</range>
				</constraint>
      
				<constraint name="UploadedBy">
								<range type="xs:string" facet="true">
									<facet-option>frequency-order</facet-option>
									<facet-option>descending</facet-option>
								 <path-index>UploadVideo/File/Person/@ID</path-index>
								</range>
				</constraint>
        <constraint name="ModifiedDate">
								<range type="xs:dateTime" facet="true">
									<facet-option>frequency-order</facet-option>
									<facet-option>descending</facet-option>
								 <path-index>ModifiedInfo/Date</path-index>
								</range>
				</constraint>
        
            
          		
						</options>
  
  let $ctsQuery := cts:query(search:parse($TermToSearch,$SearchOption,"cts:query"))
  
  let $SearchResponse := for $EachVideo in cts:search
                                    (collection($constants:VIDEO_COLLECTION)/Video,
                                    cts:and-query((
                                                  if ($StartDate!=xs:dateTime("1900-01-01T00:00:00") and $EndDate!=xs:dateTime("1900-01-01T00:00:00")) then
                                                    cts:and-query((
                                                      cts:path-range-query("ModifiedInfo/Date", ">=", $StartDate),
                                                      cts:path-range-query("ModifiedInfo/Date", "<=", $EndDate)
                                                                 )) 
                                                   else () ,
                                                   if ($IncludeBlankSpeakerFlag='Yes') 
                                                   then
                                                   cts:or-query(
                                                                  cts:not-query((
                                                                               cts:element-query( xs:QName("Speakers"), cts:and-query(()) )
                                                                               ))
                                                                  
                                                           )
                                                  else () ,
                                                  if (fn:contains($TermToSearch,"ModifiedInfo")) 
                                                    then
                                                    cts:and-query(
                                                                    cts:element-value-query(xs:QName("VideoStatus"),"Published")
                                                             )
                                                  else (),
                                                   if (fn:contains($TermToSearch,"UploadedBy")) 
                                                    then
                                                    cts:and-query(
                                                                    cts:path-range-query("UploadVideo/File/@active","=","Yes")
                                                                    
                                                             )
                                                  else () ,
                                                   if ($Status="Uploaded") 
                                                    then
                                                    cts:and-query(
                                                                    cts:path-range-query("UploadVideo/File/@active","=","Yes")
                                                                    
                                                             )
                                                  else () ,
                                                  if ($Status="Published") 
                                                    then
                                                    cts:and-query(
                                                                     cts:element-value-query(xs:QName("VideoStatus"),$Status)
                                                                    
                                                             )
                                                  else (),
                                                  
                                                  if ($IncludeBlankSpeakerFlag='Yes') 
                                                    then
                                                    cts:or-query(
                                                                    cts:not-query((
                                                                                 cts:element-query( xs:QName("Speakers"), cts:and-query(()) )
                                                                                 ))
                                                                    
                                                             )
                                                  else (),
                                                  if($TextToSearch!='')
                                                  then
                                                    
                                                      
                                                        cts:or-query((
                                                            for $EachTitle in cts:value-match(cts:path-reference('BasicInfo/Title'), fn:concat('*',$TextToSearch,'*'))
                                                            (: return cts:word-query($EachTitle, ("case-insensitive", "wildcarded", "stemmed", "diacritic-insensitive", "punctuation-insensitive")) :)
                                                            return cts:field-range-query("VideoTitle","=",$EachTitle)
                                                          ))
                                                      
                                                    
                                                  else (),
                                                  $ctsQuery  (:TermToSearch:)
                                                               
                                               ))
                                               ,"unfiltered"
                                     )
                               return $EachVideo
                
     
  let $VideoDoc := for $EachVideo in $SearchResponse
                   
                   let $VideoID := $EachVideo/@ID
                   let $IsCommentAvailable := if( collection(fn:concat($constants:COMMENT, fn:data($EachVideo/Video/@ID))) ) then fn:true() else fn:false()
                   let $VideoComments := fn:collection(concat("Comment-",$VideoID))
                   let $CommentCount := count($VideoComments/Comment)
                   return 
                   
                   <Video ID="{$VideoID}" comment="{if($IsCommentAvailable=fn:true()) then 'yes' else 'no'}">
                   { 
                     $EachVideo/BasicInfo/Title ,
                     <PriceDetails type="{$EachVideo/BasicInfo/PricingDetails/@type}"/> ,
                     <CreatedBy>{$EachVideo/CreationInfo/Person/Name}</CreatedBy>,
                     <ModifiedBy>{$EachVideo/ModifiedInfo/Person/Name}</ModifiedBy>,
                     <ModifiedDate>{$EachVideo/ModifiedInfo/Date}</ModifiedDate>,
                     <Speakers>{$EachVideo//Speakers/Person}</Speakers>,
                     $EachVideo/VideoType,
                     $EachVideo/BasicInfo/VideoCategory,
                     $EachVideo/LivePublish,
                     $EachVideo/BasicInfo/CopyrightDetails,
                     $EachVideo/AdvanceInfo/Adverts,
                     $EachVideo/UploadVideo,
                     $EachVideo/PublishInfo,
                     $EachVideo/VideoStatus,
					 $EachVideo/KeyWordInfo/ChannelKeywordList,
                     <NoOfComments>{$CommentCount}</NoOfComments> 
                    }
                   </Video>
				   
	  return ($VideoDoc) 
  
};
:)

declare function GetVideoDetailsReport($TermToSearch as xs:string, $PageLength as xs:integer, $StartPage as xs:integer, $StartDate as xs:dateTime, $EndDate as xs:dateTime,$TextToSearch as xs:string,$Status as xs:string,$IncludeBlankSpeakerFlag as xs:string) as item()*
{
  let $SearchOption :=	<options xmlns="http://marklogic.com/appservices/search">
								<term>
									<search-option>unfiltered</search-option>
									<term-option>case-insensitive</term-option>
									<term-option>wildcarded</term-option>
									<term-option>stemmed</term-option>
									<term-option>diacritic-insensitive</term-option>
									<term-option>punctuation-insensitive</term-option>
								</term>
								<constraint name="Video">
									<range type="xs:string" facet="true">
										<facet-option>frequency-order</facet-option>
										<facet-option>descending</facet-option>
										<path-index>Video/@ID</path-index>
									</range>
								</constraint>
								<constraint name="PricingDetails">
									<range type="xs:string" facet="true">
										<facet-option>frequency-order</facet-option>
										<facet-option>descending</facet-option>
										<path-index>PricingDetails/@type</path-index>
									</range>
								</constraint>
								<!-- Created By Constraint -->
								<constraint name="CreationInfo">
									<range type="xs:string" facet="true">
										<facet-option>frequency-order</facet-option>
										<facet-option>descending</facet-option>
										<path-index>CreationInfo/Person/@ID</path-index>
									</range>
								</constraint>
								<!-- ModifiedInfo constraint -->
								<constraint name="ModifiedInfo">
									<range type="xs:string" facet="true">
										<facet-option>frequency-order</facet-option>
										<facet-option>descending</facet-option>
										<path-index>ModifiedInfo/Person/@ID</path-index>
									</range>
								</constraint>
								<constraint name="Given-Name">
									<range type="xs:string" facet="true" collation="http://marklogic.com/collation/en/S1">
										<facet-option>frequency-order</facet-option>
										<facet-option>descending</facet-option>
										<path-index>Speakers/Person/Name/Given-Name</path-index>
									</range>
								</constraint>
								<constraint name="Surname">
									<range type="xs:string" facet="true" collation="http://marklogic.com/collation/en/S1">
										<facet-option>frequency-order</facet-option>
										<facet-option>descending</facet-option>
										<path-index>Speakers/Person/Name/Surname</path-index>
									</range>
								</constraint>
								<constraint name="UploadedBy">
									<range type="xs:string" facet="true">
										<facet-option>frequency-order</facet-option>
										<facet-option>descending</facet-option>
										<path-index>UploadVideo/File/Person/@ID</path-index>
									</range>
								</constraint>
								<constraint name="ModifiedDate">
									<range type="xs:dateTime" facet="true">
										<facet-option>frequency-order</facet-option>
										<facet-option>descending</facet-option>
										<path-index>ModifiedInfo/Date</path-index>
									</range>
								</constraint>
								<additional-query>{cts:collection-query($constants:VIDEO_COLLECTION)}</additional-query>
								<additional-query>
								{
									cts:and-query((
										if( $StartDate!=xs:dateTime("1900-01-01T00:00:00") and $EndDate!=xs:dateTime("1900-01-01T00:00:00") )
										then
											cts:and-query((
											  cts:path-range-query("ModifiedInfo/Date", ">=", $StartDate),
											  cts:path-range-query("ModifiedInfo/Date", "<=", $EndDate)
														 )) 
										else(),
										if( $IncludeBlankSpeakerFlag='Yes' ) 
										then
											cts:or-query((
														  cts:not-query((cts:element-query(xs:QName("Speakers"), cts:and-query(()) )))
														))
										else(),
										if( $Status="Published" ) 
										then	cts:element-value-query(xs:QName("VideoStatus"),$Status)
										else (),
										if( $TextToSearch!=' ' )
										then
											cts:or-query((
												for $EachTitle in cts:value-match(cts:path-reference('BasicInfo/Title'), fn:concat('*',$TextToSearch,'*'))
												return cts:field-range-query("VideoTitle","=",$EachTitle)
											  ))
										else ()
									))
								}
								</additional-query>
							</options>
  let $SearchResponse := search:search($TermToSearch, $SearchOption, $StartPage, $PageLength)
  let $VideoDoc := for $EachVideo in fn:doc($SearchResponse/search:result/@uri/string())/Video
                   let $VideoID := $EachVideo/@ID
                   let $IsCommentAvailable := if( collection(fn:concat($constants:COMMENT, fn:data($EachVideo/Video/@ID))) ) then fn:true() else fn:false()
                   let $VideoComments := fn:collection(concat("Comment-",$VideoID))
                   let $CommentCount := count($VideoComments/Comment)
                   return 
					   <Video ID="{$VideoID}" comment="{if($IsCommentAvailable=fn:true()) then 'yes' else 'no'}">
					   { 
						 $EachVideo/BasicInfo/Title ,
						 <PriceDetails type="{$EachVideo/BasicInfo/PricingDetails/@type}"/> ,
						 <CreatedBy>{$EachVideo/CreationInfo/Person/Name}</CreatedBy>,
						 <ModifiedBy>{$EachVideo/ModifiedInfo/Person/Name}</ModifiedBy>,
						 <ModifiedDate>{$EachVideo/ModifiedInfo/Date}</ModifiedDate>,
						 <Speakers>{$EachVideo//Speakers/Person}</Speakers>,
						 $EachVideo/VideoType,
						 $EachVideo/BasicInfo/VideoCategory,
						 $EachVideo/LivePublish,
						 $EachVideo/BasicInfo/CopyrightDetails,
						 $EachVideo/AdvanceInfo/Adverts,
						 $EachVideo/UploadVideo,
						 $EachVideo/PublishInfo,
						 $EachVideo/VideoStatus,
						 $EachVideo/KeyWordInfo/ChannelKeywordList,
						 <NoOfComments>{$CommentCount}</NoOfComments>,
						 <HideRecord>{fn:data($EachVideo/AdvanceInfo/PermissionDetails/Permission[@type="HideRecord"]/@status)}</HideRecord>
						}
					   </Video>
	  return ($VideoDoc) 
  
};