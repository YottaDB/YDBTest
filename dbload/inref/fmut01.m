fmut01 
	;;FILE;Tue Aug 18 09:00:53 1987;rrp
	;g ^noent
	;extern 
	;lbfm g lbfm^lbut04
fmmvfl g fmmvfl^fmut02
fmmvpr g fmmvpr^fmut02
	;scer g scer^sc
	;trbg g trbg^tr01
	;tren g tren^tr01
err	g err^elerec
fldr 
 n (z,ar,aridn,ptid,prid,scqt)
 s dpcd=$p(ar,"\",2)
 s prcd=$p(^pr(prid,"in"),"\",1)
 s fldrs=""
 s fldr=$p(^cd("dp",dpcd,"pr",prcd),"\",1)
 
zi9 g:'($p(^cd("fl",fldr,"in"),"\",2)'="") zi10
 g:'($d(^fm(ptid,"fl",fldr))[0) zi7 i 1
 s fldrs(fldr)=""
 ;g:'($d(^cd("dp",dpcd,"fl",fldr))[0) zi0 i 1
 ;s initlc=^cd("op","fd.fmmv.flcd.dfvl","vl")
 ;i 1 g zi1
 ;zi0 i 0
 ;zi1 
 ;g:$t zi2
 ;s initlc=^cd("dp",dpcd,"fl",fldr)
 ;zi2 
 s initlc=$s($g(^cd("dp",dpcd,"fl",fldr))="":"fr",1:^(fldr))
 g:'($p(^cd("fl",initlc,"in"),"\",2)'="") zi5 i 1
 s parent=$p(^cd("fl",fldr,"in"),"\",2)
 
zi3 g:'(parent'="") zi4
 g:parent=initlc fldr1
 s parent=$p(^cd("fl",parent,"in"),"\",2)
 g zi3
zi4 
 ;s scer="Folder """_fldr_""" does not belong to """_initlc_"""." d scer
 ;s scer="Folders won't be defined for procedure """_prid_"""." d scer
 s err="Folder """_fldr_""" does not belong to """_initlc_""". No folders for "_prid d err
 g fldrz
 i 1 g zi6
zi5 i 0
zi6 
fldr1 
 s ^fm(ptid,"fl",fldr)=initlc_"\\"
 s ^fmx("fl",initlc,ptid,"fl",fldr)=""
 s prid=prid,flcd=fldr ;d lbfm
 i 1 g zi8
zi7 i 0
zi8 
 s fldr=$p(^cd("fl",fldr,"in"),"\",2)
 g zi9
zi10 
 s fldr=$o(fldrs(""))
 
zi18 g:'(fldr'="") zi19
 ;g:'($d(^cd("dp",dpcd,"fl",fldr))[0) zi11 i 1
 ;s initlc=^cd("op","fd.fmmv.flcd.dfvl","vl")
 ;i 1 g zi12
 ;zi11 i 0
 ;zi12 
 ;g:$t zi13
 ;s initlc=^cd("dp",dpcd,"fl",fldr)
 ;zi13 
 s initlc=$s($g(^cd("dp",dpcd,"fl",fldr))="":"fr",1:^(fldr))
 s parent=$p(^cd("fl",initlc,"in"),"\",2)
 
zi16 g:'(parent'="") zi17
 g:'($p(^cd("fl",parent,"in"),"\",2)="") zi14 i 1
 s initlc=parent
 i 1 g zi15
zi14 i 0
zi15 
 s parent=$p(^cd("fl",parent,"in"),"\",2)
 g zi16
zi17 
 s sdpcd=dpcd,sprcd=prcd
 s toflcd=initlc,mvflcd=fldr,ptid=ptid
 s trcd="fmmvrcfl",trin=mvflcd ;d trbg
 d fmmvfl
 s trcd="fmmvrcfl" ;d tren
 s dpcd=sdpcd,prcd=sprcd
 s fldr=$o(fldrs(fldr))
 g zi18
zi19 
 g:'($d(^fm(ptid,"pr",prid))[0) zi20 i 1
 d pr
 i 1 g zi21
zi20 i 0
zi21 
fldrz 
 q
pr 
 n (z,ar,ptid,prid)
 s dpcd=$p(ar,"\",2)
 s prcd=$p(^pr(prid,"in"),"\",1)
 s initlc=$p(^cd("dp",dpcd,"pr",prcd),"\",2)
 s parent=$p(^cd("fl",initlc,"in"),"\",2)
 
zi24 g:'(parent'="") zi25
 g:'($p(^cd("fl",parent,"in"),"\",2)="") zi22 i 1
 s initlc=parent
 i 1 g zi23
zi22 i 0
zi23 
 s parent=$p(^cd("fl",parent,"in"),"\",2)
 g zi24
zi25 
 s toflcd=initlc,prid=prid
 s trcd="fmmvrcpr" ;d trbg
 d fmmvpr
 s trcd="fmmvrcpr" ;d tren
 q
