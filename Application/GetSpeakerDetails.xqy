xquery version "1.0-ml";

declare variable $inputSearchDetails as xs:string external ;

declare function local:RangeDateData($DateType as xs:string,$StartDate as xs:dateTime,$EndDate as xs:dateTime)
{
        let $data :=  cts:and-query((
                                    cts:element-range-query(xs:QName($DateType), ">=", xs:dateTime($StartDate)),
                                    cts:element-range-query(xs:QName($DateType), "<=", xs:dateTime($EndDate))) )
        return $data									
}; 

(:let $inputSearchDetails := "<root>
    <DateType>FinalPublishDate</DateType> 
    <StartDate>2013-10-16T00:00:00.0000</StartDate> 
    <EndDate>2013-10-16T00:00:00.0000</EndDate> 
</root>":)

let $input := xdmp:unquote($inputSearchDetails)

let $DateType := $input/root/DateType/text()

let $StartDate := xs:dateTime($input/root/StartDate/text())

let $EndDate := xs:dateTime($input/root/EndDate/text())

let $ResultData :=  if($DateType="VideoCreatedDate")
                    then (
                            cts:search(doc()/Video[contains(base-uri(),'/PCopy/')][//VideoCreatedDate[text()!='']],local:RangeDateData("VideoCreatedDate",$StartDate,$EndDate))
                          )
                    else if($DateType="VideoUploadDate")
                    then (
                            cts:search(doc()/Video[contains(base-uri(),'/PCopy/')][//UploadVideo/File/UploadDate[text()!='']],local:RangeDateData("UploadDate",$StartDate,$EndDate))
                          )
                    else if($DateType="FinalPublishDate")
                    then (
                            cts:search(doc()/Video[contains(base-uri(),'/PCopy/')][//PublishInfo/VideoPublish[@active='yes']],
                            cts:or-query(( local:RangeDateData("FinalStartDate",$StartDate,$EndDate),
                            local:RangeDateData("RecordStartDate",$StartDate,$EndDate)
                            )))
                        ) 
                    else if($DateType="FinalPublishDate")
                    then (
                            cts:search(doc()/Video[contains(base-uri(),'/PCopy/')][//PublishInfo/LivePublish[@active='yes']],
                            cts:or-query(( local:RangeDateData("LiveFinalStartDate",$StartDate,$EndDate),
                            local:RangeDateData("LiveRecordStartDate",$StartDate,$EndDate)
                            )))
                        ) 
                     
                    else if($DateType="RecordCreatedDate")
                    then (
                            cts:search(doc()[contains(base-uri(),'/PCopy/')][contains(//CreationInfo/Date,'T')],cts:or-query((
                            cts:and-query((
                                    cts:path-range-query("ModifiedInfo/Date", ">=", xs:dateTime($StartDate)),
                                    cts:path-range-query("ModifiedInfo/Date", "<=", xs:dateTime($EndDate))) ),
                            cts:and-query((
                                    cts:path-range-query("CreationInfo/Date", ">=", xs:dateTime($StartDate)),
                                    cts:path-range-query("CreationInfo/Date", "<=", xs:dateTime($EndDate))) )
                            )))
                        ) 
                    
                    else ()


let $AllFiles := <root>{$ResultData}</root>

return
<root>
{
for $Video in $AllFiles/Video

let $VideoID := $Video/@ID/string()
let $VideoNumber := $Video//VideoNumber/text()

let $Person := for $i in $Video//Speakers/Person
               let $FirstName := $i/Name/Given-Name/text()
               let $LastName := $i//Name/Surname/text()
			   let $CompanyName := $i//Affiliations/Affiliation/Organization/OrganizationName/text()
               let $Biography := $Video//Speakers/Person[1]/Biography/text()
               return 
               <record>
                      <VideoID>{$VideoID}</VideoID>
                      <VideoNumber>{$VideoNumber}</VideoNumber>
                      <FirstName>{$FirstName}</FirstName>
                      <LastName>{$LastName}</LastName>
					  <CompanyName>{$CompanyName}</CompanyName>
                      <Biography>{$Biography}</Biography>
              </record>

return $Person

}
</root>
