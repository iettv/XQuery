import module namespace constants = "http://www.TheIET.org/constants"   at "/Utils/constants.xqy"; 

let $XML :=	<Videos>
				<Video><ID>2515</ID><DOI>10.1049/iet-tv.47.1000</DOI></Video>
				<Video><ID>5896</ID><DOI>10.1049/iet-tv.44.785</DOI></Video>
				<Video><ID>5909</ID><DOI>10.1049/iet-tv.44.947</DOI></Video>
				<Video><ID>5985</ID><DOI>10.1049/iet-tv.44.1053</DOI></Video>
				<Video><ID>6069</ID><DOI>10.1049/iet-tv.44.1343</DOI></Video>
				<Video><ID>6274</ID><DOI>10.1049/iet-tv.44.1636</DOI></Video>
				<Video><ID>8937</ID><DOI>10.1049/iet-tv.44.1732</DOI></Video>
				<Video><ID>8938</ID><DOI>10.1049/iet-tv.44.1733</DOI></Video>
				<Video><ID>9082</ID><DOI>10.1049/iet-tv.47.908</DOI></Video>
				<Video><ID>9441</ID><DOI>10.1049/iet-tv.51.1301</DOI></Video>
				<Video><ID>9442</ID><DOI>10.1049/iet-tv.51.1302</DOI></Video>
				<Video><ID>9443</ID><DOI>10.1049/iet-tv.51.1303</DOI></Video>
				<Video><ID>10340</ID><DOI>10.1049/iet-tv.44.10340</DOI></Video>
				<Video><ID>11624</ID><DOI>10.1049/iet-tv.51.11624</DOI></Video>
				<Video><ID>12739</ID><DOI>10.1049/iet-tv.47.12739</DOI></Video>
				<Video><ID>13229</ID><DOI>10.1049/iet-tv.51.13229</DOI></Video>
				<Video><ID>13322</ID><DOI>10.1049/iet-tv.41.13322</DOI></Video>
				<Video><ID>13359</ID><DOI>10.1049/iet-tv.50.13359</DOI></Video>
				<Video><ID>14534</ID><DOI>10.1049/iet-tv.47.14534</DOI></Video>
				<Video><ID>14535</ID><DOI>10.1049/iet-tv.47.14535</DOI></Video>
				<Video><ID>14538</ID><DOI>10.1049/iet-tv.47.14538</DOI></Video>
				<Video><ID>14540</ID><DOI>10.1049/iet-tv.47.14540</DOI></Video>
				<Video><ID>14541</ID><DOI>10.1049/iet-tv.47.14541</DOI></Video>
				<Video><ID>14550</ID><DOI>10.1049/iet-tv.47.14550</DOI></Video>
				<Video><ID>14581</ID><DOI>10.1049/iet-tv.51.14581</DOI></Video>
				<Video><ID>14582</ID><DOI>10.1049/iet-tv.51.14582</DOI></Video>
				<Video><ID>14583</ID><DOI>10.1049/iet-tv.51.14583</DOI></Video>
				<Video><ID>14584</ID><DOI>10.1049/iet-tv.51.14584</DOI></Video>
				<Video><ID>14585</ID><DOI>10.1049/iet-tv.51.14585</DOI></Video>
				<Video><ID>14586</ID><DOI>10.1049/iet-tv.50.14586</DOI></Video>
				<Video><ID>14587</ID><DOI>10.1049/iet-tv.50.14587</DOI></Video>
				<Video><ID>14588</ID><DOI>10.1049/iet-tv.50.14588</DOI></Video>
				<Video><ID>14589</ID><DOI>10.1049/iet-tv.50.14589</DOI></Video>
				<Video><ID>14590</ID><DOI>10.1049/iet-tv.50.14590</DOI></Video>
				<Video><ID>14602</ID><DOI>10.1049/iet-tv.51.14602</DOI></Video>
				<Video><ID>14603</ID><DOI>10.1049/iet-tv.51.14603</DOI></Video>
				<Video><ID>14604</ID><DOI>10.1049/iet-tv.51.14604</DOI></Video>
				<Video><ID>14605</ID><DOI>10.1049/iet-tv.51.14605</DOI></Video>
				<Video><ID>14607</ID><DOI>10.1049/iet-tv.51.14607</DOI></Video>
				<Video><ID>14609</ID><DOI>10.1049/iet-tv.51.14609</DOI></Video>
				<Video><ID>14610</ID><DOI>10.1049/iet-tv.51.14610</DOI></Video>
				<Video><ID>14616</ID><DOI>10.1049/iet-tv.50.14616</DOI></Video>
				<Video><ID>14617</ID><DOI>10.1049/iet-tv.50.14617</DOI></Video>
				<Video><ID>14619</ID><DOI>10.1049/iet-tv.50.14619</DOI></Video>
				<Video><ID>14637</ID><DOI>10.1049/iet-tv.50.14637</DOI></Video>
				<Video><ID>14638</ID><DOI>10.1049/iet-tv.50.14638</DOI></Video>
				<Video><ID>14641</ID><DOI>10.1049/iet-tv.50.14641</DOI></Video>
				<Video><ID>14642</ID><DOI>10.1049/iet-tv.50.14642</DOI></Video>
				<Video><ID>14644</ID><DOI>10.1049/iet-tv.50.14644</DOI></Video>
				<Video><ID>14645</ID><DOI>10.1049/iet-tv.50.14645</DOI></Video>
				<Video><ID>14646</ID><DOI>10.1049/iet-tv.50.14646</DOI></Video>
				<Video><ID>14647</ID><DOI>10.1049/iet-tv.50.14647</DOI></Video>
				<Video><ID>14648</ID><DOI>10.1049/iet-tv.50.14648</DOI></Video>
				<Video><ID>15706</ID><DOI>10.1049/iet-tv.47.15706</DOI></Video>
				<Video><ID>15710</ID><DOI>10.1049/iet-tv.47.15710</DOI></Video>
				<Video><ID>15711</ID><DOI>10.1049/iet-tv.47.15711</DOI></Video>
				<Video><ID>15712</ID><DOI>10.1049/iet-tv.47.15712</DOI></Video>
				<Video><ID>15713</ID><DOI>10.1049/iet-tv.47.15713</DOI></Video>
				<Video><ID>15716</ID><DOI>10.1049/iet-tv.47.15716</DOI></Video>
				<Video><ID>15721</ID><DOI>10.1049/iet-tv.47.15721</DOI></Video>
				<Video><ID>15896</ID><DOI>10.1049/iet-tv.47.15896</DOI></Video>
				<Video><ID>15944</ID><DOI>10.1049/iet-tv.47.15944</DOI></Video>
				<Video><ID>15947</ID><DOI>10.1049/iet-tv.47.15947</DOI></Video>
				<Video><ID>15948</ID><DOI>10.1049/iet-tv.47.15948</DOI></Video>
				<Video><ID>16065</ID><DOI>10.1049/iet-tv.47.16065</DOI></Video>
				<Video><ID>16078</ID><DOI>10.1049/iet-tv.47.16078</DOI></Video>
				<Video><ID>16079</ID><DOI>10.1049/iet-tv.47.16079</DOI></Video>
				<Video><ID>16081</ID><DOI>10.1049/iet-tv.47.16081</DOI></Video>
				<Video><ID>16082</ID><DOI>10.1049/iet-tv.47.16082</DOI></Video>
				<Video><ID>16575</ID><DOI>10.1049/iet-tv.47.16575</DOI></Video>
				<Video><ID>16577</ID><DOI>10.1049/iet-tv.47.16577</DOI></Video>
				<Video><ID>16583</ID><DOI>10.1049/iet-tv.47.16583</DOI></Video>
				<Video><ID>16596</ID><DOI>10.1049/iet-tv.47.16596</DOI></Video>
				<Video><ID>17161</ID><DOI>10.1049/iet-tv.47.17161</DOI></Video>
				<Video><ID>17163</ID><DOI>10.1049/iet-tv.47.17163</DOI></Video>
				<Video><ID>17167</ID><DOI>10.1049/iet-tv.47.17167</DOI></Video>
				<Video><ID>17763</ID><DOI>10.1049/iet-tv.47.17763</DOI></Video>
				<Video><ID>17764</ID><DOI>10.1049/iet-tv.47.17764</DOI></Video>
				<Video><ID>17765</ID><DOI>10.1049/iet-tv.47.17765</DOI></Video>
				<Video><ID>17767</ID><DOI>10.1049/iet-tv.47.17767</DOI></Video>
				<Video><ID>17771</ID><DOI>10.1049/iet-tv.51.17771</DOI></Video>
				<Video><ID>17772</ID><DOI>10.1049/iet-tv.51.17772</DOI></Video>
				<Video><ID>17773</ID><DOI>10.1049/iet-tv.47.17773</DOI></Video>
				<Video><ID>17774</ID><DOI>10.1049/iet-tv.51.17774</DOI></Video>
				<Video><ID>17775</ID><DOI>10.1049/iet-tv.47.17775</DOI></Video>
				<Video><ID>17776</ID><DOI>10.1049/iet-tv.47.17776</DOI></Video>
				<Video><ID>17807</ID><DOI>10.1049/iet-tv.51.17807</DOI></Video>
				<Video><ID>18147</ID><DOI>10.1049/iet-tv.50.18147</DOI></Video>
				<Video><ID>18384</ID><DOI>10.1049/iet-tv.50.18384</DOI></Video>
				<Video><ID>18458</ID><DOI>10.1049/iet-tv.50.18458</DOI></Video>
				<Video><ID>18532</ID><DOI>10.1049/iet-tv.41.18532</DOI></Video>
				<Video><ID>18571</ID><DOI>10.1049/iet-tv.41.18571</DOI></Video>
				<Video><ID>18669</ID><DOI>10.1049/iet-tv.50.18669</DOI></Video>
				<Video><ID>18825</ID><DOI>10.1049/iet-tv.41.18825</DOI></Video>
				<Video><ID>18858</ID><DOI>10.1049/iet-tv.41.18858</DOI></Video>
				<Video><ID>18859</ID><DOI>10.1049/iet-tv.41.18859</DOI></Video>
				<Video><ID>18860</ID><DOI>10.1049/iet-tv.41.18860</DOI></Video>
				<Video><ID>18890</ID><DOI>10.1049/iet-tv.44.18890</DOI></Video>
				<Video><ID>18951</ID><DOI>10.1049/iet-tv.51.18951</DOI></Video>
				<Video><ID>18952</ID><DOI>10.1049/iet-tv.51.18952</DOI></Video>
				<Video><ID>18953</ID><DOI>10.1049/iet-tv.51.18953</DOI></Video>
				<Video><ID>18954</ID><DOI>10.1049/iet-tv.51.18954</DOI></Video>
				<Video><ID>18955</ID><DOI>10.1049/iet-tv.51.18955</DOI></Video>
				<Video><ID>18956</ID><DOI>10.1049/iet-tv.51.18956</DOI></Video>
				<Video><ID>18957</ID><DOI>10.1049/iet-tv.51.18957</DOI></Video>
				<Video><ID>19012</ID><DOI>10.1049/iet-tv.51.19012</DOI></Video>
				<Video><ID>19254</ID><DOI>10.1049/iet-tv.44.19254</DOI></Video>
				<Video><ID>19259</ID><DOI>10.1049/iet-tv.44.19259</DOI></Video>
				<Video><ID>19260</ID><DOI>10.1049/iet-tv.44.19260</DOI></Video>
				<Video><ID>19261</ID><DOI>10.1049/iet-tv.44.19261</DOI></Video>
				<Video><ID>19263</ID><DOI>10.1049/iet-tv.44.19263</DOI></Video>
				<Video><ID>19264</ID><DOI>10.1049/iet-tv.44.19264</DOI></Video>
				<Video><ID>19411</ID><DOI>10.1049/iet-tv.45.19411</DOI></Video>
				<Video><ID>19427</ID><DOI>10.1049/iet-tv.45.19427</DOI></Video>
				<Video><ID>19509</ID><DOI>10.1049/iet-tv.41.19509</DOI></Video>
				<Video><ID>19518</ID><DOI>10.1049/iet-tv.41.19518</DOI></Video>
				<Video><ID>19641</ID><DOI>10.1049/iet-tv.41.19641</DOI></Video>
				<Video><ID>19712</ID><DOI>10.1049/iet-tv.50.19712</DOI></Video>
				<Video><ID>19713</ID><DOI>10.1049/iet-tv.50.19713</DOI></Video>
				<Video><ID>19732</ID><DOI>10.1049/iet-tv.46.19732</DOI></Video>
				<Video><ID>19777</ID><DOI>10.1049/iet-tv.50.19777</DOI></Video>
				<Video><ID>19778</ID><DOI>10.1049/iet-tv.50.19778</DOI></Video>
				<Video><ID>19779</ID><DOI>10.1049/iet-tv.50.19779</DOI></Video>
				<Video><ID>19794</ID><DOI>10.1049/iet-tv.50.19794</DOI></Video>
				<Video><ID>19795</ID><DOI>10.1049/iet-tv.50.19795</DOI></Video>
				<Video><ID>19796</ID><DOI>10.1049/iet-tv.50.19796</DOI></Video>
				<Video><ID>19797</ID><DOI>10.1049/iet-tv.50.19797</DOI></Video>
				<Video><ID>19799</ID><DOI>10.1049/iet-tv.50.19799</DOI></Video>
				<Video><ID>19800</ID><DOI>10.1049/iet-tv.50.19800</DOI></Video>
				<Video><ID>19801</ID><DOI>10.1049/iet-tv.50.19801</DOI></Video>
				<Video><ID>20033</ID><DOI>10.1049/iet-tv.44.20033</DOI></Video>
				<Video><ID>20049</ID><DOI>10.1049/iet-tv.47.20049</DOI></Video>
				<Video><ID>20050</ID><DOI>10.1049/iet-tv.47.20050</DOI></Video>
				<Video><ID>20051</ID><DOI>10.1049/iet-tv.47.20051</DOI></Video>
				<Video><ID>20052</ID><DOI>10.1049/iet-tv.47.20052</DOI></Video>
				<Video><ID>20053</ID><DOI>10.1049/iet-tv.47.20053</DOI></Video>
				<Video><ID>20054</ID><DOI>10.1049/iet-tv.47.20054</DOI></Video>
				<Video><ID>20055</ID><DOI>10.1049/iet-tv.47.20055</DOI></Video>
				<Video><ID>20056</ID><DOI>10.1049/iet-tv.47.20056</DOI></Video>
				<Video><ID>20058</ID><DOI>10.1049/iet-tv.47.20058</DOI></Video>
				<Video><ID>20458</ID><DOI>10.1049/iet-tv.41.20458</DOI></Video>
				<Video><ID>20459</ID><DOI>10.1049/iet-tv.41.20459</DOI></Video>
				<Video><ID>20460</ID><DOI>10.1049/iet-tv.41.20460</DOI></Video>
				<Video><ID>20466</ID><DOI>10.1049/iet-tv.41.20466</DOI></Video>
				<Video><ID>40706</ID><DOI>10.1049/iet-tv.45.40706</DOI></Video>
				<Video><ID>40707</ID><DOI>10.1049/iet-tv.45.40707</DOI></Video>
				<Video><ID>40708</ID><DOI>10.1049/iet-tv.45.40708</DOI></Video>
				<Video><ID>40709</ID><DOI>10.1049/iet-tv.45.40709</DOI></Video>
				<Video><ID>40710</ID><DOI>10.1049/iet-tv.45.40710</DOI></Video>
				<Video><ID>40711</ID><DOI>10.1049/iet-tv.45.40711</DOI></Video>
				<Video><ID>40712</ID><DOI>10.1049/iet-tv.45.40712</DOI></Video>
				<Video><ID>40713</ID><DOI>10.1049/iet-tv.45.40713</DOI></Video>
				<Video><ID>40714</ID><DOI>10.1049/iet-tv.45.40714</DOI></Video>
				<Video><ID>40716</ID><DOI>10.1049/iet-tv.47.40716</DOI></Video>
				<Video><ID>40718</ID><DOI>10.1049/iet-tv.47.40718</DOI></Video>
				<Video><ID>40719</ID><DOI>10.1049/iet-tv.47.40719</DOI></Video>
				<Video><ID>40722</ID><DOI>10.1049/iet-tv.47.40722</DOI></Video>
				<Video><ID>40748</ID><DOI>10.1049/iet-tv.47.40748</DOI></Video>
				<Video><ID>40749</ID><DOI>10.1049/iet-tv.45.40749</DOI></Video>
				<Video><ID>40750</ID><DOI>10.1049/iet-tv.45.40750</DOI></Video>
				<Video><ID>40751</ID><DOI>10.1049/iet-tv.45.40751</DOI></Video>
				<Video><ID>40752</ID><DOI>10.1049/iet-tv.45.40752</DOI></Video>
				<Video><ID>40753</ID><DOI>10.1049/iet-tv.45.40753</DOI></Video>
				<Video><ID>40756</ID><DOI>10.1049/iet-tv.47.40756</DOI></Video>
				<Video><ID>40757</ID><DOI>10.1049/iet-tv.47.40757</DOI></Video>
				<Video><ID>40758</ID><DOI>10.1049/iet-tv.45.40758</DOI></Video>
				<Video><ID>40759</ID><DOI>10.1049/iet-tv.47.40759</DOI></Video>
				<Video><ID>40760</ID><DOI>10.1049/iet-tv.47.40760</DOI></Video>
				<Video><ID>40761</ID><DOI>10.1049/iet-tv.41.40761</DOI></Video>
				<Video><ID>40762</ID><DOI>10.1049/iet-tv.41.40762</DOI></Video>
				<Video><ID>40763</ID><DOI>10.1049/iet-tv.41.40763</DOI></Video>
				<Video><ID>40764</ID><DOI>10.1049/iet-tv.41.40764</DOI></Video>
				<Video><ID>40765</ID><DOI>10.1049/iet-tv.41.40765</DOI></Video>
				<Video><ID>40766</ID><DOI>10.1049/iet-tv.41.40766</DOI></Video>
				<Video><ID>40767</ID><DOI>10.1049/iet-tv.41.40767</DOI></Video>
				<Video><ID>40768</ID><DOI>10.1049/iet-tv.41.40768</DOI></Video>
				<Video><ID>40769</ID><DOI>10.1049/iet-tv.41.40769</DOI></Video>
				<Video><ID>40770</ID><DOI>10.1049/iet-tv.41.40770</DOI></Video>
				<Video><ID>40771</ID><DOI>10.1049/iet-tv.41.40771</DOI></Video>
				<Video><ID>40772</ID><DOI>10.1049/iet-tv.41.40772</DOI></Video>
				<Video><ID>40774</ID><DOI>10.1049/iet-tv.41.40774</DOI></Video>
				<Video><ID>40778</ID><DOI>10.1049/iet-tv.47.40778</DOI></Video>
				<Video><ID>40779</ID><DOI>10.1049/iet-tv.47.40779</DOI></Video>
				<Video><ID>40780</ID><DOI>10.1049/iet-tv.47.40780</DOI></Video>
				<Video><ID>40781</ID><DOI>10.1049/iet-tv.47.40781</DOI></Video>
				<Video><ID>40784</ID><DOI>10.1049/iet-tv.47.40784</DOI></Video>
				<Video><ID>40785</ID><DOI>10.1049/iet-tv.47.40785</DOI></Video>
				<Video><ID>40786</ID><DOI>10.1049/iet-tv.47.40786</DOI></Video>
				<Video><ID>40788</ID><DOI>10.1049/iet-tv.47.40788</DOI></Video>
				<Video><ID>40805</ID><DOI>10.1049/iet-tv.41.40805</DOI></Video>
				<Video><ID>40953</ID><DOI>10.1049/iet-tv.44.40953</DOI></Video>
				<Video><ID>40954</ID><DOI>10.1049/iet-tv.44.40954</DOI></Video>
				<Video><ID>40963</ID><DOI>10.1049/iet-tv.44.40963</DOI></Video>
				<Video><ID>40964</ID><DOI>10.1049/iet-tv.44.40964</DOI></Video>
				<Video><ID>40965</ID><DOI>10.1049/iet-tv.44.40965</DOI></Video>
				<Video><ID>40967</ID><DOI>10.1049/iet-tv.44.40967</DOI></Video>
				<Video><ID>40968</ID><DOI>10.1049/iet-tv.44.40968</DOI></Video>
				<Video><ID>40969</ID><DOI>10.1049/iet-tv.44.40969</DOI></Video>
				<Video><ID>40970</ID><DOI>10.1049/iet-tv.44.40970</DOI></Video>
				<Video><ID>40972</ID><DOI>10.1049/iet-tv.44.40972</DOI></Video>
				<Video><ID>41065</ID><DOI>10.1049/iet-tv.44.41065</DOI></Video>
				<Video><ID>41160</ID><DOI>10.1049/iet-tv.44.41160</DOI></Video>
				<Video><ID>41174</ID><DOI>10.1049/iet-tv.44.41174</DOI></Video>
				<Video><ID>41175</ID><DOI>10.1049/iet-tv.44.41175</DOI></Video>
				<Video><ID>41246</ID><DOI>10.1049/iet-tv.49.41246</DOI></Video>
				<Video><ID>41333</ID><DOI>10.1049/iet-tv.41.41333</DOI></Video>
				<Video><ID>41386</ID><DOI>10.1049/iet-tv.51.41386</DOI></Video>
				<Video><ID>41389</ID><DOI>10.1049/iet-tv.51.41389</DOI></Video>
				<Video><ID>41527</ID><DOI>10.1049/iet-tv.51.41527</DOI></Video>
				<Video><ID>41528</ID><DOI>10.1049/iet-tv.51.41528</DOI></Video>
				<Video><ID>41529</ID><DOI>10.1049/iet-tv.51.41529</DOI></Video>
				<Video><ID>41530</ID><DOI>10.1049/iet-tv.51.41530</DOI></Video>
				<Video><ID>41533</ID><DOI>10.1049/iet-tv.44.41533</DOI></Video>
				<Video><ID>41559</ID><DOI>10.1049/iet-tv.50.41559</DOI></Video>
			</Videos>
for $Videos in ($XML/Video)[1]
let $VideoID := $Videos/ID/text()
let $DOI     := $Videos/DOI/text()
let $VideoURI := fn:concat($constants:VIDEO_DIRECTORY,$VideoID,".xml")
let $PHistoryUri := fn:concat($constants:PCOPY_DIRECTORY,$VideoID,".xml")
return
   (
   let $VideoXML := doc($VideoURI)
   let $VideoNumber := $VideoXML/Video/VideoNumber/text()
   return
	   if($VideoXML/Video/PublishInfo/VideoPublish[@active="yes"])
	   then
       if($VideoXML/Video/PublishInfo/VideoPublish/DOI)
       then xdmp:node-replace($VideoXML/Video/PublishInfo/VideoPublish/DOI, <DOI>{$DOI}</DOI>)
       else xdmp:node-insert-child($VideoXML/Video/PublishInfo/VideoPublish, <DOI>{$DOI}</DOI>)
     else
		 if($VideoXML/Video/PublishInfo/LivePublish/DOI)
		 then xdmp:node-replace($VideoXML/Video/PublishInfo/LivePublish/DOI, <DOI>{$DOI}</DOI>)
		 else xdmp:node-insert-child($VideoXML/Video/PublishInfo/LivePublish, <DOI>{$DOI}</DOI>)
   ,
   if(fn:doc-available($PHistoryUri))
   then
	   let $VideoXML := doc($PHistoryUri)
	   let $VideoNumber := $VideoXML/Video/VideoNumber/text()
	   return
	   if($VideoXML/Video/PublishInfo/VideoPublish[@active="yes"])
	   then
       if($VideoXML/Video/PublishInfo/VideoPublish/DOI)
       then xdmp:node-replace($VideoXML/Video/PublishInfo/VideoPublish/DOI, <DOI>{$DOI}</DOI>)
       else xdmp:node-insert-child($VideoXML/Video/PublishInfo/VideoPublish, <DOI>{$DOI}</DOI>)
     else
		 if($VideoXML/Video/PublishInfo/LivePublish/DOI)
		 then xdmp:node-replace($VideoXML/Video/PublishInfo/LivePublish/DOI, <DOI>{$DOI}</DOI>)
		 else xdmp:node-insert-child($VideoXML/Video/PublishInfo/LivePublish, <DOI>{$DOI}</DOI>)
   else ()
   )
   
   
   
   
   
   
=================================================================================================================================


import module namespace constants = "http://www.TheIET.org/constants"   at "/Utils/constants.xqy"; 

let $Prefix := '10.1049/iet-tv.vn.'
let $XML :=	<Videos>
				<ID>0086f290-d9d5-47bb-95e1-5a05113b98ae</ID>
				<ID>00e1bcfd-1d0e-45d5-8e8b-bd386b09a66a</ID>
				<ID>027c30e5-36b2-434e-b0f8-d8295157e919</ID>
				<ID>029560e1-5a34-472f-8276-a1e4d047be45</ID>
				<ID>02e334ad-270c-438e-999f-1ff8616b9e2e</ID>
				<ID>02e51bbc-b4ba-47e0-b0f9-69ad994a304c</ID>
				<ID>05e101d5-e187-4c74-84f7-12772bc59bfc</ID>
				<ID>06f588bd-418c-444b-848d-f73563eb91f7</ID>
				<ID>06f663df-4b71-4051-8287-66682ad68dae</ID>
				<ID>077e01f8-42c5-4623-8da6-3a8e2239b90f</ID>
				<ID>07e9ae08-aa81-46e3-8aca-e1d30b881d64</ID>
				<ID>081f9435-b389-42ee-974d-63fa0811f5c7</ID>
				<ID>0b49a573-07a1-41e2-a7b6-ddd3a0003957</ID>
				<ID>1450cef9-ed28-4c55-a9cc-58b106ad4cfc</ID>
				<ID>1492a557-834d-4a07-8903-bc61060690a0</ID>
				<ID>1542a7f4-f4f3-4f8d-9652-3e28a7d1bc93</ID>
				<ID>17000015-f10b-4a97-9f79-a534b129255b</ID>
				<ID>17f5a2f1-4b88-419c-a0ba-87f108a71a80</ID>
				<ID>19735919-be2d-4d63-8b81-cab67cedffdf</ID>
				<ID>1bd24483-41e3-4e2b-a914-d0c23d5fcf59</ID>
				<ID>1be52d3d-670f-4f38-905f-9035120c1a95</ID>
				<ID>1f0b3752-2b25-417f-b8b1-f12560d65816</ID>
				<ID>21ef0a23-8fa5-4415-893c-48b3ee376276</ID>
				<ID>230a0f23-1949-42e9-8333-47a279036fe8</ID>
				<ID>2508da04-3767-457b-8c95-35a710c9f453</ID>
				<ID>2660e6f7-bb21-4581-ba37-6a616acf5d4d</ID>
				<ID>2a6e003f-1abb-4eca-80f9-1ef935425697</ID>
				<ID>2c6a86b2-7cc6-4b45-b4d2-ce61a97fcaa8</ID>
				<ID>2c9ca2e5-73e4-4343-a929-8ff91a3f3584</ID>
				<ID>2d300e08-972b-4eac-8a34-1b65a7da3ef5</ID>
				<ID>2d4766f8-a143-4f2e-b6c9-12acdefa1fdc</ID>
				<ID>2d49a9a9-f5e9-467c-b592-9f006bf4410d</ID>
				<ID>301d23ec-2d72-4e38-a6bc-50ea2f18ad5d</ID>
				<ID>3098f7b9-b31e-4c05-8bc5-74049c70f170</ID>
				<ID>3308193f-3198-4be5-a34d-0ed19336b439</ID>
				<ID>340cbf34-af0b-40c5-b89d-ca9614e772d5</ID>
				<ID>34e05ff6-97e6-481e-ae87-6f3ce8b38907</ID>
				<ID>366387a1-0077-42da-a801-d291d03c58ad</ID>
				<ID>36b9a80b-6fc1-4a1b-82ba-566093c083c6</ID>
				<ID>37ba27a6-6eab-4109-aa02-f6a7ca662e00</ID>
				<ID>37e9412e-8c2a-466e-82f7-8eddb7c586f1</ID>
				<ID>39e51dc6-eca1-4e3c-821a-585fd272144e</ID>
				<ID>3c7e8ab1-967b-49b0-8199-0ba803bfa74f</ID>
				<ID>3d923031-b3dc-4784-88df-4937ccc153da</ID>
				<ID>3f9921ee-1a29-4d52-8da6-9f5bd7c33533</ID>
				<ID>40dbe065-9a1f-4207-b656-6c10a02da708</ID>
				<ID>419eebf0-ccb9-4d49-8325-7fce3bccf50c</ID>
				<ID>4b041edd-a38e-463c-ab00-a924f8329504</ID>
				<ID>4cf46193-bbd7-498a-b3e3-34ac5b3373ee</ID>
				<ID>4d9d7cf8-1c8e-4d13-a2d6-dc8257432d1d</ID>
				<ID>4f8e66ed-417f-4356-9def-5374716a20ee</ID>
				<ID>52d1dc86-8e49-4173-91ca-b955d6ffd87f</ID>
				<ID>5637034d-cc6f-4050-a240-3fc9bf1ab7e2</ID>
				<ID>56378a2a-45e0-41bc-8726-77199dd29d56</ID>
				<ID>575fed25-9c38-4453-8d1a-2a6ddb634021</ID>
				<ID>57b9315b-04d3-43af-8805-1b597990587a</ID>
				<ID>5b8b7cf2-bebc-4a23-afe8-9df3d7ea79f5</ID>
				<ID>5d9bdc88-f7a4-443f-a74f-4e0e573b4b1f</ID>
				<ID>5dd606ef-330a-43ad-aaff-59ad285a7cbc</ID>
				<ID>5dfb1f92-c2ac-4931-b2ed-154644881bc7</ID>
				<ID>5e1bb012-5092-4239-bea0-4d7e12066708</ID>
				<ID>5e3ccd9c-5fd7-427e-9f41-da7e914fdc73</ID>
				<ID>616a87eb-1cc6-4e65-95a5-cef212659038</ID>
				<ID>62193a9f-4f3d-4401-838e-65713612166b</ID>
				<ID>62245f64-6db6-44ab-a84c-70ce2143dae9</ID>
				<ID>6365ea07-3615-431a-b3b6-09f2312d1e5b</ID>
				<ID>6373e637-326e-4c76-98ca-528efe13a646</ID>
				<ID>638986b7-f5f2-463d-af4c-7892816abb3d</ID>
				<ID>66a991a9-ae1b-447a-9a5f-2fa397b76602</ID>
				<ID>678d68e8-f1fa-4d65-900e-fc0b35313e54</ID>
				<ID>68ca358a-8754-463c-9a1b-7013af3128a8</ID>
				<ID>6adb39f2-d8a5-4d3c-878d-4a57804a8520</ID>
				<ID>6dff2471-c4c1-4f71-865c-8b856bfadd1e</ID>
				<ID>714e9ded-6896-448a-b02b-c827ccd7685a</ID>
				<ID>73dd6ed7-a387-493e-bf1c-adc58e262fe7</ID>
				<ID>74cb7f1e-79cc-45e6-812b-71f47b09d05f</ID>
				<ID>777a7e07-b664-40bf-9eb2-9d2b1933f57a</ID>
				<ID>78e58195-1602-4201-b267-73e697538091</ID>
				<ID>79ad00af-cc06-4566-83b8-858ae6f60694</ID>
				<ID>79df0fad-95b1-43d6-80e4-34c8846aa74f</ID>
				<ID>7cd68bed-6c6a-425f-97f8-3c73b4384116</ID>
				<ID>7d9a890e-35e4-415e-8c91-3e0dbd590001</ID>
				<ID>7e42a156-abbb-4dad-a7be-a43f011c7879</ID>
				<ID>7e4cfa2d-721f-4e32-8932-7528448803ca</ID>
				<ID>7e75895b-3f8c-4aed-a95b-4664c78993b2</ID>
				<ID>7e7e8e7b-e713-4b82-8dbd-f6a997ac05ed</ID>
				<ID>7ec74ba6-599c-431b-bc12-8dc6765d3798</ID>
				<ID>81965c0e-9f42-4fdb-a904-df2a8b6359e0</ID>
				<ID>8213e3d5-caeb-4f28-a1ba-7347f13dd134</ID>
				<ID>843b2df8-9522-43f4-a873-a6abdec30811</ID>
				<ID>8817e077-3b0b-435f-8d7a-1eb104697f51</ID>
				<ID>88e18e2b-e1a0-4a7c-bd01-b4a3ba6eaa9c</ID>
				<ID>8b0092c5-a412-4b30-89d3-f2d15d8984a2</ID>
				<ID>8b24ccc3-6d71-45e9-a025-0aa37b9e1b5b</ID>
				<ID>8cf4ae90-b1f4-4089-9ebd-01a8b39b58ce</ID>
				<ID>8e050fbe-3584-4543-a56c-af92343b2cce</ID>
				<ID>8fbc6a30-a085-4703-b306-cd41ad3c0703</ID>
				<ID>92fa9834-b27e-4bae-a66d-bc14252e4f7a</ID>
				<ID>933cf8dc-e582-4a53-ac4e-203b0a0a73d5</ID>
				<ID>97f71581-87fd-449e-8b1f-dc45ae805deb</ID>
				<ID>9d6063c4-8e9c-4e43-aa4b-5c23563d8348</ID>
				<ID>9e8e32e5-5b94-4067-ba03-c873392319bc</ID>
				<ID>9f82b95a-56a9-4d7b-8ee0-6583b759e64e</ID>
				<ID>a01bea11-6e24-4f79-b7b2-67da3d02e34e</ID>
				<ID>a0b56cd8-65fa-4b34-b90f-8d9679e05267</ID>
				<ID>a2751a99-abb4-4bac-a6e7-55f18d23c8c3</ID>
				<ID>a7cf5dc5-c958-4a0f-91cf-e11d8bac335b</ID>
				<ID>a7d0597b-6fc8-41b4-87d4-65bcd6865608</ID>
				<ID>a848db8a-cf87-4bcd-82f8-ad66452c9733</ID>
				<ID>aa1988be-4a9e-48c4-adff-a4109c97a9cb</ID>
				<ID>abd3b5fd-ed07-4a54-80ea-c6ffab78f7a5</ID>
				<ID>adf65d63-9e1a-4a19-a0f1-c0aa13b71335</ID>
				<ID>b25b2bde-cc3c-47ec-bf1d-d8863291282d</ID>
				<ID>b4148903-701d-418f-9c09-54cc8afdd2e7</ID>
				<ID>b7f87774-1a20-4cc7-be44-6f3791aa0506</ID>
				<ID>b8096d0c-ea30-4556-9082-b9ee07a68262</ID>
				<ID>bcf64e0b-8854-4e63-9c38-5546381df090</ID>
				<ID>beaabd39-5c8d-4dfb-9a41-0824c94f3f29</ID>
				<ID>bf79fa6f-d258-48e3-b3db-4d92f7fa6107</ID>
				<ID>bfbaf60b-85cf-4419-8f66-db8ad31f730c</ID>
				<ID>c2963b25-1b87-4920-b428-494f72370b5a</ID>
				<ID>c31d679d-dc65-4ae2-b28e-21d386c476f7</ID>
				<ID>c429c976-99f9-4920-9d0b-be778fabdcaa</ID>
				<ID>c4ea2825-7353-42b4-a308-9374a71386cd</ID>
				<ID>c6db7f73-d33a-40c5-bcfe-0fa777c09198</ID>
				<ID>c9080d79-9a28-4fa2-835e-3c1c2c92ba7c</ID>
				<ID>cc93145d-1186-445f-bd31-eb0545dc2646</ID>
				<ID>cccd8c28-d392-4ad9-82a6-46b2df5c875c</ID>
				<ID>ccfa4862-8b85-40d6-bae0-028f5bbe1f81</ID>
				<ID>ccff6e58-2f02-449d-bd55-a5d821af7fbf</ID>
				<ID>d4267d66-600c-4379-8aa4-010507723956</ID>
				<ID>d59355ba-671e-4daa-9adf-a56411e85216</ID>
				<ID>d8a36594-8309-47ac-96e2-fb01ca5454d7</ID>
				<ID>d8cb6fe2-03e0-4dd4-84e8-d6587479d8f4</ID>
				<ID>dafca976-dca1-40b5-bfd9-c80f563e6389</ID>
				<ID>dc1bc07b-9f2b-4ca8-a52a-79c95f2a7676</ID>
				<ID>de2b4285-8885-4e2b-a42d-36d6aa1211a7</ID>
				<ID>de34e903-c201-4fc2-a4be-808e67360733</ID>
				<ID>e0404266-cbe5-4aa8-8a1d-58ac5c53629e</ID>
				<ID>e365f2c0-60a6-492a-96e2-81b78c90541a</ID>
				<ID>e47d1aac-4f3a-44cd-a004-cead35729c60</ID>
				<ID>ebb6d40f-6166-4b5a-91f1-7f47ab8b054c</ID>
				<ID>ed1f0f22-6d57-4aa0-a706-5b0d36f34664</ID>
				<ID>eed5ae44-29b9-4186-8c55-1a1129955373</ID>
				<ID>ef3bab40-93f8-4590-a1f5-780489a71d0b</ID>
				<ID>f2e08eb7-fade-41b0-9253-f20ab99ab7d6</ID>
				<ID>f3b1755a-7a16-4673-8f3c-e44c1532df9f</ID>
				<ID>f5d3c4dd-9bea-4adb-a7e4-3d88e376d8e8</ID>
				<ID>f5e47a49-7d08-49a1-8790-83065ae262bd</ID>
				<ID>fb333833-6912-4971-80df-7f169173d6f6</ID>
				<ID>fb3f8e55-7e0b-4fba-910b-9a0fc575adc8</ID>
				<ID>fbc53800-0934-4eb1-bde4-e8fc0a32d90a</ID>
				<ID>fbf2cc23-9384-4d8d-80a9-a19c2de17d73</ID>
				<ID>fe1e9dac-3050-475b-a51f-ae41ba7d91a5</ID>
			</Videos>
for $VideoID in ($XML/ID/text())[1]
let $VideoURI := fn:concat($constants:VIDEO_DIRECTORY,$VideoID,".xml")
let $PHistoryUri := fn:concat($constants:PCOPY_DIRECTORY,$VideoID,".xml")
return
   (
   let $VideoXML := doc($VideoURI)
   let $VideoNumber := $VideoXML/Video/VideoNumber/text()
   return
	   if($VideoXML/Video/PublishInfo/VideoPublish[@active="yes"])
	   then
       if($VideoXML/Video/PublishInfo/VideoPublish/DOI)
       then xdmp:node-replace($VideoXML/Video/PublishInfo/VideoPublish/DOI, <DOI>{concat($Prefix,$VideoNumber)}</DOI>)
       else xdmp:node-insert-child($VideoXML/Video/PublishInfo/VideoPublish, <DOI>{concat($Prefix,$VideoNumber)}</DOI>)
     else
		 if($VideoXML/Video/PublishInfo/LivePublish/DOI)
		 then xdmp:node-replace($VideoXML/Video/PublishInfo/LivePublish/DOI, <DOI>{concat($Prefix,$VideoNumber)}</DOI>)
		 else xdmp:node-insert-child($VideoXML/Video/PublishInfo/LivePublish, <DOI>{concat($Prefix,$VideoNumber)}</DOI>)
   ,
   if(fn:doc-available($PHistoryUri))
   then
	   let $VideoXML := doc($PHistoryUri)
	   let $VideoNumber := $VideoXML/Video/VideoNumber/text()
	   return
	   if($VideoXML/Video/PublishInfo/VideoPublish[@active="yes"])
	   then
       if($VideoXML/Video/PublishInfo/VideoPublish/DOI)
       then xdmp:node-replace($VideoXML/Video/PublishInfo/VideoPublish/DOI, <DOI>{concat($Prefix,$VideoNumber)}</DOI>)
       else xdmp:node-insert-child($VideoXML/Video/PublishInfo/VideoPublish, <DOI>{concat($Prefix,$VideoNumber)}</DOI>)
     else
		 if($VideoXML/Video/PublishInfo/LivePublish/DOI)
		 then xdmp:node-replace($VideoXML/Video/PublishInfo/LivePublish/DOI, <DOI>{concat($Prefix,$VideoNumber)}</DOI>)
		 else xdmp:node-insert-child($VideoXML/Video/PublishInfo/LivePublish, <DOI>{concat($Prefix,$VideoNumber)}</DOI>)
   else ()
   )


------------------------------------
(:Activity update :)
for $value in cts:element-values(xs:QName("ActorType"), (), "frequency-order")
return <facet frequency="{cts:frequency($value)}">{$value}</facet>

for $x in /Activity/Actor[ActorType[.='Unanonymous']]
let $UserName := <UserName>Unknown Status</UserName>
let $AccountType := <AccountType>Unknown Status</AccountType>
let $UserType := <UserType>Unknown Status</UserType>
let $CorporateAccountName := <CorporateAccountName>Unknown Status</CorporateAccountName>
return
  (
     if($x/AccountType) then xdmp:node-replace($x/AccountType, $AccountType) else xdmp:node-insert-child($x, $AccountType),
     if($x/$UserType) then xdmp:node-replace($x/UserType, $UserType) else xdmp:node-insert-child($x, $UserType),
     if($x/$UserName) then xdmp:node-replace($x/UserName, $UserName) else xdmp:node-insert-child($x/$UserName, $UserName),
	 if($x/$CorporateAccountName) then xdmp:node-replace($x/CorporateAccountName, $CorporateAccountName) else xdmp:node-insert-child($x/$CorporateAccountName, $CorporateAccountName)
  )
  
for $x in /Activity[Actor/ActorType='Unanonymous' and not(Actor/UserName)]
let $UserName := <UserName>Unknown Status</UserName>
return
  xdmp:node-insert-child($x/Actor, $UserName)

(: if WikiUser | VickyVisitor | VickyVisiter | user is there :)
for $x in /Activity/Actor[CorporateAccountName='VickyVisitor']
let $UserName := <UserName>Unknown Status</UserName>
let $AccountType := <AccountType>Unknown Status</AccountType>
let $UserType := <UserType>Unknown Status</UserType>
let $CorporateAccountName := <CorporateAccountName>Unknown Status</CorporateAccountName>
return
  (
     if($x/AccountType) then xdmp:node-replace($x/AccountType, $AccountType) else xdmp:node-insert-child($x, $AccountType),
     if($x/$UserType) then xdmp:node-replace($x/UserType, $UserType) else xdmp:node-insert-child($x, $UserType),
     if($x/$UserName) then xdmp:node-replace($x/UserName, $UserName) else xdmp:node-insert-child($x/$UserName, $UserName),
	 if($x/$CorporateAccountName) then xdmp:node-replace($x/CorporateAccountName, $CorporateAccountName) else xdmp:node-insert-child($x/$CorporateAccountName, $CorporateAccountName)
  )
  

for $x in /Activity/Actor[CorporateAccountName='VickyVisiter']
let $UserName := <UserName>Unknown Status</UserName>
let $AccountType := <AccountType>Unknown Status</AccountType>
let $UserType := <UserType>Unknown Status</UserType>
let $CorporateAccountName := <CorporateAccountName>Unknown Status</CorporateAccountName>
return
  (
     if($x/AccountType) then xdmp:node-replace($x/AccountType, $AccountType) else xdmp:node-insert-child($x, $AccountType),
     if($x/$UserType) then xdmp:node-replace($x/UserType, $UserType) else xdmp:node-insert-child($x, $UserType),
     if($x/$UserName) then xdmp:node-replace($x/UserName, $UserName) else xdmp:node-insert-child($x/$UserName, $UserName),
	 if($x/$CorporateAccountName) then xdmp:node-replace($x/CorporateAccountName, $CorporateAccountName) else xdmp:node-insert-child($x/$CorporateAccountName, $CorporateAccountName)
  )
  

for $x in /Activity/Actor[AccountType='WikiUser']
let $UserName := <UserName>Unknown Status</UserName>
let $AccountType := <AccountType>Unknown Status</AccountType>
let $UserType := <UserType>Unknown Status</UserType>
let $CorporateAccountName := <CorporateAccountName>Unknown Status</CorporateAccountName>
return
  (
     if($x/AccountType) then xdmp:node-replace($x/AccountType, $AccountType) else xdmp:node-insert-child($x, $AccountType),
     if($x/$UserType) then xdmp:node-replace($x/UserType, $UserType) else xdmp:node-insert-child($x, $UserType),
     if($x/$UserName) then xdmp:node-replace($x/UserName, $UserName) else xdmp:node-insert-child($x/$UserName, $UserName),
	 if($x/$CorporateAccountName) then xdmp:node-replace($x/CorporateAccountName, $CorporateAccountName) else xdmp:node-insert-child($x/$CorporateAccountName, $CorporateAccountName)
  )


for $x in /Activity/Actor[UserType='WikiUser']
let $UserName := <UserName>Unknown Status</UserName>
let $AccountType := <AccountType>Unknown Status</AccountType>
let $UserType := <UserType>Unknown Status</UserType>
let $CorporateAccountName := <CorporateAccountName>Unknown Status</CorporateAccountName>
return
  (
     if($x/AccountType) then xdmp:node-replace($x/AccountType, $AccountType) else xdmp:node-insert-child($x, $AccountType),
     if($x/$UserType) then xdmp:node-replace($x/UserType, $UserType) else xdmp:node-insert-child($x, $UserType),
     if($x/$UserName) then xdmp:node-replace($x/UserName, $UserName) else xdmp:node-insert-child($x/$UserName, $UserName),
	 if($x/$CorporateAccountName) then xdmp:node-replace($x/CorporateAccountName, $CorporateAccountName) else xdmp:node-insert-child($x/$CorporateAccountName, $CorporateAccountName)
  )
  

for $x in /Activity/Actor[CorporateAccountName='WikiUser']
let $UserName := <UserName>Unknown Status</UserName>
let $AccountType := <AccountType>Unknown Status</AccountType>
let $UserType := <UserType>Unknown Status</UserType>
let $CorporateAccountName := <CorporateAccountName>Unknown Status</CorporateAccountName>
return
  (
     if($x/AccountType) then xdmp:node-replace($x/AccountType, $AccountType) else xdmp:node-insert-child($x, $AccountType),
     if($x/$UserType) then xdmp:node-replace($x/UserType, $UserType) else xdmp:node-insert-child($x, $UserType),
     if($x/$UserName) then xdmp:node-replace($x/UserName, $UserName) else xdmp:node-insert-child($x/$UserName, $UserName),
	 if($x/$CorporateAccountName) then xdmp:node-replace($x/CorporateAccountName, $CorporateAccountName) else xdmp:node-insert-child($x/$CorporateAccountName, $CorporateAccountName)
  )



(: not required :)
for $x in /Activity/Actor[ActorType='Unanonymous' and matches(UserName, "vicky", 'i')]
let $UserName := <UserName>Unknown Status</UserName>
let $AccountType := <AccountType>Unknown Status</AccountType>
let $UserType := <UserType>Unknown Status</UserType>
let $CorporateAccountName := <CorporateAccountName>Unknown Status</CorporateAccountName>
return
  (
     if($x/AccountType) then xdmp:node-replace($x/AccountType, $AccountType) else xdmp:node-insert-child($x, $AccountType),
     if($x/$UserType) then xdmp:node-replace($x/UserType, $UserType) else xdmp:node-insert-child($x, $UserType),
     if($x/$UserName) then xdmp:node-replace($x/UserName, $UserName) else xdmp:node-insert-child($x/$UserName, $UserName),
     if($x/$CorporateAccountName) then xdmp:node-replace($x/CorporateAccountName, $CorporateAccountName) else xdmp:node-insert-child($x/$CorporateAccountName, $CorporateAccountName)
  )
  
(: not required :)
for $x in /Activity/Actor[ActorType='Unanonymous' and matches(UserName, "Wiki", 'i')]
let $UserName := <UserName>Unknown Status</UserName>
let $AccountType := <AccountType>Unknown Status</AccountType>
let $UserType := <UserType>Unknown Status</UserType>
let $CorporateAccountName := <CorporateAccountName>Unknown Status</CorporateAccountName>
return
  (
     if($x/AccountType) then xdmp:node-replace($x/AccountType, $AccountType) else xdmp:node-insert-child($x, $AccountType),
     if($x/$UserType) then xdmp:node-replace($x/UserType, $UserType) else xdmp:node-insert-child($x, $UserType),
     if($x/$UserName) then xdmp:node-replace($x/UserName, $UserName) else xdmp:node-insert-child($x/$UserName, $UserName),
     if($x/$CorporateAccountName) then xdmp:node-replace($x/CorporateAccountName, $CorporateAccountName) else xdmp:node-insert-child($x/$CorporateAccountName, $CorporateAccountName)
  )




  =================================================