xquery version "1.0-ml";

import module namespace constants = "http://www.TheIET.org/constants"   at "/Utils/constants.xqy";

for $Video in /Video
let $VideoUri := xdmp:node-uri($Video)
return try{xdmp:node-delete(doc($VideoUri)/Video/VideoNumber)} catch($e){}