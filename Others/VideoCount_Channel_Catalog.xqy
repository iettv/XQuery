xquery version "1.0-ml";
declare namespace html = "http://www.w3.org/1999/xhtml";
import module namespace constants = "http://www.TheIET.org/constants"   at "/Utils/constants.xqy";

(:Pass ChannelID:) 

let $inputSearchDetails := '<Video><ChannelID>2</ChannelID></Video>'
let $inputSearchDetails :=xdmp:unquote($inputSearchDetails)   
let $ChannelID := $inputSearchDetails//ChannelID/text()

let $case1 := cts:search(collection("PublishedCopy"),
						cts:and-query((
						cts:element-range-query(xs:QName("FinalStartDate"), "!=",xs:dateTime("1900-01-01T00:00:00.0000")),
						cts:element-range-query(xs:QName("FinalStartDate"), "<=",xs:dateTime("2012-12-31T23:59:59.0000")),
						cts:element-attribute-range-query(xs:QName("Channel"),xs:QName("ID"), "=", $ChannelID )
									))
						)
let $case1count := count($case1)

let $case2 := cts:search(collection("PublishedCopy"),
						cts:and-query((
						cts:element-range-query(xs:QName("FinalStartDate"), "!=",xs:dateTime("1900-01-01T00:00:00.0000")),
						cts:element-range-query(xs:QName("FinalStartDate"), ">=",xs:dateTime("2013-01-01T00:00:00.0000")),
            cts:element-attribute-range-query(xs:QName("Channel"),xs:QName("ID"), "=", $ChannelID )
									))
						)
let $case2count := count($case2)

let $case3 := cts:search(collection("PublishedCopy"),
						cts:and-query((
						cts:element-range-query(xs:QName("FinalStartDate"), "!=",xs:dateTime("1900-01-01T00:00:00.0000")),
						cts:element-range-query(xs:QName("FinalStartDate"), "<=",xs:dateTime("2013-12-31T23:59:59.0000")),
						cts:element-range-query(xs:QName("FinalStartDate"), ">=",xs:dateTime("2013-01-01T00:00:00.0000")),
            cts:element-attribute-range-query(xs:QName("Channel"),xs:QName("ID"), "=", $ChannelID )
									))
						)
let $case3count := count($case3)

let $case4 := cts:search(collection("PublishedCopy"),
						cts:and-query((
						cts:element-range-query(xs:QName("FinalStartDate"), "!=",xs:dateTime("1900-01-01T00:00:00.0000")),
						cts:element-range-query(xs:QName("FinalStartDate"), "<=",xs:dateTime("2014-12-31T23:59:59.0000")),
						cts:element-range-query(xs:QName("FinalStartDate"), ">=",xs:dateTime("2014-01-01T00:00:00.0000")),
            cts:element-attribute-range-query(xs:QName("Channel"),xs:QName("ID"), "=", $ChannelID )
									))
						)
let $case4count := count($case4)

let $case5 := cts:search(collection("PublishedCopy"),
						cts:and-query((
						cts:element-range-query(xs:QName("FinalStartDate"), "!=",xs:dateTime("1900-01-01T00:00:00.0000")),
						cts:element-range-query(xs:QName("FinalStartDate"), "<=",xs:dateTime("2015-12-31T23:59:59.0000")),
						cts:element-range-query(xs:QName("FinalStartDate"), ">=",xs:dateTime("2015-01-01T00:00:00.0000")),
            cts:element-attribute-range-query(xs:QName("Channel"),xs:QName("ID"), "=", $ChannelID )
									))
						)
let $case5count := count($case5)

let $primary := cts:search(collection("PublishedCopy"),
						cts:and-query((
						cts:element-range-query(xs:QName("FinalStartDate"), "!=",xs:dateTime("1900-01-01T00:00:00.0000")),
            cts:element-attribute-value-query(xs:QName("Channel"),xs:QName("default"),  "true" ),
            cts:element-attribute-range-query(xs:QName("Channel"),xs:QName("ID"), "=", $ChannelID )
									))
						)
let $primary := count($primary)


return <Videos>
    <Before2012>{$case1count}</Before2012><After2013>{$case2count}</After2013><Count2013>{$case3count}</Count2013>
  <Count2014>{$case4count}</Count2014><Count2015>{$case5count}</Count2015>
  <PrimaryChannel>{$primary}</PrimaryChannel>
</Videos>