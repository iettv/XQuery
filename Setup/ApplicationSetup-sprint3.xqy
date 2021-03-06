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

declare function local:attachForestToDatabase($config as element(configuration), $database_name as xs:string,$forest_name as xs:string)
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
			let $group-id := admin:group-get-id($config, $group-name)
			let $NewServer := fn:data($server-config/name)
			let $root := fn:data($server-config/root)
			let $port := xs:integer(fn:data($server-config/port))
			let $modules := fn:data($server-config/modules)
			let $module-id :=  if($modules eq "filesystem")	then 0  else xdmp:database($modules)
			let $database-id := xdmp:database(fn:data($server-config/database))
			let $config := admin:xdbc-server-create($config,$group-id,$NewServer,$root,$port,$module-id,$database-id)   
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
        let $group-id := admin:group-get-id($config, $group-name)
        let $NewServer := fn:data($server-config/name)
        let $root := fn:data($server-config/root)
        let $port := xs:integer(fn:data($server-config/port))
        let $database-id := xdmp:database(fn:data($server-config/database))
        let $config := admin:webdav-server-create($config,$group-id,$NewServer,$root,$port,$database-id)
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
let $XDBCPort := 9501
let $WebDavPort := 9502
let $HttpPort := 9503
let $XDBCService := "IETTV-XDBC-Server"
let $WebDavService := "IETTV-WEBDAV-Server"
let $HttpService := "IETTV-HTTP-Server"
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
let $config := local:createPathRangeIndex($config, $server-config-http, "Default")
let $config := admin:get-configuration()
let $config := local:databaseSpecification($config, $server-config-http)


return "Application database Created"