xquery version "1.0-ml";

import module namespace VIDEOS     = "http://www.TheIET.org/ManageVideos"      at "/Utils/ManageVideos.xqy";


declare variable $inputSearchDetails as xs:string external ;

let $Log 	   := xdmp:log("[ IET-TV ][ Add InspecAbstract Element ][ Call ][ Service call ]")
(:let $inputSearchDetails := "<VideoRecord>
                                  <VideoID>171889896</VideoID>
                                  <VideoType>PublishedCopy</VideoType>
                            </VideoRecord>":)
let $InputXml  := xdmp:unquote($inputSearchDetails)
let $VideoID := $InputXml/VideoRecord/VideoID/text()
let $VideoType := $InputXml/VideoRecord/VideoType/text()
let $VideoXml := cts:search(collection($VideoType),
                  cts:element-attribute-value-query(
                    xs:QName("Video"),
                    xs:QName("ID"),
                    $VideoID))
let $InspecAbstract := <InspecAbstract>{VIDEOS:AddInspecAbstract($VideoXml)}</InspecAbstract>

return 
        if ($VideoXml/Video)
        then
                if ($VideoXml/Video/InspecAbstract)
                then ((xdmp:node-replace($VideoXml/Video/InspecAbstract,$InspecAbstract),
                     (xdmp:log("[ IET-TV ][ Add InspecAbstract Element ][ Call ][ Successfully Replaced ]"),
                     "Success" )))
                else ((xdmp:node-insert-child($VideoXml/Video,$InspecAbstract),
                     (xdmp:log("[ IET-TV ][ Add InspecAbstract Element ][ Call ][ Successfully Inserted ]"),
                     "Success" )))
        else 
              (xdmp:log("[ IET-TV ][ Add InspecAbstract Element ][ Call ][ Video ID Not Available ]"),
               "Failure" )
               
