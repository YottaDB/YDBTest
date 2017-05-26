c002134 ;
	; this is basically same as d002164 (from v43001b test). 
	; Here it is called many times and finishes on it's own.
	; this test tries to do random database operations with random nested TP transactions with random TCOMMIT/TROLLBACK

	w "-----------------------------------",!,"$J:",$J,!
	s nreg=8
	s fullstr="abcdefghi"
	h $r(2)
	set randmax=1+$r(8)
	write "randmax=",randmax,!
	view "GDSCERT":1
	;f  q:^stop=1  d
	f loop=1:1:100  d
	.	s level=0
	.	s type=$r(4)	; favor TP
	.	i type=0 d nontp
	.	e  d tp
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
	; 8 is the number of regions, since we do a random on it, we'll touch some (but not all regions:
	s count=$r(8)
	w space,"tstart ():serial",!
	tstart ():serial
	d space
	w space,"$trestart = ",$trestart,!
	f i=1:1:count  d 
	.	s nest=$r(randmax)
	.	i nest=0 d tpnest
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
	s str="lock +^"_global_"("_index_")  lock -^"_global_"("_index_")"
	q

