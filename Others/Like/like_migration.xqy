import module namespace constants     = "http://www.TheIET.org/constants"      at "/Utils/constants.xqy"; 

for $Video in data(collection("PublishedCopy")/Video/@ID)
let $Like := count(doc(concat('/Action/', $Video, $constants:SUF_ACTION,'.xml'))/VideoAction/User/Action[.='Like'])
let $PHistoryUri := fn:concat($constants:PCOPY_DIRECTORY,$Video,".xml")
return xdmp:node-insert-child(doc($PHistoryUri)/Video,  <LikeCount>{if($Like) then $Like else 0}</LikeCount>)