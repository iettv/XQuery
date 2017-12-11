xquery version '1.0-ml';

(: This service is to send Video Metadata to build Video Page for Google search engine :)
(: input parm must be : <Video><Start>1</Start><End>10</End></Video> :)

declare variable $inputSearchDetails as xs:string external;

<Videos>
{
let $Parm := xdmp:unquote($inputSearchDetails)
for $Loop in $Parm/Video/Start/text() to $Parm/Video/End/text()
for $Video in collection('PublishedCopy')/Video[VideoNumber=$Loop]
let $Title := $Video/BasicInfo/Title
let $Description := $Video/BasicInfo/ShortDescription
let $VideoNumber := $Video/VideoNumber
let $StreamID := <StreamID>{$Video/UploadVideo/File/@streamID/string()}</StreamID>
let $ModDate  := $Video/ModifiedInfo
let $VideoCustomThumbnailImage := <VideoCustomThumbnailImage>{$Video/AdvanceInfo/PermissionDetails/VideoThumbnailImage}</VideoCustomThumbnailImage>
let $Keywords := let $Inspec := string-join(for $x in $Video/VideoInspec//*[name()='Kwd' or (name()='Compound-Kwd-Part' and self::*[@content-type='text'])] return $x, '; ')
                 let $Default := string-join(for $EachKeyWord in $Video//DefaultKeyword return $EachKeyWord, ' ;')
                 let $Custom := string-join(for $EachKeyWord in $Video//CustomKeyword return $EachKeyWord, ' ;')
                 return <Keywords>{replace(concat($Inspec, ',' , $Default, ',' , $Custom),',,','')}</Keywords>        
return
	<Video>{$Title,$Description,$VideoNumber,$Keywords,$StreamID,$VideoCustomThumbnailImage,$ModDate}</Video>
}
</Videos>