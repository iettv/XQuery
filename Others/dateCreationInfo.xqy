(:
This script is to fix DateTime format of CrationInfo Date
	23-06-2015 17:33:46 === 2015-06-23T17:33:46
	23/06/2015 17:33:46 === 2015-06-23T17:33:46
:)

for $CreationInfo in /Video/CreationInfo[Date[contains(.,' ')]]
let $Year := substring($CreationInfo/Date,7,4)
let $Month := substring($CreationInfo/Date,4,2)
let $Date := substring($CreationInfo/Date,1,2)
let $Hour := substring($CreationInfo/Date,12,2)
let $Minute := substring($CreationInfo/Date,15,2)
let $Second := substring($CreationInfo/Date,18,2)
return xdmp:node-replace($CreationInfo/Date,<Date>{xs:dateTime(concat($Year,'-',$Month,'-',$Date,'T',$Hour,':',$Minute,':',$Second))}</Date>)



