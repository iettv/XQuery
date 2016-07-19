xquery version "1.0-ml";

import module namespace constants = "http://www.TheIET.org/constants"   at "/Utils/constants.xqy"; 

(: 
	This service is to take Master Related Channel ID from front-end and put it into MarLogic instance
	which will help us to skip Inactive Channel from all the places.
	
		<Channels>
			<Channel>
				<ID>1</ID>
				<Status>Active/Inactive</Status>
				<ChannelType></ChannelType>
			</Channel>
			......
		</Channels>
:)

declare variable $inputSearchDetails as xs:string external;
let $MasterXML := xdmp:unquote($inputSearchDetails)
return
	try
	{(
		if( fn:doc-available($constants:MasterChannelUri) )
		then
			for $EachChannel in $MasterXML//Channel
			let $CurrentChannelID := $EachChannel/ID/text()
			let $MasterChannelDoc := doc($constants:MasterChannelUri)
			let $IsChannelAlreadyExist := if($MasterChannelDoc/Channels/Channel[ID=$CurrentChannelID]) then fn:true() else fn:false()
			return
				if( $IsChannelAlreadyExist = fn:true() )
				then
					xdmp:node-replace($MasterChannelDoc/Channels/Channel[ID/text()=$CurrentChannelID],$EachChannel)
				else
					xdmp:node-insert-child($MasterChannelDoc/Channels,$EachChannel)
		else
			xdmp:document-insert($constants:MasterChannelUri,$MasterXML)
		,
		xdmp:log("[ MasterChannelIngestion ][ Success ][ Master Channel List added Successfully ]")
		,
		"SUCCESS"
	)}
	catch($e)
	{(
		xdmp:log("[ MasterChannelIngestion ][ ERROR ][ Master Channel List ingestion error ]")
		,
		xdmp:log($e)
		,
		"ERROR"
	)}
