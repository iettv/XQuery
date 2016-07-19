xquery version "1.0-ml";

import module namespace VIDEOS = "http://www.TheIET.org/ManageVideos"   at  "/Utils/ManageVideos.xqy";
import module namespace constants = "http://www.TheIET.org/constants"   at "/Utils/constants.xqy";
import module namespace admin     = "http://marklogic.com/xdmp/admin"   at "/MarkLogic/admin.xqy";
import module namespace search    = "http://marklogic.com/appservices/search" at "/MarkLogic/appservices/search/search.xqy";
import module namespace mem       = "http://xqdev.com/in-mem-update"     at  "/MarkLogic/appservices/utils/in-mem-update.xqy";

(: <Video><UserID></UserID><TopList>10</TopList><SearchKey>LocationName</SearchKey><SearchValue>*stevenage*</SearchValue><VideoType>NonPromo</VideoType><PageLength>10</PageLength><StartPage>1</StartPage></Video> :)

declare variable $inputSearchDetails as xs:string external;
let $InputXML  	:= xdmp:unquote($inputSearchDetails, "", ("format-xml", "repair-full"))
let $Log 		:= xdmp:log("[ GetAdminVideoByCriteria ][ CALL1111 ][ Service call successfully ]")
let $userid 	:= $InputXML/Video/UserID
let $TopList	:= $InputXML/Video/TopList
let $searchKey 	:=$InputXML/Video/SearchKey
let $searchValue :=$InputXML/Video/SearchValue
let $VideoType	:= $InputXML/Video/VideoType
let $PageLength	:= $InputXML/Video/PageLength/text()
let $StartPage	:= $InputXML/Video/StartPage/text()
let $Start      := if($StartPage = 1) then $StartPage else sum(($StartPage * $PageLength) - $PageLength + 1)
let $End        := fn:sum(xs:integer($Start) + xs:integer($PageLength))
let $videoXML 	:= (:VIDEOS:get-admin-video($UserId,$TopList,$SearchKey,$SearchValue, $VideoType):)
					<Videos>{
						let $Result :=	if ($userid ne "" and $searchKey ne "VideoID" )
										then 
											(:let $Log := xdmp:log("****************************************A: 1******************"):)
											let $UserQueryCreatedBy  := cts:path-range-query("CreationInfo/Person/@ID", "=", $userid)     
											let $UserQueryModifiedBy := cts:path-range-query("ModifiedInfo/Person/@ID", "=", $userid)        	
											return
												cts:search(fn:collection(fn:concat($constants:VIDEO_TYPE,$VideoType)),
																		cts:and-query((
																			cts:element-query(xs:QName($searchKey),$searchValue),
																			cts:or-query(($UserQueryCreatedBy,$UserQueryModifiedBy))
																			))
															)
										else
										if( $userid ne "" and $searchKey eq "VideoID" )
										then
											 (:let $Log := xdmp:log("****************************************A: 2******************"):)
											 let $UserQueryCreatedBy  := cts:path-range-query("CreationInfo/Person/@ID", "=", $userid)     
											 let $UserQueryModifiedBy := cts:path-range-query("ModifiedInfo/Person/@ID", "=", $userid)        
											 return cts:search(fn:collection(fn:concat($constants:VIDEO_TYPE,$VideoType)),
																		cts:and-query((
																			cts:element-attribute-value-query(xs:QName("Video"),
																			xs:QName("ID"),$searchValue),($UserQueryCreatedBy,$UserQueryModifiedBy)
																))
															)
										else
										if( $userid eq "" and $searchKey eq "VideoID" and $VideoType ne "" )
										then
											(:let $Log := xdmp:log("****************************************A: 3******************")
											return:)
												fn:doc(fn:concat($constants:VIDEO_DIRECTORY,fn:substring-before(fn:substring-after($searchValue,'*'),'*'),".xml"))
										else
										if( $userid eq "" and $searchKey eq "VideoID" and $VideoType eq "" )
										then
											(:let $Log := xdmp:log("****************************************A: 4******************")
											return:) fn:doc(fn:concat($constants:VIDEO_DIRECTORY,$searchValue,".xml"))/Video
										else
										if( $userid  eq "" and $searchKey eq "StreamID"  and $VideoType ne "" )
										then
										(:let $Log := xdmp:log("****************************************A: 7******************")
										return:)
											cts:search(fn:collection(fn:concat($constants:VIDEO_TYPE,$VideoType)),
														cts:element-attribute-value-query(xs:QName("File"),xs:QName("streamID"),$searchValue)
														)
										else
										if( $userid  eq "" and $searchKey eq "LocationName"  and $VideoType ne "" )
										then
											(:let $Log := xdmp:log("****************************************A: 8******************")
											return:)
												fn:collection(fn:concat($constants:VIDEO_TYPE,$VideoType))[cts:contains(/Video/AdvanceInfo/LocationDetails/Location/LocationName,$searchValue)]
										else
										if( $userid  eq "" and ($searchKey ne "VideoID" and $searchKey ne "ModifiedInfo/Date")  and $VideoType ne "" )
										then
										(:let $Log := xdmp:log("****************************************A: 5******************")
										return:)
											cts:search(fn:collection(fn:concat($constants:VIDEO_TYPE,$VideoType)),
														cts:element-query(xs:QName($searchKey),$searchValue)
														)
										else
										if( $userid  eq "" and $searchKey eq "ModifiedInfo/Date" and $VideoType ne "" )
										then
										(:let $Log := xdmp:log("****************************************A: 6******************")
										return:)
											fn:collection(fn:concat($constants:VIDEO_TYPE,$VideoType))[contains(/Video/ModifiedInfo/Date, substring-before($searchValue,"T"))]
										else ()
										
						return 
					  
						if( $Result )
						then
						(
							<Count>{count($Result)}</Count>
							,
									(:let $Log := xdmp:log($Result)
									return:)
										if($PageLength!='0')
										then
											for $EachVideo in ($Result)[position() ge $Start and position() lt $End]
											   let $VideoID :=  <VideoID>{fn:data($EachVideo/Video/@ID)}</VideoID>
											   let $IsCommentAvailable := if( collection(fn:concat($constants:COMMENT, $VideoID)) ) then fn:true() else fn:false()
											   let $IsAbuseReported := if( collection(fn:concat($constants:COMMENT, $VideoID))//Comment/@abuse='yes' ) then fn:true() else fn:false()
												return <Video ID="{$VideoID}" comment="{if($IsCommentAvailable=fn:true()) then 'yes' else 'no'}" abuse="{if($IsAbuseReported=fn:true()) then 'yes' else 'no'}">{
													 $EachVideo/Video/VideoNumber
													,$EachVideo/Video/BasicInfo/Title
													,$EachVideo/Video/CreationInfo
													,$EachVideo/Video/BasicInfo/VideoCategory
													,$EachVideo/Video/VideoStatus
													,$EachVideo/Video/ModifiedInfo
													,$EachVideo/Video/UploadVideo/File/Duration
													,$EachVideo/Video/VideoType
													,$EachVideo/Video/Events
													,$EachVideo/Video/AdvanceInfo/PermissionDetails/Permission[@type="DisplayQAndA"]
													,<StreamID>{data($EachVideo/Video/UploadVideo/File/@streamID)}</StreamID>
													,<Speakers>{normalize-space(string-join(for $EachSpeaker in $EachVideo/Video/Speakers/Person return concat($EachSpeaker/Title/string(), ' ', $EachSpeaker/Name/Given-Name/string(), ' ', $EachSpeaker/Name/Surname/string()), ','))}</Speakers>
													,<Location>{normalize-space(string-join(for $EachLocation in $EachVideo/Video/AdvanceInfo/LocationDetails/Location return $EachLocation/LocationName/string(), ','))}</Location>
												}</Video>
										else
											for $EachVideo in $Result
											   let $VideoID :=  <VideoID>{fn:data($EachVideo/Video/@ID)}</VideoID>
											   let $IsCommentAvailable := if( collection(fn:concat($constants:COMMENT, $VideoID)) ) then fn:true() else fn:false()
											   let $IsAbuseReported := if( collection(fn:concat($constants:COMMENT, $VideoID))//Comment/@abuse='yes' ) then fn:true() else fn:false()
												return <Video ID="{$VideoID}" comment="{if($IsCommentAvailable=fn:true()) then 'yes' else 'no'}" abuse="{if($IsAbuseReported=fn:true()) then 'yes' else 'no'}">{
													 $EachVideo/Video/VideoNumber
													,$EachVideo/Video/BasicInfo/Title
													,$EachVideo/Video/CreationInfo
													,$EachVideo/Video/BasicInfo/VideoCategory
													,$EachVideo/Video/VideoStatus
													,$EachVideo/Video/ModifiedInfo
													,$EachVideo/Video/UploadVideo/File/Duration
													,$EachVideo/Video/VideoType
													,$EachVideo/Video/Events
													,$EachVideo/Video/AdvanceInfo/PermissionDetails/Permission[@type="DisplayQAndA"]
													,<StreamID>{data($EachVideo/Video/UploadVideo/File/@streamID)}</StreamID>
													,<Speakers>{normalize-space(string-join(for $EachSpeaker in $EachVideo/Video/Speakers/Person return concat($EachSpeaker/Title/string(), ' ', $EachSpeaker/Name/Given-Name/string(), ' ', $EachSpeaker/Name/Surname/string()), ','))}</Speakers>
													,<Location>{normalize-space(string-join(for $EachLocation in $EachVideo/Video/AdvanceInfo/LocationDetails/Location return $EachLocation/LocationName/string(), ','))}</Location>
												}</Video>
							)
						else
							"NONE"
					}</Videos>
return $videoXML