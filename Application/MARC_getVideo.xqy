xquery version "1.0-ml";

import module namespace MARC_Constants  = "http://www.TheIET.org/MARCConstants"   at "/MARCUtils/MARCConstants.xqy";

(: To get Marc Videos  <MarcVideos><VideoID>TEXT</VideoID><VideoID>TEXT</VideoID><VideoID>TEXT</VideoID></MarcVideos> :)

declare variable $inputSearchDetails as xs:string external;

let $MarcVideo  := xdmp:unquote($inputSearchDetails)
let $AllVideos := 	<Videos>
					{
					for $eachMarcVideo in $MarcVideo//VideoID
					let $VideoID   := $eachMarcVideo/text()
					return
						if($VideoID)
						then
						(
							if( fn:doc-available(fn:concat($MARC_Constants:MARC_DIRECTORY,$VideoID,".xml")) )
							then 
								fn:doc(fn:concat($MARC_Constants:MARC_DIRECTORY,$VideoID,".xml"))
							else
							(
								<collection>No Such File Available</collection>
								,
								xdmp:log("*********No Such File Available**********")
							)
						)
						else 
						(
							<collection>VideoID is empty</collection>
							,
							xdmp:log("******VideoID is empty*******")
						)
					}
					</Videos>
return $AllVideos