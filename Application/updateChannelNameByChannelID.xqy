xquery version "1.0-ml";
import module namespace VIDEOS = "http://www.TheIET.org/ManageVideos"   at "/Utils/ManageVideos.xqy";

(: Input Params : "<Channels><Channel><ChannelID>127</ChannelID><ChannelName>TLC</ChannelName></Channel></Channels>" :)

declare variable $inputSearchDetails as xs:string external;

let $InputXML  := xdmp:unquote($inputSearchDetails)
let $ChannelID := $InputXML//ChannelID/text()
let $ChannelName :=$InputXML//ChannelName/text()
return
	if(not($ChannelID))
	then
		(
			xdmp:log("ChannelID is empty")
			,
			"ChannelID is empty"
		)
	else
	if(not($ChannelName))
	then
		(
			xdmp:log("ChannelName is empty")
			,
			"ChannelName is empty"
		)
	else
		(
			let $ChannelConfig := xdmp:node-replace(doc(concat("/Admin/Channel-",$ChannelID,".xml"))/ChannelConfiguration[@ChannelId eq $ChannelID]/@ChannelName , attribute ChannelName {$ChannelName})
			for $EachCollection in (collection("Video"),collection("PublishedCopy"))
			return
				(
					xdmp:node-replace($EachCollection/Video/BasicInfo/ChannelMapping/Channel[@ID eq $ChannelID]/ChannelName, <ChannelName>{$ChannelName}</ChannelName>)
					,
					xdmp:node-replace($EachCollection/Video/KeyWordInfo/ChannelKeywordList/Channel[@ID eq $ChannelID]/ChannelName, <ChannelName>{$ChannelName}</ChannelName>)
				)
			,
			 (
				"SUCCESS"
				,
				xdmp:log(concat("ChannelName has been Successfully Updated for ChannelID-",$ChannelID))
			 )
				 
		)

