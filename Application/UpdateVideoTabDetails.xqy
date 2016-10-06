xquery version "1.0-ml";

declare variable $inputSearchDetails as xs:string external ;

(:let $inputSearchDetails := "<Video>
	<DataType>BasicInfo Title,BasicInfo ChannelMapping,BasicInfo CopyrightDetails,BasicInfo PricingDetails,BasicInfo PromoDetails,AdvanceInfo Advert,AdvanceInfo LocationDetails,AdvanceInfo PermissionDetails,AdvanceInfo Subtitles,AdvanceInfo Syndication,AdvanceInfo Transcripts,Attachments,ClientInfo,KeyWordInfo,ModifiedInfo,ProductionInfo,Speakers,UploadVideo,Events,PublishInfo</DataType>
	<VideoID>15245</VideoID>
	<PublishInfo>
    <VideoPublish active='yes'>
      <RecordStartDate>1900-01-01T00:00:00.0000</RecordStartDate>
      <RecordStartTime>00:00:00.0000</RecordStartTime>
      <FinalStartDate>2017-07-26T16:55:00.0000</FinalStartDate>
      <FinalStartTime>16:55:00.0000</FinalStartTime>
      <FinalExpiryDate>1900-01-01T00:00:00.0000</FinalExpiryDate>
      <FinalExpiryTime>00:00:00.0000</FinalExpiryTime>
      <URL>
      </URL>
      <DOI>10.1049/iet-tv.vn.8820</DOI>
    </VideoPublish>
    <LivePublish active='no'>
      <LiveRecordStartDate>1900-01-01T00:00:00.0000</LiveRecordStartDate>
      <LiveRecordStartTime>00:00:00.0000</LiveRecordStartTime>
      <LiveFinalStartDate>1900-01-01T00:00:00.0000</LiveFinalStartDate>
      <LiveFinalStartTime>00:00:00.0000</LiveFinalStartTime>
      <LiveFinalExpiryDate>1900-01-01T00:00:00.0000</LiveFinalExpiryDate>
      <LiveFinalExpiryTime>00:00:00.0000</LiveFinalExpiryTime>
      <URL>
      </URL>
      <BackupURL>
      </BackupURL>
      <StreamName>
      </StreamName>
      <LiveEntryID>
      </LiveEntryID>
      <UserName>
      </UserName>
      <Password>
      </Password>
      <BitrateList>
        <Bitrate>
          <Rate>
          </Rate>
          <Width>
          </Width>
          <Height>
          </Height>
        </Bitrate>
        <Bitrate>
          <Rate>
          </Rate>
          <Width>
          </Width>
          <Height>
          </Height>
        </Bitrate>
        <Bitrate>
          <Rate>
          </Rate>
          <Width>
          </Width>
          <Height>
          </Height>
        </Bitrate>
      </BitrateList>
    </LivePublish>
  </PublishInfo>
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
let $Speakers := $input/Video/Speakers
let $UploadVideo := $input/Video/UploadVideo
let $Events := $input/Video/Events
let $PublishInfo := $input/Video/PublishInfo


for $i in doc()/Video[@ID/string()=$VideoId][contains(base-uri(),'/PCopy/') or contains(base-uri(),'/Video/')]

return 
( 
(if (contains($DataType,'BasicInfo Title'))
then ((if ($i/BasicInfo/Title)
          then (xdmp:node-replace($i/BasicInfo/Title, $BasicInfoTitle))
          else (xdmp:node-insert-child($i/BasicInfo,$BasicInfoTitle))),
      (if ($i/BasicInfo/VideoCategory)
          then (xdmp:node-replace($i/BasicInfo/VideoCategory, $BasicInfoVideoCategory))
          else (xdmp:node-insert-child($i/BasicInfo,$BasicInfoVideoCategory))),
      (if ($i/BasicInfo/Abstract)
          then (xdmp:node-replace($i/BasicInfo/Abstract, $BasicInfoAbstract))
          else (xdmp:node-insert-child($i/BasicInfo,$BasicInfoAbstract))),
      (if ($i/BasicInfo/ShortDescription)
          then (xdmp:node-replace($i/BasicInfo/ShortDescription, $BasicInfoShortDescription))
          else (xdmp:node-insert-child($i/BasicInfo,$BasicInfoShortDescription))),
      (if ($i/BasicInfo/VideoCreatedDate)
          then (xdmp:node-replace($i/BasicInfo/VideoCreatedDate,$BasicInfoVideoCreatedDate))
          else (xdmp:node-insert-child($i/BasicInfo,$BasicInfoVideoCreatedDate)))
    )
else ()),
(if (contains($DataType,'BasicInfo ChannelMapping'))
then (if ($i/BasicInfo/ChannelMapping)
          then (xdmp:node-replace($i/BasicInfo/ChannelMapping, $BasicInfoChannelMap))
          else (xdmp:node-insert-child($i/BasicInfo,$BasicInfoChannelMap))
     )
else ()),
(if (contains($DataType,'BasicInfo CopyrightDetails'))
then (if ($i/BasicInfo/CopyrightDetails)
          then (xdmp:node-replace($i/BasicInfo/CopyrightDetails, $BasicInfoCopyright))
          else (xdmp:node-insert-child($i/BasicInfo,$BasicInfoCopyright))
      )
else ()),
(if (contains($DataType,'BasicInfo PricingDetails'))
then (if ($i/BasicInfo/PricingDetails)
          then (xdmp:node-replace($i/BasicInfo/PricingDetails, $BasicInfoPricing))
          else (xdmp:node-insert-child($i/BasicInfo,$BasicInfoPricing))
      )
else ()),
(if (contains($DataType,'BasicInfo PromoDetails'))
then (if ($i/BasicInfo/PromoDetails)
          then (xdmp:node-replace($i/BasicInfo/PromoDetails, $BasicInfoPromo))
          else (xdmp:node-insert-child($i/BasicInfo,$BasicInfoPromo))
      )
else ()),
(if (contains($DataType,'AdvanceInfo Advert'))
then (if ($i/AdvanceInfo/Advert)
          then (xdmp:node-replace($i/AdvanceInfo/Advert, $AdvanceInfoAdvert))
          else (xdmp:node-insert-child($i/AdvanceInfo,$AdvanceInfoAdvert))
      )
else ()),
(if (contains($DataType,'AdvanceInfo LocationDetails'))
then (if ($i/AdvanceInfo/LocationDetails)
          then (xdmp:node-replace($i/AdvanceInfo/LocationDetails, $AdvanceInfoLocation))
          else (xdmp:node-insert-child($i/AdvanceInfo,$AdvanceInfoLocation))
      )
else ()),
(if (contains($DataType,'AdvanceInfo PermissionDetails'))
then (if ($i/AdvanceInfo/PermissionDetails)
          then (xdmp:node-replace($i/AdvanceInfo/PermissionDetails, $AdvanceInfoPermission))
          else (xdmp:node-insert-child($i/AdvanceInfo,$AdvanceInfoPermission))
      )
else ()),
(if (contains($DataType,'AdvanceInfo Subtitles'))
then (if ($i/AdvanceInfo/Subtitles)
          then (xdmp:node-replace($i/AdvanceInfo/Subtitles, $AdvanceInfoSubtitles))
          else (xdmp:node-insert-child($i/AdvanceInfo,$AdvanceInfoSubtitles))
      )
else ()),
(if (contains($DataType,'AdvanceInfo Syndication'))
then (if ($i/AdvanceInfo/Syndication)
          then (xdmp:node-replace($i/AdvanceInfo/Syndication, $AdvanceInfoSyndication))
          else (xdmp:node-insert-child($i/AdvanceInfo,$AdvanceInfoSyndication))
      )
else ()),
(if (contains($DataType,'AdvanceInfo Transcripts'))
then (if ($i/AdvanceInfo/Transcripts)
          then (xdmp:node-replace($i/AdvanceInfo/Transcripts, $AdvanceInfoTranscripts))
          else (xdmp:node-insert-child($i/AdvanceInfo,$AdvanceInfoTranscripts))
      )
else ()),
(if (contains($DataType,'Attachments'))
then (if ($i/Attachments)
          then (xdmp:node-replace($i/Attachments, $Attachments))
          else (xdmp:node-insert-child($i,$Attachments))
      )
else ()),
(if (contains($DataType,'ClientInfo'))
then (if ($i/ClientInfo)
          then (xdmp:node-replace($i/ClientInfo, $ClientInfo))
          else (xdmp:node-insert-child($i,$ClientInfo))
      )
else ()),
(if (contains($DataType,'KeyWordInfo'))
then (if ($i/KeyWordInfo)
          then (xdmp:node-replace($i/KeyWordInfo, $KeyWordInfo))
          else (xdmp:node-insert-child($i,$KeyWordInfo))
      )
else ()),
(if (contains($DataType,'ModifiedInfo'))
then (if ($i/ModifiedInfo)
          then (xdmp:node-replace($i/ModifiedInfo, $ModifiedInfo))
          else (xdmp:node-insert-child($i,$ModifiedInfo))
      )
else ()),
(if (contains($DataType,'ProductionInfo'))
then (if ($i/ProductionInfo)
          then (xdmp:node-replace($i/ProductionInfo, $ProductionInfo))
          else (xdmp:node-insert-child($i,$ProductionInfo))
      )
else ()),
(if (contains($DataType,'Speakers'))
then (if ($i/Speakers)
          then (xdmp:node-replace($i/Speakers, $Speakers))
          else (xdmp:node-insert-child($i,$Speakers))
      )
else ()),
(if (contains($DataType,'UploadVideo'))
then (if ($i/UploadVideo)
          then (xdmp:node-replace($i/UploadVideo, $UploadVideo))
          else (xdmp:node-insert-child($i,$UploadVideo))
      )
else ()),
(if (contains($DataType,'Events'))
then (if ($i/Events)
          then (xdmp:node-replace($i/Events, $Events))
          else (xdmp:node-insert-child($i,$Events))
      )
else ()),
(if (contains($DataType,'PublishInfo'))
then (if ($i/PublishInfo)
          then (xdmp:node-replace($i/PublishInfo, $PublishInfo))
          else (xdmp:node-insert-child($i,$PublishInfo))
      )
else ()),
(if($i/@ID/string()=$VideoId)
    then ("SUCCESS")
 else ("FAILURE")
)
)
