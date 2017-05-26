unicodedo;
	do Test1
	do Test2
	do Test3
	quit

Test1;
	for I=1:1:100 do
	. set iustr="ustr"
	. set ustr=$$^ugenstr(I)
	. DO function1(ustr)
	. DO function1(@iustr)
	write "Test1 Completed",!
	quit
function1(ustr)
		set lclustr=$$^ugenstr(I)
		if lclustr'=ustr write "fail",!
	quit

Test2;
	; Try all different types of utf-8 literals as ugenstr.m
	Do litfn1("লায়েক")
	Do litfn2("ＡＤＩＲ")
	Do litfn3("αβγδε")
	Do litfn4("我能吞下玻璃而不伤身体")
	write "Test2 Completed",!
	quit

litfn1(ustr)
	if ustr'="লায়েক" write "fail",!
	quit
litfn2(ustr)
	if ustr'="ＡＤＩＲ" write "fail",!
	quit
litfn3(ustr)
	if ustr'="αβγδε" write "fail",!
	quit
litfn4(ustr)
	if ustr'="我能吞下玻璃而不伤身体" write "fail",!
	quit
	
Test3;
	;Test DO command for pass by reference
	for J=1:1:10 do
	. set saveustr=$$retMyStr(J)
	. set ustr="junk"
	. DO passbyref(J,.ustr)
	. if saveustr'=ustr write "fail" 
	write "Test3 Completed",!
	quit
passbyref(J,ustr)
	new (J,ustr)
	set ustr=$$retMyStr(J)
	quit
retMyStr(J)
	new I,ustr,tmpustr
	set ustr=""
	for I=J*10:1:(J*10)+10 do
	. set tmpustr=$$^ugenstr(I)
	. set ustr=ustr_tmpustr
	quit ustr
