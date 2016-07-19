xquery version "1.0-ml";

declare variable $inputSearchDetails as xs:string external ;

declare function local:RangeDateData($DateType as xs:string,$StartDate as xs:dateTime,$EndDate as xs:dateTime)
{
        let $data :=  cts:and-query((
                                    cts:element-range-query(xs:QName($DateType), ">=", xs:dateTime($StartDate)),
                                    cts:element-range-query(xs:QName($DateType), "<=", xs:dateTime($EndDate))) )
        return $data									
}; 

(: let $inputSearchDetails := "<root>
    <DateType>VideoUploadDate</DateType> 
    <StartDate>2016-04-15T17:25:58.0000</StartDate> 
    <EndDate>2016-04-15T17:25:58.0000</EndDate> 
</root>" :)

let $input := xdmp:unquote($inputSearchDetails)

let $DateType := $input/root/DateType/text()

let $StartDate := xs:dateTime($input/root/StartDate/text())

let $EndDate := xs:dateTime($input/root/EndDate/text())

let $ResultData :=  if($DateType="VideoCreatedDate")
                    then (
                            cts:search(doc()[contains(base-uri(),'/PCopy/')][//VideoCreatedDate[text()!='']],local:RangeDateData("VideoCreatedDate",$StartDate,$EndDate))
                          )
                    else if($DateType="VideoUploadDate")
                    then (
                            cts:search(doc()[contains(base-uri(),'/PCopy/')][//UploadVideo/File/UploadDate[text()!='']],local:RangeDateData("UploadDate",$StartDate,$EndDate))
                          )
                    else if($DateType="FinalPublishDate")
                    then (
                            cts:search(doc()[contains(base-uri(),'/PCopy/')][//PublishInfo/VideoPublish[@active='yes']],
                            cts:or-query(( local:RangeDateData("FinalStartDate",$StartDate,$EndDate),
                            local:RangeDateData("RecordStartDate",$StartDate,$EndDate)
                            )))
                        ) 
                    else if($DateType="FinalPublishDate")
                    then (
                            cts:search(doc()[contains(base-uri(),'/PCopy/')][//PublishInfo/LivePublish[@active='yes']],
                            cts:or-query(( local:RangeDateData("LiveFinalStartDate",$StartDate,$EndDate),
                            local:RangeDateData("LiveRecordStartDate",$StartDate,$EndDate)
                            )))
                        ) 
                     
                    else if($DateType="RecordCreatedDate")
                    then (
                            cts:search(doc()[contains(base-uri(),'/PCopy/')][contains(//CreationInfo/Date,'T')],cts:or-query((
                            cts:and-query((
                                    cts:path-range-query("ModifiedInfo/Date", ">=", xs:dateTime($StartDate)),
                                    cts:path-range-query("ModifiedInfo/Date", "<=", xs:dateTime($EndDate))) ),
                            cts:and-query((
                                    cts:path-range-query("CreationInfo/Date", ">=", xs:dateTime($StartDate)),
                                    cts:path-range-query("CreationInfo/Date", "<=", xs:dateTime($EndDate))) )
                            )))
                        ) 
                    
                    else ()


let $AllFiles := <root>{$ResultData}</root>

return
<root>
{
for $Video in $AllFiles/Video

let $file_uri := $Video/base-uri()
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
</root>


