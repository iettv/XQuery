xquery version "1.0-ml";
import module namespace VIDEOS = "http://www.TheIET.org/ManageVideos"   at "/Utils/ManageVideos.xqy";
import module namespace constants = "http://www.TheIET.org/constants"   at "/Utils/constants.xqy"; 

(: Input Params : "<Videos><Video ID='2'><Duration>02:00:00</Duration><StreamId streamID='123'></StreamId><UploadStatus>ReadyPre-change</UploadStatus><ModifiedUserEmailID>user@gmail.com</ModifiedUserEmailID><UploadEmailID>user@gmail.com</UploadEmailID><NotificationCount>0</NotificationCount></Video></Videos>" :)

declare variable $inputSearchDetails as xs:string external; 

let $InputXML 	 := xdmp:unquote($inputSearchDetails)
let $Log 		:= xdmp:log("[ IET-TV ][ SetStreamInfo ][ Call ][ Service call ]")

let $isVideoIDValid :=  string-join(
							for $VideoType at $position in $InputXML//Video
							let $IsVideoIDValid := fn:doc-available(concat($constants:PCOPY_DIRECTORY,$VideoType/@ID,".xml"))
							return
								if( $IsVideoIDValid eq fn:false())
								then concat($position," - ",fn:data($VideoType/@ID)) else ()
							," # ")
let $CheckVideoParameter := for $VideoType in $InputXML//Video
							return
								if( $VideoType/@ID = '' or $VideoType/Duration = '' )
								then fn:false()	else fn:true()
return
(
	if($CheckVideoParameter eq fn:false())
	then
	(
		xdmp:log("[ IET-TV ][ SetStreamInfo ][ Info ][ Some VideoID or Duration is empty ]"),
		"Some VideoID or Duration is empty"
	)
	else
	(
		let $result :=	for $EachVideo in $InputXML//Video
						return
							  try
							  {
								(
									xdmp:node-replace(doc(concat($constants:VIDEO_DIRECTORY,$EachVideo/@ID,".xml"))/Video//Duration, <Duration>{$EachVideo/Duration/text()}</Duration>),
									xdmp:node-replace(doc(concat($constants:VIDEO_DIRECTORY,$EachVideo/@ID,".xml"))/Video/UploadVideo/File/UploadStatus, <UploadStatus>{$EachVideo/UploadStatus/text()}</UploadStatus>),
									xdmp:node-replace(doc(concat($constants:VIDEO_DIRECTORY,$EachVideo/@ID,".xml"))/Video/UploadVideo/File/NotificationCount, <NotificationCount>{$EachVideo/NotificationCount/text()}</NotificationCount>),
									if( fn:doc-available(fn:concat($constants:PCOPY_DIRECTORY,$EachVideo/@ID,".xml")) )
									then
									(
										xdmp:node-replace(doc(fn:concat($constants:PCOPY_DIRECTORY,$EachVideo/@ID,".xml"))/Video//Duration, <Duration>{$EachVideo/Duration/text()}</Duration>),
										xdmp:node-replace(doc(fn:concat($constants:PCOPY_DIRECTORY,$EachVideo/@ID,".xml"))/Video/UploadVideo/File/UploadStatus, <UploadStatus>{$EachVideo/UploadStatus/text()}</UploadStatus>),
										xdmp:node-replace(doc(fn:concat($constants:PCOPY_DIRECTORY,$EachVideo/@ID,".xml"))/Video/UploadVideo/File/NotificationCount, <NotificationCount>{$EachVideo/NotificationCount/text()}</NotificationCount>)
									)
									else ()
								)
							  }
							  catch($e)
							  {(
									xdmp:log(concat("[ DurationIngestion ][ ERROR ][ ", $EachVideo/VideoID, " ]")),
									"DurationIngestion ERROR"
							  )}
		
		return 
		(
		xdmp:log("[ IET-TV ][ SetStreamInfo ][ Success ][ Result sent ]"),
		$isVideoIDValid
		)
	)
)
