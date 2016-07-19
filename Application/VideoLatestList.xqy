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
let $LatestCount := xs:integer($InputParam//Latest/text())
let $TotalLatestCount := count(doc($constants:CommonLatestVideo)//VideoID)

return
	
	if( not($LatestCount) )
	then
		(
			xdmp:log(concat("[ VideoHomePage ][ Fail ][ Invalid Latest count ][ Count ", $LatestCount, " ]")),
			"ERROR!!! Invalid Latest count."
		)
	else
		<Videos>
		<TotalLatestCount>{$TotalLatestCount}</TotalLatestCount>
			{
			  ( VIDEOS:GetLatestVideoByCount($LatestCount) )
			}
		</Videos>

    