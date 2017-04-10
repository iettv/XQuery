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
		  let $LikeCount := doc($PHistoryUri)/Video/LikeCount
		  return
			if($LikeCount)
			then xdmp:node-replace($LikeCount, <LikeCount>{$UpdatedLike}</LikeCount>)
			else xdmp:node-insert-child(doc($PHistoryUri)/Video,  <LikeCount>{$UpdatedLike}</LikeCount>)
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
    let $DraftVideoUri := concat($constants:PCOPY_DIRECTORY, $VideoID, ".xml")
    let $CheckViews := doc(concat($constants:ACTION_DIRECTORY,$VideoID,$constants:SUF_ACTION,".xml"))
    return 
    if( not(doc-available($VideoUri)) )
    then
      "ERROR!!! This Video ID does not exist"
    else
		let $ActionUri := concat($constants:ACTION_DIRECTORY,$VideoID,$constants:SUF_ACTION,".xml")
		let $IsActionDocAvailable := doc-available($ActionUri)
		return
         			
         			if( ($Action="View") and ((($IsActionDocAvailable = fn:false())) or (not($CheckViews/VideoAction/LiveViews))) )
         			
         			    then
         			            let $ActionXML := if (fn:doc($DraftVideoUri)/Video/PublishInfo/LivePublish[@active='yes'])
         			                              then
         			                                     <VideoAction><VideoID>{$VideoID}</VideoID><LiveViews>1</LiveViews></VideoAction>
         			                              else ()
         			                                     
                 					return
                 					(
                 					   xdmp:document-insert($ActionUri,$ActionXML,(), $constants:ACTION)
                 						,
                 					   let $PHistoryUri := fn:concat($constants:PCOPY_DIRECTORY,$VideoID,".xml")
                 					   return
                 						   if( fn:doc-available($PHistoryUri) and doc($PHistoryUri)/Video/PublishInfo/LivePublish[@active='yes'] )
                 						   then
                 							     let $LiveViewCount := doc($PHistoryUri)/Video/LiveViewCount
                                            							  return
                                            								if($LiveViewCount)
                                            								then xdmp:node-replace($LiveViewCount, <LiveViewCount>{sum($LiveViewCount/text()+1)}</LiveViewCount>)
                                            								else
                                            									let $View := doc(concat($constants:ACTION_DIRECTORY, $VideoID, $constants:SUF_ACTION,'.xml'))//LiveViews/text()
                                            									return xdmp:node-insert-child(doc($PHistoryUri)/Video,  <LiveViewCount>{if($View) then sum($View+1) else 0}</LiveViewCount>)
                 						   else ()
                 						,
                             let $PHistoryUri := fn:concat($constants:PCOPY_DIRECTORY,$VideoID,".xml")
                             return 
                 						if (doc($PHistoryUri)/Video/PublishInfo/LivePublish[@active='yes'])
                 						then
                 						      <Result id="{$VideoID}"><User><Action></Action></User><Likes>0</Likes><DisLikes>0</DisLikes><LiveViews>1</LiveViews></Result>
                 						else ()
                 						      
                 					)
			else if( $Action = "View" and ($IsActionDocAvailable = fn:true()) )
			     then
               					let $GetActionDoc := doc($ActionUri)
               					let $CurrentView := number($GetActionDoc/VideoAction/Views)
               					let $LiveCurrentView := number($GetActionDoc/VideoAction/LiveViews)
               					let $CurrentLike := count($GetActionDoc/VideoAction/User/Action[.='Like'])
               					let $CurrentDisLike := count($GetActionDoc/VideoAction/User/Action[.='Dislike'])
               					let $UserAction := $GetActionDoc/VideoAction/User[(UserID=$UserID) or (UserIP=$UserIP) or (Email=$UserEmail)]/Action/text()
               					return
               					(
               					                      if (doc($VideoUri)/Video/PublishInfo/LivePublish[@active='yes'])
               			                              then
               			                                     xdmp:node-replace($GetActionDoc//VideoAction/LiveViews, <LiveViews>{sum($LiveCurrentView + 1)}</LiveViews>)
               			                              else ()
               						,
               						let $PHistoryUri := fn:concat($constants:PCOPY_DIRECTORY,$VideoID,".xml")
               						return
               						   if(fn:doc-available($PHistoryUri) and doc($PHistoryUri)/Video/PublishInfo/LivePublish[@active='yes'])
               						   then
               						          let $LiveViewCount := doc($PHistoryUri)/Video/LiveViewCount
                              							  return
                              								if($LiveViewCount)
                              								then xdmp:node-replace($LiveViewCount, <LiveViewCount>{sum($LiveViewCount/text()+1)}</LiveViewCount>)
                              								else
                              									let $View := doc(concat($constants:ACTION_DIRECTORY, $VideoID, $constants:SUF_ACTION,'.xml'))//LiveViews/text()
                              									return xdmp:node-insert-child(doc($PHistoryUri)/Video,  <LiveViewCount>{if($View) then sum($View+1) else 0}</LiveViewCount>)
               						   else ()						
               						,
               						if (doc($VideoUri)/Video/PublishInfo/LivePublish[@active='yes'])
               			                              then
               			                                     <Result id="{$VideoID}"><User><Action>{$UserAction}</Action></User><Likes>{$CurrentLike}</Likes><DisLikes>{$CurrentDisLike}</DisLikes><LiveViews>{sum($LiveCurrentView + 1)}</LiveViews></Result>
               			                              else ()
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
								<Result id="{$VideoID}"><User><Action>{$Action}</Action></User><Likes>{sum($CurrentLike + 1)}</Likes><DisLikes>{$CurrentDisLike}</DisLikes><LiveViews>{$LiveCurrentView}</LiveViews></Result>,
								local:updateLikeCount($VideoID,sum($CurrentLike + 1))
							)
						else
							(
								xdmp:node-insert-child($GetActionDoc/VideoAction, <User><UserID>{$UserID}</UserID><UserIP>{$UserIP}</UserIP><Email>{$UserEmail}</Email><Action>{$Action}</Action></User>),
								<Result id="{$VideoID}"><User><Action>{$Action}</Action></User><Likes>{$CurrentLike}</Likes><DisLikes>{sum($CurrentDisLike + 1)}</DisLikes><LiveViews>{$LiveCurrentView}</LiveViews></Result>,
								local:updateLikeCount($VideoID,$CurrentLike)
							)
					else
					if($IsUserActionExists/child::*)
					then
						if($Action = "Like")
						then
								if($UserAction!="Like")
								then
									(
									xdmp:node-replace($IsUserActionExists/Action, <Action>{$Action}</Action>),
									<Result id="{$VideoID}"><User><Action>{$UserAction}</Action></User><Likes>{sum($CurrentLike + 1)}</Likes><DisLikes>{if($CurrentDisLike) then sum($CurrentDisLike - 1) else 0}</DisLikes><LiveViews>{$LiveCurrentView}</LiveViews></Result>,
									local:updateLikeCount($VideoID,sum($CurrentLike + 1))
									)
								else
									(
										<Result id="{$VideoID}"><User><Action>{$UserAction}</Action></User><Likes>{if($CurrentLike) then $CurrentLike else 0}</Likes><DisLikes>{if($CurrentDisLike) then $CurrentDisLike else 0}</DisLikes><LiveViews>{$LiveCurrentView}</LiveViews></Result>,
										local:updateLikeCount($VideoID, if($CurrentLike) then $CurrentLike else 0)
									)	
								
						else
							if($UserAction!="Dislike")
							then
								(
								xdmp:node-replace($IsUserActionExists/Action, <Action>{$Action}</Action>),
								<Result id="{$VideoID}"><User><Action>{$UserAction}</Action></User><Likes>{if($CurrentLike) then sum($CurrentLike - 1) else 0}</Likes><DisLikes>{sum($CurrentDisLike + 1)}</DisLikes><LiveViews>{$LiveCurrentView}</LiveViews></Result>,
								local:updateLikeCount($VideoID, if($CurrentLike) then sum($CurrentLike - 1) else 0)
								)
							else
							(
								<Result id="{$VideoID}"><User><Action>{$UserAction}</Action></User><Likes>{if($CurrentLike) then $CurrentLike else 0}</Likes><DisLikes>{if($CurrentDisLike) then $CurrentDisLike else 0}</DisLikes><LiveViews>{$LiveCurrentView}</LiveViews></Result>,
								local:updateLikeCount($VideoID, if($CurrentLike) then $CurrentLike else 0)
							)	
					else ()
			else
				let $ActionXML := <VideoAction><VideoID>{$VideoID}</VideoID><LiveViews>0</LiveViews><User><UserID>{$UserID}</UserID><UserIP>{$UserIP}</UserIP><Email>{$UserEmail}</Email><Action>{$Action}</Action></User></VideoAction>
				return
					(
						xdmp:document-insert($ActionUri,$ActionXML,(), $constants:ACTION)
						,
						<Result id="{$VideoID}"><User><Action>{$Action}</Action></User><Likes>{if($Action="Like") then 1 else 0}</Likes><DisLikes>{if($Action="Dislike") then 1 else 0}</DisLikes><LiveViews>0</LiveViews></Result>
						,
						local:updateLikeCount($VideoID, if($Action="Like") then 1 else 0)
					)
