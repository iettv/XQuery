import module namespace  functx = "http://www.functx.com" at "/MarkLogic/functx/functx-1.0-nodoc-2007-01.xqy";
import module namespace admin     = 'http://marklogic.com/xdmp/admin'   at '/MarkLogic/admin.xqy';  
import module namespace mem       = "http://xqdev.com/in-mem-update"     at  "/MarkLogic/appservices/utils/in-mem-update.xqy";

declare variable $inputSearchDetails as xs:string external ;

declare function local:GetXMLFile($Video_ID as xs:string)
{
	let $Config 		:= admin:get-configuration()
                          let $CurrentDBName  := admin:database-get-name($Config, xdmp:database("IETTV-Database"))
                          let $VideoFile 	:= xdmp:eval("xquery version '1.0-ml';
                                              import module namespace admin     = 'http://marklogic.com/xdmp/admin'   at '/MarkLogic/admin.xqy';
                                              declare variable $Video_ID as xs:string external;
                                              doc(concat('/PCopy/',$Video_ID,'.xml'))/Video[matches(@ID,$Video_ID)]"
                                              , 
                                              (xs:QName("Video_ID"), $Video_ID),
                                              <options xmlns="xdmp:eval">
                                                <database>{xdmp:database("IETTV-Database")}</database>
                                              </options>)
                                              
                                              return $VideoFile
											
};


 let $ActivityXML  	:= xdmp:unquote($inputSearchDetails) 
(:let $ActivityXML  	:= <Activity><ID>5ba5de4a-489e-4053-891e-418146c03230</ID><EntityID Type="VideoId">d1515fdb-925b-45a5-a6e8-c6101c99477d</EntityID><PlatformID>IET-TV</PlatformID><ActivityDate>2015-05-29</ActivityDate><ActivityTime>13:24:56</ActivityTime><Actor><ActorType>Unanonymous</ActorType><UserID>-1</UserID><UserName>Unknown Status</UserName><UserIP>192.168.2.110</UserIP><BrowserName>Chrome</BrowserName><BrowserVersion>43.0</BrowserVersion><Device>Desktop</Device><AccountType>Unknown Status</AccountType><CorporateAccountID>-1</CorporateAccountID><CorporateAccountName>Unknown Status</CorporateAccountName><UserType>Unknown Status</UserType></Actor><Action><Type>View</Type><SubType/><Details/><Description/><ActivityType>WebPortal</ActivityType><AdditionalInfo><NameValue><Name>VideoId</Name><Value>d1515fdb-925b-45a5-a6e8-c6101c99477d</Value></NameValue><NameValue><Name>VideoTitle</Name><Value>VideoTitle</Value></NameValue><NameValue><Name>ChannelId</Name><Value>0</Value></NameValue><NameValue><Name>ChannelName</Name><Value/></NameValue><NameValue><Name>SubscriptionType</Name><Value>SubscriptionType</Value></NameValue><NameValue><Name>Duration</Name><Value>Duration</Value></NameValue></AdditionalInfo></Action></Activity>:)
let $ActivityDate 	:= xs:date($ActivityXML/Activity/ActivityDate/string())
let $CurrentYear 	:= fn:year-from-date($ActivityDate)
let $CurrentMonth 	:= functx:month-name-en($ActivityDate)
let $CurrentQuarter := xdmp:quarter-from-date($ActivityDate)
let $ActionType 	:= $ActivityXML/Activity/Action/Type/string()
let $VideoID 		:= $ActivityXML/Activity/EntityID/string() 
let $Video_ID 		:= $ActivityXML//EntityID/string() 
let $ActivityID 	:= $ActivityXML/Activity/ID/string()
let $Channel 		:= let $IsChannel := $ActivityXML/Activity/Action/AdditionalInfo/NameValue[Name="ChannelId"]/Value/string()
						return if($IsChannel) then fn:concat("Channel-", $IsChannel) else ()
let $ActivityURI  	:= fn:concat("/",$CurrentYear,"/",$CurrentQuarter,"/",$CurrentMonth,"/",$ActionType,"/",$ActivityID,".xml")
let $platform 		:= $ActivityXML//PlatformID/string()
let $Type     		:= $ActivityXML//Action/ActivityType/string()

let $Title        := $ActivityXML//Action/AdditionalInfo/NameValue[matches(Name,'VideoTitle')]/Value
let $Duration        := $ActivityXML//Action/AdditionalInfo/NameValue[matches(Name,'Duration')]/Value
let $SubscriptionType        := $ActivityXML//Action/AdditionalInfo/NameValue[matches(Name,'SubscriptionType')]/Value

let $GetMasterXML := local:GetXMLFile($Video_ID)

let $FetchTitle := $GetMasterXML//BasicInfo/Title/string()
let $FetchDuration := $GetMasterXML//UploadVideo/File/Duration/string()
let $FetchSubscriptionType := $GetMasterXML//PricingDetails/@type/string()

let $EmbedTitle := mem:node-replace($ActivityXML//Action/AdditionalInfo/NameValue[matches(Name,'VideoTitle')]/Value, <Value>{$FetchTitle}</Value>)

let $UpdatedXML1   := if ($ActivityXML//Action/AdditionalInfo/NameValue[matches(Name,'VideoTitle')]/Value[.=''])
                     then ($EmbedTitle)
                     else ($ActivityXML)

let $EmbedDuration := mem:node-replace($UpdatedXML1//Action/AdditionalInfo/NameValue[matches(Name,'Duration')]/Value, <Value>{$FetchDuration}</Value>)

let $UpdatedXML2   := if ($UpdatedXML1//Action/AdditionalInfo/NameValue[matches(Name,'Duration')]/Value[.=''])
                     then ($EmbedDuration)
                     else ($UpdatedXML1)


let $EmbedSubscriptionType := mem:node-replace($UpdatedXML2//Action/AdditionalInfo/NameValue[matches(Name,'SubscriptionType')]/Value, <Value>{$FetchSubscriptionType}</Value>)

let $UpdatedXML3   := if ($UpdatedXML2//Action/AdditionalInfo/NameValue[matches(Name,'SubscriptionType')]/Value[.=''])
                     then ($EmbedSubscriptionType)
                     else ($UpdatedXML2)

return 
  
  try
    {(
        xdmp:document-insert($ActivityURI,$UpdatedXML3,(), ($VideoID, $Channel, $platform, $Type)),
        "SUCCESS",
        xdmp:log(concat("[ IET-TV ][ ActivityIngestion ][ SUCCESS ][ Activity has been logged successfully!!! URI : ",$ActivityURI, " ]"))
    )}
  catch($e)
    {(
        xdmp:log(concat("[ IET-TV ][ ActivityIngestion ][ ERROR ][ ",$ActivityID, " ]")),
        "ERROR"
    )}
    
