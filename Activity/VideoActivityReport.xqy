xquery version "1.0-ml";

module namespace VideoActivityReport = "http://www.TheIET.org/VideoActivityReport";
import module namespace search     = "http://marklogic.com/appservices/search" at "/MarkLogic/appservices/search/search.xqy";

declare function GetVideoActivityReport($TermToSearch as xs:string, $StartDate as xs:date, $EndDate as xs:date, $PageLength as xs:integer, $StartPage as xs:integer) as item()
{
	let $Start := $StartPage
	let $SearchOption := <options xmlns="http://marklogic.com/appservices/search">
							<term>
								<term-option>case-insensitive</term-option>
								<term-option>diacritic-insensitive</term-option>
								<term-option>punctuation-insensitive</term-option>
							</term>
							<additional-query>
									{
									  cts:and-query((
													  cts:element-range-query(xs:QName("ActivityDate"), ">=", $StartDate),
													  cts:element-range-query(xs:QName("ActivityDate"), "<=",$EndDate)
												   ))
									}
							</additional-query>
							<additional-query>{cts:collection-query("Admin")}</additional-query>
							<constraint name="UserName">
								<range type="xs:string" facet="true">
									<element ns="" name="UserName"/>
									<term-option>case-insensitive</term-option>
									<facet-option>frequency-order</facet-option>
									<facet-option>descending</facet-option>
								</range>
							</constraint> 
							<constraint name="UserID">
								<range type="xs:string" facet="true">
									<element ns="" name="UserID"/>
									<term-option>case-insensitive</term-option>
									<facet-option>frequency-order</facet-option>
									<facet-option>descending</facet-option>
								</range>
							</constraint>
							<constraint name="VideoID">
								<range type="xs:string" facet="true">
									<element ns="" name="EntityID"/>
									<term-option>case-insensitive</term-option>
									<facet-option>frequency-order</facet-option>
									<facet-option>descending</facet-option>
								</range>
							</constraint>
							<constraint name="Type">
								<range type="xs:string" facet="true">
									<element ns="" name="Type"/>
									<term-option>case-insensitive</term-option>
									<facet-option>frequency-order</facet-option>
									<facet-option>descending</facet-option>
								</range>
							</constraint>  
							<constraint name="PriceType">
								<range type="xs:string" facet="true">
									<facet-option>frequency-order</facet-option>
									<facet-option>descending</facet-option>
								 <path-index>AdditionalInfo/NameValue[Name='PriceTypeName']/Value</path-index>
								</range>
							</constraint>
						</options>
	let $SearchResponse 		:=  search:search($TermToSearch, $SearchOption, $Start, $PageLength)
	let $TotalVideoRecord 		:= data($SearchResponse/@total)
	let $ActivityChunks 		:= 	for $Record in data($SearchResponse//search:result/@uri)
									let $eachUri := fn:doc($Record)
									return
									(									
									<Activity>
										<VideoID>{$eachUri/Activity/EntityID/text()}</VideoID>
										<UserName>{$eachUri/Activity/Actor/UserName/text()}</UserName>
										<Title>{$eachUri/Activity/Action/AdditionalInfo/NameValue[Name="VideoTitle"]/Value/text()}</Title>
										<VideoMode>{$eachUri/Activity/Action/AdditionalInfo/NameValue[Name="VideoMode"]/Value/text()}</VideoMode>
										<SubType>{$eachUri/Activity/Action/AdditionalInfo/NameValue[Name="SubType"]/Value/text()}</SubType>
										<ActivityName>{$eachUri/Activity/Action/Type/text()}</ActivityName>
										<ActivityDate>{$eachUri/Activity//ActivityDate/text()}</ActivityDate>
										<UserIP>{$eachUri/Activity/Actor/UserIP/text()}</UserIP>
										<PriceType>{$eachUri/Activity/Action/AdditionalInfo/NameValue[Name="PriceTypeName"]/Value/text()}</PriceType>
										<ActivityID>{$eachUri/Activity/ID/text()}</ActivityID>
										<ActivityTime>{$eachUri/Activity//ActivityTime/text()}</ActivityTime>
										<AdditionalInfo>{$eachUri/Activity/Action/AdditionalInfo/*}</AdditionalInfo>
									</Activity>
									)
	return
		<Result>
			<TotalRecord>{$TotalVideoRecord}</TotalRecord>
			<Activities>{$ActivityChunks}</Activities>
		</Result>
};