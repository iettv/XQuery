------------------------------------
(:Activity update :)
for $value in cts:element-values(xs:QName("ActorType"), (), "frequency-order")
return <facet frequency="{cts:frequency($value)}">{$value}</facet>

for $x in /Activity/Actor[ActorType[.='Unanonymous']]
let $UserName := <UserName>Unknown Status</UserName>
let $AccountType := <AccountType>Unknown Status</AccountType>
let $UserType := <UserType>Unknown Status</UserType>
let $CorporateAccountName := <CorporateAccountName>Unknown Status</CorporateAccountName>
return
  (
     if($x/AccountType) then xdmp:node-replace($x/AccountType, $AccountType) else xdmp:node-insert-child($x, $AccountType),
     if($x/$UserType) then xdmp:node-replace($x/UserType, $UserType) else xdmp:node-insert-child($x, $UserType),
     if($x/$UserName) then xdmp:node-replace($x/UserName, $UserName) else xdmp:node-insert-child($x/$UserName, $UserName),
	 if($x/$CorporateAccountName) then xdmp:node-replace($x/CorporateAccountName, $CorporateAccountName) else xdmp:node-insert-child($x/$CorporateAccountName, $CorporateAccountName)
  )
  
for $x in /Activity[Actor/ActorType='Unanonymous' and not(Actor/UserName)]
let $UserName := <UserName>Unknown Status</UserName>
return
  xdmp:node-insert-child($x/Actor, $UserName)

(: if WikiUser | VickyVisitor | VickyVisiter | user is there :)
for $x in /Activity/Actor[CorporateAccountName='VickyVisitor']
let $UserName := <UserName>Unknown Status</UserName>
let $AccountType := <AccountType>Unknown Status</AccountType>
let $UserType := <UserType>Unknown Status</UserType>
let $CorporateAccountName := <CorporateAccountName>Unknown Status</CorporateAccountName>
return
  (
     if($x/AccountType) then xdmp:node-replace($x/AccountType, $AccountType) else xdmp:node-insert-child($x, $AccountType),
     if($x/$UserType) then xdmp:node-replace($x/UserType, $UserType) else xdmp:node-insert-child($x, $UserType),
     if($x/$UserName) then xdmp:node-replace($x/UserName, $UserName) else xdmp:node-insert-child($x/$UserName, $UserName),
	 if($x/$CorporateAccountName) then xdmp:node-replace($x/CorporateAccountName, $CorporateAccountName) else xdmp:node-insert-child($x/$CorporateAccountName, $CorporateAccountName)
  )
  

for $x in /Activity/Actor[CorporateAccountName='VickyVisiter']
let $UserName := <UserName>Unknown Status</UserName>
let $AccountType := <AccountType>Unknown Status</AccountType>
let $UserType := <UserType>Unknown Status</UserType>
let $CorporateAccountName := <CorporateAccountName>Unknown Status</CorporateAccountName>
return
  (
     if($x/AccountType) then xdmp:node-replace($x/AccountType, $AccountType) else xdmp:node-insert-child($x, $AccountType),
     if($x/$UserType) then xdmp:node-replace($x/UserType, $UserType) else xdmp:node-insert-child($x, $UserType),
     if($x/$UserName) then xdmp:node-replace($x/UserName, $UserName) else xdmp:node-insert-child($x/$UserName, $UserName),
	 if($x/$CorporateAccountName) then xdmp:node-replace($x/CorporateAccountName, $CorporateAccountName) else xdmp:node-insert-child($x/$CorporateAccountName, $CorporateAccountName)
  )
  

for $x in /Activity/Actor[AccountType='WikiUser']
let $UserName := <UserName>Unknown Status</UserName>
let $AccountType := <AccountType>Unknown Status</AccountType>
let $UserType := <UserType>Unknown Status</UserType>
let $CorporateAccountName := <CorporateAccountName>Unknown Status</CorporateAccountName>
return
  (
     if($x/AccountType) then xdmp:node-replace($x/AccountType, $AccountType) else xdmp:node-insert-child($x, $AccountType),
     if($x/$UserType) then xdmp:node-replace($x/UserType, $UserType) else xdmp:node-insert-child($x, $UserType),
     if($x/$UserName) then xdmp:node-replace($x/UserName, $UserName) else xdmp:node-insert-child($x/$UserName, $UserName),
	 if($x/$CorporateAccountName) then xdmp:node-replace($x/CorporateAccountName, $CorporateAccountName) else xdmp:node-insert-child($x/$CorporateAccountName, $CorporateAccountName)
  )


for $x in /Activity/Actor[UserType='WikiUser']
let $UserName := <UserName>Unknown Status</UserName>
let $AccountType := <AccountType>Unknown Status</AccountType>
let $UserType := <UserType>Unknown Status</UserType>
let $CorporateAccountName := <CorporateAccountName>Unknown Status</CorporateAccountName>
return
  (
     if($x/AccountType) then xdmp:node-replace($x/AccountType, $AccountType) else xdmp:node-insert-child($x, $AccountType),
     if($x/$UserType) then xdmp:node-replace($x/UserType, $UserType) else xdmp:node-insert-child($x, $UserType),
     if($x/$UserName) then xdmp:node-replace($x/UserName, $UserName) else xdmp:node-insert-child($x/$UserName, $UserName),
	 if($x/$CorporateAccountName) then xdmp:node-replace($x/CorporateAccountName, $CorporateAccountName) else xdmp:node-insert-child($x/$CorporateAccountName, $CorporateAccountName)
  )
  

for $x in /Activity/Actor[CorporateAccountName='WikiUser']
let $UserName := <UserName>Unknown Status</UserName>
let $AccountType := <AccountType>Unknown Status</AccountType>
let $UserType := <UserType>Unknown Status</UserType>
let $CorporateAccountName := <CorporateAccountName>Unknown Status</CorporateAccountName>
return
  (
     if($x/AccountType) then xdmp:node-replace($x/AccountType, $AccountType) else xdmp:node-insert-child($x, $AccountType),
     if($x/$UserType) then xdmp:node-replace($x/UserType, $UserType) else xdmp:node-insert-child($x, $UserType),
     if($x/$UserName) then xdmp:node-replace($x/UserName, $UserName) else xdmp:node-insert-child($x/$UserName, $UserName),
	 if($x/$CorporateAccountName) then xdmp:node-replace($x/CorporateAccountName, $CorporateAccountName) else xdmp:node-insert-child($x/$CorporateAccountName, $CorporateAccountName)
  )



(: not required :)
for $x in /Activity/Actor[ActorType='Unanonymous' and matches(UserName, "vicky", 'i')]
let $UserName := <UserName>Unknown Status</UserName>
let $AccountType := <AccountType>Unknown Status</AccountType>
let $UserType := <UserType>Unknown Status</UserType>
let $CorporateAccountName := <CorporateAccountName>Unknown Status</CorporateAccountName>
return
  (
     if($x/AccountType) then xdmp:node-replace($x/AccountType, $AccountType) else xdmp:node-insert-child($x, $AccountType),
     if($x/$UserType) then xdmp:node-replace($x/UserType, $UserType) else xdmp:node-insert-child($x, $UserType),
     if($x/$UserName) then xdmp:node-replace($x/UserName, $UserName) else xdmp:node-insert-child($x/$UserName, $UserName),
     if($x/$CorporateAccountName) then xdmp:node-replace($x/CorporateAccountName, $CorporateAccountName) else xdmp:node-insert-child($x/$CorporateAccountName, $CorporateAccountName)
  )
  
(: not required :)
for $x in /Activity/Actor[ActorType='Unanonymous' and matches(UserName, "Wiki", 'i')]
let $UserName := <UserName>Unknown Status</UserName>
let $AccountType := <AccountType>Unknown Status</AccountType>
let $UserType := <UserType>Unknown Status</UserType>
let $CorporateAccountName := <CorporateAccountName>Unknown Status</CorporateAccountName>
return
  (
     if($x/AccountType) then xdmp:node-replace($x/AccountType, $AccountType) else xdmp:node-insert-child($x, $AccountType),
     if($x/$UserType) then xdmp:node-replace($x/UserType, $UserType) else xdmp:node-insert-child($x, $UserType),
     if($x/$UserName) then xdmp:node-replace($x/UserName, $UserName) else xdmp:node-insert-child($x/$UserName, $UserName),
     if($x/$CorporateAccountName) then xdmp:node-replace($x/CorporateAccountName, $CorporateAccountName) else xdmp:node-insert-child($x/$CorporateAccountName, $CorporateAccountName)
  )




  =================================================