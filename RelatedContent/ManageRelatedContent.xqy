xquery version "1.0-ml";

module namespace RELATED = "http://www.TheIET.org/ManageRelatedContent";

declare variable $_HOME_FOLDER 	as xs:string := "C:/IET-TV/Related Content";
declare variable $_COL_RELATED 	as xs:string := "Key";
declare variable $_DB_NAME 		as xs:string := "IETTV-RelatedContent";


declare function GetNormalizeText($Node as element())
{
  let $DivisionAsString 	:= $Node
  let $RemovedTags 			:= fn:replace($DivisionAsString, "<[^>]*>", " ")
  let $AllLowerCase 		:= fn:lower-case($RemovedTags)
  let $PunctuationToSpaces  := fn:translate( $AllLowerCase, "()[]<>{}!0-@#$%.;:',&#34;-", " " )
  let $ExtraSpacesRemoved   := fn:normalize-space( $PunctuationToSpaces )
  let $PrefixNumbersRemoved := fn:replace($ExtraSpacesRemoved, "^([( ]*([0-9](\.?[0-9])*|[xiv]+|[a-z])[)\.])", "(~)")
  let $RemoveDiacretic 		:= fn:replace(fn:normalize-unicode( $PrefixNumbersRemoved , 'NFD'), '[\p{M}]', '')
  return
	$RemoveDiacretic
};

(: To support folder structure
		/Related Content
			/Books
				abcd.zip
			/Journals
				abcd.zip
				xyd.zip
				...
:)
declare function KeyGeneration()
{
      if(xdmp:filesystem-file-exists($_HOME_FOLDER))
      then
               	for $HotDirectory in xdmp:filesystem-directory($_HOME_FOLDER)//dir:entry
               	let $FileName1 := $HotDirectory/dir:filename/text()
               	let $SubDirectory := $HotDirectory/dir:pathname/text()
               	for $SubDirectoryZip in xdmp:filesystem-directory($SubDirectory)//dir:entry
               	let $FileName2 := substring-before($SubDirectoryZip/dir:filename/text(),'.zip')
               	(: let $Log := xdmp:log("-------------- Zip Fetched -----------------") :)
               	let $ZipPath := $SubDirectoryZip/dir:pathname/text()
               	for $EachPart in try{xdmp:zip-manifest(xdmp:document-get($SubDirectoryZip/dir:pathname/text()))//*:part} catch($e){$e}
               	let $XML := try{xdmp:zip-get(xdmp:document-get($ZipPath), $EachPart/text())} catch($e){$e}
               	let $DocElement := $XML/*/name()
               	(: let $Log := xdmp:log("-------------- Loop started -----------------") :)
               	return
               	  try
               	  {
               
               		  if( $DocElement='ebook' )
               		  then
               			  let $Log := xdmp:log("-------------- Book Record -----------------")
               			  let $BookTitle := $XML/ebook/book-metadata//titlegrp/title
               			  let $BookDOI := $XML/ebook/book-metadata/book-identifiers/doi
               			  let $BookAbstract := $XML/ebook/book-metadata/abstract
               			  let $KeywordInspec := $XML/ebook/book-metadata/vocabs
               			  let $BookEditors := $XML/ebook/book-metadata/editorgrp
               			  let $BookCopyrightHolder := $XML/ebook/book-metadata/pubinfo/cpyrt/cpyrtholder
               			  let $MatchingKeys :=  <MatchingKeys>
               									  <FileUri>{concat('/',$FileName1,'/',$FileName2,'/',$EachPart/text())}</FileUri>
               									  <DOI>{fn:concat('http://dx.doi.org/',$BookDOI/text())}</DOI>
               									  <Type>Book</Type>
               									  <Original>
               										<Title>{$BookTitle/text()}</Title>
               										<Keywords>{$KeywordInspec}</Keywords>
               									  </Original>
               									  <Key>
               										<KeyTitle>{GetNormalizeText($BookTitle)}</KeyTitle>
               										<KeyAbstract>{GetNormalizeText($BookAbstract)}</KeyAbstract>
               										<KeyContributor>{for $EachContributor in $BookEditors//book-editor return GetNormalizeText(<Contributor>{concat($EachContributor/fname, ' ', $EachContributor/surname)}</Contributor>)}</KeyContributor>
               										<KeyKeywords>{GetNormalizeText(<Keyword>{string-join(for $EachKeyWord in $KeywordInspec//text() return $EachKeyWord, ' ')}</Keyword>)}</KeyKeywords>
               										<KeyCopyright>{GetNormalizeText($BookCopyrightHolder)}</KeyCopyright>
               									  </Key>
               								   </MatchingKeys>
               			   return
               				 (
               				  xdmp:document-insert(concat('/',$FileName1,'/',$FileName2,'/',$EachPart/text()),$XML,(), "Book"),
               				  xdmp:document-insert(concat("/Key/", $FileName1,'/',$FileName2,'/',$EachPart/text()),$MatchingKeys,(), $_COL_RELATED)
               				  )
               		  else
               		  if( $DocElement='article' )
               		  then
               			  let $Log := xdmp:log("-------------- Article Record -----------------")
               			  let $ArticleDOI   := $XML/article/front/article-meta/article-id[@pub-id-type='doi']/text()
               			  let $ArticleTitle := $XML/article/front/article-meta/title-group/article-title
               			  let $ArticleAbstract := $XML/article/front/article-meta/abstract
               			  let $ArticleContributor := $XML/article/front/article-meta/contrib-group
               			  let $ArticleKewyords := $XML/article/front/article-meta/kwd-group
               			  let $ArticleCopyrightStatement := $XML/article/front/article-meta/permissions/copyright-statement
               			  let $MatchingKeys :=  <MatchingKeys>
               									  <FileUri>{concat('/',$FileName1,'/',$FileName2,'/',$EachPart/text())}</FileUri>
               									  <DOI>{fn:concat('http://dx.doi.org/',$ArticleDOI)}</DOI>
               									  <Type>Journal</Type>
               									  <Original>
               										<Title>{$ArticleTitle/text()}</Title>
               										<Keywords>{$ArticleKewyords}</Keywords>
               									  </Original>
               									  <Key>
               										<KeyTitle>{GetNormalizeText($ArticleTitle)}</KeyTitle>
               										<KeyAbstract>{GetNormalizeText($ArticleAbstract)}</KeyAbstract>
               										<KeyContributor>{for $EachContributor in $ArticleContributor//contrib/name return GetNormalizeText(<Contributor>{concat($EachContributor/surname, ' ', $EachContributor/given-names)}</Contributor>)}</KeyContributor>
               										<KeyKeywords>{GetNormalizeText(<Keyword>{for $EachKeyWord in $ArticleKewyords//text() return $EachKeyWord}</Keyword>)}</KeyKeywords>
               										<KeyCopyright>{GetNormalizeText($ArticleCopyrightStatement)}</KeyCopyright>
               									  </Key>
               								   </MatchingKeys>
               			  return
               				(
               				  xdmp:document-insert(concat('/',$FileName1,'/',$FileName2,'/',$EachPart/text()),$XML,(), "Journal"),
               				  xdmp:document-insert(concat("/Key/", $FileName1,'/',$FileName2,'/',$EachPart/text()),$MatchingKeys,(), $_COL_RELATED)
               				)
               		  else () (: xdmp:log("-------------- Another Format-----------------") :)
               	  }
               	  catch($e){$e}
      
      else (xdmp:log("Directory Not Exist ==> C:\IET-TV\Related Content "))
      
};

  
(: To support folder structure
		/Related Content
			abcd.zip
			xyz.zip
			....
:)
declare function KeyGenerationOld()
{
	for $HotDirectory in xdmp:filesystem-directory($_HOME_FOLDER)//dir:entry
	let $ZipName := $HotDirectory/dir:filename/text()
	let $ZipPath := $HotDirectory/dir:pathname/text()
	for $EachPart in xdmp:zip-manifest(xdmp:document-get($ZipPath))/*:part
	return
	  try
	  {
		let $XML := xdmp:zip-get(xdmp:document-get($ZipPath), $EachPart/text())
		let $DocElement := $XML/*/name()
		return
		  if( $DocElement='ebook' )
		  then
			  let $BookTitle 	:= $XML/ebook/book-metadata//titlegrp/title
			  let $BookDOI 		:= $XML/ebook/book-metadata/book-identifiers/doi
			  let $BookAbstract := $XML/ebook/book-metadata/abstract
			  let $KeywordInspec:= $XML/ebook/book-metadata/vocabs
			  let $BookEditors 	:= $XML/ebook/book-metadata/editorgrp
			  let $BookCopyrightHolder := $XML/ebook/book-metadata/pubinfo/cpyrt/cpyrtholder
			  let $MatchingKeys :=  <MatchingKeys>
									  <FileUri>{fn:concat("/Book/", $EachPart/text())}</FileUri>
									  <DOI>{$BookDOI/text()}</DOI>
									  <Type>Book</Type>
									  <Original>
										<Title>{$BookTitle/text()}</Title>
										<Keywords>{$KeywordInspec}</Keywords>
									  </Original>
									  <Key>
										<KeyTitle>{GetNormalizeText($BookTitle)}</KeyTitle>
										<KeyAbstract>{GetNormalizeText($BookAbstract)}</KeyAbstract>
										<KeyContributor>{for $EachContributor in $BookEditors//book-editor return GetNormalizeText(<Contributor>{fn:concat($EachContributor/fname, ' ', $EachContributor/surname)}</Contributor>)}</KeyContributor>
										<KeyKeywords>{GetNormalizeText(<Keyword>{string-join(for $EachKeyWord in $KeywordInspec//text() return $EachKeyWord, ' ')}</Keyword>)}</KeyKeywords>
										<KeyCopyright>{GetNormalizeText($BookCopyrightHolder)}</KeyCopyright>
									  </Key>
								   </MatchingKeys>
			   return
				 (
				  xdmp:document-insert(fn:concat("/Book/", $EachPart/text()),$XML,(), "Book"),
				  xdmp:document-insert(fn:concat("/Key/", $EachPart/text()),$MatchingKeys,(), $_COL_RELATED)
				  )
		  else
		  if( $DocElement='article' )
		  then
			  let $ArticleDOI   	:= $XML/article/front/article-meta/article-id[@pub-id-type='doi']/text()
			  let $ArticleTitle 	:= $XML/article/front/article-meta/title-group/article-title
			  let $ArticleAbstract 	:= $XML/article/front/article-meta/abstract
			  let $ArticleContributor := $XML/article/front/article-meta/contrib-group
			  let $ArticleKewyords 	:= $XML/article/front/article-meta/kwd-group
			  let $ArticleCopyrightStatement := $XML/article/front/article-meta/permissions/copyright-statement
			  let $MatchingKeys 	:=  <MatchingKeys>
										  <FileUri>{fn:concat("/Article/", $EachPart/text())}</FileUri>
										  <DOI>{$ArticleDOI}</DOI>
										  <Type>Journal</Type>
										  <Original>
											<Title>{$ArticleTitle/text()}</Title>
											<Keywords>{$ArticleKewyords}</Keywords>
										  </Original>
										  <Key>
											<KeyTitle>{GetNormalizeText($ArticleTitle)}</KeyTitle>
											<KeyAbstract>{GetNormalizeText($ArticleAbstract)}</KeyAbstract>
											<KeyContributor>{for $EachContributor in $ArticleContributor//contrib/name return GetNormalizeText(<Contributor>{fn:concat($EachContributor/surname, ' ', $EachContributor/given-names)}</Contributor>)}</KeyContributor>
											<KeyKeywords>{GetNormalizeText(<Keyword>{for $EachKeyWord in $ArticleKewyords//text() return $EachKeyWord}</Keyword>)}</KeyKeywords>
											<KeyCopyright>{GetNormalizeText($ArticleCopyrightStatement)}</KeyCopyright>
										  </Key>
								   </MatchingKeys>
			  return
				(
				  xdmp:document-insert(fn:concat("/Article/", $EachPart/text()),$XML,(), "Journal"),
				  xdmp:document-insert(fn:concat("/Key/", $EachPart/text()),$MatchingKeys,(), $_COL_RELATED)
				)
		  else ()
	  }
	  catch($e){$e}
};