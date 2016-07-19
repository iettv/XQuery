xquery version "1.0-ml";
import module namespace admin = "http://marklogic.com/xdmp/admin" at "/MarkLogic/admin.xqy";


declare function local:createElementRangeIndex($config as element(configuration), $server-config as element(http-server), $group-name as xs:string)
{
	let $dbid := xdmp:database(fn:data($server-config/database))
	let $RecordStartDate := let $Index := admin:database-range-element-index("dateTime", "",	"RecordStartDate", "http://marklogic.com/collation/",fn:false()) return admin:save-configuration(admin:database-add-range-element-index($config, $dbid, $Index))
	let $FinalStartDate := let $Index := admin:database-range-element-index("dateTime", "",	"FinalStartDate", "http://marklogic.com/collation/",fn:false()) return admin:save-configuration(admin:database-add-range-element-index($config, $dbid, $Index))
	let $FinalExpiryDate := let $Index := admin:database-range-element-index("dateTime", "",	"FinalExpiryDate", "http://marklogic.com/collation/",fn:false()) return admin:save-configuration(admin:database-add-range-element-index($config, $dbid, $Index))
	let $Duration := let $Index := admin:database-range-element-index("time", "",	"Duration", "http://marklogic.com/collation/",fn:false()) return admin:save-configuration(admin:database-add-range-element-index($config, $dbid, $Index))
	let $UpdatedDate := let $Index := admin:database-range-element-index("dateTime", "",	"UpdatedDate", "http://marklogic.com/collation/",fn:false()) return admin:save-configuration(admin:database-add-range-element-index($config, $dbid, $Index))
	let $VideoCategory := let $Index := admin:database-range-element-index("string", "",	"VideoCategory", "http://marklogic.com/collation/",fn:false()) return admin:save-configuration(admin:database-add-range-element-index($config, $dbid, $Index))
	let $EventStatrDate := let $Index := admin:database-range-element-index("dateTime", "",	"StartDate", "http://marklogic.com/collation/",fn:false()) return admin:save-configuration(admin:database-add-range-element-index($config, $dbid, $Index))

	let $Channel := let $Index := admin:database-range-element-attribute-index("int", "", "Channel", "", "ID",  "http://marklogic.com/collation/", fn:false() ) return admin:save-configuration(admin:database-add-range-element-attribute-index($config, $dbid, $Index))
	let $Keyword := let $Index := admin:database-range-element-attribute-index("int", "", "DefaultKeyword", "", "ID",  "http://marklogic.com/collation/", fn:false() ) return admin:save-configuration(admin:database-add-range-element-attribute-index($config, $dbid, $Index))
	let $PricingType := let $Index := admin:database-range-element-attribute-index("string", "", "PricingDetails", "", "type",  "http://marklogic.com/collation/", fn:false() ) return admin:save-configuration(admin:database-add-range-element-attribute-index($config, $dbid, $Index))
	
	return "DONE"

};

declare function local:createPathRangeIndex($config as element(configuration), $server-config as element(http-server), $group-name as xs:string)
{
	let $dbid := xdmp:database(fn:data($server-config/database))
	let $CreatedPersonID := let $Index :=admin:database-range-path-index($dbid,"string","CreationInfo/Person/@ID","http://marklogic.com/collation/",fn:false(),"ignore") return admin:save-configuration(admin:database-add-range-path-index($config, $dbid, $Index))
	let $ModifiedPersonID := let $Index :=admin:database-range-path-index($dbid,"string","ModifiedInfo/Person/@ID","http://marklogic.com/collation/",fn:false(),"ignore") return admin:save-configuration(admin:database-add-range-path-index($config, $dbid, $Index))
	let $SpeakerPersonID := let $Index :=admin:database-range-path-index($dbid,"string","Speakers/Person/@ID","http://marklogic.com/collation/",fn:false(),"ignore") return admin:save-configuration(admin:database-add-range-path-index($config, $dbid, $Index))
	return "DONE"
};

declare function local:createServerTask($config,$task-path,$task-root,$task-period,$task-minute, $task-database,$task-modules,$task-user)
{
	let $task    := admin:group-hourly-scheduled-task($task-path,$task-root, $task-period, $task-minute, xdmp:database($task-database), xdmp:database($task-modules), xdmp:user($task-user), (),"normal")
	let $addTask := admin:group-add-scheduled-task($config, admin:group-get-id($config, "Default"), $task)
	let $saveTask:=admin:save-configuration($addTask)
	return "Schedule Task Created"

};

declare function local:databaseSpecification($config as element(configuration), $server-config as element(http-server))
{
	let $dbid := xdmp:database(fn:data($server-config/database))
	let $word-searches := admin:save-configuration(admin:database-set-word-searches($config,$dbid,fn:true()))
	let $fastcase-sensitive-searches := admin:save-configuration(admin:database-set-fast-case-sensitive-searches($config,$dbid,fn:true()))
	let $fastcase-diacritic-searches := admin:save-configuration(admin:database-set-fast-diacritic-sensitive-searches($config,$dbid,fn:true()))
	let $wildcard-searches := admin:save-configuration(admin:database-set-trailing-wildcard-searches($config,$dbid,fn:true()))
	let $lexspec := admin:database-word-lexicon("http://marklogic.com/collation/")
	let $word-lecixon := admin:save-configuration(admin:database-add-word-lexicon($config, $dbid, $lexspec))
    let $CollectionLexicon := admin:save-configuration(admin:database-set-collection-lexicon($config, $dbid, fn:true()))
	let $three-character-searches := admin:save-configuration(admin:database-set-three-character-searches($config,$dbid,fn:true()))
	let $three-character-word-position := admin:save-configuration(admin:database-set-three-character-word-positions($config,$dbid,fn:true()))
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
let $config := local:createPathRangeIndex($config, $server-config-http, "Default")
let $config := admin:get-configuration()
let $config := local:databaseSpecification($config, $server-config-http)

(:Scheduler for ChannelCarouselUpdation:)
let $task-path := "/Scheduler/ChannelCarouselUpdation.xqy"
let $task-root :="/"
let $task-period:=1
let $task-minute :=00
let $task-database :=$DBNAME
let $task-modules:=$MODULESDBNAME
let $task-user:="admin"
let $config  := admin:get-configuration()
let $config := local:createServerTask($config,$task-path,$task-root,$task-period,$task-minute, $task-database,$task-modules,$task-user)

(:Scheduler for CarouselUpdation :)
let $task-path := "/Scheduler/CarouselUpdation.xqy"
let $task-root :="/"
let $task-period:=1
let $task-minute :=00
let $task-database :=$DBNAME
let $task-modules:=$MODULESDBNAME
let $task-user:="admin"
let $config  := admin:get-configuration()
let $config := local:createServerTask($config,$task-path,$task-root,$task-period,$task-minute, $task-database,$task-modules,$task-user)


return "Application Database Specification, Range Index and Scheduler created"