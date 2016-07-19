 xquery version "1.0-ml";

  import module namespace admin = "http://marklogic.com/xdmp/admin" at "/MarkLogic/admin.xqy";
		
  let $config := admin:get-configuration()
  let $dbid := xdmp:database("IETTV-Database")
  (: Element Range Index Delete :)
  let $RecordStartDate := admin:database-range-element-index("dateTime", "",	"RecordStartDate", "http://marklogic.com/collation/",fn:false())
  let $Delete          := try{admin:save-configuration(admin:database-delete-range-element-index($config, $dbid, $RecordStartDate))} catch($e){}
  let $FinalStartDate  := admin:database-range-element-index("dateTime", "",	"FinalStartDate", "http://marklogic.com/collation/",fn:false())
  let $Delete          := try{admin:save-configuration(admin:database-delete-range-element-index($config, $dbid, $FinalStartDate))} catch($e){}
  let $FinalExpiryDate := admin:database-range-element-index("dateTime", "",	"FinalExpiryDate", "http://marklogic.com/collation/",fn:false())
  let $Delete          := try{admin:save-configuration(admin:database-delete-range-element-index($config, $dbid, $FinalExpiryDate))} catch($e){}
  let $Duration        := admin:database-range-element-index("time", "",	"Duration", "http://marklogic.com/collation/",fn:false())
  let $Delete          := try{admin:save-configuration(admin:database-delete-range-element-index($config, $dbid, $Duration))} catch($e){}
  (: Attribute Range Index Delete :)
  let $Channel         := admin:database-range-element-attribute-index("int", "", "Channel", "", "channelID",  "http://marklogic.com/collation/", fn:false() )
  let $Delete          := try{admin:save-configuration(admin:database-delete-range-element-attribute-index($config, $dbid, $Channel))} catch($e){}
  let $Keyword         := admin:database-range-element-attribute-index("int", "", "Keyword", "", "keywordID",  "http://marklogic.com/collation/", fn:false() )
  let $Delete          := try{admin:save-configuration(admin:database-delete-range-element-attribute-index($config, $dbid, $Keyword))} catch($e){}
  return "Success"