xquery version "1.0-ml";

(:
  This service is useful to get all Channel Landing Page by ChannelID 
  input format : <ChannelPage><ChannelId>8</ChannelId><Popular>3</Popular><ForthComing>3</ForthComing><Latest>4</Latest></ChannelPage> 
:)

import module namespace CHANNEL    = "http://www.TheIET.org/ManageChannel"   at  "/Utils/ManageChannel.xqy";
import module namespace common     = "http://www.TheIET.org/common"          at  "/Utils/common.xqy";
import module namespace constants  = "http://www.TheIET.org/constants"       at  "/Utils/constants.xqy";

declare variable $inputSearchDetails as xs:string external;

let $ParamXML := xdmp:unquote($inputSearchDetails)
let $ChannelID := $ParamXML/ChannelPage/ChannelId/text()
let $PopularCount := $ParamXML/ChannelPage/Popular/text()
let $ForthComingCount := $ParamXML/ChannelPage/ForthComing/text()
let $LatestCount := $ParamXML/ChannelPage/Latest/text()
let $ChannelUri := fn:concat($constants:ADMIN_DIRECTORY,$constants:PRE_CHANNEL_CONFIG,$ChannelID,".xml")

let $TotalPopularCount:= count(CHANNEL:GetChannelMostPopularFile($ChannelID)//Video)
let $TotalForthComingCount := count(doc(concat($constants:ChannelForthComing,$ChannelID,".xml"))//VideoID)
let $TotalLatestCount := count(doc(concat($constants:ChannelLatest,$ChannelID,".xml"))//VideoID)

return
  if( $ChannelID = '' or (string-length($ChannelID) = 0) )
  then
    (
      xdmp:log(concat("[ ChannelLandingPage ][ ERROR ][ Client ID does not exist in proper format ][ Provided channel ID is : ", $ChannelID, " ]")),
      "ERROR: Please provide channel ID. It does not exist or it is in improper format. Keep it as  <ChannelPage><ChannelId>x</ChannelId></ChannelPage>"
    )
  else
  if( $PopularCount = '' or $PopularCount = 0 or (string-length($PopularCount) = 0) )
  then
    (
      xdmp:log(concat("[ ChannelLandingPage ][ ERROR ][ Required count value of Most Popular Video is missing. ][ Provided value is : ", $PopularCount, " ]")),
      "ERROR: Please provide count to get popular videos. It does not exist or it is in improper format. Keep it as  <ChannelPage><Popular>x</Popular></ChannelPage>"
    )
  else
  if( $ForthComingCount = '' or $ForthComingCount = 0 or (string-length($ForthComingCount) = 0) )
  then
    (
      xdmp:log(concat("[ ChannelLandingPage ][ ERROR ][ Required count value of Fourth Coming Video is missing. ][ Provided value is : ", $ForthComingCount, " ]")),
      "ERROR: Please provide count to get forth coming videos. It does not exist or it is in improper format. Keep it as  <ChannelPage><ForthComing>x</ForthComing></ChannelPage>"
    )
  else
  if( $LatestCount = '' or $LatestCount = 0 or (string-length($LatestCount) = 0) )
  then
    (
      xdmp:log(concat("[ ChannelLandingPage ][ ERROR ][ Required count value of Latest Video is missing. ][ Provided value is : ", $LatestCount, " ]")),
      "ERROR: Please provide count to get latest videos. It does not exist or it is in improper format. Keep it as  <ChannelPage><Latest>x</Latest></ChannelPage>"
    )
  else
  if( fn:doc-available($ChannelUri) )
  then
	  let $ChannelVideos := <Videos>
							<TotalPopularCount>{$TotalPopularCount}</TotalPopularCount>
							<TotalForthComingCount>{$TotalForthComingCount}</TotalForthComingCount>
							<TotalLatestCount>{$TotalLatestCount}</TotalLatestCount>
								{
									( CHANNEL:GetChannelCarousel($ChannelID), CHANNEL:getChannelMostPopularByCount($ChannelID,$PopularCount), CHANNEL:GetChannelForthComingByCount($ChannelID,$ForthComingCount), CHANNEL:GetChannelLatestVideoByCount($ChannelID,$LatestCount) )
								}
							</Videos>
		return
			if( $ChannelVideos != "ERROR" )
			then
			  (
				$ChannelVideos,
				xdmp:log("[ ChannelLandingPage ][ SUCCESS ][ Channel landing page has been sent successfully ]")
			  )
			else
			  "ERROR"
	else
    (
		xdmp:log(fn:concat("[ ChannelConfig ][ No configuration file is available to send for Channel ", $ChannelID, " ]")),
		fn:concat("ERROR: No Channel configuration file is exist for channel ", $ChannelID)
    )
	