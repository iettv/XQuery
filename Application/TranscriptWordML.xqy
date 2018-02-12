xquery version "1.0-ml";

declare variable $inputSearchDetails as xs:string external;

(:let $inputSearchDetails := "<SubTitleContent>
                                <Speaker Name='Steven Devine'>
                                    <SubRip Seq='1'>
                                        <CaptionStart>00:00:02,780 </CaptionStart>
                                        <CaptionEnd> 00:00:06,780</CaptionEnd>
                                        <Speaker>Steven Devine</Speaker>
                                        <ClosedCaption>In the interest of time,</ClosedCaption>
                                        <ClosedCaption>I think we have to quickly move over.</ClosedCaption>
                                    </SubRip>
                                    <SubRip Seq='2'>
                                        <CaptionStart>00:00:06,780 </CaptionStart>
                                        <CaptionEnd> 00:00:10,320</CaptionEnd>
                                        <Speaker>Steven Devine</Speaker>
                                        <ClosedCaption>So, I'd like to… our panel members,</ClosedCaption>
                                    </SubRip>
                                </Speaker>
                            </SubTitleContent>
                            ":)
                            
let $ReportXml   := xdmp:unquote($inputSearchDetails) 
let $VideoNumber := $ReportXml/Video/VideoNo/text()
let $VideoTitle  := $ReportXml/Video/VideoTitle/text()

return
        if ($ReportXml/Video/SubTitleContent/Speaker)
        then
                    <w:document xmlns:w='http://schemas.openxmlformats.org/wordprocessingml/2006/main'>
                        <w:body>
                            <w:tbl>	
                                <w:tblPr>
                                    <w:rPr><w:rFonts w:ascii="Calibri" /><w:b /><w:sz w:val="16" /></w:rPr>
                                </w:tblPr>
                                <w:tcPr><w:shd w:val="clear" w:color="auto" w:fill="" /><w:gridSpan w:val="15" /></w:tcPr>
                                <w:tblPr><w:tblLayout w:type="fixed" /></w:tblPr><w:tblGrid><w:gridCol w="10500" /></w:tblGrid>
                                <w:tr>
                                    <w:tc><w:p>
                                    <w:r>
                                            <w:rPr>
                                                   <w:b/>
                                                   <w:sz w:val="36" />
                                                   <w:jc w:val="both"/>
                                             </w:rPr>
                                             <w:t xml:space="preserve">{concat($VideoNumber,': ',$VideoTitle)}</w:t>
                                     </w:r>
                                    </w:p></w:tc>
                               </w:tr>
                               <w:tr>
                                    <w:tc><w:p></w:p></w:tc>
                               </w:tr>
                           {
                            for $Speaker in $ReportXml/Video/SubTitleContent/Speaker 
                                let $SpeakerName := $Speaker/@Name/string()
                                return
                                  (( <w:tr>
                                    <w:tc>
                                    <w:p>{
                                    (
                                    (if ($SpeakerName) 
                                    then (
                                          <w:r>
                                            <w:rPr>
                                                   <w:b/>
                                                   </w:rPr>
                                                   <w:t xml:space="preserve">{concat($SpeakerName,': ')}</w:t>
                                          </w:r>
                                    )
                                    else ()
                                    )
                                    ,
                                    (
                                    <w:r>
                                            <w:rPr>
                                                   <w:jc w:val="both"/>
                                            </w:rPr>
                                          <w:t xml:space="preserve">{
                                                for $SubRip in $Speaker/SubRip
                                                    for $ClosedCaption in $SubRip/ClosedCaption
                                                        let $SubRipContent := $ClosedCaption/text()
                                                            return
                                                                   ($SubRipContent,' ')

                                              }</w:t>
                                    </w:r>
                                    )
                                    )
                                    }</w:p></w:tc>
                                    </w:tr>
                                    ),
                                    (<w:tr>
                                    <w:tc><w:p></w:p></w:tc>
                                    </w:tr>
                                    )
                                    )

                           }    
                            </w:tbl>
                        </w:body>
                    </w:document>
      else ((xdmp:log(concat("[ IET-TV ][ Transcript PDF Generation ][ There Is No SubTitleContent For Video No: ",$VideoNumber,' ]' ))))
      

