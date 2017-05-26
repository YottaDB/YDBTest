fmut02 
 ;;FILE;Tue Aug 18 09:01:06 1987;rrp
 ;g ^noent
 ;extern 
fmmvfl 
 n (z,toflcd,mvflcd,ptid)
 s paflcd=""
 s tgflcd=$p(^cd("fl",mvflcd,"in"),"\",2)
 
zi2 g:'(tgflcd'="") zi3 g:'(paflcd="") zi3
 s paflcd=tgflcd
 
zi0 g:'(paflcd'=toflcd) zi1 g:'(paflcd'="") zi1
 s paflcd=$s($d(^fm(ptid,"fl",paflcd))'[0:$p(^(paflcd),"\",1),1:"")
 g zi0
zi1 
 s:paflcd="" tgflcd=$p(^cd("fl",tgflcd,"in"),"\",2)
 g zi2
zi3 
 s:tgflcd="" tgflcd=toflcd
 s pv=^fm(ptid,"fl",mvflcd)
 s pvflcd=$p(pv,"\",1)
 s pvexdt=$p(pv,"\",3)
 k ^fmx("fl",pvflcd,ptid,"fl",mvflcd)
 k:pvexdt'="" ^fmx("ex",pvflcd,pvexdt,ptid,"fl",mvflcd)
 s mvdt=+$h
 s mvdu=$p(^cd("fl",tgflcd,"in"),"\",4)
 s exdt=$s(mvdu="":"",1:mvdt+mvdu)
 s ^fm(ptid,"fl",mvflcd)=tgflcd_"\"_mvdt_"\"_exdt
 s ^fmx("fl",tgflcd,ptid,"fl",mvflcd)=""
 s:exdt'="" ^fmx("ex",tgflcd,exdt,ptid,"fl",mvflcd)=""
 s mvflcdhi=$p(^cd("fl",mvflcd,"in"),"\",1)
 s flcd=$o(^fmx("fl",tgflcd,ptid,"fl",""))
 
zi8 g:'(flcd'="") zi9
 s flcd1=$p(^cd("fl",flcd,"in"),"\",2)
 s flcdin1=^cd("fl",flcd1,"in")
 s flcdhi1=+flcdin1
 
zi4 g:'(flcdhi1>mvflcdhi) zi5 g:'(flcd1'="") zi5
 s flcd1=$p(flcdin1,"\",2)
 s:flcd1'="" flcdin1=^cd("fl",flcd1,"in")
 s flcdhi1=+flcdin1
 g zi4
zi5 
 g:'(flcd1=mvflcd) zi6 i 1
 s xmvflcd=mvflcd,xtoflcd=toflcd
 s toflcd=mvflcd,mvflcd=flcd,ptid=ptid d fmmvfl
 s mvflcd=xmvflcd,toflcd=xtoflcd
 i 1 g zi7
zi6 i 0
zi7 
 s flcd=$o(^fmx("fl",tgflcd,ptid,"fl",flcd))
 g zi8
zi9 
 s prid=$o(^fmx("fl",tgflcd,ptid,"pr",""))
 
zi16 g:'(prid'="") zi17
 s prin=^pr(prid,"in")
 s prcd=$p(prin,"\",1)
 s dpcd=$p(^ar($p(prin,"\",3),"in"),"\",5)
 g:'($d(^cd("dp",dpcd,"pr",prcd))'[0) zi14 i 1
 s flcd1=$p(^cd("dp",dpcd,"pr",prcd),"\",1)
 s flcdin1=^cd("fl",flcd1,"in")
 s flcdhi1=+flcdin1
 
zi10 g:'(flcdhi1>mvflcdhi) zi11 g:'(flcd1'="") zi11
 s flcd1=$p(flcdin1,"\",2)
 s:flcd1'="" flcdin1=^cd("fl",flcd1,"in")
 s flcdhi1=+flcdin1
 g zi10
zi11 
 g:'(flcd1=mvflcd) zi12 i 1
 s xtoflcd=toflcd
 s prid=prid,toflcd=mvflcd d fmmvpr
 s toflcd=xtoflcd
 i 1 g zi13
zi12 i 0
zi13 
 i 1 g zi15
zi14 i 0
zi15 
 s prid=$o(^fmx("fl",tgflcd,ptid,"pr",prid))
 g zi16
zi17 
 q
fmmvpr 
 n (z,toflcd,prid)
 s prin=^pr(prid,"in")
 s prcd=$p(prin,"\",1)
 s ptid=$p(prin,"\",2)
 s dpcd=$p(^ar($p(prin,"\",3),"in"),"\",5)
 g:$d(^cd("dp",dpcd,"pr",prcd))[0 fmmvprz
 s paflcd=""
 s tgflcd=$p(^cd("dp",dpcd,"pr",prcd),"\",1)
 
zi20 g:'(tgflcd'="") zi21 g:'(paflcd="") zi21
 s paflcd=tgflcd
 
zi18 g:'(paflcd'=toflcd) zi19 g:'(paflcd'="") zi19
 s paflcd=$s($d(^fm(ptid,"fl",paflcd))'[0:$p(^(paflcd),"\",1),1:"")
 g zi18
zi19 
 s:paflcd="" tgflcd=$p(^cd("fl",tgflcd,"in"),"\",2)
 g zi20
zi21 
 s:tgflcd="" tgflcd=toflcd
 g:'($d(^fm(ptid,"pr",prid))'[0) zi22 i 1
 s pv=^fm(ptid,"pr",prid)
 s pvflcd=$p(pv,"\",1)
 s pvexdt=$p(pv,"\",3)
 k ^fmx("fl",pvflcd,ptid,"pr",prid)
 k:pvexdt'="" ^fmx("ex",pvflcd,pvexdt,ptid,"pr",prid)
 i 1 g zi23
zi22 i 0
zi23 
 s mvdt=+$h
 s mvdu=$p(^cd("fl",tgflcd,"in"),"\",4)
 s exdt=$s(mvdu="":"",1:mvdt+mvdu)
 s ^fm(ptid,"pr",prid)=tgflcd_"\"_mvdt_"\"_exdt
 s ^fmx("fl",tgflcd,ptid,"pr",prid)=""
 s:exdt'="" ^fmx("ex",tgflcd,exdt,ptid,"pr",prid)=""
fmmvprz 
 q
