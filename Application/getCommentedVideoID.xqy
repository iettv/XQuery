xquery version "1.0-ml";

(: This service will collect all video Id where abuse has been reported :)

<AbuseComments>
  {
    for $SortedVideoID in distinct-values(for $EachCollection in cts:collection-match("Comment-*")
                                          for $Result in cts:search(collection($EachCollection)/Comment[@abuse="yes"], cts:element-range-query(xs:QName("UpdatedDate"), "<=",fn:current-dateTime()))
                                          order by xs:dateTime($Result/UpdatedDate) descending
                                          return $Result/VideoID/text())

    return <VideoID>{$SortedVideoID}</VideoID>
  }
</AbuseComments>
