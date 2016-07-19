xquery version "1.0-ml";
module namespace utils = "http://www.TheIET.org/utils";
import module namespace constants = "http://www.TheIET.org/constants"   at "constants.xqy";
import module namespace search = "http://marklogic.com/appservices/search"      at "/MarkLogic/appservices/search/search.xqy";
import module namespace debug = "http://marklogic.com/debug" at "/MarkLogic/appservices/utils/debug.xqy";

		
declare function utils:parseInputText($inputString as xs:string) as xs:string*
{
	debug:set-flag(true()),
		let $log := debug:log(("in parseInputText","start"))
  let $normalizedInputString := fn:normalize-space($inputString)
  (:
    let $normalizedInputString := fn:lower-case(fn:replace($normalizedInputString,"([&quot;])(.*?)\1","$2"))
	let $normalizedInputString := fn:lower-case(fn:replace($normalizedInputString,"[&quot;][^&quot;]*[&quot;]","$0"))
	let $normalizedInputString := fn:replace($normalizedInputString,"\(|\)|[a-zA-Z0-9\s\p{P}]+","$0~~~") 
  :)
  
	let $analyzed-string := 
		for $analyzed-token in fn:analyze-string($normalizedInputString,"[&quot;][^&quot;]*[&quot;]")/*
		return
			if (name($analyzed-token) eq "s:match") then
			(
				fn:concat(fn:lower-case(data($analyzed-token)),"~~~")
			)
			else
			(	
				
				let $parsed-analyzed-token := fn:replace(data($analyzed-token),"\sAND\s","#####")
				let $parsed-analyzed-token := fn:replace($parsed-analyzed-token,"\sNOT\s","@@@@@")
				let $parsed-analyzed-token := fn:replace($parsed-analyzed-token,"\sOR\s","!!!!!")
				let $parsed-analyzed-token := fn:replace($parsed-analyzed-token,"\(|\)|[a-zA-Z0-9\s\\.\\&quot;\\&apos;@\\*\\?-\\,\\;\\&amp;amp;\\#\\!]+","$0~~~") 
				let $parsed-analyzed-token := fn:replace($parsed-analyzed-token,"#####"," AND ~~~")
				let $parsed-analyzed-token := fn:replace($parsed-analyzed-token,"@@@@@"," NOT ~~~")
				let $parsed-analyzed-token := fn:replace($parsed-analyzed-token,"!!!!!"," OR ~~~")			
				return 
					$parsed-analyzed-token
			) 
 
	let $normalizedInputString := fn:string-join($analyzed-string,"")

		let $log := debug:log(("in normalizedInputString",$normalizedInputString))
  for $token in fn:tokenize($normalizedInputString,"~~~")[.]
  let $x := 
	if (fn:substring($token,1,1) eq "&quot;" and fn:substring($token,fn:string-length($token),1) eq "&quot;") then
	(
		fn:concat("&quot;",fn:lower-case(fn:substring($token,2,fn:string-length($token)-2)),"&quot;")
	)
	else if (fn:substring($token,1,1) eq "&apos;" and fn:substring($token,fn:string-length($token),1) eq "&apos;") then
	(
		fn:concat("&quot;",fn:lower-case(fn:substring($token,2,fn:string-length($token)-2)),"&quot;")
	)
	else if ($token ne "(" and $token ne ")" and $token ne " AND " and $token ne " NOT " and $token ne " OR ") then
	(
		if ($constants:IS_WILDCARDED_SEARCH) then
		(
			 
			if (fn:contains($token,"&quot;")) then 
			(
				fn:concat("&quot;",fn:lower-case(fn:replace($token,"&quot;","")),"&quot;") 
			)
			else
			(
				fn:concat("&quot;",fn:lower-case($token),"&quot;") 
			)
		)
		else
		(
			
			if (fn:contains($token,"&quot;")) then 
			(
				fn:concat("&quot;",fn:lower-case(fn:replace($token,"&quot;","")),"&quot;") 
			)
			else
			(
				fn:concat("&quot;",fn:lower-case($token),"&quot;") 
			)		
		)
	)
	else
	(
	  $token
	)
	return
	(
		xs:string($x)
	)
};

(: *********** Working copy till sprint 3 *************** :)
declare function utils:oldparseInputText($inputString as xs:string) as xs:string*
{

  let $normalizedInputString := fn:normalize-space($inputString)
  (:
    let $normalizedInputString := fn:lower-case(fn:replace($normalizedInputString,"([&quot;])(.*?)\1","$2"))
	let $normalizedInputString := fn:lower-case(fn:replace($normalizedInputString,"[&quot;][^&quot;]*[&quot;]","$0"))
	let $normalizedInputString := fn:replace($normalizedInputString,"\(|\)|[a-zA-Z0-9\s\p{P}]+","$0~~~") 
  :)
  
  let $analyzed-string := 
    for $analyzed-token in fn:analyze-string($normalizedInputString,"[&quot;][^&quot;]*[&quot;]")/*
	return
		if (name($analyzed-token) eq "s:match") then
		(
			fn:lower-case(data($analyzed-token))
		)
		else
		(	
			data($analyzed-token)
		) 
  let $normalizedInputString := fn:string-join($analyzed-string,"")
  let $normalizedInputString := fn:replace($normalizedInputString,"\sAND\s","#####")
  let $normalizedInputString := fn:replace($normalizedInputString,"\sNOT\s","@@@@@")
  let $normalizedInputString := fn:replace($normalizedInputString,"\sOR\s","!!!!!")
  let $normalizedInputString := fn:replace($normalizedInputString,"\(|\)|[a-zA-Z0-9\s\\.\\&quot;\\&apos;@\\*\\?]+","$0~~~") 
  let $normalizedInputString := fn:replace($normalizedInputString,"#####"," AND ~~~")
  let $normalizedInputString := fn:replace($normalizedInputString,"@@@@@"," NOT ~~~")
  let $normalizedInputString := fn:replace($normalizedInputString,"!!!!!"," OR ~~~")
  
  
  for $token in fn:tokenize($normalizedInputString,"~~~")[.]
  let $x := 
	if (fn:substring($token,1,1) eq "&quot;" and fn:substring($token,fn:string-length($token),1) eq "&quot;") then
	(
		fn:concat("&quot;",fn:lower-case(fn:substring($token,2,fn:string-length($token)-2)),"&quot;")
	)
	else if (fn:substring($token,1,1) eq "&apos;" and fn:substring($token,fn:string-length($token),1) eq "&apos;") then
	(
		fn:concat("&quot;",fn:lower-case(fn:substring($token,2,fn:string-length($token)-2)),"&quot;")
	)
	else if ($token ne "(" and $token ne ")" and $token ne " AND " and $token ne " NOT " and $token ne " OR ") then
	(
		if ($constants:IS_WILDCARDED_SEARCH) then
		(
			 
			if (fn:contains($token,"&quot;")) then 
			(
				fn:concat("&quot;",fn:lower-case(fn:replace($token,"&quot;","")),"&quot;") 
			)
			else
			(
				fn:concat("&quot;",fn:lower-case($token),"&quot;") 
			)
		)
		else
		(
			
			if (fn:contains($token,"&quot;")) then 
			(
				fn:concat("&quot;",fn:lower-case(fn:replace($token,"&quot;","")),"&quot;") 
			)
			else
			(
				fn:concat("&quot;",fn:lower-case($token),"&quot;") 
			)		
		)
	)
	else
	(
	  $token
	)
	return
	(
		xs:string($x)
	)
};



declare function utils:getStartRecordNumber($pageNumber as xs:integer, $recordsPerPage as xs:integer) as xs:integer*
{
	let $startRecordNumber :=
		if ($pageNumber lt 1) then
		(
			1
		)
		else
		(
			(($pageNumber - 1) * $recordsPerPage) + 1
		)
	return
	(
		$startRecordNumber
	)

};


(:

:)
declare function utils:getCurrentSubscription($currentTab as xs:string, $subscription_wrd as xs:string, $subscription_gnosg as xs:string,  $subscription_wm as xs:string , $subscription_others as xs:string) as xs:string*
{
	
	let $subscriptionSearch :=
    if($currentTab eq $constants:SEARCH_IN_WRD) then
		$subscription_wrd
	else if($currentTab eq $constants:SEARCH_IN_WM) then
		$subscription_wm
	else if($currentTab eq $constants:SEARCH_IN_OTHERS) then
		$subscription_others   
	else if($currentTab eq $constants:SEARCH_IN_GNOSG) then
		$subscription_gnosg
	else
		""
	return
	(
		$subscriptionSearch
	(:	let $t := fn:string-join($subscriptionSearch,"")
		return
		(
			$t
		)
	:)
	) 
	
};

declare function utils:getSearchDocumentInCollection($currentTab as xs:string) as xs:string*
{
	let $currentTab := fn:lower-case($currentTab)
	let $searchDocumentIn :=
    if($currentTab eq "wrd") then
		" AND (collection_constraint:wrd)"
	else if($currentTab eq "wrdchapter") then
		" AND (collection_constraint:wrdchapter)"
	else if($currentTab eq "gn") then
		" AND (collection_constraint:gn)"
	else if($currentTab eq "osg") then
		" AND (collection_constraint:osg)"		
	else if($currentTab eq "wm") then
		" AND (collection_constraint:wm)"				
	else if($currentTab eq "others") then
		" AND (collection_constraint:others)"						
	else if($currentTab eq "gnosg") then
		" AND (collection_constraint:gn OR collection_constraint:osg)"		
	else
		""
	return
	(
		$searchDocumentIn
	)
};

declare function utils:getSearchOtherDocumentInCollection($searchIn as xs:string) as xs:string*
{
	let $searchIn := fn:lower-case($searchIn)
	let $searchDocumentIn :=
    if($searchIn eq "wrd") then
		$constants:SEARCH_IN_WRD
	else if($searchIn eq "wrdchapter") then
		$constants:SEARCH_IN_WRDCHAPTER
	else if($searchIn eq "gn") then
		$constants:SEARCH_IN_GN
	else if($searchIn eq "gnchapter") then
		$constants:SEARCH_IN_GNCHAPTER		
	else if($searchIn eq "osg") then
		$constants:SEARCH_IN_OSG
	else if($searchIn eq "osgchapter") then
		$constants:SEARCH_IN_OSGCHAPTER		
	else
		""
	return
	(
		$searchDocumentIn
	)
};

declare function utils:getSearchCount($estimate_Query as xs:string,$search_Options as item(),$queryType as xs:string) as xs:unsignedLong*
{
	let $estimateCount := search:estimate(search:parse($estimate_Query,$search_Options, $queryType))
	return
	(
		$estimateCount
	)
};

declare function utils:getSearchCondition($sd as item(),$conditionString as xs:string, $joinCondition as xs:string, $joinPreviousCondition as xs:string) as xs:string*
{
		
		let $facetCondition := 
			for $c in $sd/child::node()
			return 
				fn:concat($conditionString,data($c),$joinCondition)
						
		let $facetCondition := fn:string-join($facetCondition,"")
		
		let $facetCondition := 
			if(fn:string-length($facetCondition) gt 0) then 
			(
				let $t := fn:substring($facetCondition,1,fn:string-length($facetCondition) - fn:string-length($joinCondition))
				let $t := fn:concat($joinPreviousCondition," (",$t,")")
				return
				(
					$t
				)
			)	
			else
			(
				let $t := ""
				return 
				(
					$t
				)
			)
				
		return 
		(
			$facetCondition
		)
};

declare function utils:getCurrentTabData($sd as item()) as xs:string*
{
	let $currentTab := fn:lower-case($sd/data(currentTab))	
	let $currentTab := 
	if(fn:string-length($currentTab) eq 0) then 
	(
		"wrd"
	)
	else
	(
		$currentTab
	)
	return
	(
		$currentTab
	)
};

declare function utils:getQuickSearch_SearchTerm_Data($sd as item()) as xs:string*
{
	debug:set-flag(true()),
		let $log := debug:log(("in getQuickSearch_SearchTerm_Data","start"))
	let $quickSearch_searchTerm := fn:normalize-space($sd/searchConditions/quicksearch/data(searchTerm))
	let $log := debug:log(("in getQuickSearch_SearchTerm_Data",$quickSearch_searchTerm))
	let $quickSearch_searchTerm := 
		if(fn:string-length($quickSearch_searchTerm) eq 0) then 
		(
			""
		)
		else
		(
			let $t := fn:string-join(utils:parseInputText($quickSearch_searchTerm),"")
			return 
			(
				fn:concat("(",$t,")")
			)
		)
	return
	(
		$quickSearch_searchTerm
	)
};

declare function utils:getQuickSearch_SearchCategory($sd as item()) as xs:string*
{
	let $quickSearch_searchCategory := fn:lower-case($sd/searchConditions/quicksearch/data(searchCategory))
	let $quickSearch_searchCategory := 
	if(fn:string-length($quickSearch_searchCategory) eq 0) then 
	(
		"all"
	)
	else
	(
		$quickSearch_searchCategory
	)
	return
	(
		$quickSearch_searchCategory
	)
};

declare function utils:getSortConstraint($sd as item(), $currentTab as xs:string) as xs:string*
{
	let $sortKey := fn:lower-case($sd/sortingOptions/sortBy/data(sortKey))
	let $sortKey := 
		if(fn:string-length($sortKey) eq 0) then 
		(
			"relevance"
		)
		else
		(
			$sortKey
		)
	let $sortKey :=
		if($sortKey eq "relevance") then 
		(
			"relevance"
		)
		else
		(
			fn:concat($sortKey, $currentTab)
		)
	let $sortOrder := fn:lower-case($sd/sortingOptions/sortBy/data(sortOrder))
	let $sortOrder := 
		if(fn:string-length($sortOrder) eq 0) then 
		(
			"desc"
		)
		else
		(
			$sortOrder
		)
	let $sort_constraint := fn:concat(" (sort:", $sortKey, "_sort_", $sortOrder,")")	
	return
	(
		$sort_constraint
	)
};

declare function utils:getRecordsPerPage($sd as item()) as xs:integer*
{
	let $recordsPerPage := $sd/data(recordsPerPage)
	let $recordsPerPage := 
	if(fn:string-length($recordsPerPage) eq 0) then 
	(
		10
	)
	else if ($recordsPerPage castable as xs:integer) then
	(
		if(xs:integer($recordsPerPage) le 1) then
		(
			10
		)
		else
		(
			xs:integer($recordsPerPage)
		)
	)
	else
	(
		10
	)
	return
	(
		$recordsPerPage
	)
};

declare function utils:getPageNumber($sd as item()) as xs:integer*
{
	let $pageNumber := $sd/data(pageNumber)
	let $pageNumber := 
	if(fn:string-length($pageNumber) eq 0) then 
	(
		1
	)
	else if ($pageNumber castable as xs:integer) then
	(
		if(xs:integer($pageNumber) le 1) then
		(
			1
		)
		else
		(
			xs:integer($pageNumber)
		)
	)
	else
	(
		1
	)
	return
	(
		$pageNumber
	)
};

declare function utils:getWrdRightsAndCollectionExpr($subscription_wrd_searchExpr as xs:string) as xs:string*
{
	
	
	let $rights_And_Collection_searchExpr := 
		if(fn:string-length($subscription_wrd_searchExpr) le 0) then
		(
			fn:concat(" (", $constants:COLLECTION_WRD, ") ")
		)
		else
		(
			fn:concat("((", $subscription_wrd_searchExpr, ") AND (", $constants:COLLECTION_WRD, "))")
		)		
	return
	(
		$rights_And_Collection_searchExpr
	)
};

declare function utils:convertEmptySequenceToBlankString($stringToConvert as item()*) as xs:string*
{
	let $stringToConvert := 
		if (empty($stringToConvert)) then
			""
		else	
			$stringToConvert 
	return
	(
		$stringToConvert
	)
};

declare function utils:getGnOsgRightsAndCollectionExpr($subscription_gn_searchExpr as xs:string, $subscription_osg_searchExpr as xs:string) as xs:string*
{
	
	
	let $rights_And_Collection_searchExpr := 
		if (fn:string-length($subscription_gn_searchExpr) gt 0 and fn:string-length($subscription_osg_searchExpr) gt 0) then
			fn:concat(
				" (", 
				"(",$subscription_gn_searchExpr,$constants:JOIN_WITH_AND,$constants:COLLECTION_GN,")", 
				" OR ",
				"(",$subscription_osg_searchExpr,$constants:JOIN_WITH_AND,$constants:COLLECTION_OSG,")",
				")" 
			)
		else if (fn:string-length($subscription_gn_searchExpr) gt 0 and fn:string-length($subscription_osg_searchExpr) eq 0) then
			fn:concat(
				" (", 
				"(",$subscription_gn_searchExpr,$constants:JOIN_WITH_AND,$constants:COLLECTION_GN,")", 
				" OR ",
				"(",$constants:COLLECTION_OSG,")",
				")" 
			)
		else if (fn:string-length($subscription_gn_searchExpr) eq 0 and fn:string-length($subscription_osg_searchExpr) gt 0) then
			fn:concat(
				" (", 
				"(",$constants:COLLECTION_GN,")", 
				" OR ",
				"(",$subscription_osg_searchExpr,$constants:JOIN_WITH_AND,$constants:COLLECTION_OSG,")",
				")" 
			)
		else
			$constants:COLLECTION_GNOSG		
	return
	(
		$rights_And_Collection_searchExpr
	)
};

declare function utils:getWmRightsAndCollectionExpr($subscription_wm_searchExpr as xs:string) as xs:string*
{
	
		
	let $rights_And_Collection_searchExpr := 
		if(fn:string-length($subscription_wm_searchExpr) le 0) then
		(
			fn:concat(" (", $constants:COLLECTION_WM, ") ")
		)
		else
		(
			fn:concat("((", $subscription_wm_searchExpr, ") AND (", $constants:COLLECTION_WM, "))")
		)		
	return
	(
		$rights_And_Collection_searchExpr
	)
};

declare function utils:getOthersRightsAndCollectionExpr($subscription_others_searchExpr as xs:string) as xs:string*
{
	
		
	let $rights_And_Collection_searchExpr := 
		if(fn:string-length($subscription_others_searchExpr) le 0) then
		(
			fn:concat(" (", $constants:COLLECTION_OTHERS, ") ")
		)
		else
		(
			fn:concat("((", $subscription_others_searchExpr, ") AND (", $constants:COLLECTION_OTHERS, "))")
		)		
	return
	(
		$rights_And_Collection_searchExpr
	)
};
(:
------------------************************-------------------
declare function utils:getSearchDocumentInExpr($currentTab as xs:string, $subscription_wrd_searchExpr as xs:string, $subscription_gn_searchExpr as xs:string, $subscription_osg_searchExpr as xs:string, $subscription_wm_searchExpr as xs:string,$subscription_others_searchExpr as xs:string) as xs:string*
{
	
		let $log := debug:log(("in getSearchDocumentInExpr",$currentTab))		
	let $subscription_currentTab_searchExpr := 
		if($currentTab eq "wrd") then
		
			fn:concat($subscription_wrd_searchExpr,utils:getSearchDocumentInCollection("wrd"))
		else if($currentTab eq "gnosg") then
			if (fn:string-length($subscription_gn_searchExpr) gt 0 and fn:string-length($subscription_osg_searchExpr) gt 0) then
				fn:concat(
							" AND (",
							"(", 
							$subscription_gn_searchExpr,
							utils:getSearchDocumentInCollection("gn"), 
							")", 
							" OR ",
							"(", 
							$subscription_osg_searchExpr,
							utils:getSearchDocumentInCollection("osg"), 
							"))"
						)
			else if (fn:string-length($subscription_gn_searchExpr) gt 0 and fn:string-length($subscription_osg_searchExpr) eq 0) then
				fn:concat(" AND ","(", $subscription_gn_searchExpr,utils:getSearchDocumentInCollection("gn"), ")")
			else if (fn:string-length($subscription_gn_searchExpr) eq 0 and fn:string-length($subscription_osg_searchExpr) gt 0) then
				fn:concat(" AND ","(", $subscription_osg_searchExpr,utils:getSearchDocumentInCollection("osg"), ")")
			else
				utils:getSearchDocumentInCollection("gnosg")		
		else if($currentTab eq "wm") then
			fn:concat($subscription_wm_searchExpr,utils:getSearchDocumentInCollection("wm"))
		else if($currentTab eq "others") then
			fn:concat($subscription_others_searchExpr,utils:getSearchDocumentInCollection("others"))
		else
			""
		let $log := debug:log(("in end getSearchDocumentInExpr",$subscription_currentTab_searchExpr))
	return
	(
		$subscription_currentTab_searchExpr
	)
};
------------------************************-------------------
:)
declare function utils:joinConstraints($constraint1 as xs:string,$join_Condition as xs:string, $constraint2 as xs:string) as xs:string*
{
	let $joined_searchExpr := 
		if (fn:string-length($constraint1) gt 0 and fn:string-length($constraint2) gt 0) then
			fn:concat($constraint1, $join_Condition, $constraint2)
		else if (fn:string-length($constraint1) gt 0 and fn:string-length($constraint2) eq 0) then
			$constraint1
		else if (fn:string-length($constraint1) eq 0 and fn:string-length($constraint2) gt 0) then
			$constraint2
		else
			""	
	return
	(
		$joined_searchExpr
	)
};



declare function utils:getSearchConditionData($sd as item()) as xs:string*
{
		
		let $searchConditionData := 
			for $c in $sd/child::node()
			return 
				data($c)
		(:let $searchConditionData := fn:string-join($searchConditionData,"") :)
		return 
		(
			$searchConditionData
		)
};

(: Build Search Options :)
declare function utils:build-search-options($currentTab as xs:string) as item()*
{
	let $search-options-start := "<options xmlns='http://marklogic.com/appservices/search'>"
	let $search-options-constraints := "
    <constraint name='collection_constraint' >
         <collection prefix='' facet='false'/>
    </constraint> 
    <constraint name='book_rights_wrd'>
		<value>
			<attribute ns='' name='book-id'/>
			<element ns='' name='regulation'/>
		</value>
	</constraint>
	<constraint name='book_rights_gn'>
		<value>
			<attribute ns='' name='book-id'/>
			<element ns='' name='chapter'/>
		</value>
	</constraint>
	<constraint name='book_rights_osg'>
		<value>
			<attribute ns='' name='book-id'/>
			<element ns='' name='chapter'/>
		</value>
	</constraint>
	<constraint name='book_rights_wm'>
		<value>
			<attribute ns='' name='book-id'/>
			<element ns='' name='chapter'/>
		</value>
	</constraint>
	<constraint name='book_rights_others'>
		<value>
			<attribute ns='' name='book-id'/>
			<element ns='' name='chapter'/>
		</value>
	</constraint>
	<operator name='sort'>
		<state name='relevance_sort_asc'>
			<sort-order direction='ascending'>
				<score/>
			</sort-order>
		</state>	
		<state name='relevance_sort_desc'>
			<sort-order>
				<score/>
			</sort-order>
		</state>
		<state name='regnumwrd_sort_asc'>
		  <sort-order direction='ascending' type='xs:string'>
			<element ns='' name='regulation'/>
			<attribute ns='' name='reg_num'/>
		  </sort-order>
		  <sort-order>
		<score/>
		  </sort-order>
		</state>
	   <state name='regnumwrd_sort_desc'>
		  <sort-order direction='descending' type='xs:string'>
			<element ns='' name='regulation'/>
			<attribute ns='' name='reg_num'/>
		  </sort-order>
		  <sort-order>
			 <score/>
		  </sort-order>
	   </state>
		<state name='regnumgnosg_sort_asc'>
		  <sort-order direction='ascending' type='xs:string'>
			<element ns='' name='chapter'/>
			<attribute ns='' name='reg-num'/>
		  </sort-order>
		  <sort-order>
			<score/>
		  </sort-order>
		</state>
	   <state name='regnumgnosg_sort_desc'>
		  <sort-order direction='descending' type='xs:string'>
			<element ns='' name='chapter'/>
			<attribute ns='' name='reg-num'/>
		  </sort-order>
		  <sort-order>
			 <score/>
		  </sort-order>
	   </state>	   
	</operator>"
	
	let $search-transform-results-base := "<transform-results apply='transformed-result' ns='http://www.TheIET.org/snippet' at='transform-snippet.xqy'>
	<per-match-tokens>60</per-match-tokens>"	
	let $search-transform-results-currentTab :=	fn:concat("<currentTab>",$currentTab,"</currentTab>")
	let $search-transform-results-end := "</transform-results>"
	let $search-options-transform-results := fn:concat($search-transform-results-base,$search-transform-results-currentTab,$search-transform-results-end)
	
	let $search-options-return-values := "<return-plan>false</return-plan>
	<return-query>true</return-query>
	<return-metrics>true</return-metrics>"

	let $search-term-options := "<term><term-option>punctuation-insensitive</term-option>"
	
	let $search-term-options := 
		if ($constants:IS_WILDCARDED_SEARCH) then
			fn:concat($search-term-options,"<term-option>wildcarded</term-option>")
		else 
			$search-term-options
	let $search-term-options := fn:concat($search-term-options,"</term>")
	
	let $search-options-end := "</options>"
	
	let $final-search-options := fn:concat($search-options-start,$search-options-constraints,$search-options-transform-results,$search-options-return-values,$search-term-options,$search-options-end)
	return
	(
		xdmp:unquote($final-search-options)/*
	)
		
};

declare function utils:build-taxonomy-search-options() as item()*
{
	let $search-options-start := "<options xmlns='http://marklogic.com/appservices/search'>"
	let $search-term-options := "<term><term-option>punctuation-insensitive</term-option>"
	
	let $search-term-options := 
		if ($constants:IS_WILDCARDED_SEARCH) then
			fn:concat($search-term-options,"<term-option>wildcarded</term-option>")
		else 
			$search-term-options
	let $search-term-options := fn:concat($search-term-options,"</term>")
	
	let $search-options-end := "</options>"
	
	let $final-search-options := fn:concat($search-options-start,$search-term-options,$search-options-end)
	return
	(
		xdmp:unquote($final-search-options)/*
	)
		
};

declare function utils:convertStringToXML($xmlstring as xs:string) as item()? {
	(: determine if any search criteria entered :)

	let $xmlstring := fn:replace($xmlstring,"&amp;","&amp;amp;")
	let $convertedStringToXML :=
	if (fn:string-length($xmlstring) le 0) then
	(
		(: no search criteria - return marked up as empty :)
		 <searchError><error>Error in Input String</error><errorMessage>String Length is Zero</errorMessage></searchError> 
	)
	else
	(
		(: use a try-catch in case the convert string to XML function (xdmp:unquote) breaks :)
		try {
			(:xdmp:unquote($xmlstring, "searchcriteria", ("default-language=en")):)
				
			 xdmp:unquote(fn:normalize-space($xmlstring))/* 
		} 
		catch ($exception) {
			(:fn:error(xs:QName("ERROR"), "Test Error") :)
			<searchError><error>Error in Input String 2</error><errorMessage>{$exception}</errorMessage></searchError>
		}
	)
	return 
	(
		$convertedStringToXML
	)
};

declare function utils:getData($sd as item(), $defaultValue as xs:string,$convertToLowerCase as xs:boolean) as xs:string*
{
	let $sourceData := 
		if ($convertToLowerCase) then
			fn:lower-case(data($sd))	
		else
			data($sd)
	let $sourceData := 
	if(fn:string-length($sourceData) eq 0) then 
	(
		$defaultValue 
	)
	else
	(
		$sourceData
	)
	return
	(
		$sourceData
	)
};

declare function utils:getData($sd as item(), $errorShortDesc as xs:string, $errorLongDesc as xs:string,$convertToLowerCase as xs:boolean) as xs:string*
{
	let $sourceData := 
		if ($convertToLowerCase) then
			fn:lower-case(data($sd))	
		else
			data($sd)
	let $sourceData := 
	if(fn:string-length($sourceData) eq 0) then 
	(
		"<searchError><error>{$errorShortDesc}</error><errorMessage>{$errorLongDesc}</errorMessage></searchError>" 
	)
	else
	(
		$sourceData
	)
	return
	(
		$sourceData
	)
};

(: 
Matches to TAXONOMY_CTSQUERY_ALL_AND in constants file
:)
declare function utils:getSearchFacetCondition($sd as item(),$conditionString as xs:string, $joinCondition as xs:string, $joinPreviousCondition as xs:string) as xs:string*
{
		debug:set-flag(true()),
		let $log := debug:log(("in getSearchFacetCondition","zzzzz"))
		let $facetCondition := 
			for $c in $sd/child::node()
			let $log := debug:log(("all sd childs",$c))
			let $parentData := utils:getSearchFacetParentCondition(data($c/@parentTerm))
			return 
				fn:concat($conditionString,$parentData,fn:string-join(utils:parseInputText(data($c)),""),$joinCondition)		
		let $facetCondition := fn:string-join($facetCondition,"")
		let $log := debug:log(("in facetcondition after string join",$facetCondition))		
		let $facetCondition := 
			if(fn:string-length($facetCondition) gt 0) then 
			(
				let $t := fn:substring($facetCondition,1,fn:string-length($facetCondition) - fn:string-length($joinCondition))
				let $t := fn:concat($joinPreviousCondition," (",$t,")")
				return
				(
					$t
				)
			)	
			else
			(
				let $t := ""
				return 
				(
					$t
				)
			)
		let $facetCondition := fn:string-join(utils:parseInputText($facetCondition),"")		
		let $log := debug:log(("facetcondition after parse input text",$facetCondition))			
		return 
		(
			$facetCondition
		)
};


(: 
Matches to TAXONOMY_CTSQUERY_LEVEL1_IS_AND_ALL_DESCENDANT_IS_OR in constants file
:)
declare function utils:getSearchFacetCondition1($sd as item(),$conditionString as xs:string, $joinCondition as xs:string, $joinPreviousCondition as xs:string) as xs:string*
{
		
		let $distinctitems := distinct-values(data($sd/taxonomyTerm/@parentTerm)) 
		let $distinctitems := 
			for $distinctItem in $distinctitems
			return	
				if(fn:contains(data($distinctItem),"~~")) then
					fn:substring-before($distinctItem,"~~")
				else
					fn:substring-before(fn:concat($distinctItem,"~~"),"~~")
		let $distinctitems := distinct-values($distinctitems)

		let $sameGroupConditions :=
			for $distinctGroups in $distinctitems (:distinct-values(data($sd/taxonomyTerm/@parentTerm)):)
				let $items :=
					$sd/taxonomyTerm[fn:starts-with(fn:concat(@parentTerm,"~~"),fn:concat(fn:tokenize($distinctGroups,"~~")[1],"~~"))]
				let $facetCondition := 
					for $c in $items
					let $parentData := utils:getSearchFacetParentCondition(data($c/@parentTerm))
					return 
						fn:concat("(",$parentData,utils:parseInputText(data($c)),")")				
								
				let $groupFacetCondition := (fn:string-join($facetCondition," OR "))
				return (fn:concat("(",fn:string-join($groupFacetCondition,""),")"))
		

		let $facetCondition := fn:string-join($sameGroupConditions," AND ")		
		return 
		(
			$facetCondition
		)
};

declare function utils:getSearchFacetParentCondition($parentAttrValue as xs:string) as xs:string*
{
	let $parentTermCondition := 
		if (fn:string-length($parentAttrValue) gt 0) then
		(
			let $tokensCondition :=
				for $token in fn:tokenize($parentAttrValue,"~~")
				return utils:parseInputText($token)
			return fn:string-join($tokensCondition,$constants:JOIN_WITH_AND)
		)
		else
		(
		)
	let $parentTermCondition := 
		if(fn:string-length($parentTermCondition) gt 0) then 
		(
			fn:concat($parentTermCondition,$constants:JOIN_WITH_AND)
		)
		else
		()
	return 
	(
		$parentTermCondition
	)
	
};

(: ----- ********* Current working getoldTaxonomyTerms (Slow). Not in use currently  ******** ----- :)
declare function utils:getOldTaxonomyTerms($sd as item(),$final_currentTab_SearchExpr as xs:string*, $search_Options as item()) as item()*
{
	
	let $taxonomyTerms :=
	<taxonomyTerms>
	{
	for $c in $sd/allTaxonomyTerms/child::node()
		let $taxonomyTermNode :=
		<taxonomyTerms>
		{
		if (data($c/@level) eq "1") then 
			$sd/allTaxonomyTerms/taxonomyTerm[@level="3" and fn:starts-with(./@parentTerm,data($c))]
		else if (data($c/@level) eq "2") then 
			$sd/allTaxonomyTerms/taxonomyTerm[@level="3" and fn:concat($c/@parentTerm,"~~",data($c)) eq ./@parentTerm]
		else if (data($c/@level) eq "3") then 	
			$c
		else
		()
		}
		</taxonomyTerms>
		let $taxonomy_searchExpr :=			
			for $termCountNode in $taxonomyTermNode/child::node()
				let $taxonomyParentDataCondition := utils:getSearchFacetParentCondition(data($termCountNode/@parentTerm))
				let $taxonomyDataCondition := fn:concat($taxonomyParentDataCondition,data($termCountNode))
				let $taxonomyDataCondition := fn:string-join(utils:parseInputText($taxonomyDataCondition),"")
				let $taxonomyDataCondition := fn:concat("(",$taxonomyDataCondition,")")
				let $taxonomyDataCondition := fn:concat($taxonomyDataCondition,$constants:JOIN_WITH_AND)
				return
					$taxonomyDataCondition
		let $taxonomy_searchExpr := utils:convertEmptySequenceToBlankString($taxonomy_searchExpr)
		let $taxonomy_searchExpr := fn:string-join($taxonomy_searchExpr,"")
		let $taxonomy_searchExpr :=
			if(fn:string-length($taxonomy_searchExpr) gt 0) then 
			(
				fn:substring($taxonomy_searchExpr,1,fn:string-length($taxonomy_searchExpr) - fn:string-length($constants:JOIN_WITH_AND))
			)
			else
			(
				$taxonomy_searchExpr	
			)		
		let $taxonomy_searchExpr := fn:concat("(",$taxonomy_searchExpr,")")
		
		return 
		(
				let $taxonomy_Word_SearchExpr := utils:joinConstraints($taxonomy_searchExpr,$constants:JOIN_WITH_AND, $final_currentTab_SearchExpr)
				
				let $count := utils:getSearchCount($taxonomy_Word_SearchExpr,$search_Options,"cts:query")
				return 
					if ($count gt -1) then
					(
					<taxonomyTerm text="{$c}" termCount="{$count}" id="{data($c/@id)}" parentTerm="{data($c/@parentTerm)}" level="{data($c/@level)}" searchTerm="{data($c/@searchTerm)}"/> 
					)
					else
					(
					)
		)
	}
	</taxonomyTerms>
	return 
	(
		$taxonomyTerms
	)
};


declare function utils:getTaxonomyTerms($sd as item(),$final_currentTab_SearchExpr as xs:string*, $search_Options as item(),$ctsQueryFileToUse as xs:string) as item()*
{
	let $currentTabCTSQuery := cts:query(search:parse($final_currentTab_SearchExpr,$search_Options, "cts:query"))

	let $taxonomyTerms :=
	<taxonomyTerms>
	{
		for $c in doc($ctsQueryFileToUse)/allTaxonomyTermsWithCTSParsedQueries/parsedCTSQuery
		
		let $mergedCTSQuery := cts:and-query(($currentTabCTSQuery,cts:query($c/*)))
		let $estimateCount := xdmp:estimate(cts:search(doc(),($mergedCTSQuery))) 
		return
		(
			if ($estimateCount gt -1) then
			(
			<taxonomyTerm text="{$c/@text}" termCount="{$estimateCount}" id="{data($c/@id)}" parentTerm="{data($c/@parentTerm)}" level="{data($c/@level)}" searchTerm="{data($c/@searchTerm)}"/> 
			)
			else
			()
		)
	}
	</taxonomyTerms>
	return 
	(
		$taxonomyTerms
	)
};

declare function utils:convertHierarchicalToFlatAllTaxonomyTerms($taxonomyTerms as item()) as item()*
{	
	let $flatTaxonomyTerms :=
	<allTaxonomyTerms>
	{
	for $c in $taxonomyTerms//term
		let $parentTerms :=
			for $ancestorNodes in $c/ancestor::node()
			return
				$ancestorNodes/@text
		
		let $parentTerms := fn:string-join($parentTerms,"~~")
		
		return
		<taxonomyTerm id="{$c/@id}" parentTerm="{$parentTerms}" searchTerm="{$c/@searchTerm}" level="{$c/@level}">{
			data($c/@text)
		}
		</taxonomyTerm>		
	}
	</allTaxonomyTerms>
	return 
	(
		$flatTaxonomyTerms
	)
};

(: 
Matches to TAXONOMY_CTSQUERY_ALL_AND in constants file
:)
declare function utils:convertHierarchicalToParsedCTSQuery($taxonomyTerms as item()) as item()*
{

	let $ctsParsedQueryTaxonomyTerms :=
	<allTaxonomyTermsWithCTSParsedQueries>
	{
	for $c in $taxonomyTerms//term
		let $parsedCTSQueryGenerationNodes := 
		if ($c/@searchTerm = 'N') then 
			let $descendantNodes :=
				for $descendantNode in $c/descendant-or-self::node()
				return
					utils:parseInputText($descendantNode/@text)
			
			let $ancestorNodes :=
				for $ancestorNode in $c/ancestor::node()
				return
					utils:parseInputText($ancestorNode/@text)
			
			return 
			($ancestorNodes,$descendantNodes)
		else
			for $ancestorNode in $c/ancestor-or-self::node()
			return
				utils:parseInputText($ancestorNode/@text)
				
		let $parsedCTSQueryGenerationNodes := fn:string-join($parsedCTSQueryGenerationNodes," AND ")
		let $parsedCTSQueryGenerationNodes := search:parse($parsedCTSQueryGenerationNodes,utils:build-taxonomy-search-options(), "cts:query")
		
		let $parentTerms :=
			for $ancestorNode in $c/ancestor::node()
			return
				$ancestorNode/@text
		
		let $parentTerms := fn:string-join($parentTerms,"~~")
		
		return
		<parsedCTSQuery id="{$c/@id}" searchTerm="{$c/@searchTerm}" parentTerm="{$parentTerms}" level="{$c/@level}" text="{$c/@text}">{$parsedCTSQueryGenerationNodes}</parsedCTSQuery>		
	}
	</allTaxonomyTermsWithCTSParsedQueries>
	return 
	(
		$ctsParsedQueryTaxonomyTerms
	)

};

(: 
Matches to TAXONOMY_CTSQUERY_LEVEL1_IS_AND_ALL_DESCENDANT_IS_OR in constants file
:)
declare function utils:convertHierarchicalToParsedCTSQuery1($taxonomyTerms as item()) as item()*
{

	let $ctsParsedQueryTaxonomyTerms :=
	<allTaxonomyTermsWithCTSParsedQueries>
	{
	for $c in $taxonomyTerms//term
		let $parsedCTSQueryGenerationNodes := 
		if ($c/@level = '1') then
			let $firstLevelNode := (utils:parseInputText($c/@text))
			let $x :=
				if ($c/@searchTerm = 'N') then 
					let $secondLevelNonsearchTermNodes :=
						for $childNode in $c/child::node()[./@level = '2' and ./@searchTerm = 'N']
							for $descendantNode in $childNode/child::node()
							return
								fn:concat(fn:string-join(utils:parseInputText($childNode/@text),""), " AND ", fn:string-join(utils:parseInputText($descendantNode/@text),""))
					let $secondLevelsearchTermNodes :=
						for $childNode in $c/child::node()[./@level = '2' and ./@searchTerm = 'Y']
							return
								utils:parseInputText($childNode/@text)
					let $d :=
						for $a in $firstLevelNode
							for $b in $secondLevelNonsearchTermNodes
								return fn:concat("(",$a, " AND ", $b,")")
					let $e :=
						for $a in $firstLevelNode
							for $b in $secondLevelsearchTermNodes
								return fn:concat("(",$a, " AND ", $b,")")
					
					let $f := ($d, $e)
					return $f
				else
					$firstLevelNode
			
			return $x
		else if ($c/@level = '2') then
			
			
			let $firstLevelNode := (utils:parseInputText($c/parent::node()/@text))
			
			let $x :=
				if ($c/@searchTerm = 'N') then 
					let $secondLevelNonsearchTermNodes :=
						for $childNode in $c/child::node()[./@level = '3' and ./@searchTerm = 'Y']
							
							return
								fn:concat(fn:string-join(utils:parseInputText($c/@text),""), " AND ", fn:string-join(utils:parseInputText($childNode/@text),""))
					
					let $d :=
						for $a in $firstLevelNode
							for $b in $secondLevelNonsearchTermNodes
								return fn:concat("(",$a, " AND ", $b,")")					
					return $d
				else
					fn:concat("(",fn:string-join($firstLevelNode,""), " AND ", fn:string-join(utils:parseInputText($c/@text),""),")")
					
			return $x
		else if ($c/@level = '3') then	
			let $ancestorNodes :=
				for $ancestorNode in $c/ancestor-or-self::node()
				return
					utils:parseInputText($ancestorNode/@text)
			
			return fn:concat("(",fn:string-join($ancestorNodes," AND "),")")
		else
		()
		
		let $parsedCTSQueryGenerationNodes := fn:string-join($parsedCTSQueryGenerationNodes," OR ")
		let $parsedCTSQueryGenerationNodes := search:parse($parsedCTSQueryGenerationNodes,utils:build-taxonomy-search-options(), "cts:query")
		
		let $parentTerms :=
			for $ancestorNode in $c/ancestor::node()
			return
				$ancestorNode/@text
		
		let $parentTerms := fn:string-join($parentTerms,"~~")
		
		return
		<parsedCTSQuery id="{$c/@id}" searchTerm="{$c/@searchTerm}" parentTerm="{$parentTerms}" level="{$c/@level}" text="{$c/@text}">{$parsedCTSQueryGenerationNodes}</parsedCTSQuery>		
	}
	</allTaxonomyTermsWithCTSParsedQueries>
	return 
	(
		$ctsParsedQueryTaxonomyTerms
	)

};

(: ----  *************  String Query used earlier. Although working, not used as giving performace issue ********* ----- :)
declare function utils:convertHierarchicalToStringQuery($taxonomyTerms as item()) as item()*
{

	let $ctsStringQueryTaxonomyTerms :=
	<allTaxonomyTermsWithStringQueries>
	{
	for $c in $taxonomyTerms//term
		let $stringQueryGenerationNodes := 
		if ($c/@searchTerm = 'N') then 
			for $descendantNode in $c/descendant-or-self::node()
			return
				utils:parseInputText($descendantNode/@text)
				
		else
			for $ancestorNodes in $c/ancestor-or-self::node()
			return
				utils:parseInputText($ancestorNodes/@text)
				
				
		let $stringQueryGenerationNodes := fn:string-join($stringQueryGenerationNodes," AND ")
	
		let $parentTerms :=
			for $ancestorNodes in $c/ancestor::node()
			return
				$ancestorNodes/@text
		
		let $parentTerms := fn:string-join($parentTerms,"~~")
		
		return
		<stringQuery id="{$c/@id}" searchTerm="{$c/@searchTerm}" parentTerm="{$parentTerms}" level="{$c/@level}" text="{$c/@text}">{$stringQueryGenerationNodes}</stringQuery>		
	}
	</allTaxonomyTermsWithStringQueries>
	return 
	(
		$ctsStringQueryTaxonomyTerms
	)

};

(: Although the Master file with CTS query is created, unable to join these pre stored conditions with the onscreen quick search and selected facet conditions.
declare function utils:convertHierarchicalToCTSQuery($taxonomyTerms as item()) as item()*
{
	
	let $ctsQueryTaxonomyTerms :=
	<allTaxonomyTermsWithCTSQueries>
	{
	for $c in $taxonomyTerms//term
		let $ctsQueryGenerationNodes := 
		if ($c/@searchTerm = 'N') then 
			for $descendantNode in $c/descendant-or-self::node()
			return
				(:utils:parseInputText($descendantNode/@text):)
				$descendantNode/@text
		else
			for $ancestorNodes in $c/ancestor-or-self::node()
			return
				(:utils:parseInputText($ancestorNodes/@text):)
				$ancestorNodes/@text
				
		let $ctsQueryGenerationNodes := fn:string-join($ctsQueryGenerationNodes," AND ")
		let $ctsQueryGenerationNodes := fn:concat("(",$ctsQueryGenerationNodes,")")
		(:let $termCTSQuery := fn:concat("&apos;",cts:query(search:parse($ctsQueryGenerationNodes,utils:build-taxonomy-search-options(), "cts:query")),"&apos;"):)
		let $termCTSQuery := cts:query(search:parse($ctsQueryGenerationNodes,utils:build-taxonomy-search-options(), "cts:query"))
		
		let $parentTerms :=
			for $ancestorNodes in $c/ancestor::node()
			return
				$ancestorNodes/@text
		
		let $parentTerms := fn:string-join($parentTerms,"~~")
		
		return
		<ctsQuery id="{$c/@id}" searchTerm="{$c/@searchTerm}" parentTerm="{$parentTerms}" level="{$c/@level}" text="{$c/@text}">{$termCTSQuery}</ctsQuery>		
	}
	</allTaxonomyTermsWithCTSQueries>
	return 
	(
		$ctsQueryTaxonomyTerms
	)

};
:)


declare function utils:getOldSearchFacetCondition($sd as item(),$conditionString as xs:string, $joinCondition as xs:string, $joinPreviousCondition as xs:string) as xs:string*
{
		
		let $facetCondition := 
			for $c in $sd/child::node()
			let $parentData := utils:getOldSearchFacetParentCondition(data($c/@parentTerm))
			return 
				fn:concat($conditionString,$parentData,data($c),$joinCondition)				
		let $facetCondition := fn:string-join($facetCondition,"")			
		let $facetCondition := 
			if(fn:string-length($facetCondition) gt 0) then 
			(
				let $t := fn:substring($facetCondition,1,fn:string-length($facetCondition) - fn:string-length($joinCondition))
				let $t := fn:concat($joinPreviousCondition," (",$t,")")
				return
				(
					$t
				)
			)	
			else
			(
				let $t := ""
				return 
				(
					$t
				)
			)
		let $facetCondition := fn:string-join(utils:oldparseInputText($facetCondition),"")			
		return 
		(
			$facetCondition
		)
};

declare function utils:getOldSearchFacetParentCondition($parentAttrValue as xs:string) as xs:string*
{
	let $parentTermCondition := 
		if (fn:string-length($parentAttrValue) gt 0) then
		(	
			fn:replace($parentAttrValue,"~~"," AND ")
		)
		else
		(
		)
	let $parentTermCondition := 
		if(fn:string-length($parentTermCondition) gt 0) then 
		(
			fn:concat($parentTermCondition,$constants:JOIN_WITH_AND)
		)
		else
		()
	return 
	(
		$parentTermCondition
	)
	
};