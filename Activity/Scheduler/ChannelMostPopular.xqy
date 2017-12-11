(: This script will run as scheduler and generate multiple XML file(s) to keep top 50 most popular Videos ID(s) in respect of channels :)

let $Log := xdmp:log("[ IET-TV ][ Scheduler ][ Start ][ ======================== Channel Most Popular Scheduler Start ======================== ]")
for $EachChannel at $Pos in cts:collections()[fn:starts-with(., "Channel-")] (: To take only channel collections :)
let $PopularVideo :=  (:(for $EachVideoID in cts:element-values(xs:QName("EntityID"), ""):) (: To get distinct video id from range index :)
					  (for $EachVideoID in cts:collections()[not(fn:starts-with(., "Channel-")) and
															 not(fn:starts-with(., "IET-TV")) and
															 not(fn:starts-with(., "WebPortal")) and
															 not(fn:starts-with(., "Admin"))
															]
                      let $VideoResult := cts:search(collection($EachChannel)/Activity,
                                                      cts:and-query((
                                                                      cts:element-query(xs:QName("Type"), "Play"),
                                                                      cts:element-query(xs:QName("EntityID"), $EachVideoID)
                                                                     )))/EntityID
                      let $Count := count($VideoResult)
                      order by $Count descending
                      return if($Count!=0) then <Video><VideoID>{$EachVideoID}</VideoID><Count>{$Count}</Count></Video> else ""
                      )[1 to 50]
return
  try{
       xdmp:document-insert(concat("/Admin/Channel-", fn:substring-after($EachChannel,"Channel-"), ".xml"), <ChannelMostPopular ChannelID="{$EachChannel}">{$PopularVideo}</ChannelMostPopular>),
       xdmp:log("[ IET-TV ][ Scheduler ][ End ][ ======================== Channel Most Popular Scheduler End ======================== ]")
     }
  catch($e){xdmp:log($e)}
;