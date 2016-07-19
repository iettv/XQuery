xquery version "1.0-ml";

(:
  This service is useful to get all Home Page Videos as per their assigned sequences to display it video Home Page accordingly.
  <HomePage><Popular>3</Popular><ForthComing>3</ForthComing><Latest>3</Latest></HomePage>
:)

import module namespace VIDEOS   = "http://www.TheIET.org/ManageVideos"   at  "/Utils/ManageVideos.xqy";
import module namespace common   = "http://www.TheIET.org/common"         at  "/Utils/common.xqy";
import module namespace CAROUSEL = "http://www.TheIET.org/ManageCarousel" at "/Utils/ManageCarousel.xqy";
import module namespace constants = "http://www.TheIET.org/constants"     at "/Utils/constants.xqy";

declare variable $inputSearchDetails as xs:string external;

let $InputParam	  := xdmp:unquote($inputSearchDetails)
let $PopularCount := xs:integer($InputParam//Popular/text())
let $TotalPopularCount:= count(VIDEOS:GetCommonPopularFile()//Video)

return
	if( not($PopularCount) )
	then
		(
			xdmp:log(concat("[ VideoHomePage ][ Fail ][ Invalid Popular count ][ Count ", $PopularCount, " ]")),
			"ERROR!!! Invalid popular count."
		)
	else
		<Videos>
		<TotalPopularCount>{$TotalPopularCount}</TotalPopularCount>
			{
			  ( VIDEOS:GetVideoMostPopularByCount($PopularCount) )
			}
		</Videos>
		