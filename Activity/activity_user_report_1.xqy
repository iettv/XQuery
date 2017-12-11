xquery version "1.0-ml";
import module namespace search = "http://marklogic.com/appservices/search"      at "/MarkLogic/appservices/search/search.xqy";
import module namespace utils = "http://www.TheIET.org/utils"   at "utils.xqy";
import module namespace activity_helper = "http://www.TheIET.org/activity_helper"   at "activity_helper.xqy";
import module namespace constants = "http://www.TheIET.org/constants"   at "constants.xqy";
import module namespace debug = "http://marklogic.com/debug" at "/MarkLogic/appservices/utils/debug.xqy";
				   
declare variable $inputSearchDetails as xs:string external ;
debug:set-flag(true()),
(:let $log := debug:log(("in activity Log","at start")):)
let $Log := xdmp:log("[ IET-TV ][ ActivityUserReport ][ Call ][ Activity User Report Service Call ]")
let $sd  := utils:convertStringToXML($inputSearchDetails)

(: Extract Activity Data :)
let $fromdate := utils:getData($sd/FromDate,"Invalid Activity Start Date","Report Start Date cannot be blank",fn:true())
let $todate := utils:getData($sd/ToDate,"Invalid Activity End Date","Report End Date cannot be blank",fn:true())
let $platform := utils:getData($sd/PlatformID,"iet-wrd",fn:true())
(:
let $actionType := utils:getData($sd/Action/Type,"Invalid Action Type","Action Type cannot be blank",fn:true())
let $actionType := fn:concat("/",$actionType,"/") 
let $sortKey := 
	if ($sd/sortingOptions/sortBy/sortKey) then 
		utils:getData($sd/sortingOptions/sortBy/sortKey,"ActivityDate",fn:false())
	else
		"ActivityDate"
		
let $sortOrder := 
	if ($sd/sortingOptions/sortBy/sortOrder) then 
		utils:getData($sd/sortingOptions/sortBy/sortOrder,"descending",fn:true())
	else
		"descending"
:)

let $ErrXml :=  activity_helper:isDataError($sd, $fromdate, $todate)		(:<success/> :)

return
	if ($ErrXml//error) 
	then $ErrXml
	else 
	(	
		(: Build Search Options :) 
		let $search_Options := activity_helper:build-search-options()

		let $dateFilter := activity_helper:getDateFilterExpr($fromdate,$todate)
		
		let $UserIDFilter := utils:getSearchCondition($sd/UserIDs,"UserID:",$constants:JOIN_WITH_OR,"")
		let $UserIDFilter := utils:convertEmptySequenceToBlankString($UserIDFilter)
		
		let $UserIPFilter := utils:getSearchCondition($sd/UserIPs,"UserIP:",$constants:JOIN_WITH_OR,"")
		let $UserIPFilter := utils:convertEmptySequenceToBlankString($UserIPFilter)
		
		let $accountTypeFilter := activity_helper:getSearchCondition($sd/AccountTypes,"Account_Type:",$constants:JOIN_WITH_OR,"")
		let $accountTypeFilter := utils:convertEmptySequenceToBlankString($accountTypeFilter)

		let $actionTypeFilter := activity_helper:getSearchCondition($sd/ActionTypes,"Action_Type:",$constants:JOIN_WITH_OR,"")
		let $actionTypeFilter := utils:convertEmptySequenceToBlankString($actionTypeFilter)
		
		let $corporateAccountIdFilter := activity_helper:getSearchCondition($sd/CorporateAccountIDs,"Corporate_Account_Id:",$constants:JOIN_WITH_OR,"")
		let $corporateAccountIdFilter := utils:convertEmptySequenceToBlankString($corporateAccountIdFilter)

		let $userTypeFilter := activity_helper:getSearchCondition($sd/UserTypes,"User_Type:",$constants:JOIN_WITH_OR,"")
		let $userTypeFilter := utils:convertEmptySequenceToBlankString($userTypeFilter)

		let $deviceFilter := activity_helper:getSearchCondition($sd/DeviceTypes,"Device_Type:",$constants:JOIN_WITH_OR,"")
		let $deviceFilter := utils:convertEmptySequenceToBlankString($deviceFilter)
		
		(: joining Expressions :)
		let $filter_Expr := utils:joinConstraints($dateFilter,$constants:JOIN_WITH_AND, $UserIDFilter)
		let $filter_Expr := utils:joinConstraints($filter_Expr,$constants:JOIN_WITH_AND, $UserIPFilter)
		let $filter_Expr := utils:joinConstraints($filter_Expr,$constants:JOIN_WITH_AND, $accountTypeFilter)
		let $filter_Expr := utils:joinConstraints($filter_Expr,$constants:JOIN_WITH_AND, $actionTypeFilter)
		let $filter_Expr := utils:joinConstraints($filter_Expr,$constants:JOIN_WITH_AND, $corporateAccountIdFilter)
		let $filter_Expr := utils:joinConstraints($filter_Expr,$constants:JOIN_WITH_AND, $userTypeFilter)		
		let $filter_Expr := utils:joinConstraints($filter_Expr,$constants:JOIN_WITH_AND, $deviceFilter)	

		let $xmlctsquery := search:parse($filter_Expr,$search_Options,"cts:query")
		let $ctsQuery := cts:query(search:parse($filter_Expr,$search_Options,"cts:query"))
		let $searchContent :=  cts:search(collection(upper-case($platform))/Activity,$ctsQuery)
		let $searchContentXML := <root>{$searchContent}</root>
        let $finalContent := for $i in $searchContentXML/Activity return 
                         if ($i/Action[matches(Type/text(),'Login')]/AdditionalInfo/NameValue/Value[text()='Failed']) then () else ($i)
		
		return 
		(
			<Activities>{$finalContent}</Activities>,
			xdmp:log("[ IET-TV ][ ActivityUserReport ][ Success ][ Activity User Report Result sent ]")
		)
		
		  
	)
