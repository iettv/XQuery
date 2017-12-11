xquery version "1.0-ml";

declare variable $inputSearchDetails as xs:string external ;

(: let $inputSearchDetails := "<record>
                               <time>30</time>
                          </record>" :)

let $input := xdmp:unquote($inputSearchDetails)

let $time := $input/record/time/text()

for $i in doc()/Video

let $VideoID := $i/@ID/string()

let $duration := $i/UploadVideo/File/Duration/text()

let $duration1 := tokenize($i/UploadVideo/File/Duration/text(),':')[1]

let $duration2 := tokenize($i/UploadVideo/File/Duration/text(),':')[2]


return if ( xs:integer($duration1) ge 1 or xs:integer($duration2) ge xs:integer($time) )
       then
	   (
			if($i/AdvanceInfo/PermissionDetails/Permission[@type='AddCPDLogo'])
			then (
					xdmp:node-replace($i/AdvanceInfo/PermissionDetails/Permission[@type='AddCPDLogo'], <Permission type="AddCPDLogo" status="yes"/>),
				   concat($VideoID,'|')
				  )
			else 
			(
			   if($i/AdvanceInfo/PermissionDetails/Permission[@type='DisplayPolling'])
			   then (xdmp:node-insert-after($i/AdvanceInfo/PermissionDetails/Permission[@type='DisplayPolling'], <Permission type="AddCPDLogo" status="yes"/>),concat($VideoID,'|'))
			   else if ($i/AdvanceInfo/PermissionDetails/Permission[@type='Discoverable'])
			   then (xdmp:node-insert-after($i/AdvanceInfo/PermissionDetails/Permission[@type='Discoverable'], <Permission type="AddCPDLogo" status="yes"/>),concat($VideoID,'|'))
			   else ()
			)
		)
		else()
		