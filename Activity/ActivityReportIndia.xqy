xquery version "1.0-ml";

declare variable $inputSearchDetails as xs:string external ;

declare function local:RangeDateData($DateType as xs:string,$StartDate as xs:date,$EndDate as xs:date)
{
        let $data :=  cts:and-query((
                                    cts:element-range-query(xs:QName($DateType), ">=", xs:date($StartDate)),
                                    cts:element-range-query(xs:QName($DateType), "<=", xs:date($EndDate))) )
        return $data									
}; 

(:let $inputSearchDetails := "<Activity>
	<FromDate>2015-01-18</FromDate>
	<ToDate>2016-09-18</ToDate>
  <Value>Single</Value>
	<AccountTypes>
		<AccountType>Individual</AccountType>
	</AccountTypes>
</Activity>
" :)


 (:let $inputSearchDetails := "<Activity>
	<FromDate>2016-01-22</FromDate>
	<ToDate>2016-08-22</ToDate>
	<Value>Double</Value>
	<AccountTypes>
		<AccountType>Institution</AccountType>
	</AccountTypes>
	<CorporateAccountIDs>
		<CorporateAccountID>421048</CorporateAccountID>
	</CorporateAccountIDs>
	<CountryCode>IND</CountryCode>
</Activity>" :)



(: let $inputSearchDetails := "<Activity>
	<FromDate>2016-01-22</FromDate>
	<ToDate>2016-08-22</ToDate>
	<Value>All</Value>
	<AccountTypes>
		<AccountType1>Corporate</AccountType1>
		<AccountType2>Institution</AccountType2>
		<AccountType3>Individual</AccountType3>
		<AccountType4>Unknown Status</AccountType4>
	</AccountTypes>
</Activity>" :)

(:let $inputSearchDetails := "<Activity>
                            <FromDate>2016-01-22</FromDate>
                            <ToDate>2016-08-22</ToDate>
                            <Value></Value>
                            <AccountTypes>
                              <AccountType1>Corporate</AccountType1>
                              <AccountType2>Institution</AccountType2>
                              <AccountType3>Individual</AccountType3>
                              <AccountType4>Unknown Status</AccountType4>
                            </AccountTypes>
                          </Activity>":)
let $input := xdmp:unquote($inputSearchDetails)
let $AccountType := $input/Activity/AccountTypes/AccountType/text()
let $AccountType1 := $input/Activity/AccountTypes/AccountType1/text()
let $AccountType2 := $input/Activity/AccountTypes/AccountType2/text()
let $AccountType3 := $input/Activity/AccountTypes/AccountType3/text()
let $AccountType4 := $input/Activity/AccountTypes/AccountType4/text()
let $CorporateAccountIDs := $input/Activity/CorporateAccountIDs/CorporateAccountID/text()
let $Value := $input/Activity/Value/text()
let $StartDate := xs:date($input/Activity/FromDate/text())
let $EndDate := xs:date($input/Activity/ToDate/text())

return 
        if(not($Value))
          then
            (
              xdmp:log(concat("[ IET-TV ][ Activity Report India ][ Info ][ Valid Element Is Empty ]"))
              ,
              "ERROR! Please provide content in Value element. Currently it is empty."
            )
        else
            let $ResultData :=  (
                    (xdmp:log("[ IET-TV ][ Activity Report India ][ Report Creation Started ]")),
                    (if ($Value='Single')
                    then (cts:search(doc()[/Activity[((Action/Type/text()='View' or Action/Type/text()='Play' or Action/Type/text()='Download') and (Actor[AccountType/text()=$AccountType]))]],local:RangeDateData("ActivityDate",$StartDate,$EndDate)))
                    else if ($Value='Double')
                    then (cts:search(doc()[/Activity[((Action/Type/text()='View' or Action/Type/text()='Play' or Action/Type/text()='Download') and (Actor[AccountType/text()=$AccountType and CorporateAccountID/text()=$CorporateAccountIDs]))]],local:RangeDateData("ActivityDate",$StartDate,$EndDate)))
                    else if ($Value='All')
                    then (cts:search(doc()[/Activity[((Action/Type/text()='View' or Action/Type/text()='Play' or Action/Type/text()='Download') and (Actor[AccountType/text()=$AccountType1 or AccountType/text()=$AccountType2 or
                    AccountType/text()=$AccountType3 or AccountType/text()=$AccountType4]))]],local:RangeDateData("ActivityDate",$StartDate,$EndDate)))
                    else ())
                    )

            let $AllFiles := <root>{$ResultData}</root>

            let $Records :=
                  <root>
                  {
                  for $Activity in $AllFiles/Activity
                  
                  let $EntityID := $Activity/EntityID/text()
                  let $Action := $Activity/Action/Type/text()
                  let $AccountID := $Activity/Actor/CorporateAccountID/text()
                  let $UserIP := $Activity/Actor/UserIP/text()
                  let $UserID := $Activity/Actor/UserID/text()
                  let $UserName := $Activity/Actor/UserName/text()
                  let $Video_Title := $Activity/Action/AdditionalInfo/NameValue[Name/text()='VideoTitle']/Value/text()
                  let $Video_Type := $Activity/Action/AdditionalInfo/NameValue[Name/text()='VideoType']/Value/text()
                  let $Subscription_Type := $Activity/Action/AdditionalInfo/NameValue[Name/text()='SubscriptionType']/Value/text()
                  let $ActivityDate := $Activity/ActivityDate/text()
                  
                  return
                  <record>
                      <EntityID>{$EntityID}</EntityID>
                      <Action>{$Action}</Action>
                      <UserIP>{$UserIP}</UserIP>
                      <UserID>{$UserID}</UserID>
                      <UserName>{$UserName}</UserName>
                      <AccountID>{$AccountID}</AccountID>
                      <VideoTitle>{$Video_Title}</VideoTitle>
                      <VideoType>{$Video_Type}</VideoType>
                      <ActivityDate>{$ActivityDate}</ActivityDate>
                      <SubscriptionType>{$Subscription_Type}</SubscriptionType>
                  </record>
                  }
                  </root>

            let $StructuredXml := 
                        <root>
                        {
                               for $record in $Records/record
                                       
                                       let $Entity_ID := $record/EntityID/text()
                                       let $ViewCount := count($Records//record/EntityID[text()=$Entity_ID and following-sibling::Action[text()='View']])
                                       let $PlayCount := count($Records//record/EntityID[text()=$Entity_ID and following-sibling::Action[text()='Play']])
                                       let $DownloadCount := count($Records//record/EntityID[text()=$Entity_ID and following-sibling::Action[text()='Download']])
                                       let $Action := $record/Action/text()
                                       let $UserIP := $record/UserIP/text()
                                       let $UserID := $record/UserID/text()
                                       let $UserName := $record/UserName/text()
                                       let $AccountID := $record/AccountID/text()
                                       let $VideoTitle := $record/VideoTitle/text()
                                       let $VideoType := $record/VideoType/text()
                                       let $ActivityDate := $record/ActivityDate/text()
                                       let $SubscriptionType := $record/SubscriptionType/text()
                                return
                        <record>
                            <EntityID>{$Entity_ID}</EntityID>
                            <ViewCount>{$ViewCount}</ViewCount>
                            <PlayCount>{$PlayCount}</PlayCount>
                            <DownloadCount>{$DownloadCount}</DownloadCount>
                            <UserIP>{$UserIP}</UserIP>
                            <UserID>{$UserID}</UserID>
                            <UserName>{$UserName}</UserName>
                            <Action>{$Action}</Action>
                            <AccountID>{$AccountID}</AccountID>
                            <VideoTitle>{$VideoTitle}</VideoTitle>
                            <VideoType>{$VideoType}</VideoType>
                            <ActivityDate>{$ActivityDate}</ActivityDate>
                            <SubscriptionType>{$SubscriptionType}</SubscriptionType>
                        </record>
                        }
                        </root>

               let $GroupingXml := 
                    <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                        xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs fn"
                        xmlns:fn="http://www.w3.org/2005/xpath-functions" version="2.0">
                    
                        <xsl:output method="xml" indent="yes"/>
                        
                        <xsl:template match="root">
                            <result>
                                <xsl:for-each-group select="record" group-by="EntityID">
                                    <record>
                                        <EntityID>
                                            <xsl:value-of select="EntityID"/>
                                        </EntityID>
                                                <xsl:for-each
                                                    select="../record/ActivityDate[../EntityID=fn:current-grouping-key()]">
                                                    <Date>
                                                        <value>
                                                            <xsl:value-of select="../ActivityDate"/>
                                                        </value>
                                                        <xsl:copy-of select="../AccountID"/>
                                                        <xsl:copy-of select="../VideoTitle"/>
                                                        <xsl:copy-of select="../VideoType"/>
                                                        <xsl:copy-of select="../SubscriptionType"/>
                                                        <xsl:copy-of select="../UserIP"/>
                                                        <xsl:copy-of select="../UserID"/>
                                                        <xsl:copy-of select="../UserName"/>
                                                        <xsl:copy-of select="../ViewCount"/>
                                                        <xsl:copy-of select="../PlayCount"/>
                                                        <xsl:copy-of select="../DownloadCount"/>
                                                    </Date>
                                                </xsl:for-each>
                                    </record>
                                </xsl:for-each-group>
                            </result>
                        </xsl:template>
                    
                    </xsl:stylesheet>

            let $GroupStructuredXml :=  xdmp:xslt-eval($GroupingXml,$StructuredXml)

            let $GroupStructuredXsl := 
                        <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                            xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs fn"
                            xmlns:fn="http://www.w3.org/2005/xpath-functions" version="2.0">
                            
                            <xsl:output method="xml" indent="yes"/>
                            
                            <xsl:template match="result">
                                <Root>
                                    <xsl:apply-templates/>
                                </Root>
                            </xsl:template>
                            
                            <xsl:template match="record">
                                <xsl:copy>
                                    <xsl:copy-of select="EntityID"/>
                                    <xsl:variable name="DateSort">
                                        <Root>
                                            <xsl:for-each select="Date">
                                                <xsl:sort select="value"/>
                                                <xsl:copy-of select="."/>
                                            </xsl:for-each>
                                        </Root>
                                    </xsl:variable>
                                    <xsl:copy-of select="$DateSort/Root/Date[fn:last()]/node()/."/>
                                </xsl:copy>
                            </xsl:template>
                            
                        </xsl:stylesheet>
                        
            let $ActivityIndiaReport := xdmp:xslt-eval($GroupStructuredXsl,$GroupStructuredXml) 
            return
                    (
                      ($ActivityIndiaReport),
                      (xdmp:log("[ IET-TV ][ Activity Report India ][ Report Creation End ][ Successfully Result Sent ]"))
                     )
