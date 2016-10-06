xquery version "1.0-ml";

declare variable $inputSearchDetails as xs:string external ;

(:let $inputSearchDetails := "<Activity>
                                <VideoId>100137</VideoId>
                                <VideoId>6225</VideoId>
                                <VideoId>7136</VideoId>
                                </Activity>
                            ":)
                            
let $InputXML := xdmp:unquote($inputSearchDetails)

let $VideoType := for $VideoID in $InputXML/Activity/VideoId/text()
                  return <record>
                                <video_id>{$VideoID}</video_id>
                                <video_type>{(/Video[@ID=$VideoID][contains(base-uri(),'/PCopy/')]/BasicInfo/VideoCategory/text())[1]}</video_type>
                         </record>

return <root>{$VideoType}</root>
      