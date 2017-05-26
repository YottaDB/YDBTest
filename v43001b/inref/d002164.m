d002164	;
	; this test tries to do random database operations with random nested TP transactions with random TCOMMIT/TROLLBACK

	s nreg=4
	s fullstr="abcdefghi"
	f  q:^stop=1  d
	.	s level=0
	.	s type=$r(2)
	.	i type=0 d nontp
	.	i type=1 d tp
	q

nontp	;
	s space=$j(" ",$tl+1)
	d oper
	w space,str,!
	x str
	q

tp	;
	d space
	;s count=$r(2*nreg+2)
	s count=$r(3)
	w space,"tstart ():serial",!
	tstart ():serial
	d space
	w space,"$trestart = ",$trestart,!
	f i=1:1:count  d 
	.	s nest=$r(2)
	.	i nest=1 d tpnest
	.	d oper 
	.	w space,str,!  
	.	i str'="" x str
	d space
	s tptype=$r(2)
	;i tptype=0 w space,"trollback ",$tl-1,! trollback $tl-1
	;e  w space,"tcommit",! tcommit
	w space,"tcommit",! tcommit
	d space
	q

tpnest	;
	if level>1 quit
	s level=level+1
	d tp
	s level=level-1
	q
	
space	;
	s space=$j("    ",($tl+1)*4)
	q

oper	;
	s reg=$r(nreg+1)
	s global=$e(fullstr,reg+1)
	s index=$r(1)
	s operation=$r(5)
	i operation=0 d xset
	i operation=1 d xkill
	i operation=2 d xget
	i (operation=3)&($tl>0) d xlock 
	i (operation=3)&($tl=0) d noop
	i operation=4 d noop
	q

noop	;
	s str=""
	q

xset	;
	s str="set ^"_global_"("_index_")="_$j
	q

xkill	;
	s str="kill ^"_global_"("_index_")"
	q

xget	;
	s str="set tmp=$get(^"_global_"("_index_"))"
	q

xlock	;
	;s str="lock +^"_global_"("_index_")  lock -^"_global_"("_index_")"
	s str="lock +^a("_index_")  lock -^a("_index_")"
	q

