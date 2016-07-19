xquery version "1.0-ml";

import module namespace constants = "http://www.TheIET.org/constants"   at "/Utils/constants.xqy"; 
(:
	This service will create an XML file in MarkLogic repository so that other program may generate Video Number for video meta-data file(s)
:)
xdmp:document-insert($constants:VideoSequenceUri, <Counter>0</Counter>)