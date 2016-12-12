xquery version "1.0-ml";

import module namespace VIDEOS     = "http://www.TheIET.org/ManageVideos"   at  "../Utils/ManageVideos.xqy";
import module namespace constants  = "http://www.TheIET.org/constants"      at  "../Utils/constants.xqy";
import module namespace CHANNEL =  "http://www.TheIET.org/ManageChannel"    at  "../Utils/ManageChannel.xqy";

	for $EachChannel in collection($constants:CHANNEL_CONFIG)
	let $ChannelCarouselUri := base-uri($EachChannel)
	let $ChannelId := substring-before(substring-after($ChannelCarouselUri,$constants:PopularByChannel),'.xml')
	let $Log := xdmp:log(concat("[ IET-TV ][ Channel Carousel Scheduler ][ Call ][ ======================= Channel Carousel Scheduler started (", $ChannelId,") ======================= ]"))
	let $CarouselXml := doc($ChannelCarouselUri)
	let $UpdatedCarouseXml := CHANNEL:ConfigureChannelCarouselVideos($CarouselXml,$ChannelId, "Scheduler")
    return
		(
			if($UpdatedCarouseXml!="ERROR")
			then
				(
					xdmp:document-insert($ChannelCarouselUri, $UpdatedCarouseXml,(),$constants:CHANNEL_CONFIG),
					xdmp:log(concat("[ IET-TV ][ Channel Carousel Scheduler ][ Success ][ Carousel configuration file updated by scheduler for Channel = ", $ChannelId," ]"))
				)
			else
				xdmp:log("[ ChannelCarouselConfigurationScheduler ][ ERROR ][ Some Video ID is not present to set configuration ]")
			,
			xdmp:log(concat("[ IET-TV ][ Channel Carousel Scheduler ][ End ][ ======================= Channel Carousel Scheduler end (", $ChannelId,") ======================= ]"))
		)