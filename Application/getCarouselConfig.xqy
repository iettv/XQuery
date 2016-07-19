xquery version "1.0-ml";

import module namespace constants  = "http://www.TheIET.org/constants"    at  "/Utils/constants.xqy";


(: This is useful to send back Carousel Configuration  :)

    if( fn:doc-available($constants:CarouselFile) )
    then
      let $CarouselConfig := fn:doc($constants:CarouselFile)
      return
        <CarouselConfiguration>
          {
            for $EachVideo in $CarouselConfig/CarouselConfiguration/Video
            let $ConfigureType := $EachVideo/Type/string()
            return
              if($ConfigureType="VideoId")
			  then
				let $VideoID     := $EachVideo/VideoId/text()
				let $PHistoryUri := concat($constants:PCOPY_DIRECTORY,$VideoID,".xml")
				let $VideoTitle  := doc($PHistoryUri)/Video/BasicInfo/Title/text()
				return <Video><PositionId>{$EachVideo/PositionId/string()}</PositionId><VideoId>{$VideoID}</VideoId><VideoTitle>{$VideoTitle}</VideoTitle><Type>VideoId</Type></Video>
			  else
              if($ConfigureType="LatestVideo") then <Video><PositionId>{$EachVideo/PositionId/string()}</PositionId><VideoId></VideoId><Type>LatestVideo</Type></Video> else
              if($ConfigureType="MostPopularVideo") then <Video><PositionId>{$EachVideo/PositionId/string()}</PositionId><VideoId></VideoId><Type>MostPopularVideo</Type></Video> else ()
          }
        </CarouselConfiguration>
    else ( xdmp:log("[ CarouselConfig ][ No configuration file is available to send ]"), "ERROR! No Carousel Configuration file is available.")