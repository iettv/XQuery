(: Step 1: Remove all VideoNumber element from MarkLogic Database :)

xquery version "1.0-ml";

import module namespace constants = "http://www.TheIET.org/constants"   at "/Utils/constants.xqy";

for $Video in /Video
return xdmp:node-delete($Video/VideoNumber)

---------------------------------------------------------------------------------------------------------------------

(: Step 2: Insert VideoNumber Counter into MarkLogic Database :)

xquery version "1.0-ml";

import module namespace constants = "http://www.TheIET.org/constants"   at "/Utils/constants.xqy"; 
(:
	This service will create an XML file in MarkLogic repository so that other program may generate Video Number for video meta-data file(s)
:)
xdmp:document-insert($constants:VideoSequenceUri, <Counter>0</Counter>)

--------------------------------------------------------------------------------------------------------------------------
(: Step 3: Generate VideoNumber on Videos on MarkLogic Database :)

xquery version "1.0-ml";

import module namespace constants = "http://www.TheIET.org/constants"   at "/Utils/constants.xqy";

let $UpdatedCounter := 0
let $Counter := doc($constants:VideoSequenceUri)/Counter/text()
return
(
  let $Videos := <Video>
					{
						let $Other := <Video><ID>/Video/6adb39f2-d8a5-4d3c-878d-4a57804a8520.xml</ID><ID>/Video/100367.xml</ID><ID>/Video/bf79fa6f-d258-48e3-b3db-4d92f7fa6107.xml</ID><ID>/Video/19261.xml</ID><ID>/Video/17000015-f10b-4a97-9f79-a534b129255b.xml</ID><ID>/Video/5637034d-cc6f-4050-a240-3fc9bf1ab7e2.xml</ID><ID>/Video/575fed25-9c38-4453-8d1a-2a6ddb634021.xml</ID><ID>/Video/8e050fbe-3584-4543-a56c-af92343b2cce.xml</ID></Video>
						for $Video in (cts:search(/Video,  cts:collection-query(("Video-Status-Published", "Video-Status-Withdrawn"))), for $EachRecord in $Other//ID/text() return doc($EachRecord)/Video)
						let $Result := concat(data($Video/@ID), ">>" ,
											   $Video/VideoStatus/text(), ">>",
											   normalize-space($Video/BasicInfo/Title/text()), ">>",
											   if(data($Video/PublishInfo/VideoPublish/@active)='yes') then "Video" else  "Live", ">>",
											   if(data($Video/PublishInfo/VideoPublish/@active)='yes')
											   then
												 if($Video/PublishInfo/VideoPublish/FinalStartDate/text()='1900-01-01T00:00:00.0000')
												 then concat($Video/PublishInfo/VideoPublish/RecordStartDate/text(), ">> RecordStartDate ")
												 else concat($Video/PublishInfo/VideoPublish/FinalStartDate/text(), ">> FinalStartDate ")
											   else
												if($Video/PublishInfo/LivePublish/LiveRecordStartDate/text()='1900-01-01T00:00:00.0000')
												then concat($Video/PublishInfo/LivePublish/LiveFinalStartDate/text(),  ">> FinalStartDate ")
												else concat($Video/PublishInfo/LivePublish/LiveRecordStartDate/text(), ">> RecordStartDate ")
												)
						order by xs:dateTime(tokenize($Result,'>>')[5]) ascending
						return <ID>{tokenize($Result,'>>')[1]}</ID>
					}
					</Video>
  for $EachID at $Pos in $Videos/ID/text()
  let $VideoURI   := fn:concat($constants:VIDEO_DIRECTORY,$EachID,".xml")
  let $NewCounter := sum(xs:integer($Counter) + $Pos)
  let $SetCounter := xdmp:set($UpdatedCounter, $NewCounter)
  return
   (
      xdmp:node-insert-after(doc($VideoURI)/Video/HomePageVideo, <VideoNumber>{$NewCounter}</VideoNumber>)
    ,
      let $PCopyUri := fn:concat($constants:PCOPY_DIRECTORY,$EachID,".xml")
      return
        if(doc-available($PCopyUri))
        then xdmp:node-insert-after(doc($PCopyUri)/Video/HomePageVideo, <VideoNumber>{$NewCounter}</VideoNumber>)
        else ()
   )
   ,
   xdmp:document-insert($constants:VideoSequenceUri, <Counter>{$UpdatedCounter}</Counter>)
)

--------------------------------------------------------------------------------------------------------------------------
xquery version "1.0-ml";

import module namespace constants = "http://www.TheIET.org/constants"   at "/Utils/constants.xqy";

let $UpdatedCounter := 0
let $Counter := doc($constants:VideoSequenceUri)/Counter/text()
return
(
  let $Videos := <Video>
					{
						for $Video in (cts:search(/Video,  cts:collection-query(("Video-Status-Published", "Video-Status-Withdrawn"))))
						let $Result := concat(data($Video/@ID), ">>" ,
											   $Video/VideoStatus/text(), ">>",
											   normalize-space($Video/BasicInfo/Title/text()), ">>",
											   if(data($Video/PublishInfo/VideoPublish/@active)='yes') then "Video" else  "Live", ">>",
											   if(data($Video/PublishInfo/VideoPublish/@active)='yes')
											   then
												 if($Video/PublishInfo/VideoPublish/FinalStartDate/text()='1900-01-01T00:00:00.0000')
												 then concat($Video/PublishInfo/VideoPublish/RecordStartDate/text(), ">> RecordStartDate ")
												 else concat($Video/PublishInfo/VideoPublish/FinalStartDate/text(), ">> FinalStartDate ")
											   else
												if($Video/PublishInfo/LivePublish/LiveRecordStartDate/text()='1900-01-01T00:00:00.0000')
												then concat($Video/PublishInfo/LivePublish/LiveFinalStartDate/text(),  ">> FinalStartDate ")
												else concat($Video/PublishInfo/LivePublish/LiveRecordStartDate/text(), ">> RecordStartDate ")
												)
						order by xs:dateTime(tokenize($Result,'>>')[5]) ascending
						return <ID>{tokenize($Result,'>>')[1]}</ID>
					}
					</Video>
  for $EachID at $Pos in $Videos/ID/text()
  let $VideoURI   := fn:concat($constants:VIDEO_DIRECTORY,$EachID,".xml")
  let $NewCounter := sum(xs:integer($Counter) + $Pos)
  let $SetCounter := xdmp:set($UpdatedCounter, $NewCounter)
  return
   (
      xdmp:node-insert-after(doc($VideoURI)/Video/HomePageVideo, <VideoNumber>{$NewCounter}</VideoNumber>)
    ,
      let $PCopyUri := fn:concat($constants:PCOPY_DIRECTORY,$EachID,".xml")
      return
        if(doc-available($PCopyUri))
        then xdmp:node-insert-after(doc($PCopyUri)/Video/HomePageVideo, <VideoNumber>{$NewCounter}</VideoNumber>)
        else ()
   )
   ,
   xdmp:document-insert($constants:VideoSequenceUri, <Counter>{$UpdatedCounter}</Counter>)
)
---------------------------------------------------------------------------------------

import module namespace constants = "http://www.TheIET.org/constants"   at "/Utils/constants.xqy";


let $UpdatedCounter := 0
let $Counter := doc($constants:VideoSequenceUri)/Counter/text()
let $UpdateRecord:= xdmp:node-replace(doc("/Video/41503.xml")/Video/VideoNumber, <VideoNumber>{sum($Counter+1)}</VideoNumber>)
let $UpdateRecord:= xdmp:node-replace(doc("/PCopy/41503.xml")/Video/VideoNumber, <VideoNumber>{sum($Counter+1)}</VideoNumber>)
let $Counter := xdmp:document-insert($constants:VideoSequenceUri, <Counter>{sum($Counter+1)}</Counter>)
return $Counter



-------------------------------------------------------------------------------------------------------------------------------------------------