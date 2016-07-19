xquery version "1.0-ml";

import module namespace admin = "http://marklogic.com/xdmp/admin" at "/MarkLogic/admin.xqy";

declare function local:createForest($config as element(configuration), $forest_name as xs:string)
{
	try {
			let $config := admin:forest-create($config,$forest_name,xdmp:host(), ())
			return admin:save-configuration($config)
		}
	catch($e)
		{(
			xdmp:log($e),
			"ERROR : Some error occurs during Forest creation. Please check ML log file to get more details."
		)}
};

declare function local:createDatabase($config as element(configuration), $database_name as xs:string, $security_dbname as xs:string, $schema_dbname as xs:string)
{
	try {
		let $config := admin:database-create($config,$database_name,xdmp:database($security_dbname),xdmp:database($schema_dbname))
		return admin:save-configuration($config)
		}
	catch($e)
		{(
			xdmp:log($e),
			"ERROR : Some error occurs during Database creation. Please check ML log file to get more details."
		)}
};

declare function local:attachForestToDatabase($config as element(configuration), $database_name as xs:string, $forest_name as xs:string)
{
	try
		{
			let $IETTV-Database-Id := admin:database-get-id($config,$database_name)
			let $config := admin:database-attach-forest($config,$IETTV-Database-Id,xdmp:forest($forest_name))
			return admin:save-configuration($config)
		}
	catch($e)
		{(
			xdmp:log($e),
			"ERROR : Some error occurs during Forest attachment with the Database. Please check ML log file to get more details."
		)}
};

declare function local:createHttpServer($config as element(configuration), $server-config as element(http-server), $group-name as xs:string)
{
	try
		{
			let $group-id := admin:group-get-id($config, $group-name)
			let $NewServer := fn:data($server-config/name)
			let $root := fn:data($server-config/root)
			let $port := xs:integer(fn:data($server-config/port))
			let $modules := fn:data($server-config/modules)
			let $module-id :=  if($modules eq "filesystem")	then 0  else xdmp:database($modules)
			let $database-id := xdmp:database(fn:data($server-config/database))
			let $config := admin:http-server-create($config,$group-id,$NewServer,$root,$port,$module-id,$database-id )
			return admin:save-configuration($config)
		}
	catch($e)
		{(
			xdmp:log($e),
			"ERROR : Some error occurs during HTTP server creation. Please check ML log file to get more details."
		)}
};

declare function local:createXdbcServer($config as element(configuration), $server-config as element(xdbc-server), $group-name as xs:string)
{
	try
		{
			let $group-id 	:= admin:group-get-id($config, $group-name)
			let $NewServer 	:= fn:data($server-config/name)
			let $root 		:= fn:data($server-config/root)
			let $port 		:= xs:integer(fn:data($server-config/port))
			let $modules 	:= fn:data($server-config/modules)
			let $module-id 	:=  if($modules eq "filesystem")	then 0  else xdmp:database($modules)
			let $database-id := xdmp:database(fn:data($server-config/database))
			let $config 	:= admin:xdbc-server-create($config,$group-id,$NewServer,$root,$port,$module-id,$database-id)   
			return admin:save-configuration($config)
		}
	catch($e)
		{(
			xdmp:log($e),
			"ERROR : Some error occurs during XDBC server creation. Please check ML log file to get more details."
		)}
};

declare function local:createWebdavServer($config as element(configuration), $server-config as element(webdav-server), $group-name as xs:string)
{
	try
	{
        let $group-id 	:= admin:group-get-id($config, $group-name)
        let $NewServer 	:= fn:data($server-config/name)
        let $root 		:= fn:data($server-config/root)
        let $port 		:= xs:integer(fn:data($server-config/port))
        let $database-id := xdmp:database(fn:data($server-config/database))
        let $config 	:= admin:webdav-server-create($config,$group-id,$NewServer,$root,$port,$database-id)
		return admin:save-configuration($config)
	}
	catch($e)
		{(
			xdmp:log($e),
			"ERROR : Some error occurs during WEBDEV server creation. Please check ML log file to get more details."
		)}
};

declare function local:createElementRangeIndex($config as element(configuration), $server-config as element(http-server), $group-name as xs:string)
{
	let $dbid        := xdmp:database(fn:data($server-config/database))
	let $KeyTitle    := let $Index := admin:database-range-element-index("string", "",	"KeyTitle", "http://marklogic.com/collation/",fn:false()) return admin:save-configuration(admin:database-add-range-element-index($config, $dbid, $Index))
	let $KeyAbstract := let $Index := admin:database-range-element-index("string", "",	"KeyAbstract", "http://marklogic.com/collation/",fn:false()) return admin:save-configuration(admin:database-add-range-element-index($config, $dbid, $Index))
	let $KeyContributor := let $Index := admin:database-range-element-index("string", "",	"KeyContributor", "http://marklogic.com/collation/",fn:false()) return admin:save-configuration(admin:database-add-range-element-index($config, $dbid, $Index))
	let $KeyKeywords  := let $Index := admin:database-range-element-index("string", "",	"KeyKeywords", "http://marklogic.com/collation/",fn:false()) return admin:save-configuration(admin:database-add-range-element-index($config, $dbid, $Index))
	let $KeyCopyright := let $Index := admin:database-range-element-index("string", "",	"KeyCopyright", "http://marklogic.com/collation/",fn:false()) return admin:save-configuration(admin:database-add-range-element-index($config, $dbid, $Index))
	return "DONE"

};

declare function local:databaseSpecification($config as element(configuration), $server-config as element(http-server))
{
	let $dbid := xdmp:database(fn:data($server-config/database))
	let $CollectionLexicon := admin:save-configuration(admin:database-set-collection-lexicon($config, $dbid, fn:true()))
	return "DONE"
};

(: Start Value set - Change all below values before execution ************************** :)
let $DBNAME := "New-IETTV-RelatedContent"
let $DBFORESTNAME := "New-IETTV-Forest-RelatedContent"
let $MODULESDBNAME := "New-IETTV-Modules-RelatedContent"
let $MODULESFORESTNAME := "New-IETTV-Code-RelatedContent"
let $SECURITY_DBNAME := "Security"
let $SCHEMA_DBNAME := "Schemas"
let $XDBCPort := 6901
let $WebDavPort := 6902
let $HttpPort := 6903
let $XDBCService := "New-IETTV-XDBC-RelatedContent"
let $WebDavService := "New-IETTV-WEBDAV-RelatedContent"
let $HttpService := "New-IETTV-HTTP-RelatedContent"
let $server-config-http :=  <http-server><name>{$HttpService}</name><port>{$HttpPort}</port><root>/</root><modules>{$MODULESDBNAME}</modules><database>{$DBNAME}</database></http-server>
let $server-config-xdbc :=	<xdbc-server><name>{$XDBCService}</name><port>{$XDBCPort}</port><root>/</root><modules>{$MODULESDBNAME}</modules><database>{$DBNAME}</database></xdbc-server>
let $server-config-webdav := <webdav-server><name>{$WebDavService}</name><port>{$WebDavPort}</port><root>/</root><database>{$MODULESDBNAME}</database></webdav-server>		  
		  
	  
(: Get and set the configurations :)
let $config := admin:get-configuration()
let $config := local:createForest($config,$DBFORESTNAME)	
let $config := admin:get-configuration()
let $config := local:createForest($config,$MODULESFORESTNAME)	
let $config := admin:get-configuration()
let $config := local:createDatabase($config,$DBNAME,$SECURITY_DBNAME,$SCHEMA_DBNAME)	
let $config := admin:get-configuration()
let $config := local:createDatabase($config,$MODULESDBNAME,$SECURITY_DBNAME,$SCHEMA_DBNAME)	
let $config := admin:get-configuration()
let $config := local:attachForestToDatabase($config, $DBNAME, $DBFORESTNAME)	
let $config := admin:get-configuration()
let $config := local:attachForestToDatabase($config, $MODULESDBNAME, $MODULESFORESTNAME)
let $config := admin:get-configuration()
let $config := admin:database-set-directory-creation($config, xdmp:database($MODULESDBNAME), "automatic")
let $config := admin:save-configuration($config)
let $config := admin:get-configuration()
let $config := local:createHttpServer($config, $server-config-http, "Default")	
let $config := admin:get-configuration()
let $config := local:createXdbcServer($config, $server-config-xdbc, "Default")	
let $config := admin:get-configuration()
let $config := local:createWebdavServer($config, $server-config-webdav, "Default")	
let $config := admin:get-configuration()
let $config := local:createElementRangeIndex($config, $server-config-http, "Default")
let $config := admin:get-configuration()
let $config := local:databaseSpecification($config, $server-config-http)


let $task-path 	:= "/Scheduler/RelatedIngestion.xqy"
let $task-root 	:= "/"
let $task-database:= "New-IETTV-RelatedContent"
let $task-modules := "New-IETTV-Modules-RelatedContent"
let $task-user 	:= "admin"
let $config  		:= admin:get-configuration()
let $task     	:= admin:group-daily-scheduled-task($task-path, $task-root,1,xs:time("23:00:00"),xdmp:database($task-database),xdmp:database($task-modules), xdmp:user($task-user), (), "higher")
let $addTask 		:= admin:group-add-scheduled-task($config, admin:group-get-id($config, "Default"), $task)
let $saveTask		:= admin:save-configuration($addTask)


return "RelatedContent database,Specification, Range Index and Scheduler created"
