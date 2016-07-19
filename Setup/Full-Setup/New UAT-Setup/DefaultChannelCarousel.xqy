
import module namespace constants     = "http://www.TheIET.org/constants"      at "/Utils/constants.xqy";

(:<ChannelConfiguration ChannelId="21" ChannelName="Disney"><Channel><PositionId>1</PositionId><VideoId></VideoId><Type>LatestVideo</Type></Channel><Channel><PositionId>2</PositionId><VideoId></VideoId><Type>LatestVideo</Type></Channel><Channel><PositionId>3</PositionId><VideoId></VideoId><Type>LatestVideo</Type></Channel><Channel><PositionId>4</PositionId><VideoId></VideoId><Type>LatestVideo</Type></Channel><Channel><PositionId>5</PositionId><VideoId></VideoId><Type>LatestVideo</Type></Channel><Channel><PositionId>6</PositionId><VideoId></VideoId><Type>LatestVideo</Type></Channel><Channel><PositionId>7</PositionId><VideoId></VideoId><Type>LatestVideo</Type></Channel><Channel><PositionId>8</PositionId><VideoId></VideoId><Type>LatestVideo</Type></Channel><Channel><PositionId>9</PositionId><VideoId></VideoId><Type>LatestVideo</Type></Channel></ChannelConfiguration>:)
(:<Channels><Channel><ChannelName>ABC</ChannelName><ChannelID>1</ChannelID></Channel><Channel><ChannelName>DEF</ChannelName><ChannelID>2</ChannelID></Channel><Channel><ChannelName>GHI</ChannelName><ChannelID>3</ChannelID></Channel><Channel><ChannelName>JKL</ChannelName><ChannelID>4</ChannelID></Channel><Channel><ChannelName>MNO</ChannelName><ChannelID>5</ChannelID></Channel><Channel><ChannelName>PQR</ChannelName><ChannelID>6</ChannelID></Channel><Channel><ChannelName>STU</ChannelName><ChannelID>7</ChannelID></Channel><Channel><ChannelName>VWX</ChannelName><ChannelID>8</ChannelID></Channel></Channels>:)
 
declare variable $inputSearchDetails as xs:string external ;

let $ChannelXml  := xdmp:unquote($inputSearchDetails)
for $eachChannel in $ChannelXml//Channel
let $ChannelID := $eachChannel/ChannelID/text()
let $ChannelUri := fn:concat($constants:ADMIN_DIRECTORY,$constants:PRE_CHANNEL_CONFIG,$ChannelID,".xml")
let $DefaultChannelCarouselXML := <ChannelConfiguration ChannelId="{$eachChannel/ChannelID/text()}" ChannelName="{$eachChannel/ChannelName/text()}"><Channel><PositionId>1</PositionId><VideoId>Latest Video is unavailable</VideoId><Type>LatestVideo</Type></Channel><Channel><PositionId>2</PositionId><VideoId>Latest Video is unavailable</VideoId><Type>LatestVideo</Type></Channel><Channel><PositionId>3</PositionId><VideoId>Latest Video is unavailable</VideoId><Type>LatestVideo</Type></Channel><Channel><PositionId>4</PositionId><VideoId>Latest Video is unavailable</VideoId><Type>LatestVideo</Type></Channel><Channel><PositionId>5</PositionId><VideoId>Latest Video is unavailable</VideoId><Type>LatestVideo</Type></Channel><Channel><PositionId>6</PositionId><VideoId>Latest Video is unavailable</VideoId><Type>LatestVideo</Type></Channel><Channel><PositionId>7</PositionId><VideoId>Latest Video is unavailable</VideoId><Type>LatestVideo</Type></Channel><Channel><PositionId>8</PositionId><VideoId>Latest Video is unavailable</VideoId><Type>LatestVideo</Type></Channel><Channel><PositionId>9</PositionId><VideoId>Latest Video is unavailable</VideoId><Type>LatestVideo</Type></Channel></ChannelConfiguration>
return 
(
	xdmp:document-insert($ChannelUri, $DefaultChannelCarouselXML, (), $constants:CHANNEL_CONFIG),
	xdmp:log(concat("[ DefaultChannelCarouselConfiguration ][ SUCCESS ][ Configuration has been set successfully for ChannelID- ",$ChannelID))
)