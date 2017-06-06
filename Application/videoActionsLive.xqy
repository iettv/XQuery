xquery version "1.0-ml";

(: <VideoAction><VideoID></VideoID><UserID>456</UserID><UserIP>10.120.50</UserIP><Email></Email><Action>Dislike/Like/View</Action></VideoAction> :)

import module namespace constants  = "http://www.TheIET.org/constants"    at  "/Utils/constants.xqy";
import module namespace VIDEOS     = "http://www.TheIET.org/ManageVideos" at  "/Utils/ManageVideos.xqy";


declare function local:updateLikeCount($VideoID, $UpdatedLike)
{
	let $PHistoryUri := fn:concat($constants:PCOPY_DIRECTORY,$VideoID,".xml")
	return
	   if( fn:doc-available($PHistoryUri) )
	   then
		  let $LikeCount := doc($PHistoryUri)/Video/LiveLikeCount
		  return
			if($LikeCount)
			then xdmp:node-replace($LikeCount, <LiveLikeCount>{$UpdatedLike}</LiveLikeCount>)
			else xdmp:node-insert-child(doc($PHistoryUri)/Video,  <LiveLikeCount>{$UpdatedLike}</LiveLikeCount>)
	   else ()
};

declare function local:updateDislikeCount($VideoID, $UpdatedDislike)
{
	let $PHistoryUri := fn:concat($constants:PCOPY_DIRECTORY,$VideoID,".xml")
	return
	   if( fn:doc-available($PHistoryUri) )
	   then
		  let $DislikeCount := doc($PHistoryUri)/Video/LiveDislikeCount
		  return
			if($DislikeCount)
			then xdmp:node-replace($DislikeCount, <LiveDislikeCount>{$UpdatedDislike}</LiveDislikeCount>)
			else xdmp:node-insert-child(doc($PHistoryUri)/Video,  <LiveDislikeCount>{$UpdatedDislike}</LiveDislikeCount>)
	   else ()
};

declare variable $inputSearchDetails as xs:string external;

let $VideoXML := xdmp:unquote($inputSearchDetails)
let $VideoID := $VideoXML/VideoAction/VideoID/text()
let $Action := $VideoXML/VideoAction/Action/text()
let $UserID := $VideoXML/VideoAction/UserID/text()
let $UserIP := $VideoXML/VideoAction/UserIP/text()
let $UserEmail :=$VideoXML/VideoAction/Email/text()
return
  if( not($VideoID) or (string-length($VideoID) le 0) )
  then
	"ERROR!!! Please provide video ID."
  else
  if( $Action!='Like' and $Action!='Dislike' and $Action!='View' )
  then
	"ERROR!!! Please provide action must be Like or Dislike only."
  else
  if( not($UserID) and not($UserIP) and not($UserEmail) )
  then
	"ERROR!!! Please provide minimum one value from UserID, UserIP, or Email."
  else
	(: To check: is video exist on ML database :)
    let $VideoUri := concat($constants:PCOPY_DIRECTORY, $VideoID, ".xml")
    return 
    if( not(doc-available($VideoUri)) )
    then
      "ERROR!!! This Video ID does not exist"
    else
		let $ActionUri := concat($constants:ACTION_LIVE_DIRECTORY,$VideoID,$constants:STUF_ACTION,".xml")
		let $IsActionDocAvailable := doc-available($ActionUri)
		return
         		if (fn:doc($VideoUri)/Video/PublishInfo/LivePublish[@active='yes'])
         		then
                       	if ($Action="View" and $IsActionDocAvailable = fn:false())
                       			
                       			    then
                       			            let $ActionXML := <VideoAction><VideoID>{$VideoID}</VideoID><LiveViews>1</LiveViews></VideoAction>
                       			                                     
                               					return
                               					(
                               					   xdmp:document-insert($ActionUri,$ActionXML,(), $constants:ACTION_LIVE)
                               						,
                               					   let $PHistoryUri := fn:concat($constants:PCOPY_DIRECTORY,$VideoID,".xml")
                               					   return
                               						   if( fn:doc-available($PHistoryUri))
                               						   then
                               							     let $LiveViewCount := doc($PHistoryUri)/Video/LiveViewCount
                                                          							  return
                                                          								if($LiveViewCount)
                                                          								then xdmp:node-replace($LiveViewCount, <LiveViewCount>{sum($LiveViewCount/text()+1)}</LiveViewCount>)
                                                          								else
                                                          									let $View := doc(concat($constants:ACTION_LIVE_DIRECTORY, $VideoID, $constants:STUF_ACTION,'.xml'))//LiveViews/text()
                                                          									return xdmp:node-insert-child(doc($PHistoryUri)/Video,  <LiveViewCount>{if($View) then sum($View+1) else 0}</LiveViewCount>)
                               						   else ()
                               						,
                                           let $PHistoryUri := fn:concat($constants:PCOPY_DIRECTORY,$VideoID,".xml")
                                           return 
                               						if (doc($PHistoryUri))
                               						then
                               						      <Result id="{$VideoID}"><User><Action></Action></User><LiveLikes>0</LiveLikes><LiveDisLikes>0</LiveDisLikes><LiveViews>1</LiveViews></Result>
                               						else ()
                               						      
                               					)
              			else if( $Action = "View" and ($IsActionDocAvailable = fn:true()) )
              			     then
                             					let $GetActionDoc := doc($ActionUri)
                             					let $LiveCurrentView := number($GetActionDoc/VideoAction/LiveViews)
                             					let $CurrentLike := count($GetActionDoc/VideoAction/User/Action[.='Like'])
                             					let $CurrentDisLike := count($GetActionDoc/VideoAction/User/Action[.='Dislike'])
                             					let $UserAction := $GetActionDoc/VideoAction/User[(UserID=$UserID) or (UserIP=$UserIP) or (Email=$UserEmail)]/Action/text()
                             					return
                             					(
                             					    xdmp:node-replace($GetActionDoc//VideoAction/LiveViews, <LiveViews>{sum($LiveCurrentView + 1)}</LiveViews>)
                             						,
                             						let $PHistoryUri := fn:concat($constants:PCOPY_DIRECTORY,$VideoID,".xml")
                             						return
                             						   if(fn:doc-available($PHistoryUri))
                             						   then
                             						          let $LiveViewCount := doc($PHistoryUri)/Video/LiveViewCount
                                            							  return
                                            								if($LiveViewCount)
                                            								then xdmp:node-replace($LiveViewCount, <LiveViewCount>{sum($LiveViewCount/text()+1)}</LiveViewCount>)
                                            								else
                                            									let $View := doc(concat($constants:ACTION_LIVE_DIRECTORY, $VideoID, $constants:STUF_ACTION,'.xml'))//LiveViews/text()
                                            									return xdmp:node-insert-child(doc($PHistoryUri)/Video,  <LiveViewCount>{if($View) then sum($View+1) else 0}</LiveViewCount>)
                             						   else ()						
                             						,
                             						<Result id="{$VideoID}"><User><Action>{$UserAction}</Action></User><LiveLikes>{$CurrentLike}</LiveLikes><LiveDisLikes>{$CurrentDisLike}</LiveDisLikes><LiveViews>{sum($LiveCurrentView + 1)}</LiveViews></Result>
                             					)
              			
              			else
              			if( $Action != "View" and $IsActionDocAvailable = fn:true() )
              			then
              				let $GetActionDoc := doc($ActionUri)
              				let $LiveCurrentView := number($GetActionDoc/VideoAction/LiveViews)
              				let $CurrentLike := count($GetActionDoc/VideoAction/User/Action[.='Like'])
              				let $CurrentDisLike := count($GetActionDoc/VideoAction/User/Action[.='Dislike'])
              				let $IsUserActionExists := $GetActionDoc/VideoAction/User[(UserID=$UserID) or (UserIP=$UserIP) or (Email=$UserEmail)]
              				let $UserAction := $IsUserActionExists/Action/text()
              				return
              					if(not($IsUserActionExists/child::*))
              					then
              						if($Action = "Like")
              						then
              							(
              								xdmp:node-insert-child($GetActionDoc/VideoAction, <User><UserID>{$UserID}</UserID><UserIP>{$UserIP}</UserIP><Email>{$UserEmail}</Email><Action>{$Action}</Action></User>),
              								<Result id="{$VideoID}"><User><Action>{$Action}</Action></User><LiveLikes>{sum($CurrentLike + 1)}</LiveLikes><LiveDisLikes>{$CurrentDisLike}</LiveDisLikes><LiveViews>{$LiveCurrentView}</LiveViews></Result>,
              								local:updateLikeCount($VideoID,sum($CurrentLike + 1)),
              								local:updateDislikeCount($VideoID,$CurrentDisLike)
              							)
              						else
              							(
              								xdmp:node-insert-child($GetActionDoc/VideoAction, <User><UserID>{$UserID}</UserID><UserIP>{$UserIP}</UserIP><Email>{$UserEmail}</Email><Action>{$Action}</Action></User>),
              								<Result id="{$VideoID}"><User><Action>{$Action}</Action></User><LiveLikes>{$CurrentLike}</LiveLikes><LiveDisLikes>{sum($CurrentDisLike + 1)}</LiveDisLikes><LiveViews>{$LiveCurrentView}</LiveViews></Result>,
              								local:updateLikeCount($VideoID,$CurrentLike),
              								local:updateDislikeCount($VideoID,sum($CurrentDisLike + 1))
              							)
              					else if($IsUserActionExists/child::*)
              					then
              						if($Action = "Like")
              						then
              								if($UserAction!="Like")
              								then
              									(
              									xdmp:node-replace($IsUserActionExists/Action, <Action>{$Action}</Action>),
              									<Result id="{$VideoID}"><User><Action>{$UserAction}</Action></User><LiveLikes>{sum($CurrentLike + 1)}</LiveLikes><LiveDisLikes>{if($CurrentDisLike) then sum($CurrentDisLike - 1) else 0}</LiveDisLikes><LiveViews>{$LiveCurrentView}</LiveViews></Result>,
              									local:updateLikeCount($VideoID,sum($CurrentLike + 1)),
              									local:updateDislikeCount($VideoID,sum($CurrentDisLike - 1))
              									)
              								else
              									(
              										<Result id="{$VideoID}"><User><Action>{$UserAction}</Action></User><LiveLikes>{if($CurrentLike) then $CurrentLike else 0}</LiveLikes><LiveDisLikes>{if($CurrentDisLike) then $CurrentDisLike else 0}</LiveDisLikes><LiveViews>{$LiveCurrentView}</LiveViews></Result>,
              										local:updateLikeCount($VideoID, if($CurrentLike) then $CurrentLike else 0),
              										local:updateDislikeCount($VideoID, if($CurrentDisLike) then $CurrentDisLike else 0)
              									)	
              								
              						else if ($UserAction!="Dislike")
              						then
              								(
              								xdmp:node-replace($IsUserActionExists/Action, <Action>{$Action}</Action>),
              								<Result id="{$VideoID}"><User><Action>{$UserAction}</Action></User><LiveLikes>{if($CurrentLike) then sum($CurrentLike - 1) else 0}</LiveLikes><LiveDisLikes>{sum($CurrentDisLike + 1)}</LiveDisLikes><LiveViews>{$LiveCurrentView}</LiveViews></Result>,
              								local:updateLikeCount($VideoID, if($CurrentLike) then sum($CurrentLike - 1) else 0),
              								local:updateDislikeCount($VideoID, if($CurrentDisLike) then sum($CurrentDisLike + 1) else 0)
              								)
              						else
              							(
              								<Result id="{$VideoID}"><User><Action>{$UserAction}</Action></User><LiveLikes>{if($CurrentLike) then $CurrentLike else 0}</LiveLikes><LiveDisLikes>{if($CurrentDisLike) then $CurrentDisLike else 0}</LiveDisLikes><LiveViews>{$LiveCurrentView}</LiveViews></Result>,
              								local:updateLikeCount($VideoID, if($CurrentLike) then $CurrentLike else 0),
              								local:updateDislikeCount($VideoID, if($CurrentDisLike) then $CurrentDisLike else 0)
              							)	
              					else ()
              			else
              				let $ActionXML := <VideoAction><VideoID>{$VideoID}</VideoID><LiveViews>0</LiveViews><User><UserID>{$UserID}</UserID><UserIP>{$UserIP}</UserIP><Email>{$UserEmail}</Email><Action>{$Action}</Action></User></VideoAction>
              				return
              					(
              						xdmp:document-insert($ActionUri,$ActionXML,(), $constants:ACTION)
              						,
              						<Result id="{$VideoID}"><User><Action>{$Action}</Action></User><LiveLikes>{if($Action="Like") then 1 else 0}</LiveLikes><LiveDisLikes>{if($Action="Dislike") then 1 else 0}</LiveDisLikes><LiveViews>0</LiveViews></Result>
              						,
              						local:updateLikeCount($VideoID, if($Action="Like") then 1 else 0),
              						local:updateDislikeCount($VideoID, if($Action="Dislike") then 1 else 0)
              					)
                else ("ERROR!!! This Video Is Not Live")
                