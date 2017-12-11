xquery version "1.0-ml";

module namespace LOOKUP = "http://www.TheIET.org/ManageLookup";

import module namespace VIDEOS     = "http://www.TheIET.org/ManageVideos"      at "/Utils/ManageVideos.xqy";
import module namespace search     = "http://marklogic.com/appservices/search" at "/MarkLogic/appservices/search/search.xqy";
import module namespace constants  = "http://www.TheIET.org/constants"         at "/Utils/constants.xqy"; 
import module namespace DICTIONARY = "http://www.TheIET.org/ManageDictionary"  at "/Utils/ManageDictionary.xqy";
import module namespace CHANNEL    = "http://www.TheIET.org/ManageChannel"     at "/Utils/ManageChannel.xqy";
import module namespace admin      = "http://marklogic.com/xdmp/admin"         at "/MarkLogic/admin.xqy";
import module namespace mem        = "http://xqdev.com/in-mem-update"          at  "/MarkLogic/appservices/utils/in-mem-update.xqy";

(: <SearchUserVideo><TextToSearch>susan</TextToSearch><TermToSearch>author:susan* AND ChannelType:1 AND ChannelType:2 AND KeywordType:1 AND PriceType:Premium AND Length:1</TermToSearch><PageLength>6</PageLength><StartPage>1</StartPage><SortBy>Oldest</SortBy></SearchUserVideo> :)

(: A new constraint 'Search' has been added to search within "Title,Speaker,Keywords,Description, and Abstract" through Fields :)

declare function VideoSearch($SkipChannel as item(), $TextToSearch as xs:string, $TermToSearch as xs:string, $PageLength as xs:integer, $StartPage as xs:integer, $SortBy as xs:string) as item()
{
	let $IsAuthor     := $TermToSearch
	
	let $CorrectWord  := if( starts-with($TextToSearch, 'Date:') or fn:starts-with($TextToSearch,'VideoNumber:')) then $TextToSearch else SpellCorrect($TextToSearch)
	(:let $InactiveChannelConstraint := string-join(for $StaffChannel in doc($constants:MasterChannelUri)//ID/text()[ancestor::Channel/Status='Inactive']
												  return concat('-ChannelType:',$StaffChannel), ' AND '):)
	let $SkipChannelConstraint := if( $SkipChannel//text() ne "NONE" )
								  then
										string-join(for $StaffChannel in $SkipChannel/ID/text()
												       return concat('-ChannelType:',$StaffChannel)
											  , ' AND ')
								  else "NONE"
	let $FilteredTerm := if(fn:starts-with($CorrectWord, ' ')) then fn:substring-after($CorrectWord, ' ') else $CorrectWord
	let $TermToSearch := if( fn:starts-with($TextToSearch,'author:') )
						 then
							 if(fn:contains($TermToSearch, '('))
							 then fn:concat(fn:concat('author:',fn:replace(substring-after($TextToSearch, 'author:'), ' ','@'), ' OR author:', normalize-space($CorrectWord),'*'), ' (', fn:substring-after($TermToSearch, '('))
							 else fn:concat('author:',replace(substring-after($TextToSearch, 'author:'), ' ','@'), ' OR author:', normalize-space($CorrectWord),'*')
						 else
						(: if( fn:starts-with($TextToSearch,'Date:') )
						 then
							if(fn:contains($TermToSearch, '('))
							then fn:concat('a* (', fn:substring-after($TermToSearch, '('))
							else 'a*'
						 else:)
						 if( fn:starts-with($TextToSearch,'VideoNumber:') or fn:starts-with($TextToSearch,'Date:') )
						 then $TermToSearch
						 else
                            (:							
							if(fn:contains($TermToSearch, '('))
							 then
								if(lower-case($TextToSearch) = lower-case($FilteredTerm))
								then if($TextToSearch cast as xs:integer) then fn:concat('Search:"', fn:lower-case($TextToSearch), '" OR *', fn:lower-case($TextToSearch), '* (', fn:substring-after($TermToSearch, '(')) else fn:concat('Search:"', fn:lower-case($TextToSearch), '" OR ', fn:lower-case($TextToSearch), ' (', fn:substring-after($TermToSearch, '('))
								else fn:concat('Search:"', fn:lower-case($TextToSearch), '" OR ', 'Search:"', $FilteredTerm, '" OR *', fn:lower-case($TextToSearch), '* OR *', $FilteredTerm, '* (', fn:substring-after($TermToSearch, '('))
							 else
								if(lower-case($TextToSearch) = lower-case($FilteredTerm))
								then if($TextToSearch cast as xs:integer) then fn:concat('Search:"', fn:lower-case($TextToSearch), '" OR ', fn:lower-case($TextToSearch)) else fn:concat('Search:"', fn:lower-case($TextToSearch), '" OR *', fn:lower-case($TextToSearch), '*')
								else fn:concat('Search:"', fn:lower-case($TextToSearch), '" OR ', 'Search:"', $FilteredTerm, '" OR *', fn:lower-case($TextToSearch), '* OR *', $FilteredTerm, '*')
							 :)
							 if(fn:contains($TermToSearch, '('))
							 then fn:concat('Search:"', fn:lower-case($TextToSearch), '" OR ', 'Search:"', $FilteredTerm, '" OR *', fn:lower-case($TextToSearch), '* OR *', $FilteredTerm, '* (', fn:substring-after($TermToSearch, '('))
							 else fn:concat('Search:"', fn:lower-case($TextToSearch), '" OR ', 'Search:"', $FilteredTerm, '" OR *', fn:lower-case($TextToSearch), '* OR *', $FilteredTerm, '*')
							 
    let $Start := if($StartPage = 1) then $StartPage else fn:sum(($StartPage * $PageLength) - $PageLength + 1)
	let $SearchOption := <options xmlns="http://marklogic.com/appservices/search">
							<term>
								<term-option>case-insensitive</term-option>
								<term-option>wildcarded</term-option>
								<term-option>stemmed</term-option>
								<term-option>diacritic-insensitive</term-option>
								<term-option>punctuation-insensitive</term-option>
							</term>
							{
							  if( $SortBy eq "TitleAscending" )
                              then  <sort-order type="xs:string" collation="http://marklogic.com/collation/" direction="ascending"><field name="VideoTitle"/></sort-order>
							  else
							  if( $SortBy eq "TitleDescending" )
                              then	<sort-order type="xs:string" collation="http://marklogic.com/collation/" direction="descending"><field name="VideoTitle"/></sort-order>
							  else
							  if( $SortBy eq "PublishedDes" )
                              then	<sort-order type="xs:dateTime" direction="descending"><element ns="" name="FilteredPubDate"/></sort-order> 
							  else
							  if( $SortBy eq "PublishedAsc" )
                              then	<sort-order type="xs:dateTime" direction="ascending"><element ns="" name="FilteredPubDate"/></sort-order> 
							  else
							  if( $SortBy eq "CreatedDes" )
                              then	<sort-order type="xs:string" collation="http://marklogic.com/collation/" direction="descending"><element ns="" name="VideoCreatedDate"/></sort-order> 
							  else
							  if( $SortBy eq "CreatedAsc" )
                              then	<sort-order type="xs:string" collation="http://marklogic.com/collation/" direction="ascending"><element ns="" name="VideoCreatedDate"/></sort-order> 
							  else
							  if( $SortBy eq "Popular" )
                              then	<sort-order type="xs:integer" collation="http://marklogic.com/collation/" direction="descending"><element ns="" name="ViewCount"/></sort-order> 
							  else
							  if( $SortBy eq "Like" )
                              then	<sort-order type="xs:integer" collation="http://marklogic.com/collation/" direction="descending"><element ns="" name="LikeCount"/></sort-order> 
							  else()
							}
							<constraint name="PriceType">
							   <range collation="http://marklogic.com/collation/" type="xs:string" facet="true">
									<attribute ns="" name="type"/>
									<element ns="" name="PricingDetails"/>
									<facet-option>frequency-order</facet-option>
									<facet-option>descending</facet-option>
							   </range>
							</constraint>
							<constraint name="ChannelType">
								<range type="xs:int" facet="true">
									<attribute ns="" name="ID"/>
									<element ns="" name="Channel"/>
									<facet-option>frequency-order</facet-option>
									<facet-option>descending</facet-option>
								</range>
							</constraint>
							<!--constraint name="VideoNumber">
								<range type="xs:int" facet="false">
									<element ns="" name="VideoNumber"/>
								</range>
							</constraint-->
							<constraint name="VideoNumber">
								<range collation="http://marklogic.com/collation/" type="xs:string" facet="false">
									<element ns="" name="VideoNumber"/>
								</range>
							</constraint>
							<constraint name="Title">
								<range type="xs:string" facet="true">
									<element ns="" name="Title"/>
									<facet-option>frequency-order</facet-option>
									<facet-option>descending</facet-option>
								</range>
							</constraint>
							<constraint name="Subtitles">
								<range collation="http://marklogic.com/collation/" type="xs:string" facet="true">
									<attribute ns="" name="active"/>
									<element ns="" name="Subtitle "/>
									<facet-option>frequency-order</facet-option>
									<facet-option>descending</facet-option>
								</range>
							</constraint>
							<constraint name="Transcripts">
								<range collation="http://marklogic.com/collation/" type="xs:string" facet="true">
									<attribute ns="" name="active"/>
									<element ns="" name="Transcript"/>
									<facet-option>frequency-order</facet-option>
									<facet-option>descending</facet-option>
								</range>
							</constraint>
							<constraint name="permission-AddCPDLogo">
                                <range type="xs:string" facet="true">
                                  <path-index>AdvanceInfo/PermissionDetails/Permission[@type='AddCPDLogo']/@status</path-index>
                                </range>
                            </constraint>
							<constraint name="KeywordType">
							   <range collation="http://marklogic.com/collation/" type="xs:string" facet="true">
									<element ns="" name="DefaultKeyword"/>
									<facet-option>frequency-order</facet-option>
									<facet-option>descending</facet-option>
							   </range>
							</constraint>
							<constraint name="InspecKeyword">
							   <range collation="http://marklogic.com/collation/" type="xs:string" facet="true">
									<element ns="" name="Kwd"/>
									<facet-option>frequency-order</facet-option>
									<facet-option>descending</facet-option>
							   </range>
							</constraint>
							<constraint name="CustomKeyword">
							   <range collation="http://marklogic.com/collation/" type="xs:string" facet="true">
									<element ns="" name="CustomKeyword"/>
									<facet-option>frequency-order</facet-option>
									<facet-option>descending</facet-option>
							   </range>
							</constraint>
							<constraint name="Search">
							  <word>
								<field name="Search"/>
							  </word> 
							</constraint>
							<constraint name="author">
								<properties/>
							</constraint>
							<constraint name="VideoCategory">
								<range type="xs:string" facet="true">
									<element ns="" name="VideoCategory"/>
									<facet-option>frequency-order</facet-option>
									<facet-option>descending</facet-option>
								</range>
							</constraint>
							<search:constraint name="Length">
								<search:range type="xs:time">
									<search:bucket lt="00:05:00" ge="00:00:00" name="1">&lt; 5 mins</search:bucket>
									<search:bucket lt="00:10:00" ge="00:05:00" name="2">5 - 10 mins</search:bucket>
									<search:bucket lt="00:30:00" ge="00:10:00" name="3">10 - 30 mins</search:bucket>
									<search:bucket  ge="00:30:00" name="4">&gt; 30 mins</search:bucket>
									<search:element ns="" name="Duration"/>
								</search:range>
							</search:constraint>
							<additional-query>
								{
									cts:and-query((
												for $StaffChannel in $constants:StaffChannelXml//text()
												return	
													cts:not-query(cts:element-attribute-range-query(xs:QName("Channel"), xs:QName("ID"), "=", xs:integer($StaffChannel)))
												,
												cts:or-query((
															  cts:element-range-query(xs:QName("FinalExpiryDate"), ">=",fn:current-dateTime()),
															  cts:element-range-query(xs:QName("FinalExpiryDate"), "=",xs:dateTime("1900-01-01T00:00:00.0000"))
															)),
												cts:or-query((
															  cts:and-query((
																cts:element-range-query(xs:QName("RecordStartDate"), "<=",fn:current-dateTime()),
																cts:element-range-query(xs:QName("RecordStartDate"), "!=",xs:dateTime("1900-01-01T00:00:00.0000"))
																	  )),
															  cts:and-query((
																cts:element-range-query(xs:QName("FinalStartDate"), "<=",fn:current-dateTime()),
																cts:element-range-query(xs:QName("FinalStartDate"), "!=",xs:dateTime("1900-01-01T00:00:00.0000"))
																	  )),
															  cts:and-query((
																cts:element-range-query(xs:QName("RecordStartDate"), "=",xs:dateTime("1900-01-01T00:00:00.0000")),
																cts:element-range-query(xs:QName("FinalStartDate"), "=",xs:dateTime("1900-01-01T00:00:00.0000"))
																 ))    
															)),
												cts:or-query((
															  cts:element-range-query(xs:QName("LiveFinalExpiryDate"), ">=",fn:current-dateTime()),
															  cts:element-range-query(xs:QName("LiveFinalExpiryDate"), "=",xs:dateTime("1900-01-01T00:00:00.0000"))
															)),
												cts:or-query((
															  cts:and-query((
																cts:element-range-query(xs:QName("LiveRecordStartDate"), "<=",fn:current-dateTime()),
																cts:element-range-query(xs:QName("LiveRecordStartDate"), "!=",xs:dateTime("1900-01-01T00:00:00.0000"))
																	  )),
															  cts:and-query((
																cts:element-range-query(xs:QName("LiveFinalStartDate"), "<=",fn:current-dateTime()),
																cts:element-range-query(xs:QName("LiveFinalStartDate"), "!=",xs:dateTime("1900-01-01T00:00:00.0000"))
																	  )),
															  cts:and-query((
																cts:element-range-query(xs:QName("LiveRecordStartDate"), "=",xs:dateTime("1900-01-01T00:00:00.0000")),
																cts:element-range-query(xs:QName("LiveFinalStartDate"), "=",xs:dateTime("1900-01-01T00:00:00.0000"))
																 ))    
															))
												))
								}
							</additional-query>
							{
							if( starts-with($TextToSearch, 'Date:') )
							then
							let $FilterDate := substring-after($TextToSearch, 'Date:')
							let $upperlimit := xs:dateTime("0001-01-01T00:00:00.0000")
							let $lowerlimit := xs:dateTime("0001-01-01T00:00:00.0000")
							let $constantMonth := xs:yearMonthDuration('P1M')
							let $constantYear := xs:yearMonthDuration('P1Y')
							let $result := 	if($FilterDate[matches(.,'[0-9][0-9][0-9][0-9]-[0-9][0-9]')])
											then
											(
											xdmp:set($lowerlimit,xs:dateTime(concat($FilterDate,"-01T00:00:00.0000"))),
											xdmp:set($upperlimit,xs:dateTime(xs:date(xs:date(concat($FilterDate,"-01")) + $constantMonth),xs:time("00:00:00.0000")))
											)
											else
											(
											xdmp:set($lowerlimit,xs:dateTime(concat($FilterDate,"-01-01T00:00:00.0000"))),
											xdmp:set($upperlimit,xs:dateTime(xs:date(xs:date(concat($FilterDate,"-01-01")) + $constantYear),xs:time("00:00:00.0000")))
											)
							return
								<additional-query>
									{
										cts:and-query((
											cts:element-range-query(xs:QName("VideoCreatedDate"), ">=",$lowerlimit),
											cts:element-range-query(xs:QName("VideoCreatedDate"), "<",$upperlimit)
													))
									}
								</additional-query>
							else ()
							}
							<additional-query>{cts:collection-query($constants:PCOPY)}</additional-query>
						</options>
	
	let $SearchResponse 	:=  if( $SkipChannelConstraint != "NONE" ) 
								then search:search(fn:concat('((',$TermToSearch,')', ' AND (',$SkipChannelConstraint,')') , $SearchOption, $Start, $PageLength)
								else search:search($TermToSearch, $SearchOption, $Start, $PageLength)
	let $SearchQueryText 	:= 	<QText>{$FilteredTerm}</QText>
    let $TotalVideoRecord 	:= data($SearchResponse/@total)
    let $VideoChunksList :=   for $Record in $SearchResponse/search:result
                              let $VideoXml := fn:doc($Record/@uri/string())
                              return VIDEOS:GetVideoElementForHomePage($VideoXml/Video)
    
	let $VideoChunks :=	$VideoChunksList
	
    let $GetChannelFacets :=  	<ChannelFacets>
								  {
									for $EachFacet in $SearchResponse/search:facet[@name="ChannelType"]/search:facet-value
									return <facet frequency="{fn:data($EachFacet/@count)}">{fn:data($EachFacet/@name)}</facet>
								  }
								</ChannelFacets>
    let $GetKeywordsFacets :=  <KeywordFacets>
                                  {
                                    let $ChannelKeywords := <Keywords>
															{
															(for $EachFacet in $SearchResponse/search:facet[@name="KeywordType"]/search:facet-value
															return <facet frequency="{fn:data($EachFacet/@count)}" Type="KeywordType">{fn:data($EachFacet/@name)}</facet>)[1 to 20]
															}
															</Keywords>
									let $InspecKeywords :=  <Keywords>
															{
															(for $EachFacet in $SearchResponse/search:facet[@name="InspecKeyword"]/search:facet-value
															return <facet frequency="{fn:data($EachFacet/@count)}" Type="InspecKeyword">{fn:data($EachFacet/@name)}</facet>)[1 to 20]
															}
															</Keywords>
									let $CustomKeyword :=  <Keywords>
															{
															(for $EachFacet in $SearchResponse/search:facet[@name="CustomKeyword"]/search:facet-value
															return <facet frequency="{fn:data($EachFacet/@count)}" Type="CustomKeyword">{fn:data($EachFacet/@name)}</facet>)[1 to 20]
															}
															</Keywords>
									let $AllKeywords := ($ChannelKeywords/*,$InspecKeywords/*,$CustomKeyword/*)
									let $sortedKeywords := 	(for $each in $AllKeywords
															order by xs:integer($each/@frequency/string()) descending
															return $each)[1 to 20]
									return $sortedKeywords
                                  }
                                </KeywordFacets>
	let $GetPriceFacets :=  <Price>
							  {
								for $EachFacet in $SearchResponse/search:facet[@name="PriceType"]/search:facet-value
								return <facet frequency="{fn:data($EachFacet/@count)}">{fn:data($EachFacet/@name)}</facet>
							  }
							</Price>
	let $GetAttachmentFacets := <VideoAttachment>
								{
								for $EachFacet in $SearchResponse/search:facet[@name="Subtitles"]/search:facet-value[@name eq "yes"]
								return <facet frequency="{fn:data($EachFacet/@count)}">Subtitle</facet>
								,
								for $EachFacet in $SearchResponse/search:facet[@name="Transcripts"]/search:facet-value[@name eq "yes"]
								return <facet frequency="{fn:data($EachFacet/@count)}">Transcript</facet>
								,
								for $EachFacet in $SearchResponse/search:facet[@name="permission-AddCPDLogo"]/search:facet-value[@name eq "yes"]
								return <facet frequency="{fn:data($EachFacet/@count)}">CPD</facet>
								}
							  </VideoAttachment>
	let $GetLengthFacets :=  <Length>
							  {
								for $EachFacet in $SearchResponse/search:facet[@name="Length"]/search:facet-value
								return <facet frequency="{fn:data($EachFacet/@count)}">{$EachFacet/text()}</facet>
							  }
							</Length>
	let $GetVideoCategoryFacets :=  <VideoCategory>
									  {
										for $EachFacet in $SearchResponse/search:facet[@name="VideoCategory"]/search:facet-value
										return <facet frequency="{fn:data($EachFacet/@count)}">{$EachFacet/text()}</facet>
									  }
									 </VideoCategory>
    let $GetTitleFacets :=  <Title>
									  {
										for $EachFacet in $SearchResponse/search:facet[@name="Title"]/search:facet-value
										return <facet frequency="{fn:data($EachFacet/@count)}">{$EachFacet/text()}</facet>
									  }
									 </Title>
	let $GetSeriesFacets :=  <BoxSet>
							  {
								for $EachFacet in $SearchResponse/search:facet[@name="SeriesID"]/search:facet-value
								return <facet frequency="{fn:data($EachFacet/@count)}">{$EachFacet/text()}</facet>
							  }
							</BoxSet>
	let $GetEventFacets :=  <Event>
							  {
								for $EachFacet in $SearchResponse/search:facet[@name="EventID"]/search:facet-value
								return <facet frequency="{fn:data($EachFacet/@count)}">{$EachFacet/text()}</facet>
							  }
							</Event>
	let $SeriesSum     :=   <SeriesSum>{<facet frequency="{sum(for $eachfacet in data($GetSeriesFacets/facet/@frequency) return $eachfacet)}">Series</facet>
                                        ,
                                        <facet frequency="{sum(for $eachfacet in data($GetEventFacets/facet/@frequency) return $eachfacet)}">Event Series</facet>
                                        }
                            </SeriesSum>
	
	return <Videos>{$SearchQueryText,$GetAttachmentFacets,$GetChannelFacets,$GetKeywordsFacets,$GetPriceFacets,$GetLengthFacets,$GetVideoCategoryFacets,$GetTitleFacets}<TotalVideoRecord>{$TotalVideoRecord}</TotalVideoRecord>{$VideoChunks}</Videos>
};

declare function SpellCorrect($TextToSearch as xs:string)
{
	let $CorrectWord := ""
	let $CorrectSpell := 	for $EachToken in if(fn:starts-with($TextToSearch, 'author:')) then fn:tokenize(substring-after($TextToSearch, 'author:'), ' ') else fn:tokenize($TextToSearch, ' ')
							return
								if(matches($EachToken, '\d'))
								then xdmp:set($CorrectWord, concat($CorrectWord, ' ',$EachToken))
								else
									let $IsCorrect := DICTIONARY:IsCorrect($EachToken)
									return
										if($IsCorrect = fn:false())
										then
											let $Suggested := DICTIONARY:SpellSuggest($EachToken)
											return
												if($Suggested)
												then xdmp:set($CorrectWord, concat($CorrectWord, ' ',$Suggested))
												else xdmp:set($CorrectWord, concat($CorrectWord, ' ',$EachToken))
										else xdmp:set($CorrectWord, concat($CorrectWord, ' ',$EachToken))
	return if(fn:starts-with($TextToSearch, 'author:')) then replace(lower-case(normalize-space($CorrectWord)),' ','@') else lower-case($CorrectWord)
};


(: Attribute Range Indexes must be created before using this function  Channel/@channelID :)
declare function GetSpecificResult($TextToSearch as xs:string, $TermToSearch as xs:string, $PageLength as xs:integer, $StartPage as xs:integer, $Mode as xs:string, $SortBy as xs:string, $ChannelID as xs:string)
{
	let $AdditionalFilter := 	if( $ChannelID='No' )
								then
									if($Mode='Latest')	then cts:or-query(( for $x in fn:doc($constants:CommonLatestVideo)/Latest/VideoID return cts:document-query((fn:concat("/PCopy/",$x,".xml"))) )) else
									if($Mode='Popular')	then cts:or-query(( for $x in VIDEOS:GetCommonPopularFile()/CommonMostPopular/Video/VideoID return cts:document-query((fn:concat("/PCopy/",$x,".xml"))) )) else
									if($Mode='Forthcoming')	then cts:or-query(( for $x in fn:doc($constants:CommonForthComingVideo)/ForthComing/VideoID return cts:document-query((fn:concat("/PCopy/",$x,".xml"))) )) else	""
								else if( $ChannelID!='No' )
								then
									if($Mode='Latest')	then cts:or-query(( for $x in fn:doc(fn:concat($constants:ChannelLatest, $ChannelID, '.xml'))/Latest/VideoID return cts:document-query((fn:concat("/PCopy/",$x,".xml"))) )) else
									if($Mode='Popular')	then cts:or-query(( for $x in CHANNEL:GetChannelMostPopularFile($ChannelID)/ChannelMostPopular/Video/VideoID return cts:document-query((fn:concat("/PCopy/",$x,".xml"))) )) else
									if($Mode='Forthcoming')	then cts:or-query(( for $x in fn:doc(concat($constants:ChannelForthComing, $ChannelID, '.xml'))/ForthComing/VideoID return cts:document-query((fn:concat("/PCopy/",$x,".xml"))) )) else	""
								else ""
								
	let $IsAuthor     := $TermToSearch
	let $CheckTerm := if( ($Mode eq "Popular") and (string-length($TermToSearch) eq xs:integer(1)) ) then "1" else "2"
	let $CorrectWord  := $TextToSearch
	let $FilteredTerm := $TextToSearch
	
	let $Start := if($StartPage = 1) then $StartPage else fn:sum(($StartPage * $PageLength) - $PageLength + 1)
	let $SearchOption := <options xmlns="http://marklogic.com/appservices/search">
							<term>
								<term-option>case-insensitive</term-option>
								<term-option>wildcarded</term-option>
								<term-option>stemmed</term-option>
								<term-option>diacritic-insensitive</term-option>
								<term-option>punctuation-insensitive</term-option>
							</term>
							{
							  if( $SortBy eq "TitleAscending" )
                              then  <sort-order type="xs:string" collation="http://marklogic.com/collation/" direction="ascending"><field name="VideoTitle"/></sort-order>
							  else
							  if( $SortBy eq "TitleDescending" )
                              then	<sort-order type="xs:string" collation="http://marklogic.com/collation/" direction="descending"><field name="VideoTitle"/></sort-order>
							  else
							  if( $SortBy eq "PublishedDes" )
                              then	<sort-order type="xs:dateTime" direction="descending"><element ns="" name="FilteredPubDate"/></sort-order> 
							  else
							  if( $SortBy eq "PublishedAsc" )
                              then	<sort-order type="xs:dateTime" direction="ascending"><element ns="" name="FilteredPubDate"/></sort-order> 
							  else
							  if( $SortBy eq "CreatedDes" )
                              then	<sort-order type="xs:string" collation="http://marklogic.com/collation/" direction="descending"><element ns="" name="VideoCreatedDate"/></sort-order> 
							  else
							  if( $SortBy eq "CreatedAsc" )
                              then	<sort-order type="xs:string" collation="http://marklogic.com/collation/" direction="ascending"><element ns="" name="VideoCreatedDate"/></sort-order> 
							  else
							  if( $SortBy eq "Popular" )
                              then	<sort-order type="xs:integer" collation="http://marklogic.com/collation/" direction="descending"><element ns="" name="ViewCount"/></sort-order> 
							  else
							  if( $SortBy eq "Like" )
                              then	<sort-order type="xs:integer" collation="http://marklogic.com/collation/" direction="descending"><element ns="" name="LikeCount"/></sort-order> 
							  else()
							}
							<constraint name="PriceType">
							   <range collation="http://marklogic.com/collation/" type="xs:string" facet="true">
									<attribute ns="" name="type"/>
									<element ns="" name="PricingDetails"/>
									<facet-option>frequency-order</facet-option>
									<facet-option>descending</facet-option>
							   </range>
							</constraint>
							<constraint name="ChannelType">
								<range type="xs:int" facet="true">
									<attribute ns="" name="ID"/>
									<element ns="" name="Channel"/>
									<facet-option>frequency-order</facet-option>
									<facet-option>descending</facet-option>
								</range>
							</constraint>
							<constraint name="VideoNumber">
								<range type="xs:int" facet="false">
									<element ns="" name="VideoNumber"/>
								</range>
							</constraint>
							<constraint name="KeywordType">
							   <range collation="http://marklogic.com/collation/" type="xs:string" facet="true">
									<element ns="" name="DefaultKeyword"/>
									<facet-option>frequency-order</facet-option>
									<facet-option>descending</facet-option>
							   </range>
							</constraint>
							<constraint name="InspecKeyword">
							   <range collation="http://marklogic.com/collation/" type="xs:string" facet="true">
									<element ns="" name="Kwd"/>
									<facet-option>frequency-order</facet-option>
									<facet-option>descending</facet-option>
							   </range>
							</constraint>
							<constraint name="CustomKeyword">
							   <range collation="http://marklogic.com/collation/" type="xs:string" facet="true">
									<element ns="" name="CustomKeyword"/>
									<facet-option>frequency-order</facet-option>
									<facet-option>descending</facet-option>
							   </range>
							</constraint>
							<constraint name="VideoCategory">
								<range type="xs:string" facet="true">
									<element ns="" name="VideoCategory"/>
									<facet-option>frequency-order</facet-option>
									<facet-option>descending</facet-option>
								</range>
							</constraint>
							<constraint name="Title">
								<range type="xs:string" facet="true">
									<element ns="" name="Title"/>
									<facet-option>frequency-order</facet-option>
									<facet-option>descending</facet-option>
								</range>
							</constraint>
							<constraint name="Subtitles">
								<range collation="http://marklogic.com/collation/" type="xs:string" facet="true">
									<attribute ns="" name="active"/>
									<element ns="" name="Subtitle "/>
									<facet-option>frequency-order</facet-option>
									<facet-option>descending</facet-option>
								</range>
							</constraint>
							<constraint name="Transcripts">
								<range collation="http://marklogic.com/collation/" type="xs:string" facet="true">
									<attribute ns="" name="active"/>
									<element ns="" name="Transcript"/>
									<facet-option>frequency-order</facet-option>
									<facet-option>descending</facet-option>
								</range>
							</constraint>
							<constraint name="permission-AddCPDLogo">
                                <range type="xs:string" facet="true">
                                  <path-index>AdvanceInfo/PermissionDetails/Permission[@type='AddCPDLogo']/@status</path-index>
                                </range>
                            </constraint>
							<search:constraint name="Length">
								<search:range type="xs:time">
									<search:bucket lt="00:05:00" ge="00:00:00" name="1">&lt; 5 mins</search:bucket>
									<search:bucket lt="00:10:00" ge="00:05:00" name="2">5 - 10 mins</search:bucket>
									<search:bucket lt="00:30:00" ge="00:10:00" name="3">10 - 30 mins</search:bucket>
									<search:bucket  ge="00:30:00" name="4">&gt; 30 mins</search:bucket>
									<search:element ns="" name="Duration"/>
								</search:range>
							</search:constraint>
							<additional-query>{$AdditionalFilter}</additional-query>
						</options>
	let $SearchResponse 	:=  search:search($TermToSearch, $SearchOption, $Start, $PageLength)
	let $SearchQueryText 	:= 	<QText>{$FilteredTerm}</QText>
    let $TotalVideoRecord 	:= 	data($SearchResponse/@total)
    let $VideoChunksList 	:=  for $Record in $SearchResponse/search:result
								let $VideoXml := fn:doc($Record/@uri/string())
								return VIDEOS:GetVideoElementForHomePage($VideoXml/Video)
    
	let $VideoChunksList := if( ($SortBy eq "Relevance") and  ($Mode eq 'Forthcoming') and (string-length($TextToSearch) gt 1) )
							then
							(
							let $Start := if($StartPage = 1) then $StartPage else sum(($StartPage * $PageLength) - $PageLength + 1)
												  let $End   := fn:sum(xs:integer($Start) + xs:integer($PageLength))
												  let $ForthComingList := if($ChannelID eq "No") then fn:doc($constants:CommonForthComingVideo) else fn:doc(concat($constants:ChannelForthComing, $ChannelID, '.xml'))
												  for $eachVideo in ($ForthComingList//VideoID)[position() ge $Start and position() lt $End]
												  let $VideoXml:= fn:doc(concat("/PCopy/",$eachVideo/text(),".xml"))
												  return VIDEOS:GetVideoElementForHomePage($VideoXml/Video)
							)
							else $VideoChunksList

	let $VideoChunks :=	$VideoChunksList
						
	let $GetChannelFacets :=  	<ChannelFacets>
								  {
									for $EachFacet in $SearchResponse/search:facet[@name="ChannelType"]/search:facet-value
									return <facet frequency="{fn:data($EachFacet/@count)}">{fn:data($EachFacet/@name)}</facet>
								  }
								</ChannelFacets>
    let $GetKeywordsFacets :=  <KeywordFacets>
                                  {
                                    let $ChannelKeywords := <Keywords>
															{
															(for $EachFacet in $SearchResponse/search:facet[@name="KeywordType"]/search:facet-value
															return <facet frequency="{fn:data($EachFacet/@count)}" Type="KeywordType">{fn:data($EachFacet/@name)}</facet>)[1 to 20]
															}
															</Keywords>
									let $InspecKeywords :=  <Keywords>
															{
															(for $EachFacet in $SearchResponse/search:facet[@name="InspecKeyword"]/search:facet-value
															return <facet frequency="{fn:data($EachFacet/@count)}" Type="InspecKeyword">{fn:data($EachFacet/@name)}</facet>)[1 to 20]
															}
															</Keywords>
									let $CustomKeyword :=  <Keywords>
															{
															(for $EachFacet in $SearchResponse/search:facet[@name="CustomKeyword"]/search:facet-value
															return <facet frequency="{fn:data($EachFacet/@count)}" Type="CustomKeyword">{fn:data($EachFacet/@name)}</facet>)[1 to 20]
															}
															</Keywords>
									let $AllKeywords := ($ChannelKeywords/*,$InspecKeywords/*,$CustomKeyword/*)
									let $sortedKeywords := 	(for $each in $AllKeywords
															order by xs:integer($each/@frequency/string()) descending
															return $each)[1 to 20]
									return $sortedKeywords
                                  }
                                </KeywordFacets>
	let $GetPriceFacets :=  <Price>
							  {
								for $EachFacet in $SearchResponse/search:facet[@name="PriceType"]/search:facet-value
								return <facet frequency="{fn:data($EachFacet/@count)}">{fn:data($EachFacet/@name)}</facet>
							  }
							</Price>
    let $GetLengthFacets :=  <Length>
							  {
								for $EachFacet in $SearchResponse/search:facet[@name="Length"]/search:facet-value
								return <facet frequency="{fn:data($EachFacet/@count)}">{$EachFacet/text()}</facet>
							  }
							</Length>
	let $GetAttachmentFacets := <VideoAttachment>
								{
								for $EachFacet in $SearchResponse/search:facet[@name="Subtitles"]/search:facet-value[@name eq "yes"]
								return <facet frequency="{fn:data($EachFacet/@count)}">Subtitle</facet>
								,
								for $EachFacet in $SearchResponse/search:facet[@name="Transcripts"]/search:facet-value[@name eq "yes"]
								return <facet frequency="{fn:data($EachFacet/@count)}">Transcript</facet>
								,
								for $EachFacet in $SearchResponse/search:facet[@name="permission-AddCPDLogo"]/search:facet-value[@name eq "yes"]
								return <facet frequency="{fn:data($EachFacet/@count)}">CPD</facet>
								}
							  </VideoAttachment>
	let $GetTitleFacets :=  <Title>
									  {
										for $EachFacet in $SearchResponse/search:facet[@name="Title"]/search:facet-value
										return <facet frequency="{fn:data($EachFacet/@count)}">{$EachFacet/text()}</facet>
									  }
									 </Title>
	let $GetVideoCategoryFacets :=  <VideoCategory>
									  {
										for $EachFacet in $SearchResponse/search:facet[@name="VideoCategory"]/search:facet-value
										return <facet frequency="{fn:data($EachFacet/@count)}">{$EachFacet/text()}</facet>
									  }
									 </VideoCategory>														
	let $GetSeriesFacets :=  <BoxSet>
							  {
								for $EachFacet in $SearchResponse/search:facet[@name="SeriesID"]/search:facet-value
								return <facet frequency="{fn:data($EachFacet/@count)}">{$EachFacet/text()}</facet>
							  }
							</BoxSet>
	let $GetEventFacets :=  <Event>
							  {
								for $EachFacet in $SearchResponse/search:facet[@name="EventID"]/search:facet-value
								return <facet frequency="{fn:data($EachFacet/@count)}">{$EachFacet/text()}</facet>
							  }
							</Event>
    let $SeriesSum     :=   <SeriesSum>{<facet frequency="{sum(for $eachfacet in data($GetSeriesFacets/facet/@frequency) return $eachfacet)}">Series</facet>
                                        ,
                                        <facet frequency="{sum(for $eachfacet in data($GetEventFacets/facet/@frequency) return $eachfacet)}">Event Series</facet>
                                        }
                            </SeriesSum>
	return <Videos><TotalRecord>{$TotalVideoRecord}</TotalRecord>{$GetAttachmentFacets,$GetChannelFacets,$GetKeywordsFacets,$GetPriceFacets,$GetLengthFacets,$GetVideoCategoryFacets,$GetTitleFacets}<SearchResult>{$VideoChunks}</SearchResult></Videos>
};

(: Attribute Range Indexes must be created before using this function  Keyword/@keywordID :)
declare function GetKeywordsFacets()
{
  <KeywordFacets>
    {
	(
      for $value in cts:element-attribute-values(xs:QName("DefaultKeyword"), xs:QName("ID"), (), "frequency-order",GetFacetOption())
	  return <facet frequency="{cts:frequency($value)}">{$value}</facet>
	 )[position() le 5]
    }
  </KeywordFacets>
};

declare function GetPriceFacets()
{
	<Price>
    {
      for $value in cts:element-attribute-values(xs:QName("PricingDetails"), xs:QName("type"), (), "frequency-order",GetFacetOption())
      return <facet frequency="{cts:frequency($value)}">{$value}</facet>
    }
  </Price>
};
  
declare function GetDurationFacets()
{
	<Length>
		  {
			  for $bucket in cts:element-value-ranges(xs:QName("Duration"),(xs:time("00:05:00"),xs:time("00:10:00"),xs:time("00:30:00"),xs:time("00:31:00")))
			  let $Frequency := cts:frequency($bucket)
			  let $Duration := if($bucket//*:upper-bound) then $bucket//*:upper-bound/text() else $bucket//*:lower-bound/text()
			  return <facet frequency="{$Frequency}">{if($Duration ="00:05:00") then "< 5 mins" else if($Duration ="00:10:00") then "5 - 10 mins" else if($Duration ="00:30:00") then "10 - 30 mins" else if($Duration ="00:31:00") then "> 30 mins" else $Duration}</facet>
		  }
	</Length>
};

declare function GetVideoCategoryFacets()
{
	<VideoCategory>
    {
      for $value in cts:element-values(xs:QName("VideoCategory"), (), "frequency-order",GetFacetOption())
      return <facet frequency="{cts:frequency($value)}">{$value}</facet>
    }
  </VideoCategory>
};

declare function GetFacetOption()
{
   let $query := cts:and-query((
						cts:or-query((
									cts:element-range-query(xs:QName("FinalExpiryDate"), ">=",fn:current-dateTime()),
									cts:element-range-query(xs:QName("FinalExpiryDate"), "=",xs:dateTime("1900-01-01T00:00:00.0000"))
									 )),
						cts:or-query((
							cts:and-query((
								cts:element-range-query(xs:QName("RecordStartDate"), "<=",fn:current-dateTime()),
								cts:element-range-query(xs:QName("RecordStartDate"), "!=",xs:dateTime("1900-01-01T00:00:00.0000"))
										  )),
							cts:and-query((
								cts:element-range-query(xs:QName("FinalStartDate"), "<=",fn:current-dateTime()),
								cts:element-range-query(xs:QName("FinalStartDate"), "!=",xs:dateTime("1900-01-01T00:00:00.0000"))
										  )),
							cts:and-query((
								cts:element-range-query(xs:QName("RecordStartDate"), "=",xs:dateTime("1900-01-01T00:00:00.0000")),
								cts:element-range-query(xs:QName("FinalStartDate"), "=",xs:dateTime("1900-01-01T00:00:00.0000"))
										 ))     
									 ))
			                   ))
	return $query					  
};

(:
declare function GetVideosByChannelId($ChannelId as xs:integer, $PageLength as xs:integer, $StartPage as xs:integer)
{
  let $Start := if($StartPage = 1) then $StartPage else sum(($StartPage * $PageLength) - $PageLength + 1)
  let $End   := fn:sum(xs:integer($Start) + xs:integer($PageLength))
  let $SearchResult := <Videos>{cts:search(fn:collection($constants:PCOPY)/Video[AdvanceInfo/PermissionDetails/Permission[@permissionType eq "HideRecord" and @permissionStatus eq "no"]], cts:element-attribute-range-query(xs:QName("Channel"), xs:QName("channelID"),"=", $ChannelId))}</Videos>
  let $SearchCount := fn:count($SearchResult/Video)
  return
    <Channel>
      <ChannelCount>{$SearchCount}</ChannelCount>
     {
      for $EachVideo in $SearchResult/Video[position() ge $Start and position() lt $End]
      return VIDEOS:GetVideoElementForHomePage($EachVideo)
     }
    </Channel>
};
:)
