xquery version "1.0-ml";

import module namespace constants = "http://www.TheIET.org/constants"      at "/Utils/constants.xqy";
import module namespace VIDEOS    = "http://www.TheIET.org/ManageVideos"   at "/Utils/ManageVideos.xqy";
import module namespace mem       = "http://xqdev.com/in-mem-update"       at "/MarkLogic/appservices/utils/in-mem-update.xqy";

(:~ This service is to generate Related Video content and depends on external parameters
	: @VideoID       - The ID of the video to which Related video required.
	: @SkipChannel   - Keeps Channel ID - Private/Staff-Channel so that script may ignore those Channels from search. And if any log in user has access on
	:                 Private Channel, it must be excluded from the list. And front-end team will exclude this when call this function.
	:                 If there is no Private/Staff-Channel, it must be <SkipChannel>NONE</SkipChannel>
	:
	:  <Videos><SkipChannel><ID>1</ID><ID>2</ID><ID>3</ID></SkipChannel><VideoID>444809ff-5c30-4c46-9327-7de9e905dd4c</VideoID></Videos> 
:)


declare variable $inputSearchDetails as xs:string external;
let $InputXML  		:= xdmp:unquote($inputSearchDetails)
let $VideoID 		:= $InputXML/Videos/VideoID/text()
let $SkipChannel 	:= $InputXML/Videos/SkipChannel//text()
return
	if( not($SkipChannel) and $SkipChannel!="NONE" )
	then
		(
			xdmp:log("[ RelatedVideo ][ ERROR ][ Skip Channel is Empty ]"),
			"ERROR: Please provide skip channel list. Currently it is empty."
		)
	else
	if($VideoID)
	then
		let $VideoXML 	   := fn:doc(concat($constants:PCOPY_DIRECTORY,$VideoID,".xml"))
		let $InspecKeyword := let $a := $VideoXML/Video/VideoInspec/Kwd-Group/Kwd/text()
							  for $each in $a
							  return tokenize($each," ")
		let $CompoundKeyword := let $a := $VideoXML/Video/VideoInspec/Kwd-Group/Compound-Kwd/Compound-Kwd-Part/text()
								for $each in $a
								return tokenize($each," ")
		let $DefaultKeyword := $VideoXML/Video/KeyWordInfo/ChannelKeywordList/Channel/KeywordList/DefaultKeyword/@ID
		let $CustomKeywords := $VideoXML/Video/KeyWordInfo/CustomKeywordList/CustomKeyword/text()
		let $ChannelName    := $VideoXML/Video/BasicInfo/ChannelMapping/Channel/ChannelName/text()
		let $Speakers       := $VideoXML/Video/Speakers/Person/Name/Given-Name/text()
		let $Title          := $VideoXML/Video/BasicInfo/Title/text()
		let $Description    := let $a := $VideoXML/Video/BasicInfo/ShortDescription//text()
							   for $each in $a
							   return tokenize($each," ")
		let $Abstract       := let $a := $VideoXML/Video/BasicInfo/Abstract//text()
							   for $each in $a
							   return tokenize($each," ")
		
		let $LatestVideoList := for $eachVideoID in fn:doc($constants:CommonLatestVideo)/Latest/VideoID/text() return replace($eachVideoID,"-","")
		let $LatestVideos    := <Videos>
							{	
								let $result := cts:search(fn:collection("PublishedCopy")/Video[cts:contains(replace(@ID,"-",""), $LatestVideoList)]
																							  [not(BasicInfo/ChannelMapping/Channel/@ID = $SkipChannel)]
																							  [@ID!=$VideoID]
															,
															cts:or-query((
																for $each in $InspecKeyword return cts:element-word-query(xs:QName("Kwd"),$each,("case-insensitive","diacritic-insensitive","punctuation-insensitive","stemmed","wildcarded"),20),
																for $each in $CompoundKeyword return cts:element-word-query(xs:QName("Compound-Kwd-Part"),$each,("case-insensitive","diacritic-insensitive","punctuation-insensitive","stemmed","wildcarded"),20),
																for $each in $DefaultKeyword return cts:element-attribute-value-query(xs:QName("DefaultKeyword"), xs:QName("ID"),$each,(),15),
																for $each in $CustomKeywords return cts:element-word-query(xs:QName("CustomKeyword"),$each,("case-insensitive","diacritic-insensitive","punctuation-insensitive","stemmed","wildcarded"),10),
																for $each in tokenize($Title, " ") return cts:element-word-query(xs:QName("Title"),$each,("case-insensitive","diacritic-insensitive","punctuation-insensitive","stemmed","wildcarded"),3),
																for $each in $Speakers return cts:path-range-query("/Speakers/Person/Name/Given-Name","=",$each,(),5),
																for $each in $Description return cts:element-word-query(xs:QName("ShortDescription"),$each,("case-insensitive","diacritic-insensitive","punctuation-insensitive","stemmed","wildcarded"),2),
																for $each in $ChannelName return cts:element-word-query(xs:QName("ChannelName"),$each,(),3),
																for $each in $Abstract return cts:element-word-query(xs:QName("Abstract"),$each,("case-insensitive","diacritic-insensitive","punctuation-insensitive","stemmed","wildcarded"),1)
																		))
														  )
								return $result[1 to 4] 		
							}
							</Videos>
		
		let $LatestVideo:= <LatestVideos> { VIDEOS:GetRelatedVideos($LatestVideos) } </LatestVideos>
		
		let $RelatedLatestVideoID := for $EachID in $LatestVideo//Video return concat($EachID/@ID,"")
		let $RelatedLatestVideoID := fn:string-join($RelatedLatestVideoID, " ")
		let $CurrentMostPopularList := for $eachVideoID in VIDEOS:GetCommonPopularFile()/CommonMostPopular/Video/VideoID/text() return replace($eachVideoID,"-","")
		
		let $PopularVideos :=   <Videos>
									{
										let $result := cts:search(fn:collection("PublishedCopy")/Video[cts:contains(replace(@ID,"-",""), $CurrentMostPopularList)]
																									  [not(cts:contains(@ID, $LatestVideo//Video/@ID))]
																									  [not(BasicInfo/ChannelMapping/Channel/@ID = $SkipChannel)]
																									  [@ID!=$VideoID]
																	,
																	cts:or-query((
																		for $each in $InspecKeyword return cts:element-word-query(xs:QName("Kwd"),$each,("case-insensitive","diacritic-insensitive","punctuation-insensitive","stemmed","wildcarded"),20),
																		for $each in $CompoundKeyword return cts:element-word-query(xs:QName("Compound-Kwd-Part"),$each,("case-insensitive","diacritic-insensitive","punctuation-insensitive","stemmed","wildcarded"),20),
																		for $each in $DefaultKeyword return cts:element-attribute-value-query(xs:QName("DefaultKeyword"), xs:QName("ID"),$each,(),15),
																		for $each in $CustomKeywords return cts:element-word-query(xs:QName("CustomKeyword"),$each,("case-insensitive","diacritic-insensitive","punctuation-insensitive","stemmed","wildcarded"),10),
																		for $each in tokenize($Title, " ") return cts:element-word-query(xs:QName("Title"),$each,("case-insensitive","diacritic-insensitive","punctuation-insensitive","stemmed","wildcarded"),3),
																		for $each in $Speakers return cts:path-range-query("/Speakers/Person/Name/Given-Name","=",$each,(),5),
																		for $each in $Description return cts:element-word-query(xs:QName("ShortDescription"),$each,("case-insensitive","diacritic-insensitive","punctuation-insensitive","stemmed","wildcarded"),2),
																		for $each in $ChannelName return cts:element-word-query(xs:QName("ChannelName"),$each,(),3),
																		for $each in $Abstract return cts:element-word-query(xs:QName("Abstract"),$each,("case-insensitive","diacritic-insensitive","punctuation-insensitive","stemmed","wildcarded"),1)
																				))
																 )
										return $result[1 to 4]	
									}
									</Videos>
			
		let $PopularVideo:= VIDEOS:GetRelatedVideos($PopularVideos)
		
		return (<RelatedVideos>{$LatestVideo}<PopularVideos>{$PopularVideo}</PopularVideos></RelatedVideos>)

	else
	(
		xdmp:log("VideoID is Empty"),
		"VideoID is empty"
	)
