smoke	; simple test for long variable names
	set val31="this is 31"
	set val32="this is 32"
	set val31s="this is 31 with subscript"
	set val32s="this is 32 with subscript"
	set value1=33
	set value2=44
	set value3=55
set	; set some globals and locals
	set ^b234567890123456789012345678901=val31
	set ^b234567890123456789012345678901("aa")=val31s
	set ^b2345678901234567890123456789012=val32
	set ^b2345678901234567890123456789012("aa")=val32s
	set ^abcdefg(1)=33
	set ^abcdefgh(1)=44
	set ^abcdefghi(1)=55
	set d234567890123456789012345678901=val31
	set d234567890123456789012345678901("cc")=val31s
	set d2345678901234567890123456789012=val32
	set d2345678901234567890123456789012("cc")=val32s
	set labcdef(1)=value1
	set labcdefg(1)=value2
	set labcdefgh(1)=value3
	;
	do verify
	quit
verify	; verify if the variables got the correct value
	; global variables
	do ^examine($GET(^b2345678),"","^b2345678"_$ZPOSITION)
	do ^examine(^b234567890123456789012345678901,val32," b234567890123456789012345678901 "_$ZPOSITION)
	do ^examine(^b234567890123456789012345678901("aa"),val32s," b234567890123456789012345678901(""aa"") "_$ZPOSITION)
	do ^examine(^b2345678901234567890123456789012,val32," ^b2345678901234567890123456789012 "_$ZPOSITION)
	do ^examine(^b2345678901234567890123456789012("aa"),val32s,"^b2345678901234567890123456789012(""aa"") "_$ZPOSITION)
	;
	do ^examine(^abcdefg(1),value1,"^abcdefg(1) "_$ZPOSITION)
	do ^examine(^abcdefgh(1),value2,"^abcdefgh(1) "_$ZPOSITION)
	do ^examine(^abcdefghi(1),value3,"^abcdefghi(1) "_$ZPOSITION)
	;
	do ^examine(d234567890123456789012345678901,val32,$ZPOSITION)
	do ^examine(d234567890123456789012345678901("cc"),val32s,$ZPOSITION)
	do ^examine(d2345678901234567890123456789012,val32,$ZPOSITION)
	do ^examine(d2345678901234567890123456789012("cc"),val32s,$ZPOSITION)
	do ^examine(labcdef(1),value1,$ZPOSITION)
	do ^examine(labcdefg(1),value2,$ZPOSITION)
	do ^examine(labcdefgh(1),value3,$ZPOSITION)
	quit
