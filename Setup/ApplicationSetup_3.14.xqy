
import module namespace admin="http://marklogic.com/xdmp/admin" at "/MarkLogic/admin.xqy";

declare function local:createSearchField( $config as element(configuration),$server-config as element(http-server))as element(configuration)
{
  let $dbid := xdmp:database(fn:data($server-config/database))
  let $fieldspec := admin:database-path-field("Search",(admin:database-field-path("/Video/BasicInfo/Title", 64),
  admin:database-field-path("/Video/Speakers/Person/Name/Given-Name", 40),
  admin:database-field-path("/Video/Speakers/Person/Name/Surname", 40),
  admin:database-field-path("/Video/VideoInspec/Kwd-Group/Kwd", 6),
  admin:database-field-path("/Video/VideoInspec/Kwd-Group/Compound-Kwd/Compound-Kwd-Part", 6),
  admin:database-field-path("/Video/BasicInfo/Abstract", 3),
  admin:database-field-path("/Video/BasicInfo/ShortDescription", 3),
  admin:database-field-path("/Video/KeyWordInfo/ChannelKeywordList/Channel/KeywordList/DefaultKeyword", 2),
  admin:database-field-path("/Video/KeyWordInfo/CustomKeywordList/CustomKeyword", 2)))
  return admin:database-add-field($config, $dbid, $fieldspec)
  
};

declare function local:SearchFieldSpecification($config as element(configuration), $server-config as element(http-server))
{
	let $dbid := xdmp:database(fn:data($server-config/database))
	let $field-value-searches := admin:save-configuration(admin:database-set-field-value-searches($config,$dbid, "Search", fn:true()))
	let $field-value-positions := admin:save-configuration(admin:database-set-field-value-positions($config,$dbid, "Search", fn:true()))
	let $field-trailing-wildcard-word-positions := admin:save-configuration(admin:database-set-field-trailing-wildcard-word-positions($config,$dbid, "Search", fn:true()))
	let $field-two-character-searches := admin:save-configuration(admin:database-set-field-two-character-searches($config,$dbid, "Search", fn:true()))
	let $field-one-character-searches := admin:save-configuration(admin:database-set-field-one-character-searches($config,$dbid, "Search", fn:true()))
	return "DONE"
};

let $DBNAME := "IETTV-Database"
let $MODULESDBNAME := "IETTV-Modules-Database"
let $HttpPort := 9503
let $HttpService := "IETTV-HTTP-Server"
let $server-config-http :=  <http-server><name>{$HttpService}</name><port>{$HttpPort}</port><root>/</root><modules>{$MODULESDBNAME}</modules><database>{$DBNAME}</database></http-server>

let $config := admin:get-configuration()
let $set := xdmp:set($config, local:createSearchField($config, $server-config-http))
let $config := admin:save-configuration($config)

let $config := admin:get-configuration()
let $config := local:SearchFieldSpecification($config, $server-config-http)

return "Search Path Field Created in Application Server"