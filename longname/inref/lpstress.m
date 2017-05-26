lpstress	;
	;If the bug is fixed try increasing the value of imax here
	write "litpool stress for long names",!
	set lntest="lntest.m"
	open lntest:new
	use lntest
	write "lntest;",!
	set imax=2000  ; Value lowered to prevent stack-crit errors in VMS
	for i=1:1:imax do
	. write "        set lntab67890123456789012345678901(",i,")=",i,!
	. write "        set v",i,"=""",$j(i,10),"""",!
	write "        set lntab6789(",i,")=""This means a fail :(""",!
	write "        quit",!
	close lntest
	do ^lntest
	for i=1:1:imax do
	. do ^examine($get(lntab67890123456789012345678901(i)),i," lntab6789...901("_i_")")
	if ""=$get(errcnt) write "litpool stress for long names PASSED",!
	quit
