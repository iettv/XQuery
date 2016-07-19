xquery version "1.0-ml";

import module namespace constants = "http://www.TheIET.org/constants"   at "/Utils/constants.xqy"; 

(:~ This service will consume external parameter to evaluate output.
	: @ChannelID - Its value is optional. If it is present, script will output title of that specific channel only. Otherwise all.
	: @SkipChannel - Keeps Channel ID - Inactive/Private/Staff-Channel so that script may ignore those Channels.
	: @Title  - The text of the title which 'Admin' user wants to search/set.
	: <Video><SkipChannel><ID>1</ID><ID>2</ID><ID>3</ID></SkipChannel><ChannelID>2</ChannelID><Title>TEXT</Title></Video>
:)

declare variable $inputSearchDetails as xs:string external;

let $InputParam  := xdmp:unquote($inputSearchDetails)
let $Log         := xdmp:log("[ CarouselActiveTitles ][ CALL ][ Service called successfully!!! ]")
let $Log         := xdmp:log($InputParam)
let $SkipChannel := $InputParam/Video/SkipChannel//text()
let $TitleText   := $InputParam/Video/Title/text()
let $ChannelID   := $InputParam/Video/ChannelID/text()
return
	if($SkipChannel)
	then
		if($ChannelID!='')
		then
			<Titles>
				{
				  for $Video in collection($constants:PCOPY)/Video/BasicInfo[ChannelMapping/Channel[@ID=$ChannelID]]
																			[fn:contains(lower-case(Title/text()), lower-case($TitleText))]
																			[../AdvanceInfo/PermissionDetails[Permission[@type eq "HideRecord" and @status eq "no"]]]
																			[../PublishInfo/VideoPublish/FinalExpiryDate[(.="1900-01-01T00:00:00.0000") or (. ge fn:current-dateTime())]]
																			(:[not(ChannelMapping/Channel/@ID = $constants:MasterChannelXml/Channels/Channel[Status='Inactive']/ID)]:)
																			(:[not(ChannelMapping/Channel/@ID = $SkipChannel)]:)
				  let $VideoID := fn:data($Video/ancestor::Video/@ID)
				  let $Titile  := $Video/Title
				  return <Video><ID>{$VideoID}</ID>{$Titile}</Video>
				}
			</Titles>
		else
			<Titles>
				{
				  for $Video in collection($constants:PCOPY)/Video/BasicInfo[not(ChannelMapping/Channel/@ID = $SkipChannel)]
																			[fn:contains(lower-case(Title/text()), lower-case($TitleText))]
																			[../AdvanceInfo/PermissionDetails[Permission[@type eq "HideRecord" and @status eq "no"]]]
																			[../PublishInfo/VideoPublish/FinalExpiryDate[(.="1900-01-01T00:00:00.0000") or (. ge fn:current-dateTime())]]
																			(:[not(ChannelMapping/Channel/@ID = $constants:StaffChannelXml/Channels/Channel)]
																			[not(ChannelMapping/Channel/@ID = $constants:MasterChannelXml/Channels/Channel[Status='Inactive']/ID)]:)
				  let $VideoID := fn:data($Video/ancestor::Video/@ID)
				  let $Titile  := $Video/Title
				  return <Video><ID>{$VideoID}</ID>{$Titile}</Video>
				}
			</Titles>
	else
		(
			xdmp:log("[ CarouselActiveTitles ][ ERROR ][ Skip Channel List is absent. ]"),
			"ERROR: Skip Channel List is absent"
		)