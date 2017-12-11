xquery version "1.0-ml";

(:
  This service is useful to get all Home Page Videos as per their assigned sequences to display it video Home Page accordingly.
  <HomePage><Popular>3</Popular><ForthComing>3</ForthComing><Latest>3</Latest></HomePage>
:)

import module namespace VIDEOS   = "http://www.TheIET.org/ManageVideos"   at  "/Utils/ManageVideos.xqy";
import module namespace common   = "http://www.TheIET.org/common"         at  "/Utils/common.xqy";
import module namespace CAROUSEL = "http://www.TheIET.org/ManageCarousel" at "/Utils/ManageCarousel.xqy";
import module namespace constants = "http://www.TheIET.org/constants"     at "/Utils/constants.xqy";

let $TotalPopularCount:= count(VIDEOS:GetCommonPopularFile()//Video)
let $TotalForthComingCount := count(doc($constants:CommonForthComingVideo)//VideoID)
let $TotalLatestCount := count(doc($constants:CommonLatestVideo)//VideoID)

return
	
		<Videos>
		<TotalPopularCount>{$TotalPopularCount}</TotalPopularCount>
		<TotalForthComingCount>{$TotalForthComingCount}</TotalForthComingCount>
		<TotalLatestCount>{$TotalLatestCount}</TotalLatestCount>
			{
			  ( CAROUSEL:GetVideoCarousel(18) )
			}
		</Videos>

    