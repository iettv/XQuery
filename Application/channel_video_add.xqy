xquery version "1.0-ml";

import module namespace constants = "http://www.TheIET.org/constants"     at "/Utils/constants.xqy"; 
import module namespace CHANNEL   = "http://www.TheIET.org/ManageChannel" at "/Utils/ManageChannel.xqy";

(: <ChannelConfiguration ChannelId="1" ChannelName="abc"><Channel><PositionId>1</PositionId><VideoId>02</VideoId><Type>VideoId</Type></Channel></ChannelConfiguration> :)
declare variable $inputSearchDetails as xs:string external ;

let $ChannelXml  := xdmp:unquote($inputSearchDetails)
let $ChannelDirectory := $constants:ADMIN_DIRECTORY
let $ChannelID   := data($ChannelXml/ChannelConfiguration/@ChannelId)
let $ChannelUri := fn:concat($ChannelDirectory,$constants:PRE_CHANNEL_CONFIG,$ChannelID,".xml")
let $CheckVideoID := CHANNEL:isVideoIDExists($ChannelXml,$ChannelID)
let $CheckType := CHANNEL:checkChannelConfigurationType($ChannelXml)
let $CheckConfigVideoCount := count($ChannelXml/ChannelConfiguration/Channel)
return
  (: Channel ID checking :)
  if( $ChannelID = '' )
  then
    (
      xdmp:log(concat("[ ChannelVideoIngestion ][ ERROR ][ Client ID does not exist in proper format ][ Provided channeil ID is : ", $ChannelID, " ]")),
      "ERROR: Please provide channel ID. It does not exist or it is in improper format. Keep it as <ChannelConfiguration ChannelId='x'>"
    )
  else
   (: To check invalid Video ID -- # is the delimiter of invalid Video ID, which are not in ML Database or not related to this channel :)
  if( contains($CheckVideoID,'#') or $CheckVideoID!='' )
  then
    (
      xdmp:log(("[ ChannelVideoIngestion ][ ERROR ][ Some Video ID(s) does not exists or not related to this channel or Video is hidden or Video is expired ]", $CheckVideoID)),
      $CheckVideoID (: to revert back invalid ID(s) :)
    )
  else
  (: To check Type value it should be match to 'MostPopularVideo|LatestVideo|VideoId :)
  if( $CheckType eq  fn:false() )
  then
    (
      xdmp:log(("[ ChannelVideoIngestion ][ ERROR ][ Some provided type does not match with the required. It must be match to 'MostPopularVideo|LatestVideo|VideoId", $ChannelXml)),
      "ERROR: Some provided type does not match. It must be equal to 'MostPopularVideo|LatestVideo|VideoId'"
    )
  else
 if( $CheckConfigVideoCount lt 9 )
 then
    (
      xdmp:log(("[ ChannelVideoIngestion ][ ERROR ][ Needs to provide configuration for 3 to 9 videos only ][ Current count is :", $CheckConfigVideoCount)),
      "ERROR: Please set configuration for 3 to 9 videos only."
    )
  else
    let $ChannelXml := CHANNEL:ConfigureChannelCarouselVideos($ChannelXml,$ChannelID, "Admin")
    return
        if($ChannelXml != "ERROR")
        then
          (
			xdmp:document-insert($ChannelUri, $ChannelXml, (), $constants:CHANNEL_CONFIG),
			xdmp:log("[ ChannelConfiguration ][ SUCCESS ][ Configuration has been set successfully ]"),
			"SUCCESS"
          )
        else "ERROR"



