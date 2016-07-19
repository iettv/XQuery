xquery version "1.0-ml";

let $Log 			:= xdmp:log("[ IET-TV ][ Activity-GetDistinctType ][ Call ][ To get distinct value of Device|ActivityType|PriceType call ]")
let $Device 		:= for $EachActivity in distinct-values(fn:doc()/Activity/Actor/Device)
						return <Device>{$EachActivity}</Device>
			   
let $ActivityType := for $EachActivity in distinct-values(fn:doc()/Activity/Action/Type)
                     return <ActivityType>{$EachActivity}</ActivityType>
					 
let $PriceType := for $EachActivity in distinct-values(fn:doc()/Activity/Action/AdditionalInfo/NameValue[Name eq "PriceType"]/Value)
                  return <PriceType>{$EachActivity}</PriceType>
			   
return
	(
		<Activities><Devices>{$Device}</Devices><ActivityTypes>{$ActivityType}</ActivityTypes><PriceTypes>{$PriceType}</PriceTypes></Activities>,
		xdmp:log("[ IET-TV ][ Activity-GetDistinctType ][ Success ][ To get distinct value of Device|ActivityType|PriceType result sent ]")
	)