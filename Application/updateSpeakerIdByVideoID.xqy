xquery version "1.0-ml";

declare variable $inputSearchDetails as xs:string external;

(:let $inputXML := "<Video><VideoID>2277</VideoID><Speakers><Speaker 

ID='25564'><FirstName>Eric</FirstName><LastName>Dautriat</LastName></Speaker></Speakers></Video>":)

let $input := xdmp:unquote($inputSearchDetails)

let $video_id := $input/Video/VideoID/text()

let $pc_path := concat('/PCopy/',$video_id,'.xml')

let $vi_path := concat('/Video/',$video_id,'.xml')

for $source in $input/Video/Speakers/Speaker

let $speaker_id := $source/@ID
let $first_person := $source/FirstName
let $sur_person := $source/LastName 

let $pc_givname := doc($pc_path)/Video/Speakers/Person/Name/Given-Name
let $pc_surname := doc($pc_path)/Video/Speakers/Person/Name/Surname

let $vi_givname := doc($vi_path)/Video/Speakers/Person/Name/Given-Name
let $vi_surname := doc($vi_path)/Video/Speakers/Person/Name/Surname

return (
       xdmp:node-replace(doc($pc_path)/Video/Speakers/Person[$first_person eq Name/Given-Name/text() and $sur_person eq Name/Surname/text()]/@ID, $source/@ID),
       
       xdmp:node-replace(doc($vi_path)/Video/Speakers/Person[$first_person eq Name/Given-Name/text() and $sur_person eq Name/Surname/text()]/@ID, $source/@ID),
       concat('SUCCESS')
       (:(
       if (doc($pc_path)/Video/Speakers/Person/@ID/string()=$speaker_id)
       then (concat('SUCCESS'))
       else (concat('Names does not matches or URL does not exist: ',$pc_path))
       ),
       (
       if (doc($vi_path)/Video/Speakers/Person/@ID/string()=$speaker_id)
       then (concat('SUCCESS'))
       else (concat('Names does not matches or URL does not exist: ',$vi_path))
       ):)
	   
	)
