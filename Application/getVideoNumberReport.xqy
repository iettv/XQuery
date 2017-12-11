xquery version "1.0-ml";

import module namespace constants = "http://www.TheIET.org/constants"   at "/Utils/constants.xqy"; 
import module namespace VIDEOS = "http://www.TheIET.org/ManageVideos"   at  "/Utils/ManageVideos.xqy";

(: <VideoReport><Count></Count></VideoReport> :)
declare variable $inputSearchDetails as xs:string external;
let $inputSearchDetails := "<VideoReport><Count>100</Count></VideoReport>"
let $InputXML  := xdmp:unquote($inputSearchDetails) 
let $Mode := $InputXML//Mode
let $Count := xs:integer($InputXML//Count)
let $PopularList := VIDEOS:GetCommonPopularFile()
let $Count := if($Count) then $Count else count($PopularList//Video)
let $totalCount := xs:integer(0)
let $freeCount := xs:integer(0)
let $premiumCount := xs:integer(0)
let $subscriptionCount := xs:integer(0)
let $HiddenCount := xs:integer(0)

let $TotalVideo := <VideosCount>
					{
					(
					for $each in $PopularList//Video
					let $doc := doc(concat("/PCopy/",$each/VideoID/text(),".xml"))
          
					let $doc_video := doc(concat("/Video/",$each/VideoID/text(),".xml"))
          let $collect := if (xdmp:document-get-collections(concat("/Video/",$each/VideoID/text(),".xml")) = 'Video-Status-Withdrawn')
                          then ($doc_video) 
                          else()
                          
					let $totalCount := xdmp:set($totalCount,sum($totalCount+xs:integer($each//Count/text())))
					let $freeCount := if($doc/Video/BasicInfo/PricingDetails/@type/string() eq "Free") then xdmp:set($freeCount,sum($freeCount+xs:integer($each//Count/text()))) else ()
					let $premiumCount := if($doc/Video/BasicInfo/PricingDetails/@type/string() eq "Premium") then xdmp:set($premiumCount,sum($premiumCount+xs:integer($each//Count/text()))) else ()
					let $subscriptionCount := if($doc/Video/BasicInfo/PricingDetails/@type/string() eq "Subscription") then xdmp:set($subscriptionCount,sum($subscriptionCount+xs:integer($each//Count/text()))) else ()
					let $HiddenCount := if($doc/Video//Permission[@type='HideRecord' and @status="yes"]) then xdmp:set($HiddenCount,sum($HiddenCount+1)) 
                              else if($collect/Video//Permission[@type='HideRecord' and @status="yes"]) then xdmp:set($HiddenCount,sum($HiddenCount+1)) 
                              else ()
					return <Video><VideoNumber>{
          if ($doc/Video/VideoNumber/text())
          then ($doc/Video/VideoNumber/text())
          else if ($doc_video/Video/VideoNumber/text())
          then ($doc_video/Video/VideoNumber/text())
          else ()
          }</VideoNumber>
          <ChannelMapping>{
          if ($doc/Video/BasicInfo/ChannelMapping/*)
          then ($doc/Video/BasicInfo/ChannelMapping/*)
          else if ($doc_video/Video/BasicInfo/ChannelMapping/*)
          then ($doc_video/Video/BasicInfo/ChannelMapping/*)
          else ()
          }</ChannelMapping>
          <Title>{
          if ($doc/Video/BasicInfo/Title/text())
          then ($doc/Video/BasicInfo/Title/text())
          else if ($doc_video/Video/BasicInfo/Title/text())
          then ($doc_video/Video/BasicInfo/Title/text())
          else ()
          }</Title><Views>{$each//Count/text()}</Views>
          <PricingType>{
          if ($doc/Video/BasicInfo/PricingDetails/@type/string())
          then ($doc/Video/BasicInfo/PricingDetails/@type/string())
          else if ($doc_video/Video/BasicInfo/PricingDetails/@type/string())
          then ($doc_video/Video/BasicInfo/PricingDetails/@type/string())
          else ()
          }</PricingType>
          <HideRecord>{
          if (fn:data($doc/Video/AdvanceInfo/PermissionDetails/Permission[@type="HideRecord"]/@status))
          then (fn:data($doc/Video/AdvanceInfo/PermissionDetails/Permission[@type="HideRecord"]/@status))
          else if (fn:data($doc_video/Video/AdvanceInfo/PermissionDetails/Permission[@type="HideRecord"]/@status))
          then (fn:data($doc_video/Video/AdvanceInfo/PermissionDetails/Permission[@type="HideRecord"]/@status))
          else ()
          }</HideRecord></Video>
					)[1 to $Count]
					}
					</VideosCount>
					
return <AllVideos>{$TotalVideo}<Videos><TotalVideoCount>{$totalCount}</TotalVideoCount><FreeCount>{$freeCount}</FreeCount><PremiumCount>{$premiumCount}</PremiumCount><SubscriptionCount>{$subscriptionCount}</SubscriptionCount><HiddenCount>{$HiddenCount}</HiddenCount></Videos></AllVideos>
