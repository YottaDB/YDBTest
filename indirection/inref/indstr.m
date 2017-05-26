indstr	;
	write "run-time indirection stress for long names",!
	set unix=$zversion'["VMS"
	if unix set imax=4000
	else  set imax=3000 ;VMS test needs to increase the user stack size setting in GTM$DEFAULTS.m64
	set lntest="strtst.m"
	open lntest:new
	use lntest
	write "lntest;",!
	for i=3:3:imax do
	. write "        set lntab67890123456789012345678901(",i,")=",i,!
	. write "        set variable901234567890123456x",i,"=""",$justify(i,10),"""",!
	. write "        set variable901234567890123456x",i-1,"=""variable901234567890123456x",i,"""",!
	. write "        set variable901234567890123456x",i-2,"=@variable901234567890123456x",i-1,!
	write "        quit",!
	close lntest
	do ^strtst
	set lntab6789(i)="This output means long name failed :("
	for i=3:3:imax do
	. do ^examine($get(lntab67890123456789012345678901(i)),i," lntab6789...901("_i_")")
	for i=3:3:imax do
	. set var2="variable901234567890123456x"_(i-2)
	. set var1="variable901234567890123456x"_(i-1)
	. set var0="variable901234567890123456x"_(i)
	. do ^examine($get(@var2),$justify(i,10),var2_" (-2) at "_$ZPOSITION)
	. do ^examine($get(@var1),var0,var1_" (-1) at "_$ZPOSITION)
	. do ^examine($get(@var0),$justify(i,10),var0_" (-0) at "_$ZPOSITION)
	if ""=$get(errcnt) write "run-time indirection stress for long names PASS",!
	quit
