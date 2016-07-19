xquery version "1.0-ml";

for $i in doc()/Activity//NameValue[matches(Name/text(),'Duration')]/Value[string-length(text()) = 5]
let $a := $i/base-uri()
return ($a, xdmp:node-replace($i, <Value>{concat('00:',$i)}</Value>))