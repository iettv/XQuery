import module namespace constants  = "http://www.TheIET.org/constants"  at "/Utils/constants.xqy";

let $StaffChannel := <Channels><Channel>2148</Channel></Channels>
return xdmp:document-insert($constants:StaffChannelUri, $StaffChannel)