(: This script will run as scheuler and generate an XML file to keep top 20 most popular videos:)

let $Log := xdmp:log("[ IET-TV ][ Scheduler ][ Start ][ ======================== Common Most Popular Scheduler Start ======================== ]")
let $MostPopularXml := <CommonMostPopular>
                      {
                       for $EachCollection at $Pos in cts:collections()[fn:not(fn:starts-with(., "Channel-"))]
																		[fn:not(fn:starts-with(., "IET-TV"))]
																		[fn:not(fn:starts-with(., "WebPortal"))]
																		[fn:not(fn:starts-with(., "Admin"))]
                        let $Count := xdmp:estimate(cts:search(collection($EachCollection), cts:element-query(xs:QName("Type"), "Play")))
                        order by $Count descending
                        return
                          if($Count!=0) then <Video><VideoID>{$EachCollection}</VideoID><Count>{$Count}</Count></Video> else ()
                      }
                    </CommonMostPopular>
return try{
			xdmp:document-insert("/Admin/CommonMostPopular.xml", $MostPopularXml),
			xdmp:log("[ IET-TV ][ Scheduler ][ End ][ ======================== Common Most Popular Scheduler End ======================== ]")
			}
       catch($e){xdmp:log($e)}