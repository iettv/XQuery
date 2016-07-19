xquery version "1.0-ml";

module namespace common = "http://www.TheIET.org/common";

import module namespace json = "http://marklogic.com/xdmp/json"   at  "/MarkLogic/json/json.xqy";

declare function ConvertToJson( $XML )
{
let $custom := let $config := json:config("custom")
               return 
                 (
                  map:put( $config, "whitespace", "ignore" ),
				  map:put( $config, "array-element-names", "Video" ),
                  $config
                 )
return
	json:transform-to-json($XML,$custom)
};
