xquery version "1.0-ml";

(: This is useful to send back Carousel Configuration  :)
(: input format : <ChannelConfiguration><ChannelId>8</ChannelId></ChannelConfiguration> :)

import module namespace CHANNEL    = "http://www.TheIET.org/ManageChannel" at "/Utils/ManageChannel.xqy";
import module namespace constants  = "http://www.TheIET.org/constants"     at  "/Utils/constants.xqy";


declare variable $inputSearchDetails as xs:string external;
let $ChannelID := xdmp:unquote($inputSearchDetails)/ChannelConfiguration/ChannelId/text()
let $ChannelUri := fn:concat($constants:ADMIN_DIRECTORY,$constants:PRE_CHANNEL_CONFIG,$ChannelID,".xml")
return
    if($ChannelID="All")
	then
		for $EachChannelConfig in cts:uri-match(concat($constants:PopularByChannel,"*"))
		let $ChannelCarouselConfig := fn:doc($EachChannelConfig)
		let $ChannelID := data($ChannelCarouselConfig/ChannelConfiguration/@ChannelId)
		  return
			<ChannelConfiguration ChannelId="{$ChannelID}">
			  {
				for $EachVideo in $ChannelCarouselConfig/ChannelConfiguration/Channel
				let $ConfigureType := $EachVideo/Type/string()
				return
				  if($ConfigureType="VideoId") then $EachVideo else
				  if($ConfigureType="LatestVideo") then <Channel><PositionId>{$EachVideo/PositionId/string()}</PositionId><VideoId></VideoId><Type>LatestVideo</Type></Channel> else
				  if($ConfigureType="MostPopularVideo") then <Channel><PositionId>{$EachVideo/PositionId/string()}</PositionId><VideoId></VideoId><Type>MostPopularVideo</Type></Channel> else ()
			  }
			</ChannelConfiguration>
	else
	if( fn:doc-available($ChannelUri) )
    then
      let $ChannelCarouselConfig := fn:doc($ChannelUri)
      return
        <ChannelConfiguration ChannelId="{$ChannelID}">
          {
            for $EachVideo in $ChannelCarouselConfig/ChannelConfiguration/Channel
            let $ConfigureType := $EachVideo/Type/string()
            return
              if($ConfigureType="VideoId")
			  then
					let $VideoID     := $EachVideo/VideoId/text()
					let $PHistoryUri := concat($constants:PCOPY_DIRECTORY,$VideoID,".xml")
					let $VideoTitle  := doc($PHistoryUri)/Video/BasicInfo/Title/text()
					return <Channel><PositionId>{$EachVideo/PositionId/string()}</PositionId><VideoId>{$VideoID}</VideoId><Type>VideoId</Type><VideoTitle>{$VideoTitle}</VideoTitle></Channel>
			  else
              if($ConfigureType="LatestVideo") then <Channel><PositionId>{$EachVideo/PositionId/string()}</PositionId><VideoId></VideoId><Type>LatestVideo</Type></Channel> else
              if($ConfigureType="MostPopularVideo") then <Channel><PositionId>{$EachVideo/PositionId/string()}</PositionId><VideoId></VideoId><Type>MostPopularVideo</Type></Channel> else ()
          }
        </ChannelConfiguration>
    else ( xdmp:log("[ ChannelConfig ][ No configuration file is available to send ]"), "ERROR! No Channel Configuration file is available.")
