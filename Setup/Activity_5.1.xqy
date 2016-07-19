xquery version "1.0-ml";
import module namespace admin = "http://marklogic.com/xdmp/admin" at "/MarkLogic/admin.xqy";

declare function local:createPathRangeIndex($config as element(configuration), $server-config as element(http-server), $group-name as xs:string)
{
	let $dbid := xdmp:database(fn:data($server-config/database))
	let $PriceTypeName := let $Index :=admin:database-range-path-index($dbid,"string","AdditionalInfo/NameValue[Name='PriceTypeName']/Value","http://marklogic.com/collation/",fn:false(),"ignore") return admin:save-configuration(admin:database-add-range-path-index($config, $dbid, $Index))
	return "DONE"
};

(: Start Value set - Change all below values before execution ************************** :)
let $DBNAME := "IETTV-Activity-Database"
let $DBFORESTNAME := "IETTV-Activity-Forest"
let $MODULESDBNAME := "IETTV-Activity-Modules-Database"
let $MODULESFORESTNAME := "IETTV-Activity-Modules-Forest"
let $SECURITY_DBNAME := "Security"
let $SCHEMA_DBNAME := "Schemas"
let $HttpPort := 9506
let $HttpService := "IETTV-Activity-HTTP-Server"
let $server-config-http :=  <http-server><name>{$HttpService}</name><port>{$HttpPort}</port><root>/</root><modules>{$MODULESDBNAME}</modules><database>{$DBNAME}</database></http-server>


(: Get and set the configurations :)
let $config := admin:get-configuration()
let $config := local:createPathRangeIndex($config, $server-config-http, "Default")

return "Activity Database Path Range Indexes created"