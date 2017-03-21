xquery version "1.0-ml";

import module namespace VIDEOS     = "http://www.TheIET.org/ManageVideos"      at "/Utils/ManageVideos.xqy";
import module namespace constants = "http://www.TheIET.org/constants"   at "/Utils/constants.xqy";

declare variable $inputSearchDetails as xs:string external ;

(:let $inputSearchDetails := "<root>
    <VideoType>PCopy</VideoType>
    <DateType>VideoUploadDate</DateType> 
    <StartDate>2016-04-15T17:25:58.0000</StartDate> 
    <EndDate>2016-12-15T17:25:58.0000</EndDate> 
</root>":)

let $Log 	   := xdmp:log("[ IET-TV ][ GetVideoDetailsNew ][ Call ][ Service call ]")
let $InputXml  := xdmp:unquote($inputSearchDetails)
let $VideoType := $InputXml/root/VideoType/text()
let $DateType  := $InputXml/root/DateType/text()
let $StartDate := xs:dateTime($InputXml/root/StartDate/text())
let $EndDate   := xs:dateTime($InputXml/root/EndDate/text())
let $RangeDateRecord := VIDEOS:RangeDateRecordProcessing($DateType,$VideoType,$StartDate,$EndDate)
let $VideoXml  := <root>{$RangeDateRecord}</root>

return
        (<root>
        {
        for $Video in $VideoXml/Video
        
                let $VideoID := $Video/@ID/string()
                let $VideoNumber := $Video//VideoNumber/text()
                let $VideoURL := $Video//VideoURL/text()
                let $Title := $Video//BasicInfo/Title/text()
                let $VideoCreatedDate := $Video//BasicInfo/VideoCreatedDate/text()
                let $S_Description := $Video//BasicInfo/ShortDescription/text()
                let $L_Description := $Video//BasicInfo/Abstract//text() 
                let $Location := $Video//Events//Location/LocationName/text()
                let $City := $Video//Events//Location/Address/City/text()
                let $Country := $Video//Events//Location/Address/Country/text()
                let $VideoType := $Video//VideoType/text()
                let $Channel := $Video//BasicInfo/ChannelMapping//ChannelName/text()
                let $Pricing := $Video//BasicInfo/PricingDetails/@type/string()
                let $IsHidden := $Video//AdvanceInfo/PermissionDetails/Permission[2]/@status/string()
                let $Filename := $Video//UploadVideo/File/FileName/string()
                let $Duration := $Video//UploadVideo/File/Duration/string()
                let $StreamID := $Video//UploadVideo/File/@streamID/string()
                let $VideoFinalPublishDate := $Video//PublishInfo/VideoPublish/FinalStartDate/text()
                let $VideoLivePublishDate := $Video//PublishInfo/LivePublish/LiveFinalStartDate/text()
        
        return
                <record>
                        <VideoID>{$VideoID}</VideoID>
                        <VideoNumber>{$VideoNumber}</VideoNumber>
                        <VideoURL>{$VideoURL}</VideoURL>
                        <Title>{$Title}</Title>
                        <VideoCreatedDate>{$VideoCreatedDate}</VideoCreatedDate>
                        <DescriptionShort>{$S_Description}</DescriptionShort>
                        <DescriptionLong>{$L_Description}</DescriptionLong>
                        <Location>{$Location}</Location>
                        <City>{$City}</City>
                        <Country>{$Country}</Country>
                        <VideoType>{$VideoType}</VideoType>
                        <Channel>{$Channel}</Channel>
                    	<Pricing>{$Pricing}</Pricing>
                    	<IsHidden>{$IsHidden}</IsHidden>
                        <Filename>{$Filename}</Filename>
                        <Duration>{$Duration}</Duration>
                        <StreamID>{$StreamID}</StreamID>
                    	<VideoFinalPublishYear>{fn:year-from-dateTime($VideoFinalPublishDate)}</VideoFinalPublishYear>
                        <VideoFinalPublishDate>{$VideoFinalPublishDate}</VideoFinalPublishDate>
                        <VideoLivePublishDate>{$VideoLivePublishDate}</VideoLivePublishDate>
                </record>
        }
        </root>,
        xdmp:log("[ IET-TV ][ GetVideoDetailsNew ][ Call ][ Service result sent ]")
        )