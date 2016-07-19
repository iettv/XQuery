xquery version "1.0-ml";

import module namespace admin     = "http://marklogic.com/xdmp/admin"   at "/MarkLogic/admin.xqy";
import module namespace constants  = 'http://www.TheIET.org/constants'  at  '/Utils/constants.xqy';

declare function local:normalize($Node as element())
{
  let $DivisionAsString := $Node
  let $RemovedTags 		:= fn:replace($DivisionAsString, "<[^>]*>", " ")
  let $AllLowerCase 	:= fn:lower-case($RemovedTags)
  let $PunctuationToSpaces  := fn:translate( $AllLowerCase, "()[]<>{}!0-@#$%.;:',&#34;-", " " )
  let $ExtraSpacesRemoved 	:= fn:normalize-space( $PunctuationToSpaces )
  let $PrefixNumbersRemoved := fn:replace($ExtraSpacesRemoved, "^([( ]*([0-9](\.?[0-9])*|[xiv]+|[a-z])[)\.])", "(~)")
  let $RemoveDiacretic 		:= fn:replace(fn:normalize-unicode( $PrefixNumbersRemoved , 'NFD'), '[\p{M}]', '')
  return $RemoveDiacretic
};
(: let $inputSearchDetails := <Video><VideoId>7472</VideoId></Video> :)
declare variable $inputSearchDetails as xs:string external;
let $inputParam := xdmp:unquote($inputSearchDetails)
let $VideoId := $inputParam//VideoId/text()
let $VideoUri := fn:concat($constants:PCOPY_DIRECTORY,$VideoId,".xml")
let $VideoXml := fn:doc($VideoUri)
let $VideoID                := fn:data($VideoXml/Video/@ID)
let $VideoTitle   			:= $VideoXml/Video/BasicInfo/Title
let $VideoKeyWordInfo      	:= $VideoXml/Video/KeyWordInfo
let $VideoKeyWordInspec    	:= $VideoXml/Video/VideoInspec
let $Speakers     			:= $VideoXml/Video/Speakers
let $VideoTitleNormalize          := <Title>{local:normalize($VideoTitle)}</Title>
let $VideoKeyWordInfoNormalize    := <KewyWordInfos>{$VideoKeyWordInfo}</KewyWordInfos>
let $VideoKeyWordInspecNormalize  := <Inspec>
                                        {
                                          for $KeyWord in $VideoKeyWordInspec//*[name()='Kwd' or name()='Compound-Kwd-Part'] return $KeyWord
                                        }
                                     </Inspec>
let $SpeakersNormalize            := <Speakers>
                                        {
                                          local:normalize
                                          (
                                          <Speakers>
                                            {
                                              string-join(for $EachSpeaker in $Speakers/Person/Name
                                              let $GivenName := $EachSpeaker/Given-Name/text()
                                              let $Surname := $EachSpeaker/Surname/text()
                                              return fn:concat($GivenName,' ',$Surname), ' ')
                                            }
                                          </Speakers>
                                          )
                                        }
                                     </Speakers>


return
    (
		let $Config 	    := admin:get-configuration()
		let $CurrentDBName  := admin:database-get-name($Config, xdmp:database())
		let $RealtedInfo 	:= xdmp:eval(	"xquery version '1.0-ml';
											declare variable $VideoTitleNormalize as element() external;
											declare variable $VideoKeyWordInfoNormalize as element() external;
											declare variable $VideoKeyWordInspecNormalize as element() external;
											declare variable $SpeakersNormalize as element() external;
											declare variable $VideoUri as xs:string external;
											
											let $MatchingResults :=   <Result>{cts:search(fn:collection('Key')/MatchingKeys,
																					   cts:or-query((
																						 cts:element-word-query(xs:QName('KeyTitle'), $VideoTitleNormalize/text(), ('whitespace-insensitive','case-insensitive', 'wildcarded', 'stemmed', 'diacritic-insensitive', 'punctuation-insensitive'), xs:double(8))
																						 ,
																						 cts:element-word-query(xs:QName('KeyContributor'), $SpeakersNormalize/text(), ('whitespace-insensitive','case-insensitive', 'wildcarded', 'stemmed', 'diacritic-insensitive', 'punctuation-insensitive'), xs:double(2))
																						 ,
																						 for $EachDefaultKeyWord in  $VideoKeyWordInfoNormalize//*[name()='DefaultKeyword' or name()='CustomKeyword' ]/text()
																						 return cts:element-word-query(xs:QName('KeyAbstract'), $EachDefaultKeyWord, ('whitespace-insensitive','case-insensitive',  'stemmed', 'diacritic-insensitive', 'punctuation-insensitive'), xs:double(10))
																						 ,
																						 for $EachKeyWord in $VideoKeyWordInspecNormalize/descendant-or-self::*[not(*)]/text()
																						 return
																						 cts:element-word-query(xs:QName('KeyKeywords'), $EachKeyWord, ('whitespace-insensitive','case-insensitive',  'stemmed', 'diacritic-insensitive', 'punctuation-insensitive'), xs:double(16))
																						 ))
																				)[1 to 4]}</Result>
											return
											  let $FilteredElement := for $EachResult in $MatchingResults/MatchingKeys
																	  return
																		$EachResult

											  return if($FilteredElement) then if($FilteredElement) then <Matched><VideoUri>{$VideoUri}</VideoUri>{$FilteredElement}</Matched> else () else ()
											
										  "
										  , 
										  (
											xs:QName("VideoTitleNormalize"), $VideoTitleNormalize,
											xs:QName("VideoKeyWordInfoNormalize"), $VideoKeyWordInfoNormalize,
											xs:QName("VideoKeyWordInspecNormalize"), $VideoKeyWordInspecNormalize,
											xs:QName("SpeakersNormalize"), $SpeakersNormalize,
											xs:QName("VideoUri"), $VideoUri
										  )
										  ,
										<options xmlns="xdmp:eval">
											<database>{xdmp:database($constants:RELATED_DB_NAME)}</database>
										 </options>
									  )
		 return ($RealtedInfo)
		 
	 
	 )
   