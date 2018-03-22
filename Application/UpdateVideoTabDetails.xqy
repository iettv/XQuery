xquery version "1.0-ml";

declare variable $inputSearchDetails as xs:string external ;

(:let $inputSearchDetails := "<Video>
    <DataType>Speakers</DataType>
    <VideoID>e16c5326-2358-488a-bae5-1a1619cbcc6a</VideoID>
    <Speakers>
        <Person ID='46736'>
            <Title>Mr</Title>
            <Name>
                <Given-Name>Raj</Given-Name>
                <Surname>Dubey</Surname>
                <Suffix/>
            </Name>
            <PhoneNo/>
            <MobileNo/>
            <Affiliations>
                <Affiliation ID=''>
                    <Organization>
                        <OrganizationName/>
                        <Department>
                            <DepartmentName/>
                        </Department>
                        <Address>
                            <Addr-Line/>
                            <Postcode/>
                            <City/>
                            <State/>
                            <Country/>
                            <Phone/>
                            <Fax/>
                            <Email/>
                            <URL/>
                        </Address>
                    </Organization>
                </Affiliation>
            </Affiliations>
            <JobTitle/>
            <FileName>Images/AutoDefaultSpeaker.png$</FileName>
            <FilePath/>
            <Biography/>
        </Person>
        <Person ID='46735'>
            <Title>Mr</Title>
            <Name>
                <Given-Name>Ritesh</Given-Name>
                <Surname>Dubey</Surname>
                <Suffix/>
            </Name>
            <PhoneNo/>
            <MobileNo/>
            <Affiliations>
                <Affiliation ID=''>
                    <Organization>
                        <OrganizationName/>
                        <Department>
                            <DepartmentName/>
                        </Department>
                        <Address>
                            <Addr-Line/>
                            <Postcode/>
                            <City/>
                            <State/>
                            <Country/>
                            <Phone/>
                            <Fax/>
                            <Email/>
                            <URL/>
                        </Address>
                    </Organization>
                </Affiliation>
            </Affiliations>
            <JobTitle/>
            <FileName>Images/AutoDefaultSpeaker.png$</FileName>
            <FilePath/>
            <Biography/>
        </Person>
        <Person ID='46728'>
            <Title>MR</Title>
            <Name>
                <Given-Name>Baba</Given-Name>
                <Surname>Mahadik</Surname>
                <Suffix/>
            </Name>
            <PhoneNo/>
            <MobileNo/>
            <Affiliations>
                <Affiliation ID=''>
                    <Organization>
                        <OrganizationName>RAVE</OrganizationName>
                        <Department>
                            <DepartmentName>IT</DepartmentName>
                        </Department>
                        <Address>
                            <Addr-Line>Mumbai</Addr-Line>
                            <Postcode/>
                            <City/>
                            <State>MH </State>
                            <Country>IND</Country>
                            <Phone/>
                            <Fax/>
                            <Email>babaso.mahadik@northgateps.com</Email>
                            <URL/>
                        </Address>
                    </Organization>
                </Affiliation>
            </Affiliations>
            <JobTitle>LSE</JobTitle>
            <FileName>Speaker_46728.jpg</FileName>
            <FilePath/>
            <Biography>test</Biography>
        </Person>
    </Speakers>
</Video>":)

let $input := xdmp:unquote($inputSearchDetails)
let $VideoId := $input/Video/VideoID/text()
let $DataType := $input/Video/DataType/text()
let $BasicInfoTitle := $input/Video/BasicInfoTitle/Title
let $BasicInfoVideoCategory := $input/Video/BasicInfoTitle/VideoCategory
let $BasicInfoAbstract := $input/Video/BasicInfoTitle/Abstract
let $BasicInfoShortDescription := $input/Video/BasicInfoTitle/ShortDescription
let $BasicInfoVideoCreatedDate := $input/Video/BasicInfoTitle/VideoCreatedDate
let $BasicInfoChannelMap := $input/Video/BasicInfoChannelMap/ChannelMapping
let $BasicInfoCopyright := $input/Video/BasicInfoCopyright/CopyrightDetails
let $BasicInfoPricing := $input/Video/BasicInfoPricing/PricingDetails
let $BasicInfoPromo := $input/Video/BasicInfoPromo/PromoDetails
let $AdvanceInfoAdvert := $input/Video/AdvanceInfoAdvert/Advert
let $AdvanceInfoLocation := $input/Video/AdvanceInfoLocation/LocationDetails
let $AdvanceInfoPermission := $input/Video/AdvanceInfoPermission/PermissionDetails
let $AdvanceInfoSubtitles := $input/Video/AdvanceInfoSubtitles/Subtitles
let $AdvanceInfoSyndication := $input/Video/AdvanceInfoSyndication/Syndication
let $AdvanceInfoTranscripts := $input/Video/AdvanceInfoTranscripts/Transcripts
let $Attachments := $input/Video/Attachments
let $ClientInfo := $input/Video/ClientInfo
let $KeyWordInfo := $input/Video/KeyWordInfo
let $ModifiedInfo := $input/Video/ModifiedInfo
let $ProductionInfo := $input/Video/ProductionInfo
let $Orator := $input/Video/Speakers
let $UploadVideo := $input/Video/UploadVideo
let $Events := $input/Video/Events
let $PublishInfo := $input/Video/PublishInfo

return
(
(if (contains($DataType,'Speakers'))
then
      if( fn:doc-available(concat('/PCopy/',$VideoId,'.xml')))
      then
               let $Speakers := for $Speakers in $input//Speakers/Person
                                return <Speaker>{normalize-space(fn:concat($Speakers/Title/text(), ' ', $Speakers/Name/Given-Name/text(), ' ', $Speakers/Name/Surname/text()))}</Speaker>
               return
                        xdmp:document-set-properties(concat('/PCopy/',$VideoId,'.xml'),<Speakers>{$Speakers}</Speakers>)
       else ()
else ())
,
(for $Video in (doc()/Video[@ID/string()=$VideoId])

return 
(
(if (contains($DataType,'BasicInfo Title'))
then ((if ($Video/BasicInfo/Title)
then (xdmp:node-replace($Video/BasicInfo/Title, $BasicInfoTitle))
else (xdmp:node-insert-child($Video/BasicInfo,$BasicInfoTitle))),
(if ($Video/BasicInfo/VideoCategory)
then (xdmp:node-replace($Video/BasicInfo/VideoCategory, $BasicInfoVideoCategory))
else (xdmp:node-insert-child($Video/BasicInfo,$BasicInfoVideoCategory))),
(if ($Video/BasicInfo/Abstract)
then (xdmp:node-replace($Video/BasicInfo/Abstract, $BasicInfoAbstract))
else (xdmp:node-insert-child($Video/BasicInfo,$BasicInfoAbstract))),
(if ($Video/BasicInfo/ShortDescription)
then (xdmp:node-replace($Video/BasicInfo/ShortDescription, $BasicInfoShortDescription))
else (xdmp:node-insert-child($Video/BasicInfo,$BasicInfoShortDescription))),
(if ($Video/BasicInfo/VideoCreatedDate)
then (xdmp:node-replace($Video/BasicInfo/VideoCreatedDate,$BasicInfoVideoCreatedDate))
else (xdmp:node-insert-child($Video/BasicInfo,$BasicInfoVideoCreatedDate)))
)
else ()),
(if (contains($DataType,'BasicInfo ChannelMapping'))
then (if ($Video/BasicInfo/ChannelMapping)
then (xdmp:node-replace($Video/BasicInfo/ChannelMapping, $BasicInfoChannelMap))
else (xdmp:node-insert-child($Video/BasicInfo,$BasicInfoChannelMap))
)
else ()),
(if (contains($DataType,'BasicInfo CopyrightDetails'))
then (if ($Video/BasicInfo/CopyrightDetails)
then (xdmp:node-replace($Video/BasicInfo/CopyrightDetails, $BasicInfoCopyright))
else (xdmp:node-insert-child($Video/BasicInfo,$BasicInfoCopyright))
)
else ()),
(if (contains($DataType,'BasicInfo PricingDetails'))
then (if ($Video/BasicInfo/PricingDetails)
then (xdmp:node-replace($Video/BasicInfo/PricingDetails, $BasicInfoPricing))
else (xdmp:node-insert-child($Video/BasicInfo,$BasicInfoPricing))
)
else ()),
(if (contains($DataType,'BasicInfo PromoDetails'))
then (if ($Video/BasicInfo/PromoDetails)
then (xdmp:node-replace($Video/BasicInfo/PromoDetails, $BasicInfoPromo))
else (xdmp:node-insert-child($Video/BasicInfo,$BasicInfoPromo))
)
else ()),
(if (contains($DataType,'AdvanceInfo Advert'))
then (if ($Video/AdvanceInfo/Advert)
then (xdmp:node-replace($Video/AdvanceInfo/Advert, $AdvanceInfoAdvert))
else (xdmp:node-insert-child($Video/AdvanceInfo,$AdvanceInfoAdvert))
)
else ()),
(if (contains($DataType,'AdvanceInfo LocationDetails'))
then (if ($Video/AdvanceInfo/LocationDetails)
then (xdmp:node-replace($Video/AdvanceInfo/LocationDetails, $AdvanceInfoLocation))
else (xdmp:node-insert-child($Video/AdvanceInfo,$AdvanceInfoLocation))
)
else ()),
(if (contains($DataType,'AdvanceInfo PermissionDetails'))
then (if ($Video/AdvanceInfo/PermissionDetails)
then (xdmp:node-replace($Video/AdvanceInfo/PermissionDetails, $AdvanceInfoPermission))
else (xdmp:node-insert-child($Video/AdvanceInfo,$AdvanceInfoPermission))
)
else ()),
(if (contains($DataType,'AdvanceInfo Subtitles'))
then (if ($Video/AdvanceInfo/Subtitles)
then (xdmp:node-replace($Video/AdvanceInfo/Subtitles, $AdvanceInfoSubtitles))
else (xdmp:node-insert-child($Video/AdvanceInfo,$AdvanceInfoSubtitles))
)
else ()),
(if (contains($DataType,'AdvanceInfo Syndication'))
then (if ($Video/AdvanceInfo/Syndication)
then (xdmp:node-replace($Video/AdvanceInfo/Syndication, $AdvanceInfoSyndication))
else (xdmp:node-insert-child($Video/AdvanceInfo,$AdvanceInfoSyndication))
)
else ()),
(if (contains($DataType,'AdvanceInfo Transcripts'))
then (if ($Video/AdvanceInfo/Transcripts)
then (xdmp:node-replace($Video/AdvanceInfo/Transcripts, $AdvanceInfoTranscripts))
else (xdmp:node-insert-child($Video/AdvanceInfo,$AdvanceInfoTranscripts))
)
else ()),
(if (contains($DataType,'Attachments'))
then (if ($Video/Attachments)
then (xdmp:node-replace($Video/Attachments, $Attachments))
else (xdmp:node-insert-child($Video,$Attachments))
)
else ()),
(if (contains($DataType,'ClientInfo'))
then (if ($Video/ClientInfo)
then (xdmp:node-replace($Video/ClientInfo, $ClientInfo))
else (xdmp:node-insert-child($Video,$ClientInfo))
)
else ()),
(if (contains($DataType,'KeyWordInfo'))
then (if ($Video/KeyWordInfo)
then (xdmp:node-replace($Video/KeyWordInfo, $KeyWordInfo))
else (xdmp:node-insert-child($Video,$KeyWordInfo))
)
else ()),
(if (contains($DataType,'ModifiedInfo'))
then (if ($Video/ModifiedInfo)
then (xdmp:node-replace($Video/ModifiedInfo, $ModifiedInfo))
else (xdmp:node-insert-child($Video,$ModifiedInfo))
)
else ()),
(if (contains($DataType,'ProductionInfo'))
then (if ($Video/ProductionInfo)
then (xdmp:node-replace($Video/ProductionInfo, $ProductionInfo))
else (xdmp:node-insert-child($Video,$ProductionInfo))
)
else ()),
(if (contains($DataType,'Speakers'))
then (
(if ($Video/Speakers)
then (xdmp:node-replace($Video/Speakers, $Orator))
else (xdmp:node-insert-child($Video,$Orator)))
)
else ()),
(if (contains($DataType,'UploadVideo'))
then (if ($Video/UploadVideo)
then (xdmp:node-replace($Video/UploadVideo, $UploadVideo))
else (xdmp:node-insert-child($Video,$UploadVideo))
)
else ()),
(if (contains($DataType,'Events'))
then (if ($Video/Events)
then (xdmp:node-replace($Video/Events, $Events))
else (xdmp:node-insert-child($Video,$Events))
)
else ()),
(if (contains($DataType,'PublishInfo'))
then (if ($Video/PublishInfo)
then (xdmp:node-replace($Video/PublishInfo, $PublishInfo))
else (xdmp:node-insert-child($Video,$PublishInfo))
)
else ()),
(if($Video/@ID/string()=$VideoId)
then ("SUCCESS")
else ("FAILURE")
)
)
)
)