for $EachVideo in xdmp:directory("/PCopy/")
let $Uri := xdmp:node-uri($EachVideo)
let $Speakers := for $Speakers in $EachVideo/Video/Speakers/Person
                 return <Speaker>{normalize-space(fn:concat($Speakers/Title/text(), ' ', $Speakers/Name/Given-Name/text(), ' ', $Speakers/Name/Surname/text()))}</Speaker>
return xdmp:document-set-properties($Uri, <Speakers>{$Speakers}</Speakers>)

