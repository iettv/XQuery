xquery version "1.0-ml";

module namespace MARCVIDEOS = "http://www.TheIET.org/MARCManageVideos";

import module namespace MARC_Constants  = "http://www.TheIET.org/MARCConstants"   	at "/MARCUtils/MARCConstants.xqy";
import module namespace admin           = "http://marklogic.com/xdmp/admin"   		at "/MarkLogic/admin.xqy";
import module namespace constants 		= "http://www.TheIET.org/constants"   		at "/Utils/constants.xqy";
import module namespace search    		= "http://marklogic.com/appservices/search" at "/MarkLogic/appservices/search/search.xqy";

(: Function to call for MARC XML 
<Video><TermToSearch> </TermToSearch><StartDate>2015-01-01T00:00:00</StartDate><EndDate>2015-03-13T00:00:00</EndDate><PageLength>10</PageLength><StartPage>1</StartPage></Video>
:)
declare function GetVideoDetailsForMARCXML($TermToSearch as xs:string, $PageLength as xs:integer, $StartPage as xs:integer, $StartDate as xs:dateTime, $EndDate as xs:dateTime) as item()*
{
  let $Start := if($StartPage = 1) then $StartPage else fn:sum(($StartPage * $PageLength) - $PageLength + 1)
	let $SearchOption := <options xmlns="http://marklogic.com/appservices/search">
							<term>
								<term-option>case-insensitive</term-option>
								<term-option>wildcarded</term-option>
								<term-option>stemmed</term-option>
								<term-option>diacritic-insensitive</term-option>
								<term-option>punctuation-insensitive</term-option>
							</term>
							<constraint name="Video">
								<range type="xs:string" facet="true">
									<facet-option>frequency-order</facet-option>
									<facet-option>descending</facet-option>
									<path-index>Video/@ID</path-index>
								</range>
							</constraint>
							<constraint name="Number">
								<range type="xs:int" facet="true">
									<element ns="" name="VideoNumber"/>
									<facet-option>frequency-order</facet-option>
									<facet-option>descending</facet-option>
								</range>
							</constraint>
              <!--Published Copy -->
              <additional-query>
                {cts:collection-query($constants:PCOPY)}
              </additional-query>
          <!-- Additional Query for filter -->
          <additional-query>
					{
						if ($StartDate!=xs:dateTime("1900-01-01T00:00:00") and $EndDate!=xs:dateTime("1900-01-01T00:00:00")) 
						  then
                cts:and-query((
														  cts:path-range-query("ModifiedInfo/Date", ">=", $StartDate),
														  cts:path-range-query("ModifiedInfo/Date", "<=", $EndDate)
													   ))
                 
                             
						else ()
					}
				</additional-query>
		</options>
  let $SearchResponse 		:=  search:search($TermToSearch, $SearchOption, $Start, $PageLength)
  let $TotalVideoRecord 	:= data($SearchResponse/@total)
  let $VideoChunksList :=   for $Record in data($SearchResponse//search:result/@uri) return fn:doc($Record)
                            
  let $VideoFacets :=	<Videos>
								  {
									for $EachFacet in $SearchResponse/search:facet[@name="Video"]/search:facet-value
									return <Video frequency="{fn:data($EachFacet/@count)}">{fn:data($EachFacet/@name)}</Video>
								  }
								</Videos>

  return 
  <Result>
			<TotalRecord>{$TotalVideoRecord}</TotalRecord>
			<Videos>{$VideoChunksList}</Videos>
  </Result> 
	  
};


