for $Video in (cts:search(/Video,  cts:collection-query("PublishedCopy")))
let $PDate := if(data($Video/PublishInfo/VideoPublish/@active)='yes')
               then
                 if($Video/PublishInfo/VideoPublish/FinalStartDate/text()='1900-01-01T00:00:00.0000')
                 then $Video/PublishInfo/VideoPublish/RecordStartDate/text()
                 else $Video/PublishInfo/VideoPublish/FinalStartDate/text()
               else
                if($Video/PublishInfo/LivePublish/LiveFinalStartDate/text()='1900-01-01T00:00:00.0000')
                then $Video/PublishInfo/LivePublish/LiveRecordStartDate/text()
                else $Video/PublishInfo/LivePublish/LiveFinalStartDate/text()
let $Uri := xdmp:node-uri($Video)
return xdmp:node-insert-child($Video,  <FilteredPubDate>{$PDate}</FilteredPubDate>)