xquery version "1.0-ml";

import module namespace  functx = "http://www.functx.com" at "/MarkLogic/functx/functx-1.0-nodoc-2007-01.xqy";
import module namespace admin     = 'http://marklogic.com/xdmp/admin'   at '/MarkLogic/admin.xqy';  

declare function local:GetXMLFile($Video_ID as xs:string)
{
	let $Config 		:= admin:get-configuration()
                          let $CurrentDBName  := admin:database-get-name($Config, xdmp:database("IETTV-Database"))
                          let $VideoFile 	:= xdmp:eval("xquery version '1.0-ml';
                                              import module namespace admin     = 'http://marklogic.com/xdmp/admin'   at '/MarkLogic/admin.xqy';
                                              declare variable $Video_ID as xs:string external;
                                              doc(concat('/Video/',$Video_ID,'.xml'))/Video[matches(@ID,$Video_ID)]"
                                              , 
                                              (xs:QName("Video_ID"), $Video_ID),
                                              <options xmlns="xdmp:eval">
                                                <database>{xdmp:database("IETTV-Database")}</database>
                                              </options>)
                                              
                                              return $VideoFile
											
};

for $i in (/Activity[//Action/AdditionalInfo/NameValue[matches(Name,'VideoTitle')]/Value[.='']])[1 to 650]
let $file_uri := $i/base-uri()
let $Video_ID := $i//EntityID/string() 

let $GetMasterXML := local:GetXMLFile($Video_ID)

let $FetchTitle := $GetMasterXML//BasicInfo/Title/string()
let $EmbedTitle := xdmp:node-replace($i//Action/AdditionalInfo/NameValue[matches(Name,'VideoTitle')]/Value, <Value>{$FetchTitle}</Value>)

return if($GetMasterXML//BasicInfo/Title/string())
       then (xdmp:log(concat("Appended the Video Title value from the master database.  The base uri is  : ", $file_uri)))
       else (xdmp:log(concat("Not Appended the Video Title value from the master database.  The base uri is  : ", $file_uri)))
       
       
