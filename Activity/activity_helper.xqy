xquery version "1.0-ml";
module namespace activity_helper = "http://www.TheIET.org/activity_helper";
import module namespace utils = "http://www.TheIET.org/utils"   at "utils.xqy";
import module namespace constants = "http://www.TheIET.org/constants"   at "constants.xqy";
import module namespace search = "http://marklogic.com/appservices/search"      at "/MarkLogic/appservices/search/search.xqy";
import module namespace debug = "http://marklogic.com/debug" at "/MarkLogic/appservices/utils/debug.xqy";

declare function activity_helper:isDataError($sd as item(), $fromdate as xs:string, $todate as xs:string) as item()? 
{
	let $ErrorXml :=
		if ($sd//error) then
		(
			$sd
		)
		else if(fn:contains($fromdate,"<error>")) then
		(
			xdmp:unquote($fromdate)/*
		)
		else if(fn:contains($todate,"<error>")) then
		(
			xdmp:unquote($todate)/*
		)	
		else
		(
			<success></success>
		)
	return
	(
		$ErrorXml
	)
	
};
(: Build Search Options :)
declare function activity_helper:build-search-options() as item()*
{
	let $search-options-start := "<options xmlns='http://marklogic.com/appservices/search'>"
	let $search-options-constraints := "	
	<constraint name='Activity_Date'>
         <range type='xs:date'>
			<element ns='' name='ActivityDate'/>
		</range>
    </constraint>
	<constraint name='UserIP'>
         <range type='xs:string'>
			<element ns='' name='UserIP'/>
		</range>
    </constraint>
	<constraint name='UserID'>
         <range type='xs:string'>
			<element ns='' name='UserID'/>
		</range>
    </constraint>
	<constraint name='Account_Type'>
         <range type='xs:string'>
			<element ns='' name='AccountType'/>
		</range>
    </constraint>
	<constraint name='Corporate_Account_Id'>
         <range type='xs:string'>
			<element ns='' name='CorporateAccountID'/>
		</range>
    </constraint>	
	<constraint name='Action_Type'>
         <range type='xs:string'>
			<element ns='' name='Type'/>
		</range>
    </constraint>	
	<constraint name='User_Type'>
         <range type='xs:string'>
			<element ns='' name='UserType'/>
		</range>
    </constraint>	
	<constraint name='Device_Type'>
         <range type='xs:string'>
			<element ns='' name='Device'/>
		</range>
    </constraint>	
	<operator name='sort'>
		<state name='ActivityDate_sort_asc'>
		  <sort-order direction='ascending' type='xs:date'>
			<element ns='' name='ActivityDate'/>
		  </sort-order>
		  <sort-order>
			<score/>
		  </sort-order>
		</state>
		<state name='ActivityDate_sort_desc'>
		  <sort-order direction='descending' type='xs:date'>
			<element ns='' name='ActivityDate'/>
		  </sort-order>
		  <sort-order>
			<score/>
		  </sort-order>
		</state>  
	</operator>"
	

	
	let $search-options-return-values := "<return-plan>false</return-plan>
	<return-query>false</return-query>
	<return-metrics>false</return-metrics>"
	let $search-options-end := "</options>"
	
	(:let $search-term-options := "<term><term-option>case-insensitive</term-option></term>":)
	let $search-term-options := ""
	
	let $final-search-options := fn:concat($search-options-start,$search-options-constraints,$search-options-return-values,$search-term-options,$search-options-end)
	return
	(
		xdmp:unquote($final-search-options)/*
	)
		
};

declare function activity_helper:getDateFilterExpr($fromdate as xs:string,$todate as xs:string) as xs:string*
{
	
	(:let $log := debug:log(("in getDateFilterExpr",$fromdate)):)
	let $date_searchExpr := 
		fn:concat(" (Activity_Date GE ", $fromdate, " AND Activity_Date LE ", $todate, ") ")
	return
	(
		$date_searchExpr
	)
};

declare function activity_helper:getSearchCondition($sd as item(),$conditionString as xs:string, $joinCondition as xs:string, $joinPreviousCondition as xs:string) as xs:string*
{
		
		let $facetCondition := 
			for $c in $sd/child::node()
			return 
				fn:concat($conditionString,fn:concat("&quot;",data($c),"&quot;"),$joinCondition)
						
		let $facetCondition := fn:string-join($facetCondition,"")
		(:let $log := debug:log(("in getSearchCondition  test",$sd)):)
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
		(:let $log := debug:log(("in getSearchCondition 2",$facetCondition)):)		
		return 
		(
			$facetCondition
		)
};
