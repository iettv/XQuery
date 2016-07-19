xquery version "1.0-ml";
module namespace utils = "http://www.TheIET.org/utils";
import module namespace constants = "http://www.TheIET.org/constants"   at "constants.xqy";
import module namespace search = "http://marklogic.com/appservices/search"      at "/MarkLogic/appservices/search/search.xqy";
import module namespace debug = "http://marklogic.com/debug" at "/MarkLogic/appservices/utils/debug.xqy";

declare function utils:convertStringToXML($xmlstring as xs:string) as item()? {
	(: determine if any search criteria entered :)
	let $log := debug:log(("in convertStringToXml:xmlstring:",$xmlstring))
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
			<searchError><error>Error in Input String</error><errorMessage>{$exception}</errorMessage></searchError>
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
declare function utils:getSearchCondition($sd as item(),$conditionString as xs:string, $joinCondition as xs:string, $joinPreviousCondition as xs:string) as xs:string*
{
		
		let $facetCondition := 
			for $c in $sd/child::node()
			return 
				fn:concat($conditionString,data($c),$joinCondition)
						
		let $facetCondition := fn:string-join($facetCondition,"")
		let $log := debug:log(("in getSearchCondition  test",$sd))
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
		let $log := debug:log(("in getSearchCondition 2",$facetCondition))			
		return 
		(
			$facetCondition
		)
};
