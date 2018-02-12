xquery version "1.0-ml";

declare variable $inputSearchDetails as xs:string external;

declare function local:RangeDateData($Date as xs:dateTime)
{
        let $data :=  cts:or-query((
                                    cts:path-range-query("ModifiedInfo/Date", ">=", xs:dateTime($Date)),
                                    cts:path-range-query("CreationInfo/Date", ">=", xs:dateTime($Date))
                            ))
        return $data									
}; 

declare function local:VideoMetadata($VideoXml as item()*, $VideoId as xs:string)
{
        let $VideoData := $VideoXml
        for $Video in $VideoData   
                        let $VideoNumber  := $Video/VideoNumber/text()
                        let $VideoStatus  := $Video/VideoStatus/text()
                        let $VideoType    := $Video/VideoType/text()
                        let $Title        := $Video/BasicInfo/Title/text()
                        let $PricingType  := $Video/BasicInfo/PricingDetails/@type/string()
                        let $PricingId    := $Video/BasicInfo/PricingDetails/@ID/string()
                        let $PricingUploadPrice  := $Video/BasicInfo/PricingDetails/UploadPrice/text()
                        let $Subtitles    := $Video/AdvanceInfo/Subtitles
                        let $CreatedDate     := $Subtitles/CreatedDate
                        let $UploadVideo    := $Video/UploadVideo/File
                        let $PublishInfo    := if ($Video/PublishInfo/VideoPublish[@active='yes'])
                                               then <VideoPublish active="yes"/>
                                               else 
                                                     <LivePublish active="yes">
                                                     {
                                                         $Video/PublishInfo/LivePublish/URL,
                                                         $Video/PublishInfo/LivePublish/DOI,
                                                         $Video/PublishInfo/LivePublish/BackupURL,
                                                         $Video/PublishInfo/LivePublish/StreamName,
                                                         $Video/PublishInfo/LivePublish/LiveEntryID,
                                                         $Video/PublishInfo/LivePublish/UserName,
                                                         $Video/PublishInfo/LivePublish/Password,
                                                         $Video/PublishInfo/LivePublish/BitrateList
                                                      }
                                                     </LivePublish>

                        return 
                                 <Video ID='{$VideoId}'>
                                       <VideoNumber>{$VideoNumber}</VideoNumber>          
                                       <VideoStatus>{$VideoStatus}</VideoStatus>          
                                       <VideoType>{$VideoType}</VideoType>
                                       <Title>{$Title}</Title>
                                       <PricingType>{$PricingType}</PricingType>
                                       <PricingId>{$PricingId}</PricingId>
                                       <PricingUploadPrice>{$PricingUploadPrice}</PricingUploadPrice>
                                       <Subtitles>{ for $i in $Subtitles/Subtitle
                                                    return
                                                           <Subtitle> 
                                                           {
                                                            $i/Language,
                                                            $i/Text,
                                                            $i/DownloadLink,
                                                            $i/FileName,
                                                            $i/FilePath
                                                           }
                                                           </Subtitle>
                                                           
                                        }</Subtitles>
                                        {
                                       if ($UploadVideo/@streamID/string())
                                       then
                                                 <UploadVideo>{
                                                       <File ftpUpload="{$UploadVideo/@ftpUpload/string()}" streamID="{$UploadVideo/@streamID/string()}" active="{$UploadVideo/@active/string()}">
                                                       {
                                                           $UploadVideo/MediaType,
                                                           $UploadVideo/Duration,
                                                           $UploadVideo/UploadStatus,
                                                           $UploadVideo/FileName,
                                                           $UploadVideo/UploadDate,
                                                           $UploadVideo/Size,
                                                           $UploadVideo/Format,
                                                           $UploadVideo/ThumbnailFilepath,
                                                           $UploadVideo/NotificationCount,
                                                           $UploadVideo/URL
                                                       }
                                                       </File>
                                                    }</UploadVideo>
                                       else ()
                                       }
                                       <PublishInfo>{$PublishInfo}</PublishInfo>
                                 </Video>						
}; 



(:let $inputSearchDetails := "<Root>
                                 <Date></Date>
                             </Root>":)
                           
let $Input   := xdmp:unquote($inputSearchDetails) 

let $Date := xs:dateTime($Input/Root/Date/text())

let $Videos :=   <Videos>
                    {
                    for $VideoId in distinct-values(/Video[((contains(base-uri(),'/PCopy/')) or ( (contains(base-uri(),'/Video/')) and ((VideoStatus='Draft') or (VideoStatus='Withdrawn')) ))]/@ID/string())
                    return
                        if (string-length($Input/Root/Date/text()) ge 1)
                        then
                              let $VideoXml        := cts:search(/Video[@ID/string()=$VideoId][( (contains(//CreationInfo/Date,'T')) and (contains(//ModifiedInfo/Date,'T'))  )][((contains(base-uri(),'/PCopy/')) or ( (contains(base-uri(),'/Video/')) and ((VideoStatus='Draft') or (VideoStatus='Withdrawn')) ))][string-length(UploadVideo/File/@streamID/string()) ge 1][not(PublishInfo/LivePublish[@active='yes'])],local:RangeDateData(xs:dateTime($Date)))
                              return
                                local:VideoMetadata($VideoXml,$VideoId)
                        else
                              let $VideoXml        := /Video[@ID/string()=$VideoId][( (contains(//CreationInfo/Date,'T')) and (contains(//ModifiedInfo/Date,'T'))  )][((contains(base-uri(),'/PCopy/')) or ( (contains(base-uri(),'/Video/')) and ((VideoStatus='Draft') or (VideoStatus='Withdrawn')) ))][string-length(UploadVideo/File/@streamID/string()) ge 1][not(PublishInfo/LivePublish[@active='yes'])]
                              return
                                local:VideoMetadata($VideoXml,$VideoId)
                    }
                    </Videos>
                    
return  
       $Videos
