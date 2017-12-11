xquery version "1.0-ml";

import module namespace REPORTS   = "http://www.TheIET.org/ManageReports"   at  "/Utils/ManageReports.xqy";

(: <Videos><VideoID>a4ba4a0c-9eaf-4088-bd0d-54a0c534bcd9</VideoID><VideoID>a9a2a965-ab2e-4fb3-95b0-7ce124b02610</VideoID></Videos> :)

declare variable $inputSearchDetails as xs:string external ;
let $VideoXML := REPORTS:GetVideoByVideoIDs($inputSearchDetails)
return <Videos>{$VideoXML}</Videos>
