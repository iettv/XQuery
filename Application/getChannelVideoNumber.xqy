xquery version "1.0-ml";

import module namespace constants = "http://www.TheIET.org/constants"   at "/Utils/constants.xqy"; 
import module namespace VIDEOS = "http://www.TheIET.org/ManageVideos"   at  "/Utils/ManageVideos.xqy";
import module namespace CHANNEL   = "http://www.TheIET.org/ManageChannel" at "/Utils/ManageChannel.xqy";


(: <VideoReport><Mode>ChannelPopular</Mode><Channels><Channel><ChannelName>ABC</ChannelName><ChannelID>2210</ChannelID></Channel><Channel><ChannelName>ABC</ChannelName><ChannelID>2208</ChannelID></Channel></Channels></VideoReport> :)
declare variable $inputSearchDetails as xs:string external;

let $InputXML  := xdmp:unquote($inputSearchDetails, "", ("format-xml", "repair-full"))
let $Mode := $InputXML//Mode
let $Channels := $InputXML//Channels
let $Type := $InputXML//Type
return
	if($Mode eq "ChannelPopular")
	then
	(
		let $AllVideoPopular :=	<AllChannelVideoPopular>
								{
								for $eachID in $Channels/Channel
								let $count := xs:integer(0)
								let $MostPopularXml := CHANNEL:GetChannelMostPopularFile($eachID/ChannelID/text())
								let $EachChannelVideos := 	<Channel ChannelName="{$eachID/ChannelName/text()}" ID="{$eachID/ChannelID/text()}">
															{
															(
															for $each in $MostPopularXml//Video
															let $doc := doc(concat("/PCopy/",$each//VideoID/text(),".xml"))
															let $count := xdmp:set($count,sum($count+xs:integer($each//Count/text())))
															order by xs:dateTime($doc/Video/FilteredPubDate), xs:dateTime($doc/Video/BasicInfo/VideoCreatedDate)
															return <Video><VideoNumber>{$doc/Video/VideoNumber/text()}</VideoNumber><Title>{$doc/Video/BasicInfo/Title/text()}</Title><Views>{$each//Count/text()}</Views><PricingType>{$doc/Video/BasicInfo/PricingDetails/@type/string()}</PricingType>
															<PublishDate>{$doc/Video/FilteredPubDate/text()}</PublishDate>
															<MofifiedByFirstName>{$doc/Video/ModifiedInfo/Person/Name/Given-Name/text()}</MofifiedByFirstName>
															<MofifiedByLastName>{$doc/Video/ModifiedInfo/Person/Name/Surname/text()}</MofifiedByLastName>
															{
																$doc/Video/BasicInfo/VideoCreatedDate,
																$doc/Video/BasicInfo/ShortDescription,
																$doc/Video/BasicInfo/Abstract,
																$doc/Video/Speakers
															}
															</Video>
															,
															<Count>{$count}</Count>
															)
															}
															</Channel>
								return $EachChannelVideos
								}
								</AllChannelVideoPopular>
		return <ChannelReport>{$AllVideoPopular}</ChannelReport>
	)
	else
	(
		let $AllVideoChannel :=	<AllVideoChannel>
								{
								for $eachID in $Channels/Channel
								let $channelVideos := cts:search(collection("PublishedCopy"), cts:element-attribute-range-query(xs:QName("Channel"),xs:QName("ID"), "=",$eachID/ChannelID/text()) )
								let $count := count($channelVideos)
								let $EachChannelVideos := <ChannelName ChannelName="{$eachID/ChannelName/text()}" ID="{$eachID/ChannelID/text()}">
														  {
														  (
														  <Count>{$count}</Count>
														  ,
														  for $each in $channelVideos
														  order by xs:dateTime($each/Video/FilteredPubDate),xs:dateTime($each/Video/BasicInfo/VideoCreatedDate)
														  return <Video><VideoNumber>{$each/Video/VideoNumber/text()}</VideoNumber><Title>{$each/Video/BasicInfo/Title/text()}</Title><PricingType>{$each/Video/BasicInfo/PricingDetails/@type/string()}</PricingType>
															<PublishDate>{$each/Video/FilteredPubDate/text()}</PublishDate>
															<MofifiedByFirstName>{$each/Video/ModifiedInfo/Person/Name/Given-Name/text()}</MofifiedByFirstName>
															<MofifiedByLastName>{$each/Video/ModifiedInfo/Person/Name/Surname/text()}</MofifiedByLastName>
															{
																$each/Video/BasicInfo/VideoCreatedDate,
																$each/Video/BasicInfo/ShortDescription,
																$each/Video/BasicInfo/Abstract,
																$each/Video/Speakers,
																$each/Video/UploadVideo/File/Duration
															}
														  </Video>
														  )
														  }
														  </ChannelName>
								return $EachChannelVideos
								}
								</AllVideoChannel>
		return $AllVideoChannel
	)
