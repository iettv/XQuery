xquery version "1.0-ml";

import module namespace constants = "http://www.TheIET.org/constants"   at "/Utils/constants.xqy";

(: Output Params : "<Videos><Video ID='5'><VideoTitle>Video Test</VideoTitle><Duration>00:00:00</Duration><StreamId streamID='123'></StreamId><UploadStatus>Ready</UploadStatus><ModifiedUserEmailID>user@gmail.com</ModifiedUserEmailID><UploadEmailID>user@gmail.com</UploadEmailID><NotificationCount>0</NotificationCount></Video></Videos>" :)

declare variable $inputSearchDetails as xs:string external;

let $Log 	:= xdmp:log("[ IET-TV ][ GetStreamInfo ][ Call ][ Service call ]")
let $Videos :=	for $Video in cts:search(fn:collection($constants:VIDEO_COLLECTION)/Video,
										cts:and-query((
														cts:element-range-query(xs:QName("Duration"), "=",xs:time("00:00:00")),
														cts:element-range-query(xs:QName("NotificationCount"), "<=","2")
													))
										)[1 to 100]
				order by xs:dateTime($Video/ModifiedInfo/Date) descending
				return
					<Video ID="{$Video/@ID}">
						<VideoTitle>{$Video/BasicInfo/Title/text()}</VideoTitle>
						{$Video/UploadVideo/File/Duration}
						<StreamId>{$Video/UploadVideo/File/@streamID}</StreamId>
						<UploadStatus>{$Video/UploadVideo/File/UploadStatus/text()}</UploadStatus>
						<ModifiedUserEmailID>{$Video/ModifiedInfo/Person/EmailID/text()}</ModifiedUserEmailID>
						<UploadEmailID>{$Video/UploadVideo/File/Person/EmailID/text()}</UploadEmailID>
						<NotificationCount>{$Video/UploadVideo/File/NotificationCount/text()}</NotificationCount>
					</Video>
return        
	if($Videos)
	then
	(
		<Videos>{$Videos}</Videos>,
		xdmp:log("[ IET-TV ][ GetStreamInfo ][ Success ][ Service result sent ]")
	)
	else
	(
		"No Video Found",
		xdmp:log("[ IET-TV ][ GetStreamInfo ][ INFO ][ No videos are available to send ]")
	)