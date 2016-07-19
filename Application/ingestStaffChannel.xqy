xquery version "1.0-ml";

import module namespace constants = "http://www.TheIET.org/constants"   at "/Utils/constants.xqy"; 

(: 
	This service is to take Staff Related Channel ID from front-end and put it into MarLogic instance
	which will help us to skip Staff Channel from other users.
	<Channels><Channel>1</Channel><Channel>7</Channel><Channel>8</Channel></Channels>
:)

declare variable $inputSearchDetails as xs:string external;
let $StaffXML := xdmp:unquote($inputSearchDetails)
return
  try{(
      if( $StaffXML//Channel!='' )
	  then xdmp:document-insert($constants:StaffChannelUri,$StaffXML)
	  else ()
      ,
      "SUCCESS"
      ,
      xdmp:log("[ StaffVideoIngestion ][ SUCCESS ][ Staff Channel List added ]")
  )}
  catch($e){(
      xdmp:log("[ StaffVideoIngestion ][ ERROR ][ Staff Channel List added ]")
	  ,
	  xdmp:log($e)
      ,
      "ERROR"
  )}
