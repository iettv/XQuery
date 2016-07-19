
import module namespace admin="http://marklogic.com/xdmp/admin" at "/MarkLogic/admin.xqy";

declare function local:createField( $config as element(configuration),$server-config as element(http-server))as element(configuration)
{
  let $dbid := xdmp:database(fn:data($server-config/database))
  let $fieldspec := admin:database-path-field("VideoTitle",admin:database-field-path("/Video/BasicInfo/Title", 1.0))
  return admin:database-add-field($config, $dbid, $fieldspec)
};

declare function local:createFieldRangeIndex( $config as element(configuration), $server-config as element(http-server))as element(configuration)
{
  let $dbid := xdmp:database(fn:data($server-config/database))
  let $rangespec := admin:database-range-field-index("string","VideoTitle","http://marklogic.com/collation/",fn:false())
  return admin:database-add-range-field-index($config, $dbid, $rangespec)
};

declare function local:fieldSpecification($config as element(configuration), $server-config as element(http-server))
{
	let $dbid := xdmp:database(fn:data($server-config/database))
	let $field-value-searches := admin:save-configuration(admin:database-set-field-value-searches($config,$dbid, "VideoTitle", fn:true()))
	let $field-value-positions := admin:save-configuration(admin:database-set-field-value-positions($config,$dbid, "VideoTitle", fn:true()))
	let $field-trailing-wildcard-word-positions := admin:save-configuration(admin:database-set-field-trailing-wildcard-word-positions($config,$dbid, "VideoTitle", fn:true()))
	let $field-two-character-searches := admin:save-configuration(admin:database-set-field-two-character-searches($config,$dbid, "VideoTitle", fn:true()))
	let $field-one-character-searches := admin:save-configuration(admin:database-set-field-one-character-searches($config,$dbid, "VideoTitle", fn:true()))
	return "DONE"
};

declare function local:createPathRangeIndex($config as element(configuration), $server-config as element(http-server), $group-name as xs:string)
{
	let $dbid := xdmp:database(fn:data($server-config/database))
	let $ModifiedInfoDate := let $Index :=admin:database-range-path-index($dbid,"dateTime","ModifiedInfo/Date","http://marklogic.com/collation/",fn:false(),"ignore") return admin:save-configuration(admin:database-add-range-path-index($config, $dbid, $Index))
	let $PricingDetailsType := let $Index :=admin:database-range-path-index($dbid,"string","PricingDetails/@type","http://marklogic.com/collation/",fn:false(),"ignore") return admin:save-configuration(admin:database-add-range-path-index($config, $dbid, $Index))
	let $VideoID := let $Index :=admin:database-range-path-index($dbid,"string","Video/@ID","http://marklogic.com/collation/",fn:false(),"ignore") return admin:save-configuration(admin:database-add-range-path-index($config, $dbid, $Index))
	return "DONE"
};

let $DBNAME := "IETTV-Database"
let $MODULESDBNAME := "IETTV-Modules-Database"
let $HttpPort := 9503
let $HttpService := "IETTV-HTTP-Server"
let $server-config-http :=  <http-server><name>{$HttpService}</name><port>{$HttpPort}</port><root>/</root><modules>{$MODULESDBNAME}</modules><database>{$DBNAME}</database></http-server>

let $config := admin:get-configuration()
let $set := xdmp:set($config, local:createField($config, $server-config-http))
let $set := xdmp:set($config, local:createFieldRangeIndex($config, $server-config-http))
let $config := admin:save-configuration($config)
let $config := admin:get-configuration()
let $config := local:fieldSpecification($config, $server-config-http)
let $config := admin:get-configuration()
let $config := local:createPathRangeIndex($config, $server-config-http, "Default")


return "Path Field.Field range index Created in Application Server"