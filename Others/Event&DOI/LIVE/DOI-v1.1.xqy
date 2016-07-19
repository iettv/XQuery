import module namespace constants = "http://www.TheIET.org/constants"   at "/Utils/constants.xqy";
let $doiPre := "10.1049/iet-tv.vn."
let $Videos := <video><no>2271</no><no>2272</no><no>2499</no><no>2947</no><no>2950</no><no>3021</no><no>3759</no><no>4145</no><no>4250</no><no>4380</no><no>4472</no><no>4473</no><no>4542</no><no>4658</no><no>4660</no><no>4851</no><no>4852</no><no>4853</no><no>4854</no><no>4890</no><no>4891</no><no>4927</no><no>4928</no><no>4934</no><no>4944</no><no>4948</no><no>4979</no><no>4980</no><no>5534</no><no>5669</no><no>5702</no><no>5801</no><no>5969</no><no>5970</no><no>6056</no><no>6069</no><no>6241</no><no>6242</no><no>6245</no><no>6246</no><no>6247</no><no>6248</no><no>6335</no><no>6336</no><no>6354</no><no>6477</no><no>6481</no><no>6494</no><no>6495</no><no>6496</no><no>6569</no><no>6570</no><no>6572</no><no>6599</no><no>6672</no><no>6727</no><no>6730</no><no>6842</no><no>7063</no><no>7068</no><no>7265</no><no>7379</no><no>7380</no></video>
for $eachVideo in $Videos/no/text()
let $updatedDoi     := fn:concat($doiPre,$eachVideo)
let $VideoID        := collection("Video")/Video[VideoNumber=$eachVideo]/@ID/string()
let $VideoURI 			:= fn:concat($constants:VIDEO_DIRECTORY,$VideoID,".xml")
let $PHistoryUri		:= fn:concat($constants:PCOPY_DIRECTORY,$VideoID,".xml")
return
  (
    if(fn:doc-available($VideoURI))
    then
      let $doc := fn:doc($VideoURI)
      return
        if( $doc/Video/PublishInfo[VideoPublish/@active="yes"] )
        then xdmp:node-replace($doc/Video/PublishInfo/VideoPublish/DOI, <DOI>{$updatedDoi}</DOI>)
        else
        if( $doc/Video/PublishInfo[LivePublish/@active="yes"] )
        then xdmp:node-replace($doc/Video/PublishInfo/LivePublish/DOI, <DOI>{$updatedDoi}</DOI>)
        else xdmp:log(("======doi not replaced in =============", $VideoURI))
    else xdmp:log(("======document not available=============", $VideoURI))
    ,
    if(fn:doc-available($PHistoryUri))
    then
      let $doc := fn:doc($PHistoryUri)
      return
        if( $doc/Video/PublishInfo[VideoPublish/@active="yes"] )
        then xdmp:node-replace($doc/Video/PublishInfo/VideoPublish/DOI, <DOI>{$updatedDoi}</DOI>)
        else
        if( $doc/Video/PublishInfo[LivePublish/@active="yes"] )
        then xdmp:node-replace($doc/Video/PublishInfo/LivePublish/DOI, <DOI>{$updatedDoi}</DOI>)
        else xdmp:log(("======doi not replaced in =============", $PHistoryUri))
    else xdmp:log(("======document not available=============", $PHistoryUri))
   )    
