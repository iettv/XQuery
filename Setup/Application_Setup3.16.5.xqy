xquery version "1.0-ml";
import module namespace admin = "http://marklogic.com/xdmp/admin" at "/MarkLogic/admin.xqy";

declare function local:createElementRangeIndex($config as element(configuration), $server-config as element(http-server), $group-name as xs:string)
{
	let $dbid := xdmp:database(fn:data($server-config/database))
	let $LiveRecordStartDate := let $Index := admin:database-range-element-index("dateTime", "", "LiveRecordStartDate", "http://marklogic.com/collation/",fn:false()) return admin:save-configuration(admin:database-add-range-element-index($config, $dbid, $Index))
	let $LiveFinalStartDate  := let $Index := admin:database-range-element-index("dateTime", "", "LiveFinalStartDate", "http://marklogic.com/collation/",fn:false()) return admin:save-configuration(admin:database-add-range-element-index($config, $dbid, $Index))
	let $LiveFinalExpiryDate := let $Index := admin:database-range-element-index("dateTime", "", "LiveFinalExpiryDate", "http://marklogic.com/collation/",fn:false()) return admin:save-configuration(admin:database-add-range-element-index($config, $dbid, $Index))
	return "DONE"
};

(: Start Value set - Change all below values before execution ************************** :)
let $DBNAME := "IETTV-Database"
let $DBFORESTNAME := "IETTV-Forest"
let $MODULESDBNAME := "IETTV-Modules-Database"
let $MODULESFORESTNAME := "IETTVModules-Forest"
let $SECURITY_DBNAME := "Security"
let $SCHEMA_DBNAME := "Schemas"
let $HttpPort := 9503
let $HttpService := "IETTV-HTTP-Server"
let $server-config-http :=  <http-server><name>{$HttpService}</name><port>{$HttpPort}</port><root>/</root><modules>{$MODULESDBNAME}</modules><database>{$DBNAME}</database></http-server>
  
(: Get and set the configurations :)
let $config := admin:get-configuration()
let $config := local:createElementRangeIndex($config, $server-config-http, "Default")

return "Range Index created on Application Database"