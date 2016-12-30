xquery version "1.0-ml";

declare variable $inputSearchDetails as xs:string external ;

(:let $inputSearchDetails := "<AccontActivity>
                               <AccountID>-1</AccountID>
                               <AccountType>Unknown Status</AccountType>
                            </AccontActivity>":)

let $input := xdmp:unquote($inputSearchDetails)

let $AccountID := $input/AccontActivity/AccountID/text()
let $AccountType := $input/AccontActivity/AccountType/text()

let $count_account := count(/Activity/Actor[CorporateAccountID/text()=$AccountID][AccountType/text()=$AccountType])

return 

if ($count_account ge 1)
then (
       xdmp:log(concat("[ IET-TV ][ Activity Count By Account ID ][ Info ][ Successful ]")),
       "Success"
     )
else (
       xdmp:log(concat("[ IET-TV ][ Activity Count By Account ID ][ Info ][ Failed ]")),
       "Failure"
     )
