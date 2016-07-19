xquery version "1.0-ml";

import module namespace RELATED = "http://www.TheIET.org/ManageRelatedContent"   at  "../ManageRelatedContent.xqy";

	let $Dummy := xdmp:log("======================= Related Content Ingestion Scheduler Start =======================")
	let $Dummy := RELATED:KeyGeneration()
	let $Dummy := xdmp:log("======================= Related Content Ingestion Scheduler End =======================")
	return ()
