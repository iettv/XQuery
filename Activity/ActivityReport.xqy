xquery version "1.0-ml";

module namespace ActivityReport = "http://www.TheIET.org/ActivityReport";
import module namespace search     = "http://marklogic.com/appservices/search" at "/MarkLogic/appservices/search/search.xqy";

(: This service could be called to get all 'Activity Data' or 'Titles' only by $Mode parameter (Title/None) :)
declare function ActivityReport:GetActivity($TermToSearch as xs:string, $PageLength as xs:integer, $StartPage as xs:integer, $StartDate as xs:date, $EndDate as xs:date, $Mode as xs:string, $TextToSearch, $OrderBy as xs:string) as item()
{
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
								for $EachOrder in if(contains($OrderBy,',')) then tokenize($OrderBy,',') else $OrderBy
								let $OrderBy := if(normalize-space(tokenize($EachOrder,':')[1])='User')
												then  <sort-order type="xs:string" collation="http://marklogic.com/collation/" direction="{tokenize($EachOrder,':')[2]}"><element ns="" name="UserID"/></sort-order>
												else
												if(normalize-space(tokenize($EachOrder,':')[1])='Action')
												then <sort-order type="xs:string" collation="http://marklogic.com/collation/" direction="{tokenize($EachOrder,':')[2]}"><element ns="" name="Type"/></sort-order>
												else
												if(normalize-space(tokenize($EachOrder,':')[1])='Actor')
												then <sort-order type="xs:string" collation="http://marklogic.com/collation/" direction="{tokenize($EachOrder,':')[2]}"><element ns="" name="ActorType"/></sort-order>
												else
												if(normalize-space(tokenize($EachOrder,':')[1])='IP')
												then <sort-order type="xs:string" collation="http://marklogic.com/collation/" direction="{tokenize($EachOrder,':')[2]}"><element ns="" name="UserIP"/></sort-order>
												else
												if(normalize-space(tokenize($EachOrder,':')[1])='UserType')
												then <sort-order type="xs:string" collation="http://marklogic.com/collation/" direction="{tokenize($EachOrder,':')[2]}"><element ns="" name="UserType"/></sort-order>
												else                
												if(normalize-space(tokenize($EachOrder,':')[1])='Device')
												then  <sort-order type="xs:string" collation="http://marklogic.com/collation/" direction="{tokenize($EachOrder,':')[2]}"><element ns="" name="Device"/></sort-order>
												else
												if(normalize-space(tokenize($EachOrder,':')[1])='AccountType')
												then  <sort-order type="xs:string" collation="http://marklogic.com/collation/" direction="{tokenize($EachOrder,':')[2]}"><element ns="" name="AccountType"/></sort-order>
												else
												if(normalize-space(tokenize($EachOrder,':')[1])='CID')
												then  <sort-order type="xs:string" collation="http://marklogic.com/collation/" direction="{tokenize($EachOrder,':')[2]}"><element ns="" name="CorporateAccountID"/></sort-order>
												else
												if(normalize-space(tokenize($EachOrder,':')[1])='ActivityDate')
												then  <sort-order type="xs:date" direction="{tokenize($EachOrder,':')[2]}"><element ns="" name="ActivityDate"/></sort-order>
												else
												if(normalize-space(tokenize($EachOrder,':')[1])='UserName')
												then  <sort-order type="xs:string" direction="{tokenize($EachOrder,':')[2]}"><element ns="" name="UserName"/></sort-order>
												else ()
								return $OrderBy
							}
							<sort-order><score/></sort-order>
							<constraint name="Action">
								<range type="xs:string" facet="true">
									<element ns="" name="Type"/>
									<facet-option>frequency-order</facet-option>
									<facet-option>descending</facet-option>
								</range>
							</constraint>
							<constraint name="VideoID">
								<range type="xs:string" facet="true">
									<element ns="" name="EntityID"/>
									<facet-option>frequency-order</facet-option>
									<facet-option>descending</facet-option>
								</range>
							</constraint>
							<constraint name="Actor">
								<range type="xs:string" facet="true">
									<element ns="" name="ActorType"/>
									<facet-option>frequency-order</facet-option>
									<facet-option>descending</facet-option>
								</range>
							</constraint>
							<constraint name="User">
								<range type="xs:string" facet="true">
									<element ns="" name="UserID"/>
									<facet-option>frequency-order</facet-option>
									<facet-option>descending</facet-option>
								</range>
							</constraint>
							<constraint name="UserName">
								<range type="xs:string" facet="true">
									<element ns="" name="UserName"/>
									<facet-option>frequency-order</facet-option>
									<facet-option>descending</facet-option>
								</range>
							</constraint>   							
							<constraint name="IP">
								<range type="xs:string" facet="true">
									<element ns="" name="UserIP"/>
									<facet-option>frequency-order</facet-option>
									<facet-option>descending</facet-option>
								</range>
							</constraint>  
							<constraint name="UserType">
								<range type="xs:string" facet="true">
									<element ns="" name="UserType"/>
									<facet-option>frequency-order</facet-option>
									<facet-option>descending</facet-option>
								</range>
							</constraint> 
							<constraint name="Device">
								<range type="xs:string" facet="true">
									<element ns="" name="Device"/>
									<facet-option>frequency-order</facet-option>
									<facet-option>descending</facet-option>
								</range>
							</constraint>
							<constraint name="AccountType">
								<range type="xs:string" facet="true">
									<element ns="" name="AccountType"/>
									<facet-option>frequency-order</facet-option>
									<facet-option>descending</facet-option>
								</range>
							</constraint>
							<constraint name="CID">
								<range type="xs:string" facet="true">
									<element ns="" name="CorporateAccountID"/>
									<facet-option>frequency-order</facet-option>
									<facet-option>descending</facet-option>
								</range>
							</constraint>              
							<constraint name="ActivityDate">
									<range type="xs:date" facet="true">
										<element ns="" name="ActivityDate"/>
										<facet-option>frequency-order</facet-option>
										<facet-option>descending</facet-option>
										<computed-bucket name="today" ge="P0D" lt="P1D" anchor="start-of-day">Today</computed-bucket>
										<computed-bucket name="yesterday" ge="-P1D" lt="P0D" anchor="start-of-day">yesterday</computed-bucket>
										<computed-bucket name="30-days" ge="-P30D" lt="-P1D" anchor="start-of-day">0-30</computed-bucket>
										<computed-bucket name="60-days" ge="-P60D" lt="-P30D" anchor="start-of-day">31-60</computed-bucket>
										<computed-bucket name="90-days" ge="-P90D" lt="-P60D" anchor="start-of-day">61-90</computed-bucket>
										<computed-bucket name="120-days" ge="-P120D" lt="-P90D" anchor="start-of-day">91-120</computed-bucket>
										<computed-bucket name="year" ge="-P1Y" lt="P1D" anchor="now">Last Year</computed-bucket>
									</range>
							</constraint>
							<constraint name="ChannelId">
								<range type="xs:string" facet="true">
									<facet-option>frequency-order</facet-option>
									<facet-option>descending</facet-option>
								 <path-index>AdditionalInfo/NameValue[Name='ChannelId']/Value</path-index>
								</range>
							</constraint>
							<constraint name="SubscriptionType">
								<range type="xs:string" facet="true">
									<facet-option>frequency-order</facet-option>
									<facet-option>descending</facet-option>
								 <path-index>AdditionalInfo/NameValue[Name='SubscriptionType']/Value</path-index>
								</range>
							</constraint> 
							<additional-query>
									{
									  cts:and-query((
													  cts:element-range-query(xs:QName("ActivityDate"), ">=", $StartDate),
													  cts:element-range-query(xs:QName("ActivityDate"), "<=",$EndDate)
												   ))
									}
							</additional-query>
							{
							if($Mode ="Title" or $Mode="ActivityOnTitle")
							then
								<additional-query>
									{
										cts:or-query((
												for $EachTitle in cts:value-match(cts:path-reference('AdditionalInfo/NameValue[Name="VideoTitle"]/Value'), fn:concat('*',$TextToSearch,'*'))
												return cts:word-query($EachTitle, ("case-insensitive", "wildcarded", "stemmed", "diacritic-insensitive", "punctuation-insensitive"))
											))
									}
								</additional-query>
							else ()
							}
						</options>
  let $SearchResponse 		:=  search:search($TermToSearch, $SearchOption, $Start, $PageLength)
  let $TotalVideoRecord 	:= data($SearchResponse/@total)
  let $ActivityChunks 		:= if( $Mode="ActivityOnTitle" )
							   then
									for $Record in data($SearchResponse//search:result/@uri) return fn:doc($Record)
							   else
							   if( $Mode="Title" )
							   then
									for $EachRecord in distinct-values(for $Record in $SearchResponse return fn:doc(data($Record//search:result/@uri))/Activity/Action/AdditionalInfo/NameValue[Name='VideoTitle']/Value/text())
									return <Title>{$EachRecord}</Title>
							   else
									for $Record in data($SearchResponse//search:result/@uri) return fn:doc($Record)
  let $GetActionFacets :=	<Action>
								  {
									for $EachFacet in $SearchResponse/search:facet[@name="Action"]/search:facet-value
									return <ActionType frequency="{fn:data($EachFacet/@count)}">{fn:data($EachFacet/@name)}</ActionType>
								  }
								</Action>
	let $GetActorFacets :=  	<Actor>
								  {
									for $EachFacet in $SearchResponse/search:facet[@name="Actor"]/search:facet-value
									return <facet frequency="{fn:data($EachFacet/@count)}">{fn:data($EachFacet/@name)}</facet>
								  }
								</Actor>
    let $GetUserFacets :=  		<User>
                                  {
                                    for $EachFacet in $SearchResponse/search:facet[@name="User"]/search:facet-value
                                    return <facet frequency="{fn:data($EachFacet/@count)}">{fn:data($EachFacet/@name)}</facet>
                                  }
                                </User>
	let $GetIPFacets :=  		<IP>
								  {
									for $EachFacet in $SearchResponse/search:facet[@name="IP"]/search:facet-value
									return <facet frequency="{fn:data($EachFacet/@count)}">{fn:data($EachFacet/@name)}</facet>
								  }
								</IP>
    let $GetUserTypeFacets :=  <UserType>
								{
									for $EachFacet in $SearchResponse/search:facet[@name="UserType"]/search:facet-value
									return <facet frequency="{fn:data($EachFacet/@count)}">{$EachFacet/text()}</facet>
								}
								</UserType>
	let $GetDeviceFacets :=  	<Device>
								  {
									for $EachFacet in $SearchResponse/search:facet[@name="Device"]/search:facet-value
									return <facet frequency="{fn:data($EachFacet/@count)}">{$EachFacet/text()}</facet>
								  }
								</Device>
	let $GetAccountTypeFacets :=  <AccountType>
									  {
										for $EachFacet in $SearchResponse/search:facet[@name="AccountType"]/search:facet-value
										return <facet frequency="{fn:data($EachFacet/@count)}">{$EachFacet/text()}</facet>
									  }
								  </AccountType>	
	let $GetCIDFacets :=  		<CID>
								  {
									for $EachFacet in $SearchResponse/search:facet[@name="CID"]/search:facet-value
									return <facet frequency="{fn:data($EachFacet/@count)}">{$EachFacet/text()}</facet>
								  }
								</CID>	
    let $GetActivityDateFacets :=  <ActivityDate>
									  {
										for $EachFacet in $SearchResponse/search:facet[@name="ActivityDate"]/search:facet-value
										return <facet frequency="{fn:data($EachFacet/@count)}">{$EachFacet/text()}</facet>
									  }
									</ActivityDate>	
	let $GetSubscriptionTypeFacets :=  <SubscriptionType>
									  {
										for $EachFacet in $SearchResponse/search:facet[@name="SubscriptionType"]/search:facet-value
										return <facet frequency="{fn:data($EachFacet/@count)}">{$EachFacet/text()}</facet>
									  }
									 </SubscriptionType>							
	let $GetChannelIdFacets :=  	<ChannelId>
									  {
										for $EachFacet in $SearchResponse/search:facet[@name="ChannelId"]/search:facet-value
										return <facet frequency="{fn:data($EachFacet/@count)}">{$EachFacet/text()}</facet>
									  }
									 </ChannelId>
   return
		<Result>
			<TotalRecord>{$TotalVideoRecord}</TotalRecord>
			<Facets>
			{
				$GetActionFacets,
				$GetSubscriptionTypeFacets,
				$GetActorFacets,
				$GetUserFacets,
				$GetIPFacets,
				$GetUserTypeFacets,
				$GetDeviceFacets,
				$GetAccountTypeFacets,
				$GetCIDFacets,
				$GetActivityDateFacets,
				$GetChannelIdFacets
			}
			</Facets>
			<Activities>{$ActivityChunks}</Activities>
		</Result> 
};



declare function GetGraphData($TermToSearch as xs:string, $PageLength as xs:integer, $StartPage as xs:integer, $StartDate as xs:date, $EndDate as xs:date,$Actions as xs:string,$TextToSearch) as item()
{
	let $Start := if($StartPage = 1) then $StartPage else fn:sum(($StartPage * $PageLength) - $PageLength + 1)
	let $SearchOption := <options xmlns="http://marklogic.com/appservices/search">
							<term>
								<term-option>case-insensitive</term-option>
								<term-option>wildcarded</term-option>
								<term-option>stemmed</term-option>
								<term-option>diacritic-insensitive</term-option>
								<term-option>punctuation-insensitive</term-option>
							</term>
							<constraint name="Action">
								<range type="xs:string" facet="true">
									<element ns="" name="Type"/>
									<facet-option>frequency-order</facet-option>
									<facet-option>descending</facet-option>
								</range>
							</constraint>
							<constraint name="Actor">
								<range type="xs:string" facet="true">
									<element ns="" name="ActorType"/>
									<facet-option>frequency-order</facet-option>
									<facet-option>descending</facet-option>
								</range>
							</constraint>
							<constraint name="User">
								<range type="xs:string" facet="true">
									<element ns="" name="UserID"/>
									<facet-option>frequency-order</facet-option>
									<facet-option>descending</facet-option>
								</range>
							</constraint>              
							<constraint name="IP">
								<range type="xs:string" facet="true">
									<element ns="" name="UserIP"/>
									<facet-option>frequency-order</facet-option>
									<facet-option>descending</facet-option>
								</range>
							</constraint>  
							<constraint name="UserType">
								<range type="xs:string" facet="true">
									<element ns="" name="UserType"/>
									<facet-option>frequency-order</facet-option>
									<facet-option>descending</facet-option>
								</range>
							</constraint> 
							<constraint name="Device">
								<range type="xs:string" facet="true">
									<element ns="" name="Device"/>
									<facet-option>frequency-order</facet-option>
									<facet-option>descending</facet-option>
								</range>
							</constraint>
							<constraint name="AccountType">
								<range type="xs:string" facet="true">
									<element ns="" name="AccountType"/>
									<facet-option>frequency-order</facet-option>
									<facet-option>descending</facet-option>
								</range>
							</constraint>
							<constraint name="CID">
								<range type="xs:string" facet="true">
									<element ns="" name="CorporateAccountID"/>
									<facet-option>frequency-order</facet-option>
									<facet-option>descending</facet-option>
								</range>
							</constraint>              
							<constraint name="ActivityDate">
									<range type="xs:date" facet="true">
										<element ns="" name="ActivityDate"/>
										<facet-option>frequency-order</facet-option>
										<facet-option>descending</facet-option>
										<computed-bucket name="today" ge="P0D" lt="P1D" anchor="start-of-day">Today</computed-bucket>
										<computed-bucket name="yesterday" ge="-P1D" lt="P0D" anchor="start-of-day">yesterday</computed-bucket>
										<computed-bucket name="30-days" ge="-P30D" lt="-P1D" anchor="start-of-day">0-30</computed-bucket>
										<computed-bucket name="60-days" ge="-P60D" lt="-P30D" anchor="start-of-day">31-60</computed-bucket>
										<computed-bucket name="90-days" ge="-P90D" lt="-P60D" anchor="start-of-day">61-90</computed-bucket>
										<computed-bucket name="120-days" ge="-P120D" lt="-P90D" anchor="start-of-day">91-120</computed-bucket>
										<computed-bucket name="year" ge="-P1Y" lt="P1D" anchor="now">Last Year</computed-bucket>
									</range>
							</constraint>
							<constraint name="ChannelId">
								<range type="xs:string" facet="true">
									<facet-option>frequency-order</facet-option>
									<facet-option>descending</facet-option>
								 <path-index>AdditionalInfo/NameValue[Name='ChannelId']/Value</path-index>
								</range>
							</constraint>
							<constraint name="SubscriptionType">
								<range type="xs:string" facet="true">
									<facet-option>frequency-order</facet-option>
									<facet-option>descending</facet-option>
								 <path-index>AdditionalInfo/NameValue[Name='SubscriptionType']/Value</path-index>
								</range>
							</constraint> 
							<additional-query>
									{
									  cts:and-query((
													  cts:element-range-query(xs:QName("ActivityDate"), ">=", $StartDate),
													  cts:element-range-query(xs:QName("ActivityDate"), "<=",$EndDate)
												   ))
									}
							</additional-query>
							{
							if($TextToSearch!='')
							then
								<additional-query>
									{
										cts:or-query((
												for $EachTitle in cts:value-match(cts:path-reference('AdditionalInfo/NameValue[Name="VideoTitle"]/Value'), fn:concat('*',$TextToSearch,'*'))
												return cts:word-query($EachTitle, ("case-insensitive", "wildcarded", "stemmed", "diacritic-insensitive", "punctuation-insensitive"))
											))
									}
								</additional-query>
							else ()
							}
						</options>
	let $SearchResponse 	:=  search:search($TermToSearch, $SearchOption, $Start)
	let $TotalVideoRecord 	:=  data($SearchResponse/@total)
	let $ActivityChunks 	:=  for $Record in $SearchResponse
							    let $ActivityXml := fn:doc(data($Record/search:result/@uri))
								return $ActivityXml
	let $GetActionFacets :=	<Action>
								  {
									let $Result := for $EachFacet in $SearchResponse/search:facet[@name="Action"]/search:facet-value
													return <ActionType frequency="{fn:data($EachFacet/@count)}" type="{fn:data($EachFacet/@name)}">{fn:data($EachFacet/@name)}</ActionType>
									for $EachAction in tokenize($Actions,',')
									order by $EachAction
									return if($Result[@type=$EachAction]) then $Result[@type=$EachAction] else <ActionType frequency="0" type="{$EachAction}">{$EachAction}</ActionType>
								  }
								</Action>
	let $GetMonthFacets :=  <Month>
							  {
								for $EachFacet in $SearchResponse/search:facet[@name="Month"]/search:facet-value
								return <facet frequency="{fn:data($EachFacet/@count)}">{$EachFacet/text()}</facet>
							  }
							</Month>	
	return
		<Month>
			<TotalRecord>{$TotalVideoRecord}</TotalRecord>
			{$GetActionFacets}
		</Month> 
};