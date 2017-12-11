xquery version "1.0-ml";
import module namespace constants = "http://www.TheIET.org/constants"   at "/Utils/constants.xqy"; 

(: To get Speaker suggestion  <Speakers><Name>TEXT</Name></Speakers> :)
(:

	[AdvanceInfo/PermissionDetails/Permission[@type eq "HideRecord" and @status eq "no"] and
															   PublishInfo/VideoPublish/FinalExpiryDate[(.="1900-01-01T00:00:00.0000") or (. ge fn:current-dateTime())] and
															   PublishInfo/VideoPublish/FinalStartDate[(.="1900-01-01T00:00:00.0000") or (. ge fn:current-dateTime())]
															   ]
	
:)
declare variable $inputSearchDetails as xs:string external;

let $SpeakerXML  := xdmp:unquote($inputSearchDetails)
let $SpeakerText   := $SpeakerXML//Name/text()

return
	if($SpeakerText)
	then
	(
	let $speakerNames := <Speakers>
						{
							for $Video in collection("Video")/Video
											[ PublishInfo/VideoPublish/FinalExpiryDate[(.="1900-01-01T00:00:00.0000") or (. ge fn:current-dateTime())] and
											  PublishInfo/VideoPublish/FinalStartDate[(.="1900-01-01T00:00:00.0000") or (. le fn:current-dateTime())]
											]
											/Speakers/Person/Name[(fn:contains(lower-case(Given-Name/text()), lower-case($SpeakerText))) or (fn:contains(lower-case(Surname/text()), lower-case($SpeakerText)))]
							
							let $Given-Name := $Video/Given-Name/text()
							let $Surname := $Video/Surname/text()
							return <Name><Full-Name>{normalize-space(concat(lower-case($Given-Name)," ",lower-case($Surname)))}</Full-Name></Name>
						}
						</Speakers>
						
    let $distinctNames :=  	for $eachName in distinct-values($speakerNames//Full-Name/string())
							return <Full-Name>{$eachName}</Full-Name>
    return <Speakers>{$distinctNames}</Speakers>
	)
	
	else "Speaker Text is empty"
