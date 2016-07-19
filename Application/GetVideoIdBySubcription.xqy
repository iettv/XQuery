xquery version "1.0-ml";
declare namespace html = "http://www.w3.org/1999/xhtml";
import module namespace constants = "http://www.TheIET.org/constants"   at "/Utils/constants.xqy";
(: 
XQuery Name : GetVideoIdBySubcription.xqy
Purpose : To Get VideoIds based on Subscription details.
Input Parameter :<Video>
                            <Channel>
                      <ChannelId>2209</ChannelId><CatalogueStartYear>2014</CatalogueStartYear><CatalogueEndYear>2015</CatalogueEndYear>
                      </Channel><Channel>
                      <ChannelId>2206</ChannelId><CatalogueStartYear>2012</CatalogueStartYear><CatalogueEndYear>2015</CatalogueEndYear> 
                            </Channel>
                            <ModifiedDateFilter>2015-03-24T00:00:00</ModifiedDateFilter>
                            <AccountId>1234</AccountId>
                            </Video>
                          :)
declare variable $inputSearchDetails as xs:string external; 
let $inputSearchDetails :=xdmp:unquote($inputSearchDetails)   
let $ModifiedDateFilter :=xs:dateTime($inputSearchDetails/Video/ModifiedDateFilter/text())
let $AccountId :=$inputSearchDetails/Video/AccountId
let $FinalResult := for $Subscription in $inputSearchDetails//Channel
          
                      let $ChannelId := $Subscription/ChannelId
                      let $CatalogueStartYear :=$Subscription/CatalogueStartYear/text() 
                      let $CatalogueEndYear :=$Subscription/CatalogueEndYear/text()
                      
                      
                      let $CatalogueStartYear :=xs:dateTime(fn:concat($CatalogueStartYear,"-01-01T00:00:00"))
                      let $CatalogueEndYear :=xs:dateTime(fn:concat($CatalogueEndYear,"-12-31T00:00:00"))
                      let $VideoIds := 
                                          
                                            for $EachVideo in cts:search(fn:collection($constants:PCOPY)/Video[not(BasicInfo/ChannelMapping/Channel/@ID = $constants:StaffChannelXml/Channels/Channel)]
                                                                              [not(BasicInfo/ChannelMapping/Channel/@ID = $constants:MasterChannelXml/Channels/Channel[Status='Inactive']/ID)]
                                                                              [AdvanceInfo/PermissionDetails/Permission[@type eq "HideRecord" and @status eq "no"]]
                                                                              ,
                                                                cts:and-query((cts:path-range-query("ChannelMapping/Channel/@ID","=",$ChannelId),
                                                                    
                                                                    cts:and-query((
                                                                        cts:and-query((
                                                                          cts:element-range-query(xs:QName("FinalStartDate"), ">=",$CatalogueStartYear),
                                                                          cts:element-range-query(xs:QName("FinalStartDate"), "<=",$CatalogueEndYear)
                                                                               )),
                                                                        cts:element-range-query(xs:QName("FinalStartDate"), "!=",xs:dateTime("1900-01-01T00:00:00.0000"))
                                                                        
                                                                            )),
                                                                    if ($ModifiedDateFilter!=xs:dateTime("1900-01-01T00:00:00")) 
                                                                      then
                                                                        cts:and-query((
                                                                                      cts:path-range-query("ModifiedInfo/Date", ">=", $ModifiedDateFilter)
                                                                                      
                                                                                     ))
                                                                    else ()
                                                                        
                                                                    ))
                                                          )
                                            return <VideoID>{fn:data($EachVideo/@ID)}</VideoID>

                          return $VideoIds
        return <Videos>{$FinalResult}</Videos>
                          