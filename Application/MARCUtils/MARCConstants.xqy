xquery version "1.0-ml";

module namespace MARC_Constants = "http://www.TheIET.org/MARCConstants";

(: COLLECTIONS :)

declare variable $MARC_Constants:MARCVIDEO_COLLECTION	as xs:string := "MarcVideo";
declare variable $MARC_Constants:MARCACCOUNT_COLLECTION	as xs:string := "MarcAccount-";

(: COMMON DIRECTORIES :)

declare variable $MARC_Constants:MARC_DIRECTORY 	    as xs:string := "/MARCXML/";
declare variable $MARC_Constants:MARC_ADMIN_VIDEO	as xs:string := "/MARCAdmin/Account/";