xquery version "1.0-ml";

import module namespace LOOKUP = "http://www.TheIET.org/ManageLookup" at "/Utils/ManageSearch.xqy";

(:~ This service is to support free text search on videos and is depend on external parameters
	: @TextToSearch - The text which user wants to search. Sometimes it may contain 'Date:|author:' to support date-wise or Speaker search.
	: @TermToSearch - The combination of facets to filer search result.
	: @PageLength   - The total number of videos in a page to display.
	: @StartPage    - The page number to support pagination.
	: @SortBy       - The sorting order 'TitleAscending|TitleDescending|Recent|Oldest'. By default 'Relevance'.
	: @SkipChannel  - Keeps Channel ID - Private/Staff-Channel so that script may ignore those Channels from search. And if any log in user has access on
	:                 Private Channel, it must be excluded from the list. And front-end team will exclude this when call this function.
	:                 If there is no Private/Staff-Channel, it must be <SkipChannel>NONE</SkipChannel>
	:
	:  <SearchUserVideo><SkipChannel><ID>1</ID><ID>2</ID><ID>3</ID></SkipChannel><TextToSearch>e</TextToSearch>
	:     <TermToSearch>e* AND ChannelType:1 AND ChannelType:2 AND KeywordType:1 AND PriceType:Premium AND Length:1</TermToSearch>
	:     <PageLength>6</PageLength><StartPage>1</StartPage><SortBy>Oldest</SortBy>
	:  </SearchUserVideo>
:)

declare variable $inputSearchDetails as xs:string external;

let $Log 			:= xdmp:log("[ IET-TV ][ VideoSearch ][ Call ][ Service call ]")
let $InputParam  	:= xdmp:unquote($inputSearchDetails)
let $TermToSearch 	:= $InputParam/SearchUserVideo/TermToSearch/text()
let $Cpdlogo 	     := $InputParam//AllCPD/text()
let $TextToSearch 	:= if($InputParam//AllCPD/text()="yes")
                       then ("")
                       else ($InputParam//TextToSearch/text())
let $PageLength 	:= xs:integer($InputParam/SearchUserVideo/PageLength/text())
let $StartPage 		:= xs:integer($InputParam/SearchUserVideo/StartPage/text())
let $Sorting 		:= $InputParam/SearchUserVideo/SortBy/text()
let $SkipChannel    := $InputParam/SearchUserVideo/SkipChannel
return
  if( not($SkipChannel//text()) )
  then
    (
      xdmp:log(concat("[ IET-TV ][ VideoSearch ][ Info ][ Invalid skip channel list - SkipChannel : ", $SkipChannel, " ]"))
      ,
      "ERROR! Please provide skip channel list. Currently it is empty."
    )
  else
  if( not($TermToSearch) )
  then
    (
      xdmp:log(concat("[ IET-TV ][ VideoSearch ][ Info ][ Invalid valued provided to search - TermToSearch : ", $TermToSearch, " ]"))
      ,
      "ERROR! Please provide correct input parameter to search. Currently it is empty."
    )
  else
  if( not($TextToSearch) and not($Cpdlogo) )
  then
    (
      xdmp:log(concat("[ IET-TV ][ VideoSearch ][ Info ][ Invalid valued provided to TextToSearch - TextToSearch : ", $TextToSearch, " ]"))
      ,
      "ERROR! Please provide correct input parameter in 'text to search'. Currently it is empty."
    )
  else
  if( not($PageLength) )
  then
    (
      xdmp:log(concat("[ IET-TV ][ VideoSearch ][ Info ][ Invalid valued provided to PageLength : ", $PageLength, " ]"))
      ,
      "ERROR! Please provide correct input parameter for Page Length. Currently it is empty."
    )
  else
  if( not($StartPage) )
  then
    (
      xdmp:log(concat("[ IET-TV ][ VideoSearch ][ Info ][ Invalid valued provided to StartPage : ", $StartPage, " ]"))
      ,
      "ERROR! Please provide correct input parameter for Start Page. Currently it is empty."
    )
  else
  if( not($Sorting) )
  then
    (
      xdmp:log(concat("[ IET-TV ][ VideoSearch ][ Info ][ Invalid valued provided to Sort : ", $Sorting, " ]"))
      ,
      "ERROR! Please provide correct input parameter for Sorting. Currently it is empty."
    )
  else
	 (
		LOOKUP:VideoSearch($SkipChannel,$TextToSearch,$TermToSearch,$PageLength,$StartPage,$Sorting),
		xdmp:log("[ IET-TV ][ VideoSearch ][ Call ][ Service result sent ]")
	)