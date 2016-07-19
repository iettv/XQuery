 xquery version "1.0-ml";
import module namespace admin = "http://marklogic.com/xdmp/admin" at "/MarkLogic/admin.xqy";


declare function local:deleteElementRangeIndex($config as element(configuration), $server-config as element(http-server), $group-name as xs:string)
{
	let $dbid := xdmp:database(fn:data($server-config/database))
	let $DefaultKeywordID := let $Index :=admin:database-range-element-attribute-index("int","", "DefaultKeyword", "", "ID","http://marklogic.com/collation/", fn:false() ) return admin:save-configuration(admin:database-delete-range-element-attribute-index($config, $dbid, $Index))
	return "DONE"
};
declare function local:createElementRangeIndex($config as element(configuration), $server-config as element(http-server), $group-name as xs:string)
{
	let $dbid := xdmp:database(fn:data($server-config/database))
	let $Kwd := let $Index := admin:database-range-element-index("string", "", "Kwd", "http://marklogic.com/collation/",fn:false()) return admin:save-configuration(admin:database-add-range-element-index($config, $dbid, $Index))
	let $CustomKeyword := let $Index := admin:database-range-element-index("string", "", "CustomKeyword", "http://marklogic.com/collation/",fn:false()) return admin:save-configuration(admin:database-add-range-element-index($config, $dbid, $Index))
	let $DefaultKeyword := let $Index := admin:database-range-element-index("string", "", "DefaultKeyword", "http://marklogic.com/collation/",fn:false()) return admin:save-configuration(admin:database-add-range-element-index($config, $dbid, $Index))
    let $CollectionLexicon := admin:save-configuration(admin:database-set-collection-lexicon($config, $dbid, fn:true()))
	return "SUCCESS"
};

declare function local:createPathRangeIndex($config as element(configuration), $server-config as element(http-server), $group-name as xs:string)
{
	let $dbid := xdmp:database(fn:data($server-config/database))
	let $ChannelId := let $Index :=admin:database-range-path-index($dbid,"string","ChannelMapping/Channel/@ID","http://marklogic.com/collation/",fn:false(),"ignore") return admin:save-configuration(admin:database-add-range-path-index($config, $dbid, $Index))
	let $PublishDate := let $Index :=admin:database-range-path-index($dbid,"dateTime","PublishInfo/VideoPublish/FinalStartDate","http://marklogic.com/collation/",fn:false(),"ignore") return admin:save-configuration(admin:database-add-range-path-index($config, $dbid, $Index))
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
let $config := admin:get-configuration()
let $config := local:deleteElementRangeIndex($config, $server-config-http, "Default")
let $config := admin:get-configuration()
let $config := local:createPathRangeIndex($config, $server-config-http, "Default")

return "Element Range Index created in Application database"