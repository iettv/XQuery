xquery version "1.0-ml";

import module namespace VIDEOS     = "http://www.TheIET.org/ManageVideos"   at  "../Utils/ManageVideos.xqy";
import module namespace constants  = "http://www.TheIET.org/constants"      at  "../Utils/constants.xqy";
import module namespace CAROUSEL   = "http://www.TheIET.org/ManageCarousel" at  "../Utils/ManageCarousel.xqy";

	let $Log := xdmp:log("[ IET-TV ][ Carousel Scheduler ][ Call ][ ======================= Carousel Scheduler started ======================= ]")
	let $CarouselXml := doc($constants:CarouselFile)
	let $UpdatedCarouseXml := CAROUSEL:ConfigureCarouselVideos($CarouselXml, "Scheduler")
    return
		(
			if($UpdatedCarouseXml!="ERROR")
			then
				(
					xdmp:document-insert($constants:CarouselFile, $UpdatedCarouseXml),
					xdmp:log("[ IET-TV ][ Carousel Scheduler ][ Success ][ Carousel configuration file updated by scheduler ]")
				)
			else
				xdmp:log("[ CarouselConfigurationScheduler ][ ERROR ][ Some Video ID is not present to set configuration ]")
			,
			xdmp:log("[ IET-TV ][ Carousel Scheduler ][ End ][ ======================= Carousel Scheduler end ======================= ]")
		)