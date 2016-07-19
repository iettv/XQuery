(: script to generate an xml on ML database to track parsed videos :)

(: XmL Creation <XMLMigration><Video><VID>1</VID><Result>|Pass|Fail</Result><Sent>Yes|No</Sent></Video> :)
import module namespace constants = "http://www.TheIET.org/constants" at "/Utils/constants.xqy";

let $XmlChunk := for $Video in collection($constants:PCOPY)
                  return  <Video><VID>{data($Video/Video/@ID)}</VID><Result></Result><Sent>No</Sent></Video>
return xdmp:document-insert($constants:MURI,<XMLMigration>{$XmlChunk}</XMLMigration>)

===================================================================================================

