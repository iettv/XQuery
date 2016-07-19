xquery version "1.0-ml";

import module namespace constants = "http://www.TheIET.org/constants"   at "/Utils/constants.xqy"; 

(: To update Series in Video XML and PCopy XML:)
(:
<VideoSeries>
	<Action>Delete/Update</Action>
	<Videos>
		<VideoID>7a93acd0-b460-4d14-b28c-e73a86ad1d59</VideoID>
		<VideoID>e0298405-bdf0-45b9-9372-71aa4480b471</VideoID>		
	</Videos>
	<SeriesList>
		<Series ID="82">
		  <SeriesName>Rave IPL Series</SeriesName>
		  <Description>Rave IPL Series</Description>
		  <IconImage>SeriesLogos_82.jpg</IconImage>
		</Series>
		<Series ID="92">
		  <SeriesName>IET Series </SeriesName>
		  <Description>IET Series </Description>
		  <IconImage>SeriesLogos_92.jpg</IconImage>
		</Series>
  </SeriesList>
</VideoSeries>
:)

declare variable $inputSearchDetails as xs:string external;

let $VideoSeries  := xdmp:unquote($inputSearchDetails)
let $Action := $VideoSeries//Action
return
if($Action/text())
then
	(
	for $eachVideoID in $VideoSeries//Videos/VideoID
	return 
		if($eachVideoID/text())
		then 
		(
			let $PCopyXML := doc(fn:concat($constants:PCOPY_DIRECTORY,$eachVideoID/text(),".xml"))
			let $VideoXML := doc(fn:concat($constants:VIDEO_DIRECTORY,$eachVideoID/text(),".xml"))
			return 
			if($Action/text() eq "Update")
			then
			(
			if( not($PCopyXML/Video/SeriesList) )
			then
				(
					xdmp:node-insert-child($PCopyXML/Video, $VideoSeries//SeriesList),
					xdmp:node-insert-child($VideoXML/Video, $VideoSeries//SeriesList),
					xdmp:log("*********Series Inserted*********")
				)				
			else
				for $eachSeriesList in $VideoSeries//SeriesList/Series
				return
					if( ($PCopyXML/Video/SeriesList/Series/@ID/string()) eq ($eachSeriesList/@ID/string()) )
					then
					(
						xdmp:node-replace($PCopyXML/Video/SeriesList/Series[@ID/string() eq $eachSeriesList/@ID/string()], $eachSeriesList),
						xdmp:node-replace($VideoXML/Video/SeriesList/Series[@ID/string() eq $eachSeriesList/@ID/string()], $eachSeriesList),
						xdmp:log("*********Series Replaced*********")
					)
					else
					(
						xdmp:node-insert-child($PCopyXML/Video/SeriesList, $eachSeriesList),
						xdmp:node-insert-child($VideoXML/Video/SeriesList, $eachSeriesList),
						xdmp:log("*********Series Inserted*********")
					)
			)
			else if($Action/text() eq "Delete")
			then
			(
				let $Series := $VideoSeries//SeriesList/Series
				return
				(
					xdmp:node-delete($PCopyXML/Video/SeriesList/Series[@ID/string() eq $Series/@ID/string()]),
					xdmp:node-delete($VideoXML/Video/SeriesList/Series[@ID/string() eq $Series/@ID/string()]),
					xdmp:log("*********Series Deleted*********")
				)
			)
			else ()
		)
		else
		(
			"VideoID empty",
			xdmp:log("*******VideoID empty*******")
		)
	)
	else			
	(
		"Action empty",
		xdmp:log("*******Action empty*******")
	)