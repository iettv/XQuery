xquery version "1.0-ml";

module namespace constants = "http://www.TheIET.org/constants";

(: COLLECTIONS :)

declare variable $constants:HOME_PAGE_COLLECTION 			as xs:string := "Home-Page-Video";
declare variable $constants:CHANNEL_COLLECTION   			as xs:string := "Channel-";
declare variable $constants:VIDEO_COLLECTION     			as xs:string := "Video";
declare variable $constants:VIDEO_TYPE           			as xs:string := "Video-Type-";
declare variable $constants:VIDEO_STATUS         			as xs:string := "Video-Status-";
declare variable $constants:VIDEO_CHANNEL        			as xs:string := "Video-Channel-";
declare variable $constants:CHANNEL_CONFIG       			as xs:string := "Channel-Config";
declare variable $constants:ACTIVE_VIDEO_COLLECTION       	as xs:string := "Video-Status-Published";
declare variable $constants:COMMENT 						as xs:string := "Comment-";
declare variable $constants:ACTION 			   				as xs:string := "Action";
declare variable $constants:ACTION_LIVE		   				as xs:string := "Action-Live";
declare variable $constants:PCOPY 			   				as xs:string := "PublishedCopy";

(: COMMON DIRECTORIES :)
declare variable $constants:VIDEO_DIRECTORY 	as xs:string := "/Video/";
declare variable $constants:ADMIN_DIRECTORY 	as xs:string := "/Admin/";
declare variable $constants:COMMENT_DIRECTORY 	as xs:string := "/Comment/";
declare variable $constants:ACTION_DIRECTORY 	as xs:string := "/Action/";
declare variable $constants:ACTION_LIVE_DIRECTORY 	as xs:string := "/ActionLive/";
declare variable $constants:PCOPY_DIRECTORY 	as xs:string := "/PCopy/";

(: COMMON PROPERTIES :)
declare variable $constants:PROP_HOME_SEQUENCE    as xs:string := "HomePageSequence";
declare variable $constants:PROP_CHANNEL_SEQUENCE as xs:string := "ChannelPageSequence-";

(: COMMON PREFIXES :)
declare variable $constants:PRE_CHANNEL_CONFIG   as xs:string := "Channel-";
declare variable $constants:SUF_ACTION   		 as xs:string := "-Action";
declare variable $constants:STUF_ACTION   		 as xs:string := "-ActionLive";

(: MOST POPULAR :)
declare variable $constants:CommonPopular 		as xs:string := "/Admin/CommonMostPopular.xml";
declare variable $constants:PopularByChannel 	as xs:string := "/Admin/Channel-";

(: LATEST VIDEO :)
declare variable $constants:CommonLatestVideo 	as xs:string := "/Admin/CommonLatestVideo.xml";
declare variable $constants:ChannelLatest 		as xs:string := "/Admin/ChannelLatest-";

(: FORTHCOMING VIDEO :)
declare variable $constants:CommonForthComingVideo 	as xs:string := "/Admin/CommonForthComingVideo.xml";
declare variable $constants:ChannelForthComing 		as xs:string := "/Admin/ChannelForthComing-";

(: DATABASE popular scheduler will save data into this database and our popular query will fetch data from this database only to reflect most popular :)
declare variable $constants:ActivityDatabase 	as xs:string := "IETTV-Activity-Database";
declare variable $constants:ApplicationDatabase as xs:string := "IETTV-Database";
declare variable $constants:QAActivityDatabase 	as xs:string := "IETTVActivity-QA-Database";

(: CAROUSEL :)
declare variable $constants:CarouselFile as xs:string := fn:concat($constants:ADMIN_DIRECTORY,"CarouselVideos.xml");

(: DICTIONARY :)
declare variable $constants:DictionaryFile as xs:string := "/Spell/IET-TV-Dictionary.xml";

(: RELATED :)
declare variable $constants:DirectoryRelated as xs:string := "/Related/";
declare variable $constants:COL_RELATED as xs:string := "Related";
declare variable $constants:RELATED_DB_NAME as xs:string := "IETTV-RelatedContent";

(: STAFF CHANNELS :)
declare variable $constants:StaffChannelUri	as xs:string := "/Admin/StaffChannel.xml";
declare variable $constants:StaffChannelXml := fn:doc($constants:StaffChannelUri);

(: INACIVE CHANNELS :)
declare variable $constants:MasterChannelUri	as xs:string := "/Admin/MasterChannel.xml";
declare variable $constants:MasterChannelXml := fn:doc($constants:MasterChannelUri);

(: VIDEO SEQUNCE NUMBER :)
declare variable $constants:VideoSequenceUri	as xs:string := "/Admin/Sequence.xml";

(: SKIP CHANNEL :)
declare variable $constants:SkipChannelUri	as xs:string := "/Admin/SkipChannel.xml";

(: VIDEO-DOI/URL :)
declare variable $constants:VideoURL	as xs:string := "https://iettv-uat.theiet.org/?videoid="; (: LIVE https://tv.theiet.org/?videoid= :)
declare variable $constants:VideoDOI	as xs:string := "10.1049/iet-tv.vn.";
declare variable $constants:MURI as xs:string := "/Admin/MetadataUpgrade.xml";