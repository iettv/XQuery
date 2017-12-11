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
let $ForthComingCount := xs:integer($InputParam//ForthComing/text())
let $LatestCount := xs:integer($InputParam//Latest/text())
let $TotalPopularCount:= count(VIDEOS:GetCommonPopularFile()//Video)
let $TotalForthComingCount := count(doc($constants:CommonForthComingVideo)//VideoID)
let $TotalLatestCount := count(doc($constants:CommonLatestVideo)//VideoID)

return
	if( not($PopularCount) )
	then
		(
			xdmp:log(concat("[ VideoHomePage ][ Fail ][ Invalid Popular count ][ Count ", $PopularCount, " ]")),
			"ERROR!!! Invalid popular count."
		)
	else
	if( not($ForthComingCount) )
	then
		(
			xdmp:log(concat("[ VideoHomePage ][ Fail ][ Invalid Forth Coming count ][ Count ", $ForthComingCount, " ]")),
			"ERROR!!! Invalid forth coming count."
		)
	else
	if( not($LatestCount) )
	then
		(
			xdmp:log(concat("[ VideoHomePage ][ Fail ][ Invalid Latest count ][ Count ", $LatestCount, " ]")),
			"ERROR!!! Invalid Latest count."
		)
	else
		<Videos>
		<TotalPopularCount>{$TotalPopularCount}</TotalPopularCount>
		<TotalForthComingCount>{$TotalForthComingCount}</TotalForthComingCount>
		<TotalLatestCount>{$TotalLatestCount}</TotalLatestCount>
			{
			  ( CAROUSEL:GetVideoCarousel(18), VIDEOS:GetVideoMostPopularByCount($PopularCount), VIDEOS:GetVideoForthComingByCount($ForthComingCount), VIDEOS:GetLatestVideoByCount($LatestCount) )
			}
		</Videos>

    