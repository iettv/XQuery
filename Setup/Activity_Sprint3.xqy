xquery version "1.0-ml";
import module namespace admin = "http://marklogic.com/xdmp/admin" at "/MarkLogic/admin.xqy";


declare function local:createElementRangeIndex($config as element(configuration), $server-config as element(http-server), $group-name as xs:string)
{
	let $dbid := xdmp:database(fn:data($server-config/database))
	let $ActorType := let $Index := admin:database-range-element-index("string", "",	"ActorType", "http://marklogic.com/collation/",fn:false()) return admin:save-configuration(admin:database-add-range-element-index($config, $dbid, $Index))
	let $ActivityDate := let $Index := admin:database-range-element-index("date", "",	"ActivityDate", "http://marklogic.com/collation/",fn:false()) return admin:save-configuration(admin:database-add-range-element-index($config, $dbid, $Index))
	let $UserID := let $Index := admin:database-range-element-index("string", "",	"UserID", "http://marklogic.com/collation/",fn:false()) return admin:save-configuration(admin:database-add-range-element-index($config, $dbid, $Index))
	let $UserIP := let $Index := admin:database-range-element-index("string", "",	"UserIP", "http://marklogic.com/collation/",fn:false()) return admin:save-configuration(admin:database-add-range-element-index($config, $dbid, $Index))
	let $UserType := let $Index := admin:database-range-element-index("string", "",	"UserType", "http://marklogic.com/collation/",fn:false()) return admin:save-configuration(admin:database-add-range-element-index($config, $dbid, $Index))
	let $Type := let $Index := admin:database-range-element-index("string", "",	"Type", "http://marklogic.com/collation/",fn:false()) return admin:save-configuration(admin:database-add-range-element-index($config, $dbid, $Index))
	let $Device := let $Index := admin:database-range-element-index("string", "",	"Device", "http://marklogic.com/collation/",fn:false()) return admin:save-configuration(admin:database-add-range-element-index($config, $dbid, $Index))
	let $CorporateAccountID := let $Index := admin:database-range-element-index("string", "",	"CorporateAccountID", "http://marklogic.com/collation/",fn:false()) return admin:save-configuration(admin:database-add-range-element-index($config, $dbid, $Index))
	let $AccountType := let $Index := admin:database-range-element-index("string", "",	"AccountType", "http://marklogic.com/collation/",fn:false()) return admin:save-configuration(admin:database-add-range-element-index($config, $dbid, $Index))
    let $CollectionLexicon := admin:save-configuration(admin:database-set-collection-lexicon($config, $dbid, fn:true()))
	return "SUCCESS"

};

declare function local:createPathRangeIndex($config as element(configuration), $server-config as element(http-server), $group-name as xs:string)
{
	let $dbid := xdmp:database(fn:data($server-config/database))
	let $ChannelID := let $Index :=admin:database-range-path-index($dbid,"string","AdditionalInfo/NameValue[Name='ChannelId']/Value","http://marklogic.com/collation/",fn:false(),"ignore") return admin:save-configuration(admin:database-add-range-path-index($config, $dbid, $Index))
	let $SubscriptionType  := let $Index :=admin:database-range-path-index($dbid,"string","AdditionalInfo/NameValue[Name='SubscriptionType']/Value","http://marklogic.com/collation/",fn:false(),"ignore") return admin:save-configuration(admin:database-add-range-path-index($config, $dbid, $Index))
	let $VideoTitle := let $Index :=admin:database-range-path-index($dbid,"string","AdditionalInfo/NameValue[Name='VideoTitle']/Value","http://marklogic.com/collation/",fn:false(),"ignore") return admin:save-configuration(admin:database-add-range-path-index($config, $dbid, $Index))
	return "DONE"
};

declare function local:createServerTask($config,$task-path,$task-root,$task-period,$task-minute, $task-database,$task-modules,$task-user)
{
	let $task    := admin:group-hourly-scheduled-task($task-path,$task-root, $task-period, $task-minute, xdmp:database($task-database), xdmp:database($task-modules), xdmp:user($task-user), (),"normal")
	let $addTask := admin:group-add-scheduled-task($config, admin:group-get-id($config, "Default"), $task)
	let $saveTask:=admin:save-configuration($addTask)
	return "Schedule Task Created"

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
let $config := local:createElementRangeIndex($config, $server-config-http, "Default")
let $config := admin:get-configuration()
let $config := local:createPathRangeIndex($config, $server-config-http, "Default")	

(:Scheduler for CommonMostPopular:)
let $task-path := "/Scheduler/CommonMostPopular.xqy"
let $task-root :="/"
let $task-period:=2
let $task-minute :=00
let $task-database :=$DBNAME
let $task-modules:=$MODULESDBNAME
let $task-user:="admin"
let $config  := admin:get-configuration()
let $config := local:createServerTask($config,$task-path,$task-root,$task-period,$task-minute, $task-database,$task-modules,$task-user)

return "Activity Database Range Index and Scheduler created"