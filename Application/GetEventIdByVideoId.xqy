
xquery version "1.0-ml";

declare variable $inputSearchDetails as xs:string external ;

(:let $inputSearchDetails := "<record> 
                              <VideoID>97728748-0541-4bf9-ad84-62348960b768</VideoID>
                            </record>" :)
                            
let $InputXML := xdmp:unquote($inputSearchDetails)

let $VideoID := $InputXML/record/VideoID/text()

let $VideoInfo := for $VideoID in /Video[contains(base-uri(),'/PCopy/')][@ID/string()=$VideoID]
                  return    <Event> 
                                <EventId>{ $VideoID/Events/Event/@ID/string()}</EventId>
                              
                            </Event>

return <Record>{$VideoInfo}</Record>
