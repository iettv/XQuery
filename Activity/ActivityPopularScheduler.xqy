import module namespace admin = "http://marklogic.com/xdmp/admin" at "/MarkLogic/admin.xqy";

declare function local:createServerTask($config,$task-path,$task-root,$task-period,$task-minute, $task-database,$task-modules,$task-user)
{
	(:let $task    := admin:group-minutely-scheduled-task($task-path, $task-root,$task-period, xdmp:database($task-database), xdmp:database($task-modules), xdmp:user($task-user), (), "higher")
    let $task := admin:group-hourly-scheduled-task($task-path,$task-root, $task-period, $task-minute, xdmp:database($task-database), xdmp:database($task-modules), xdmp:user($task-user), (),"normal"):)
	let $task    := admin:group-daily-scheduled-task($task-path, $task-root,1,xs:time("22:00:00"),xdmp:database($task-database),xdmp:database($task-modules), xdmp:user($task-user), (), "higher")
	let $addTask := admin:group-add-scheduled-task($config, admin:group-get-id($config, "Default"), $task)
	let $saveTask:=admin:save-configuration($addTask)
	return "Schedule Task Created"
};

(: Start Value set - Change all below values before execution ************************** :)
let $DBNAME := "IETTV-Activity-Database"
let $MODULESDBNAME := "IETTV-Activity-Modules-Database"
let $HttpPort := 9506
let $HttpService := "IETTV-Activity-HTTP-Server"
let $server-config-http :=  <http-server><name>{$HttpService}</name><port>{$HttpPort}</port><root>/</root><modules>{$MODULESDBNAME}</modules><database>{$DBNAME}</database></http-server>
let $config := admin:get-configuration()

(: Scheduler setup :)
let $task-path := "/Scheduler/CommonMostPopular.xqy"
let $task-root :="/"
let $task-period:=1
let $task-minute :=00
let $task-database :=$DBNAME
let $task-modules := $MODULESDBNAME
let $task-user := "admin"
let $config  := admin:get-configuration()
let $config := local:createServerTask($config,$task-path,$task-root,$task-period,$task-minute, $task-database,$task-modules,$task-user)


return "Scheduler created"