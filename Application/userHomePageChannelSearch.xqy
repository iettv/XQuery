xquery version "1.0-ml";

import module namespace LOOKUP = "http://www.TheIET.org/ManageLookup" at "/Utils/ManageSearch.xqy";

(: This service is to support channel wise search :)

(: input parm must be : <SearchUserChannelVideo><ChannelID>1</ChannelID><PageLength>10</PageLength><StartPage>1</StartPage></SearchUserChannelVideo> :)
declare variable $inputSearchDetails as xs:string external ;

let $Log 		:= xdmp:log("[ IET-TV ][ ChannelSearch ][ Call ][ Service call ]")
let $InputParam := xdmp:unquote($inputSearchDetails)
let $ChannelID 	:= $InputParam/SearchUserChannelVideo/ChannelID/text()
let $PageLength := xs:integer($InputParam/SearchUserChannelVideo/PageLength/text())
let $StartPage 	:= xs:integer($InputParam/SearchUserChannelVideo/StartPage/text())
return
  if($ChannelID and $PageLength and $StartPage)
  then
    LOOKUP:GetVideosByChannelId($ChannelID,$PageLength,$StartPage)
  else
    (
      xdmp:log(concat("[ IET-TV ][ ChannelSearch ][ Call ][ Invalid valued provided to search - ChannelID : ", $ChannelID, " ][ PageLength : ", $PageLength, " ][ StartPage : ", $StartPage, " ]"))
      ,
       "ERROR! Please provide correct input parameters. Please look generated log file for more details."
    )

