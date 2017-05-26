D002354	;
	; D9D08-002354 $GET(glvn, lcl2) does not work right when lcl2 is undefined
	;
	set $zstatus="",$ecode="",$etrap="set stat1=$zstatus goto global"
	set a=1 kill b if $get(a,b)
global	;
	set $zstatus="",$ecode="",$etrap="goto end"
	set ^a=1 if $get(^a,b)
end	;
	write !,$select($zstatus["UNDEF"&(stat1["UNDEF"):"PASS",1:"FAIL")," from ",$text(+0)
	do test2
	quit
test2	;
	; This test is lifted from c001664.m. That has a lot more test cases and does not test this 
	; specific test out completely i.e. this specific test has different # of variables defined
	; in the NOUNDEF and UNDEF case and the c001664.m test framework does not have the ability
	; to differentiate this easily. Instead of enhancing the framework to do this, we are 
	; testing that specific testcase completely here (a lot easier).
	new
	set $ztrap="goto incrtrap^incrtrap"
	view "NOUNDEF"
	write !,"test2 : NOUNDEF testcase",!
	set j=$G(k,k)
	zwrite	 ; expect j to be defined to "" and k to be undefined
	view "UNDEF"
	write "test2 : UNDEF testcase",!
	set j=$G(k,k)
	zwrite	 ; expect j and k to be undefined
	quit
