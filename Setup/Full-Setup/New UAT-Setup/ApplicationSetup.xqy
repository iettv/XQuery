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
	let $VideoType := let $Index := admin:database-range-element-index("string", "",	"VideoType", "http://marklogic.com/collation/",fn:false()) return admin:save-configuration(admin:database-add-range-element-index($config, $dbid, $Index))
	let $EventStatrDate := let $Index := admin:database-range-element-index("dateTime", "",	"StartDate", "http://marklogic.com/collation/",fn:false()) return admin:save-configuration(admin:database-add-range-element-index($config, $dbid, $Index))
	let $LiveRecordStartDate := let $Index := admin:database-range-element-index("dateTime", "", "LiveRecordStartDate", "http://marklogic.com/collation/",fn:false()) return admin:save-configuration(admin:database-add-range-element-index($config, $dbid, $Index))
	let $LiveFinalStartDate  := let $Index := admin:database-range-element-index("dateTime", "", "LiveFinalStartDate", "http://marklogic.com/collation/",fn:false()) return admin:save-configuration(admin:database-add-range-element-index($config, $dbid, $Index))
	let $LiveFinalExpiryDate := let $Index := admin:database-range-element-index("dateTime", "", "LiveFinalExpiryDate", "http://marklogic.com/collation/",fn:false()) return admin:save-configuration(admin:database-add-range-element-index($config, $dbid, $Index))
	let $Kwd := let $Index := admin:database-range-element-index("string", "", "Kwd", "http://marklogic.com/collation/",fn:false()) return admin:save-configuration(admin:database-add-range-element-index($config, $dbid, $Index))
	let $CustomKeyword := let $Index := admin:database-range-element-index("string", "", "CustomKeyword", "http://marklogic.com/collation/",fn:false()) return admin:save-configuration(admin:database-add-range-element-index($config, $dbid, $Index))
	let $DefaultKeyword := let $Index := admin:database-range-element-index("string", "", "DefaultKeyword", "http://marklogic.com/collation/",fn:false()) return admin:save-configuration(admin:database-add-range-element-index($config, $dbid, $Index))

	let $Channel := let $Index := admin:database-range-element-attribute-index("int", "", "Channel", "", "ID",  "http://marklogic.com/collation/", fn:false() ) return admin:save-configuration(admin:database-add-range-element-attribute-index($config, $dbid, $Index))
	let $PricingType := let $Index := admin:database-range-element-attribute-index("string", "", "PricingDetails", "", "type",  "http://marklogic.com/collation/", fn:false() ) return admin:save-configuration(admin:database-add-range-element-attribute-index($config, $dbid, $Index))
	
	return "DONE"

};

declare function local:createPathRangeIndex($config as element(configuration), $server-config as element(http-server), $group-name as xs:string)
{
	let $dbid := xdmp:database(fn:data($server-config/database))
	let $CreatedPersonID := let $Index :=admin:database-range-path-index($dbid,"string","CreationInfo/Person/@ID","http://marklogic.com/collation/",fn:false(),"ignore") return admin:save-configuration(admin:database-add-range-path-index($config, $dbid, $Index))
	let $ModifiedPersonID := let $Index :=admin:database-range-path-index($dbid,"string","ModifiedInfo/Person/@ID","http://marklogic.com/collation/",fn:false(),"ignore") return admin:save-configuration(admin:database-add-range-path-index($config, $dbid, $Index))
	let $SpeakerPersonID := let $Index :=admin:database-range-path-index($dbid,"string","Speakers/Person/@ID","http://marklogic.com/collation/",fn:false(),"ignore") return admin:save-configuration(admin:database-add-range-path-index($config, $dbid, $Index))
	let $PermissionType := let $Index :=admin:database-range-path-index($dbid,"string","AdvanceInfo/PermissionDetails/Permission[@type eq 'HideRecord']/@status","http://marklogic.com/collation/",fn:false(),"ignore") return admin:save-configuration(admin:database-add-range-path-index($config, $dbid, $Index))
	let $SpeakerName := let $Index :=admin:database-range-path-index($dbid,"string","Speakers/Person/Name/Given-Name","http://marklogic.com/collation/en/S1",fn:false(),"ignore") return admin:save-configuration(admin:database-add-range-path-index($config, $dbid, $Index))
	let $SpeakerSurName := let $Index :=admin:database-range-path-index($dbid,"string","Speakers/Person/Name/Surname","http://marklogic.com/collation/en/S1",fn:false(),"ignore") return admin:save-configuration(admin:database-add-range-path-index($config, $dbid, $Index))
	let $ModifiedInfoDate := let $Index :=admin:database-range-path-index($dbid,"dateTime","ModifiedInfo/Date","http://marklogic.com/collation/",fn:false(),"ignore") return admin:save-configuration(admin:database-add-range-path-index($config, $dbid, $Index))
	let $PricingDetailsType := let $Index :=admin:database-range-path-index($dbid,"string","PricingDetails/@type","http://marklogic.com/collation/",fn:false(),"ignore") return admin:save-configuration(admin:database-add-range-path-index($config, $dbid, $Index))
	let $VideoID := let $Index :=admin:database-range-path-index($dbid,"string","Video/@ID","http://marklogic.com/collation/",fn:false(),"ignore") return admin:save-configuration(admin:database-add-range-path-index($config, $dbid, $Index))
	let $SpeakerName := let $Index :=admin:database-range-path-index($dbid,"string","/Speakers/Person/Name/Given-Name","http://marklogic.com/collation/",fn:false(),"ignore") return admin:save-configuration(admin:database-add-range-path-index($config, $dbid, $Index))
	let $UploadedByName := let $Index :=admin:database-range-path-index($dbid,"string","UploadVideo/File/Person/@ID","http://marklogic.com/collation/",fn:false(),"ignore") return admin:save-configuration(admin:database-add-range-path-index($config, $dbid, $Index))
	let $UploadStatus := let $Index :=admin:database-range-path-index($dbid,"string","UploadVideo/File/@active","http://marklogic.com/collation/",fn:false(),"ignore") return admin:save-configuration(admin:database-add-range-path-index($config, $dbid, $Index))
	let $BasicInfoTitle := let $Index :=admin:database-range-path-index($dbid,"string","BasicInfo/Title","http://marklogic.com/collation/",fn:false(),"ignore") return admin:save-configuration(admin:database-add-range-path-index($config, $dbid, $Index))
	(: 5.1 build :)
	let $ChannelId := let $Index :=admin:database-range-path-index($dbid,"string","ChannelMapping/Channel/@ID","http://marklogic.com/collation/",fn:false(),"ignore") return admin:save-configuration(admin:database-add-range-path-index($config, $dbid, $Index))
	let $PublishDate := let $Index :=admin:database-range-path-index($dbid,"dateTime","PublishInfo/VideoPublish/FinalStartDate","http://marklogic.com/collation/",fn:false(),"ignore") return admin:save-configuration(admin:database-add-range-path-index($config, $dbid, $Index))
	
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

declare function local:createVideoTitleField( $config as element(configuration),$server-config as element(http-server))as element(configuration)
{
	let $dbid := xdmp:database(fn:data($server-config/database))
	let $fieldspec := admin:database-path-field("VideoTitle",admin:database-field-path("/Video/BasicInfo/Title", 1.0))
	return admin:database-add-field($config, $dbid, $fieldspec)
};

declare function local:createVideoTitleFieldRangeIndex( $config as element(configuration), $server-config as element(http-server))as element(configuration)
{
	let $dbid := xdmp:database(fn:data($server-config/database))
	let $rangespec := admin:database-range-field-index("string","VideoTitle","http://marklogic.com/collation/",fn:false())
	return admin:database-add-range-field-index($config, $dbid, $rangespec)
};

declare function local:VideoTitleFieldSpecification($config as element(configuration), $server-config as element(http-server))
{
	let $dbid := xdmp:database(fn:data($server-config/database))
	let $field-value-searches := admin:save-configuration(admin:database-set-field-value-searches($config,$dbid, "VideoTitle", fn:true()))
	let $field-value-positions := admin:save-configuration(admin:database-set-field-value-positions($config,$dbid, "VideoTitle", fn:true()))
	let $field-trailing-wildcard-word-positions := admin:save-configuration(admin:database-set-field-trailing-wildcard-word-positions($config,$dbid, "VideoTitle", fn:true()))
	let $field-two-character-searches := admin:save-configuration(admin:database-set-field-two-character-searches($config,$dbid, "VideoTitle", fn:true()))
	let $field-one-character-searches := admin:save-configuration(admin:database-set-field-one-character-searches($config,$dbid, "VideoTitle", fn:true()))
	return "DONE"
};

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


(: Start Value set - Change all below values before execution ************************** :)
let $DBNAME := "New-IETTV-Database"
let $DBFORESTNAME := "New-IETTV-Forest"
let $MODULESDBNAME := "New-IETTV-Modules-Database"
let $MODULESFORESTNAME := "New-IETTVModules-Forest"
let $SECURITY_DBNAME := "Security"
let $SCHEMA_DBNAME := "Schemas"
let $XDBCPort := 9901
let $WebDavPort := 9902
let $HttpPort := 9903
let $XDBCService := "New-IETTV-XDBC-Server"
let $WebDavService := "New-IETTV-WEBDAV-Server"
let $HttpService := "New-IETTV-HTTP-Server"
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
let $config := admin:get-configuration()
let $set := xdmp:set($config, local:createVideoTitleField($config, $server-config-http))
let $set := xdmp:set($config, local:createVideoTitleFieldRangeIndex($config, $server-config-http))
let $config := admin:save-configuration($config)
let $config := admin:get-configuration()
let $config := local:VideoTitleFieldSpecification($config, $server-config-http)
let $config := admin:get-configuration()
let $set := xdmp:set($config, local:createSearchField($config, $server-config-http))
let $config := admin:save-configuration($config)
let $config := admin:get-configuration()
let $config := local:SearchFieldSpecification($config, $server-config-http)


(:Scheduler Script:)

let $task-root :=	"/"
let $task-database :=	"New-IETTV-Database"
let $task-modules := "New-IETTV-Modules-Database"
let $task-user := "admin"
let $config  := admin:get-configuration()

let $task      := admin:group-daily-scheduled-task("/Scheduler/getRelatedContent.xqy", $task-root,1,xs:time("24:00:00"),xdmp:database($task-database),xdmp:database($task-modules), xdmp:user($task-user), (), "higher")
let $addTask 	:= admin:group-add-scheduled-task($config, admin:group-get-id($config, "Default"), $task)
let $saveTask	:=	admin:save-configuration($addTask)

let $task      := admin:group-daily-scheduled-task("/Scheduler/CarouselUpdation.xqy", $task-root,1,xs:time("01:00:00"),xdmp:database($task-database),xdmp:database($task-modules), xdmp:user($task-user), (), "higher")
let $addTask 	:= admin:group-add-scheduled-task($config, admin:group-get-id($config, "Default"), $task)
let $saveTask	:=	admin:save-configuration($addTask)

let $task      := admin:group-daily-scheduled-task("/Scheduler/ChannelCarouselUpdation.xqy", $task-root,1,xs:time("02:00:00"),xdmp:database($task-database),xdmp:database($task-modules), xdmp:user($task-user), (), "higher")
let $addTask 	:= admin:group-add-scheduled-task($config, admin:group-get-id($config, "Default"), $task)
let $saveTask	:=	admin:save-configuration($addTask)

return "Application database,Specification, Range Index and Scheduler created"