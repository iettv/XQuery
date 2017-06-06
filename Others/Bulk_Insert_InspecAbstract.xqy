xquery version "1.0-ml";

declare function local:AddInspecAbstract($VideoXml as item())
{
  
   let $Title            := $VideoXml/Video/BasicInfo/Title/string()
  let $ShortDescription := $VideoXml/Video/BasicInfo/ShortDescription/string()
  let $Abstract         := $VideoXml/Video/BasicInfo/Abstract/.
  let $Speakers         := string-join((for $Person in $VideoXml/Video/Speakers/Person  
                             let $GivenName        := $Person/Name/Given-Name/string()
                             let $Surname          := $Person/Name/Surname/string()
                             let $Organization     := $Person/Affiliations/Affiliation/Organization/OrganizationName/string()
                             return
                                    if (string-length($Organization) ge 1) then (concat($GivenName,' ',$Surname,':',$Organization)) else (concat($GivenName,' ',$Surname)) 
                                   
                             ),";")
  let $GivenName        := $VideoXml/Video/Speakers/Person/Name/Given-Name/string()
  let $Surname          := $VideoXml/Video/Speakers/Person/Name/Surname/string()
  let $ChannelName      := $VideoXml/Video/BasicInfo/ChannelMapping/Channel[@default='true']/ChannelName/string()
  let $ConferenceName   := $VideoXml/Video/Events/Event/Room/string()
  let $EventName        := $VideoXml/Video/Events/Event/EventName/string()
  let $Keywords         := string-join((if ($VideoXml/Video/KeyWordInfo/ChannelKeywordList/Channel/KeywordList/DefaultKeyword) 
                               then (for $i in $VideoXml/Video/KeyWordInfo/ChannelKeywordList/Channel/KeywordList/DefaultKeyword return $i/text()) else (),
                              if ($VideoXml/Video/KeyWordInfo/CustomKeywordList/CustomKeyword)
                              then (for $i in $VideoXml/Video/KeyWordInfo/CustomKeywordList/CustomKeyword return $i) else ()
                           ),";")
  
  return 
          
        fn:string-join(( if (string-length($Title) ge 1) then (normalize-space($Title)) else (),
        if (string-length($ShortDescription) ge 1) then (normalize-space($ShortDescription)) else (),
        if (string-length($Abstract) ge 1) then (normalize-space($Abstract)) else (),
        if (not(empty($Surname)) or not(empty($GivenName))) then (normalize-space($Speakers)) else (),
        if (string-length($ChannelName) ge 1) then (normalize-space($ChannelName)) else (),
        if (string-length($EventName) ge 1) then (normalize-space($EventName)) else (),
        if (string-length($Keywords) ge 1) then (normalize-space($Keywords)) else ()
        ), "
        ")


};

let $CollectionPCopy := 'PublishedCopy'
let $CollectionVideo := 'Video'

for $VideoXml in collection($CollectionVideo)

let $VideoID := $VideoXml/Video/@ID

let $InspecAbstract := <InspecAbstract>{local:AddInspecAbstract($VideoXml)}</InspecAbstract>

return 
        
        (xdmp:node-insert-child($VideoXml/Video,$InspecAbstract),
         xdmp:log(concat("[ IET-TV ][Add InspecAbstract Element ][ Call ][ Successfully Inserted ]",'VideoID: ',$VideoID)),
         concat("[ InspecAbstract Element Inserted Successfully ] ",'VideoID: ',$VideoID)
        )
       