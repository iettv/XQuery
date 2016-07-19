xquery version "1.0-ml";

declare variable $inputSearchDetails as xs:string external ;

(:let $inputSearchDetails := "<Video>
                            <VideoID>100571</VideoID>
                            <ModifiedInfo>
                                  <Date>2015-04-21T20:27:44.3357</Date>
                                  <Person ID='0'>
                                  <Name>
                                  <Given-Name/>
                                  <Surname>Jack</Surname>
                                  <Suffix/>
                                  </Name>
                                  <EmailID/>
                                  </Person>
                            </ModifiedInfo>
                            <BasicInfo>
                                <Title>Artificia Intelligence - Ant colony optimization algorithms In computer science and
                                    operations</Title>
                                <VideoCategory>Lecture</VideoCategory>
                                <Abstract>
                                    <p>In the natural world, ants (initially) wander&nbsp;randomly, and upon finding food
                                        return to their colony while laying down&nbsp;pheromone&nbsp;trails. If other ants
                                        find such a path, they are likely not to keep travelling at random, but instead to
                                        follow the trail, returning and reinforcing it if they eventually find food
                                        (see&nbsp;Ant communication).</p>
                                    <p>&nbsp;</p>
                                    <p>In&nbsp;computer science&nbsp;and&nbsp;operations research, the&nbsp;<strong>ant
                                        colony optimization</strong>&nbsp;algorithm&nbsp;(<strong>ACO</strong>) is
                                        a&nbsp;probabilistic&nbsp;technique for solving computational problems which can be
                                        reduced to finding good paths through&nbsp;graphs.</p>
                                </Abstract>
                                <ShortDescription>Artificial Intelligence1</ShortDescription>
                                <VideoCreatedDate>2016-06-10T00:00:00.0000</VideoCreatedDate>
                            </BasicInfo>
                        </Video>":)

let $input := xdmp:unquote($inputSearchDetails)

let $InputVideoID := $input/Video/VideoID/text()

let $ModifiedInfo     := $input/Video/ModifiedInfo
let $Title            := $input/Video/BasicInfo/Title
let $VideoCategory    := $input/Video/BasicInfo/VideoCategory
let $Abstract         := $input/Video/BasicInfo/Abstract
let $ShortDescription := $input/Video/BasicInfo/ShortDescription
let $VideoCreatedDate := $input/Video/BasicInfo/VideoCreatedDate


for $i in doc()/Video[@ID/string()=$InputVideoID]

return (  (if ($i/ModifiedInfo/text() or $i/ModifiedInfo)
          then (xdmp:node-replace($i/ModifiedInfo, $ModifiedInfo))
          else (xdmp:node-insert-after($i/CreationInfo, $ModifiedInfo))
          ),
          (if ($i/BasicInfo/Title/text() or $i/BasicInfo/Title)
          then (xdmp:node-replace($i/BasicInfo/Title, $Title))
          else (xdmp:node-insert-before($i/BasicInfo/VideoCategory, $Title))
          ),
          (if ($i/BasicInfo/VideoCategory/text() or $i/BasicInfo/VideoCategory)
          then (xdmp:node-replace($i/BasicInfo/VideoCategory, $VideoCategory))
          else (xdmp:node-insert-after($i/BasicInfo/Title, $VideoCategory))
          ),
          (if ($i/BasicInfo/Abstract/text() or $i/BasicInfo/Abstract)
          then (xdmp:node-replace($i/BasicInfo/Abstract, $Abstract))
          else (xdmp:node-insert-after($i/BasicInfo/VideoCategory, $Abstract))
          )
          ,
          (if ($i/BasicInfo/ShortDescription/text() or $i/BasicInfo/ShortDescription)
          then (xdmp:node-replace($i/BasicInfo/ShortDescription, $ShortDescription))
          else (xdmp:node-insert-after($i/BasicInfo/Abstract, $ShortDescription))
          )
          ,
          (if ($i/BasicInfo/VideoCreatedDate/text() or $i/BasicInfo/VideoCreatedDate)
          then (xdmp:node-replace($i/BasicInfo/VideoCreatedDate, $VideoCreatedDate))
          else (xdmp:node-insert-after($i/BasicInfo/ShortDescription, $VideoCreatedDate))
          ),
          (
            if($i/@ID/string()=$InputVideoID)
            then ("SUCCESS")
            else ("FAILURE")
          )
       )
       