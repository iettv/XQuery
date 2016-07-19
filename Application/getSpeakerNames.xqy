xquery version "1.0-ml";

(: This service will fetch out speaker names from ML repository:)

 <Names>
 {
   for $EachName in cts:values(cts:path-reference(('Speakers/Person/Name/Surname', 'Speakers/Person/Name/Given-Name'),'collation=http://marklogic.com/collation/en/S1'))
   return <Name>{$EachName}</Name>
 }
 </Names>