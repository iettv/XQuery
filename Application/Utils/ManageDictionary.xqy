xquery version "1.0-ml";

module namespace DICTIONARY = "http://www.TheIET.org/ManageDictionary";
  
import module namespace constants  = "http://www.TheIET.org/constants"      at "/Utils/constants.xqy"; 
import module namespace spell      = "http://marklogic.com/xdmp/spell"      at "/MarkLogic/spell.xqy";
import module namespace admin      = "http://marklogic.com/xdmp/admin"      at "/MarkLogic/admin.xqy";
      
declare variable $ForesId := admin:forest-get-id(admin:get-configuration(), "IETTV-Forest");
	    
declare function CreateDictionary()
{
  <dictionary xmlns="http://marklogic.com/xdmp/spell">
      {
      for $EachCharacter in ("a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z")
      let $WildCard := fn:concat($EachCharacter, "*")
      for $EachWord in cts:word-match($WildCard,(),(),(),$ForesId)
      return <word>{$EachWord}</word>
      }
  </dictionary>
};

declare function InsertDictionary($DictionaryXml as item())
{
  spell:insert($constants:DictionaryFile, $DictionaryXml )
};

declare function IsCorrect($Word as xs:string)
{
  spell:is-correct($constants:DictionaryFile,$Word)
};

declare function SpellSuggest($Word as xs:string)
{
  (spell:suggest($constants:DictionaryFile,$Word))[1]
};
