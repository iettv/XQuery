import module namespace constants = "http://www.TheIET.org/constants"   at "/Utils/constants.xqy";

let $Videos := <videos>
                  <v><vn>387</vn><c>Sharjah</c><co>United Arab Emirates</co></v>
                  <v><vn>589</vn><c>Sharjah</c><co>United Arab Emirates</co></v>
                  <v><vn>663</vn><c>Sharjah</c><co>United Arab Emirates</co></v>
                  <v><vn>702</vn><c>Sharjah</c><co>United Arab Emirates</co></v>
                  <v><vn>1160</vn><c>Sharjah</c><co>United Arab Emirates</co></v>
                  <v><vn>1245</vn><c>Sharjah</c><co>United Arab Emirates</co></v>
                  <v><vn>1276</vn><c>Sharjah</c><co>United Arab Emirates</co></v>
                  <v><vn>1277</vn><c>Sharjah</c><co>United Arab Emirates</co></v>
                  <v><vn>1278</vn><c>Sharjah</c><co>United Arab Emirates</co></v>
                  <v><vn>1279</vn><c>Sharjah</c><co>United Arab Emirates</co></v>
                  <v><vn>1287</vn><c>Sharjah</c><co>United Arab Emirates</co></v>
                  <v><vn>1297</vn><c>Sharjah</c><co>United Arab Emirates</co></v>
                  <v><vn>1302</vn><c>Sharjah</c><co>United Arab Emirates</co></v>
                  <v><vn>1306</vn><c>Sharjah</c><co>United Arab Emirates</co></v>
                  <v><vn>1374</vn><c>Sharjah</c><co>United Arab Emirates</co></v>
                  <v><vn>1580</vn><c>Sharjah</c><co>United Arab Emirates</co></v>
                  <v><vn>2194</vn><c>Sharjah</c><co>United Arab Emirates</co></v>
                  <v><vn>2420</vn><c>Sharjah</c><co>United Arab Emirates</co></v>
                  <v><vn>2834</vn><c>Sharjah</c><co>United Arab Emirates</co></v>
                  <v><vn>2922</vn><c>Sharjah</c><co>United Arab Emirates</co></v>
                  <v><vn>2923</vn><c>Sharjah</c><co>United Arab Emirates</co></v>
                  <v><vn>2924</vn><c>Sharjah</c><co>United Arab Emirates</co></v>
                  <v><vn>2952</vn><c>Sharjah</c><co>United Arab Emirates</co></v>
                  <v><vn>3241</vn><c>Sharjah</c><co>United Arab Emirates</co></v>
                  <v><vn>3242</vn><c>Sharjah</c><co>United Arab Emirates</co></v>
                  <v><vn>3246</vn><c>Sharjah</c><co>United Arab Emirates</co></v>
                  <v><vn>3531</vn><c>Sharjah</c><co>United Arab Emirates</co></v>
                  <v><vn>3600</vn><c>Sharjah</c><co>United Arab Emirates</co></v>
                  <v><vn>6051</vn><c>London</c><co>United Kingdom</co></v>
                  <v><vn>6052</vn><c>London</c><co>United Kingdom</co></v>
                  <v><vn>6053</vn><c>London</c><co>United Kingdom</co></v>
                  <v><vn>6054</vn><c>London</c><co>United Kingdom</co></v>
                  <v><vn>6055</vn><c>London</c><co>United Kingdom</co></v>
                  <v><vn>6060</vn><c>London</c><co>United Kingdom</co></v>
                  <v><vn>6061</vn><c>London</c><co>United Kingdom</co></v>
                  <v><vn>6062</vn><c>London</c><co>United Kingdom</co></v>
                  <v><vn>6063</vn><c>London</c><co>United Kingdom</co></v>
                </videos>
for $eachVideo in $Videos/v
let $VideoID        := collection("Video")/Video[VideoNumber=$eachVideo/vn]/@ID/string()
let $VideoURI 			:= fn:concat($constants:VIDEO_DIRECTORY,$VideoID,".xml")
let $PHistoryUri		:= fn:concat($constants:PCOPY_DIRECTORY,$VideoID,".xml")
return
  (
    if(fn:doc-available($VideoURI))
    then
      let $doc := fn:doc($VideoURI)
      return
        if( $doc/Video/Events/Event )
        then
          (
            xdmp:node-replace($doc/Video/Events/Event/Location/Address/City, <City>{$eachVideo/c/text()}</City>),
            xdmp:node-replace($doc/Video/Events/Event/Location/Address/Country, <Country>{$eachVideo/co/text()}</Country>)
          )
        else  xdmp:log(("======Event not available in==========", $VideoURI))
    else xdmp:log(("======document not available=============", $VideoURI))
    ,
    if(fn:doc-available($PHistoryUri))
    then
      let $doc := fn:doc($PHistoryUri)
      return
        if( $doc/Video/Events/Event )
        then
          (
            xdmp:node-replace($doc/Video/Events/Event/Location/Address/City, <City>{$eachVideo/c/text()}</City>),
            xdmp:node-replace($doc/Video/Events/Event/Location/Address/Country, <Country>{$eachVideo/co/text()}</Country>)
          )
        else  xdmp:log(("======Event not available in==========", $PHistoryUri))
    else xdmp:log(("======document not available=============", $PHistoryUri))
   )    
