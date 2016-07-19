xquery version "1.0-ml";

import module namespace LOOKUP  = "http://www.TheIET.org/ManageLookup"  at "/Utils/ManageSearch.xqy";
import module namespace VIDEOS  = "http://www.TheIET.org/ManageVideos"  at "/Utils/ManageVideos.xqy";
import module namespace CHANNEL = "http://www.TheIET.org/ManageChannel" at "/Utils/ManageChannel.xqy";
import module namespace constants  = "http://www.TheIET.org/constants"    at  "/Utils/constants.xqy";

(: This service is useful to give search page on video type (Popular|Latest|Forthcoming)  :)
(: input parm must be : <SearchVideo><TermToSearch>1</TermToSearch><PageLength>10</PageLength><StartPage>1</StartPage><ChannelID></ChannelID><VideoType>Popular|Latest|Forthcoming</VideoType></SearchVideo> :)
declare variable $inputSearchDetails as xs:string external ;

let $InputParam  := xdmp:unquote($inputSearchDetails)
let $TermToSearch := $InputParam/SearchVideo/TermToSearch/text()
let $PageLength := xs:integer($InputParam/SearchVideo/PageLength/text())
let $StartPage := xs:integer($InputParam/SearchVideo/StartPage/text())
let $ChannelID := $InputParam/SearchVideo/ChannelID/text()
let $VideoType := $InputParam/SearchVideo/VideoType/text()
let $SortBy := $InputParam/SearchVideo/SortBy/text()
return
  if( $VideoType != 'Popular' and $VideoType != 'Latest' and $VideoType !='Forthcoming' )
  then
    (
       xdmp:log(concat("[ VideoAll ][ ERROR ][ Invalid VideoType ][ VIDEO TYPE : ", $VideoType, " ]")),
       "ERROR!!! Please provide VideoType parameter it is not correct. It must be (Popular|Latest|Forthcoming)"
    )
  else
  if( $PageLength and $StartPage )
  then
		let $Mode := 	if( $VideoType = 'Latest' ) then "Latest" else 
						if( $VideoType = 'Popular' ) then "Popular" else
						if( $VideoType = 'Forthcoming' ) then "Forthcoming" else "NONE"
		return LOOKUP:GetSpecificResult(" ",$TermToSearch,$PageLength,$StartPage,$Mode,$SortBy, if($ChannelID) then $ChannelID else "No")
  else
    (
      xdmp:log(concat("[ VideoAll ][ Invalid valued provided to search ][ PageLength : ", $PageLength, " ][ StartPage : ", $StartPage, " ]"))
      ,
      "ERROR! Please provide correct input parameters. Please look ML generated log file for more details."
    )
