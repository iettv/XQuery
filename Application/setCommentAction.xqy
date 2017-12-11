xquery version "1.0-ml";
import module namespace constants = "http://www.TheIET.org/constants"   at "/Utils/constants.xqy"; 
(: Input Param <Comments><VideoID>1234</VideoID><Comment><CommentID>1011</CommentID><Action>Hide,Abuse*</Action><Date></Date></Comment><Comment><CommentID>102</CommentID><Action>Show</Action><Date></Date></Comment><Comment><CommentID>4567</CommentID><Action>Abuse</Action><Date></Date></Comment></Comments> :)

declare variable $inputSearchDetails as xs:string external;
let $Log 		 := xdmp:log("[ IET-TV ][ CommentAction ][ Call ][ Service call ]") 
let $CommentXML  := xdmp:unquote($inputSearchDetails)
let $CheckActionIngestion :=
							for $EachComment in $CommentXML//Comment
							let $CommentUri := fn:concat($constants:COMMENT_DIRECTORY,$EachComment/CommentID/string(),".xml")
							let $Action 	:= $EachComment/Action/string()
							let $UpdateDate := xs:dateTime($EachComment/Date/string())
							return
								try
									{(
									if (xdmp:exists(doc($CommentUri)) eq fn:false())
									then
										(
											xdmp:log(fn:concat("[ IET-TV ][ CommentAction ][ Info ][ No Comment Exists for CommentID ][ ", $EachComment/CommentID/string(), " ]")),
											"Not Exist"
										)
									else
									let $UpdateAction := 	for $EachAction in tokenize($Action,',')
															let $CommentXml := doc($CommentUri)
															let $IsUpdateDateAvailable := $CommentXml/Comment/UpdatedDate
															return
																	if( contains($EachAction,"Abuse") )
																	then
																		let $CurrentAbuse := data($CommentXml/Comment/@abuse)
																		let $NewAbuse := if($CurrentAbuse="yes") then "no" else if($CurrentAbuse="no") then "yes" else "yes"
																		return
																			xdmp:node-replace($CommentXml/Comment/@abuse, attribute abuse {$NewAbuse})
																	else
																	if( contains($EachAction,"Hide") )
																	then
																		xdmp:node-replace($CommentXml/Comment/@show, attribute show {"no"})
																	else
																	if( contains($EachAction,"Show") )
																	then
																		xdmp:node-replace($CommentXml/Comment/@show, attribute show {"yes"})
																	else "Invalid"
									return
										if( $UpdateAction!="Invalid" )
										then
											let $CommentXml := doc($CommentUri)
											let $IsUpdateDateAvailable := $CommentXml/Comment/UpdatedDate
											return
												if( $IsUpdateDateAvailable )
												then xdmp:node-replace($IsUpdateDateAvailable, <UpdatedDate>{$UpdateDate}</UpdatedDate>)
												else xdmp:node-insert-child($CommentXml/Comment, <UpdatedDate>{$UpdateDate}</UpdatedDate>)
										else ()
									)}
								catch($e)
									{(
										xdmp:log("[ IET-TV ][ CommentAction ][ Error ][ Comment Update Error ]")
										,
										"FAIL"
									)}
	return
		if($CheckActionIngestion eq "Invalid")
		then
			(
				xdmp:log("[ IET-TV ][ CommentAction ][ Info ][ Invalid Action Name ]"),
				"ERROR: Please provide valid action name Hide|Show|Abuse"
			)
		else
		if($CheckActionIngestion eq "Not Exist")
		then
			(
				xdmp:log("[ IET-TV ][ CommentAction ][ Info ][ Invalid Comment ID ]"),
				"ERROR: Provided Comment ID does not exist to update"
			)
		else
		if($CheckActionIngestion eq "Fail")
		then
			(
				xdmp:log("[ IET-TV ][ CommentAction ][ Error ][ Error occurs while updating comments ]"),
				"ERROR: Error occurs while updating comments check log for more details"
			)
		else
			(
				xdmp:log("[ IET-TV ][ CommentAction ][ Success ][ Document updated ]"),
				"SUCCESS"
			)
