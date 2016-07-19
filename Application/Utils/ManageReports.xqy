xquery version "1.0-ml";

module namespace REPORTS = "http://www.TheIET.org/ManageReports";

import module namespace constants = "http://www.TheIET.org/constants"   at "/Utils/constants.xqy";
import module namespace admin     = "http://marklogic.com/xdmp/admin"   at "/MarkLogic/admin.xqy";

declare function REPORTS:GetVideoByVideoIDs($VideoIdsXML as xs:string)
{
let $VideoIdsXML := xdmp:unquote($VideoIdsXML)
for  $iLoop in $VideoIdsXML//VideoID
  let $SelectedVideo := fn:doc(fn:concat($constants:VIDEO_DIRECTORY,$iLoop,".xml"))
    return  
      <Video ID="{fn:data($SelectedVideo/Video/@ID)}"> 
          {
					 $SelectedVideo//BasicInfo/Title
          }
      </Video>

};