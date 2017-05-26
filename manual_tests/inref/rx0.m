	;;; rx0.m
rx0	n
	s cnt=0
	if $zversion["VMS" d
	. set defdir=$zdirectory
	. set zro=$zd_"/src=(gtm$vrt:[pct],"_$zd_")"
	. set $zroutines=zro
	. set start="rx0start.com"
	. set build=$ztrnlnm("GTM$EXE")
	. set build=" "_$piece(build,"$",2)
	. open start:new use start
	. write "$ ver "_$tr($piece($zv," ",2),"-.")_build,!
	. write "$ set default "_$zd,!
	. write "$ define gtm$routines """_zro_"""",!
	. close start
	. set jobstr="job watch2^rx0($j):startup="""_$zd_"rx0start.com"""
	. xecute jobstr
	else  j watch2^rx0($j)
	r x:0
	i  s cnt=cnt+1 w !,x,"was just read.",!
	Write $Select(cnt:"FAIL",1:"PASS")," from ",$Text(+0),!
	q
watch2(rx0job)
	h 5
	zsy $s($zv["VMS":"stop/id="_$$FUNC^%DH(rx0job),1:"kill -9 "_rx0job)
	q
