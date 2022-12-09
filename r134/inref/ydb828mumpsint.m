;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2021-2022 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ydb828mumpsint; Test various functions/commands that use MUMPS_INT (i.e. mval2i()) with HUGE numbers
	;
	set %stdout="mumpsint.m" open %stdout
	set str="abcd"
	set maxiters=10
	for i=1:2:maxiters do
	. ; First test with randomly generated HUGE numbers
	. for j=1:1:3 do
	. . set num(i,j)=$$gennumber^ydb828arith
	. ; Next test with HUGE numbers close to 2Gb and -2Gb (edge cases)
	. for j=1:1:3 do
	. . set num(i+1,j)=$select($random(2):(2**31)-5+$random(10),1:-(2**31)-5+$random(10))
	write "# Testing $EXTRACT/$ZEXTRACT with random huge 2nd and/or 3rd argument",!
	for i=1:1:maxiters set xstr="set x=$extract(str,"_num(i,1)_") use x" do execute(xstr)
	for i=1:1:maxiters set xstr="set x=$extract(str,2,"_num(i,2)_") use x" do execute(xstr)
	for i=1:1:maxiters set xstr="set x=$extract(str,"_num(i,1)_","_num(i,2)_") use x" do execute(xstr)
	for i=1:1:maxiters set xstr="set x=$zextract(str,"_num(i,1)_") use x" do execute(xstr)
	for i=1:1:maxiters set xstr="set x=$zextract(str,2,"_num(i,2)_") use x" do execute(xstr)
	for i=1:1:maxiters set xstr="set x=$zextract(str,"_num(i,1)_","_num(i,2)_") use x" do execute(xstr)
	write "# Testing $ZYHASH with random huge 2nd argument",!
	for i=1:1:maxiters set xstr="set x=$zyhash(str,"_num(i,1)_")" do execute(xstr)
	write "# Testing $TEXT with random huge offset argument",!
	for i=1:1:maxiters set xstr="set x=$text(+"_num(i,1)_"^x)" do execute(xstr)
	write "# Testing $FIND with random huge 3rd argument",!
	for i=1:1:maxiters set xstr="set x=$find(str,str,"_num(i,1)_")" do execute(xstr)
	write "# Testing $ZBITFIND with random huge 2nd and/or 3rd argument",!
	for i=1:1:maxiters set xstr="set x=$zbitfind(str,"_num(i,1)_")" do execute(xstr)
	for i=1:1:maxiters set xstr="set x=$zbitfind(str,1,"_num(i,2)_")" do execute(xstr)
	for i=1:1:maxiters set xstr="set x=$zbitfind(str,"_num(i,1)_","_num(i,2)_")" do execute(xstr)
	write "# Testing $ZBITSET with random huge 2nd and/or 3rd argument",!
	for i=1:1:maxiters set xstr="set x=$zbitset(str,1,"_num(i,2)_")" do execute(xstr)
	for i=1:1:maxiters set xstr="set x=$zbitset(str,"_num(i,1)_",1)" do execute(xstr)
	for i=1:1:maxiters set xstr="set x=$zbitset(str,"_num(i,1)_","_num(i,2)_")" do execute(xstr)
	write "# Testing $ZBITGET with random huge 2nd argument",!
	for i=1:1:maxiters set xstr="set x=$zbitget(str,"_num(i,1)_")" do execute(xstr)
	write "# Testing $ZBITSTR with random huge 1st and/or 2nd argument",!
	for i=1:1:maxiters set xstr="set x=$zbitstr("_num(i,1)_")" do execute(xstr)
	for i=1:1:maxiters set xstr="set x=$zbitstr("_num(i,1)_",1)" do execute(xstr)
	for i=1:1:maxiters set xstr="set x=$zbitstr(1,"_num(i,2)_")" do execute(xstr)
	for i=1:1:maxiters set xstr="set x=$zbitstr("_num(i,1)_","_num(i,2)_")" do execute(xstr)
	write "# Testing $ZCHAR with random huge 1st argument",!
	for i=1:1:maxiters set xstr="set x=$zchar("_num(i,1)_")" do execute(xstr)
	write "# Testing $ZSIGPROC with random huge 2nd argument",!
	for i=1:1:maxiters set xstr="set x=$zsigproc(1,"_num(i,1)_")" do execute(xstr)
	write "# Testing $CHAR with random huge 1st argument",!
	for i=1:1:maxiters set xstr="set x=$char("_num(i,1)_")" do execute(xstr)
	write "# Testing $JUSTIFY with random huge 2nd and/or 3rd argument",!
	for i=1:1:maxiters set xstr="set x=$justify(str,"_num(i,1)_")" do execute(xstr)
	for i=1:1:maxiters set xstr="set x=$justify(str,1,"_num(i,2)_")" do execute(xstr)
	for i=1:1:maxiters set xstr="set x=$justify(str,"_num(i,1)_",1)" do execute(xstr)
	for i=1:1:maxiters set xstr="set x=$justify(str,"_num(i,1)_","_num(i,2)_")" do execute(xstr)
	write "# Testing $ZGETJPI with random huge 1st argument",!
	for i=1:1:maxiters set xstr="set x=$zgetjpi("_num(i,1)_",""CPUTIM"")" do execute(xstr)
	write "# Testing $RANDOM with random huge 1st argument",!
	for i=1:1:maxiters set xstr="set x=$random("_num(i,1)_")" do execute(xstr)
	write "# Testing $ZMESSAGE with random huge 1st argument",!
	for i=1:1:maxiters set xstr="set x=$zmessage("_num(i,1)_")" do execute(xstr)
	write "# Testing $QSUBSCRIPT with random huge 2nd argument",!
	for i=1:1:maxiters set xstr="set x=$qsubscript(str,"_num(i,1)_")" do execute(xstr)
	write "# Testing $ASCII with random huge 2nd argument",!
	for i=1:1:maxiters set xstr="set x=$ascii(str,"_num(i,1)_")" do execute(xstr)
	write "# Testing $STACK with random huge 1st argument",!
	for i=1:1:maxiters set xstr="set x=$stack("_num(i,1)_")" do execute(xstr)
	for i=1:1:maxiters set xstr="set x=$stack("_num(i,1)_",""MCODE"")" do execute(xstr)
	write "# Testing $ZATRANSFORM with random huge 2nd, 3rd and/or 4th arguments",!
	for i=1:1:maxiters set xstr="set x=$zatransform(str,"_num(i,1)_")" do execute(xstr)
	for i=1:1:maxiters set xstr="set x=$zatransform(str,0,"_num(i,2)_")" do execute(xstr)
	for i=1:1:maxiters set xstr="set x=$zatransform(str,0,1,"_num(i,3)_")" do execute(xstr)
	for i=1:1:maxiters set xstr="set x=$zatransform(str,"_num(i,1)_","_num(i,2)_","_num(i,3)_")" do execute(xstr)
	write "# Testing $ZCOLLATE with random huge 2nd and/or 3rd argument",!
	for i=1:1:maxiters set xstr="set x=$zcollate(str,1,"_num(i,2)_")" do execute(xstr)
	for i=1:1:maxiters set xstr="set x=$zcollate(str,"_num(i,1)_",1)" do execute(xstr)
	for i=1:1:maxiters set xstr="set x=$zcollate(str,"_num(i,1)_","_num(i,2)_")" do execute(xstr)
	; The below test tries out $ZPEEK with random memory addresses. op_fnzpeek.c handles any errors (for example, a
	; SIG-11 due to accessing invalid memory addresses etc.) by setting up signal handlers for the duration of the $ZPEEK.
	; But if YottaDB is built with ASAN, the address sanitizer would detect this invalid memory access as a heap-buffer-overflow
	; or some other error type and signal a test failure. I tried to see if it is possible to disable ASAN in certain functions
	; based on https://clang.llvm.org/docs/AddressSanitizer.html#disabling-instrumentation-with-attribute-no-sanitize-address
	; but could not get that to work. I still got a heap-buffer-overflow alert from ASAN even though I disabled ASAN
	; instrumentation in the "op_fnzpeek_stpcopy()" function in "op_fnzpeek.c". Therefore decided to disable ZPEEK related
	; random memory access tests if YottaDB has been built with ASAN. Hence the if check below.
	do:'$ztrnlnm("gtm_test_libyottadb_asan_enabled")
	. write "# Testing $ZPEEK with random huge 2nd and/or 3rd argument",!
	. for i=1:1:maxiters set xstr="set x=$zpeek(""CSAREG:DEFAULT"",1,"_num(i,2)_")" do execute(xstr)
	. for i=1:1:maxiters set xstr="set x=$zpeek(""CSAREG:DEFAULT"","_num(i,1)_",1)" do execute(xstr)
	. for i=1:1:maxiters set xstr="set x=$zpeek(""CSAREG:DEFAULT"",0,"_num(i,2)_")" do execute(xstr)
	. for i=1:1:maxiters set xstr="set x=$zpeek(""CSAREG:DEFAULT"","_num(i,1)_","_num(i,2)_")" do execute(xstr)
	write "# Testing $ZSEARCH with random huge 2nd argument",!
	for i=1:1:maxiters set xstr="set x=$zsearch(str,"_num(i,1)_")" do execute(xstr)
	write "# Testing $ZTRNLNM with random huge 3rd argument",!
	for i=1:1:maxiters set xstr="set x=$ztrnlnm(str,str,"_num(i,1)_")" do execute(xstr)
	write "# Testing $ZWRITE with random huge 2nd argument",!
	for i=1:1:maxiters set xstr="set x=$zwrite(str,"_num(i,1)_")" do execute(xstr)
	write "# Testing $PIECE/$ZPIECE with random huge 3rd and/or 4th argument",!
	for i=1:1:maxiters set xstr="set x=$piece(str,str,"_num(i,2)_")" do execute(xstr)
	for i=1:1:maxiters set xstr="set x=$piece(str,str,"_num(i,1)_")" do execute(xstr)
	for i=1:1:maxiters set xstr="set x=$piece(str,str,1,"_num(i,2)_")" do execute(xstr)
	for i=1:1:maxiters set xstr="set x=$piece(str,str,"_num(i,1)_","_num(i,2)_")" do execute(xstr)
	for i=1:1:maxiters set xstr="set x=$zpiece(str,str,"_num(i,2)_")" do execute(xstr)
	for i=1:1:maxiters set xstr="set x=$zpiece(str,str,"_num(i,1)_")" do execute(xstr)
	for i=1:1:maxiters set xstr="set x=$zpiece(str,str,1,"_num(i,2)_")" do execute(xstr)
	for i=1:1:maxiters set xstr="set x=$zpiece(str,str,"_num(i,1)_","_num(i,2)_")" do execute(xstr)
	write "# Testing READ ? with random huge argument",!
	for i=1:1:maxiters set xstr="set file=""/dev/null"" open file use file read ?"_num(i,1) do execute(xstr)
	use $principal	; needed to undo the "open file" done in previous line
	write "# Testing WRITE ? with random huge argument",!
	for i=1:1:maxiters set xstr="set file=""/dev/null"" open file use file write ?"_num(i,1) do execute(xstr)
	use $principal	; needed to undo the "open file" done in previous line
	write "# Testing DO label+offset with random huge offfset",!
	for i=1:1:maxiters set xstr="do sstep+"_num(i,1) do execute(xstr)
	write "# Testing ZBREAK label+offset with random huge offfset",!
	for i=1:1:maxiters set xstr="zbreak sstep+"_num(i,1) do execute(xstr)
	write "# Testing READ # with random huge argument",!
	for i=1:1:maxiters set xstr="set file=""/dev/null"" open file use file read str#"_num(i,1) do execute(xstr)
	use $principal	; needed to undo the "open file" done in previous line
	write "# Testing WRITE * with random huge argument",!
	for i=1:1:maxiters set xstr="set file=""/dev/null"" open file use file write *"_num(i,1) do execute(xstr)
	use $principal	; needed to undo the "open file" done in previous line
	write "# Testing SET $PIECE/$ZPIECE/$EXTRACT/$ZEXTRACT with random huge 3rd and/or 4th argument",!
	for i=1:1:maxiters set xstr="set $piece(str,str,"_num(i,2)_")=str" do execute(xstr)
	for i=1:1:maxiters set xstr="set $piece(str,str,"_num(i,1)_")=str" do execute(xstr)
	for i=1:1:maxiters set xstr="set $piece(str,str,1,"_num(i,2)_")=str" do execute(xstr)
	for i=1:1:maxiters set xstr="set $piece(str,str,"_num(i,1)_","_num(i,2)_")=str" do execute(xstr)
	for i=1:1:maxiters set xstr="set $zpiece(str,str,"_num(i,2)_")=str" do execute(xstr)
	for i=1:1:maxiters set xstr="set $zpiece(str,str,"_num(i,1)_")=str" do execute(xstr)
	for i=1:1:maxiters set xstr="set $zpiece(str,str,1,"_num(i,2)_")=str" do execute(xstr)
	for i=1:1:maxiters set xstr="set $zpiece(str,str,"_num(i,1)_","_num(i,2)_")=str" do execute(xstr)
	for i=1:1:maxiters set xstr="set $extract(str,"_num(i,2)_")=str" do execute(xstr)
	for i=1:1:maxiters set xstr="set $extract(str,"_num(i,1)_")=str" do execute(xstr)
	for i=1:1:maxiters set xstr="set $extract(str,1,"_num(i,2)_")=str" do execute(xstr)
	for i=1:1:maxiters set xstr="set $extract(str,"_num(i,1)_","_num(i,2)_")=str" do execute(xstr)
	for i=1:1:maxiters set xstr="set $zextract(str,"_num(i,2)_")=str" do execute(xstr)
	for i=1:1:maxiters set xstr="set $zextract(str,"_num(i,1)_")=str" do execute(xstr)
	for i=1:1:maxiters set xstr="set $zextract(str,1,"_num(i,2)_")=str" do execute(xstr)
	for i=1:1:maxiters set xstr="set $zextract(str,"_num(i,1)_","_num(i,2)_")=str" do execute(xstr)
	write "# Testing TROLLBACK with random huge argument",!
	for i=1:1:maxiters set xstr="trollback "_num(i,1) do execute(xstr)
	write "# Testing ZBREAK label::BreakpointCount with random huge BreakpointCount",!
	for i=1:1:maxiters set xstr="zbreak sstep::"_num(i,1) do execute(xstr)
	write "# Testing ZGOTO LEVEL with random huge LEVEL",!
	for i=1:1:maxiters set xstr="zgoto 100+"_num(i,1) do execute(xstr)
	write "# Testing ZHALT LEVEL with random huge LEVEL",!
	for i=1:1:maxiters set xstr="zhalt "_num(i,1)_"+abcd" do execute(xstr)
	write "# Testing ZMESSAGE with random huge 1st argument",!
	for i=1:1:maxiters set xstr="zmessage "_num(i,1) do execute(xstr)
	write "# Testing ZTCOMMIT with random huge 1st argument",!
	for i=1:1:maxiters set xstr="ztcommit "_num(i,1) do execute(xstr)
	write "PASS",!
	quit

execute(xstr)
	new $etrap,%io
	set $etrap="use $principal do etrap"
	set %io=$io
	use %stdout write " ",xstr,! use %io
	xecute xstr
	quit

etrap	;
	new i
	; Only allow the errors under "start" label as expected. Any other error is unexpected and we halt the program in that case.
	new errfound
	set errfound=0
	for i=1:1  set line=$text(start+i) quit:line=""  do
	. set err=$piece($piece(line,",",1)," ",3)
	. set:$zstatus[err errfound=1
	if errfound set $ecode=""
	else  zshow "*" halt
	quit

start	;
	; %YDB-E-MAXSTRLEN, Maximum string length exceeded
	; %YDB-E-NUMOFLOW, Numeric overflow
	; %YDB-E-INVBITSTR, Invalid bit string
	; %YDB-E-JUSTFRACT, Fraction specifier to $JUSTIFY cannot be negative
	; %YDB-E-INVBITLEN, Invalid size of the bit string
	; %YDB-E-IONOTOPEN, Attempt to USE an I/O device which has not been opened
	; %YDB-E-RANDARGNEG, Random number generator argument must be greater than or equal to one
	; %YDB-E-NOSUBSCRIPT, No such subscript found
	; %YDB-E-COLLATIONUNDEF, Collation type ... is not defined
	; %YDB-E-BADZPEEKARG, Missing, invalid or surplus length parameter for $ZPEEK
	; %YDB-E-BADZPEEKRANGE, Access exception raised in memory range given to $ZPEEK
	; %YDB-E-ZSRCHSTRMCT, Search stream identifier out of range
	; %YDB-E-NOPLACE, Line specified in a ZBREAK cannot be found
	; %YDB-E-LABELMISSING, Label referenced but not defined: sstep
	; %YDB-E-RDFLTOOLONG, Length specified for fixed length read exceeds the maximum string size
	; %YDB-E-RDFLTOOSHORT, Length specified for fixed length read less than or equal to zero
	; %YDB-E-TLVLZERO, Transaction is not in progress
	; %YDB-E-LVUNDEF, Undefined local variable: abcd
	; %YDB-E-ZGOTOTOOBIG, Cannot ZGOTO a level greater than present level
	; %YDB-E-ZGOTOLTZERO, Cannot ZGOTO a level less than zero
	; %SYSTEM-E-UNKNOWN, Unknown system error
	; %SYSTEM-E-ENO,
	; %YDB-E-TRANSMINUS, Negative numbers not allowed with ZTCOMMIT
	; %YDB-E-TRANSNOSTART, ZTCOMMIT(s) issued without corresponding ZTSTART(s)
	; %YDB-E-INVDLRCVAL, Invalid $CHAR() value
	; %YDB-E-BADCHAR, $ZCHAR(192) is not a valid character in the UTF-8 encoding form
	; %YDB-E-ZATRANSCOL, The collation requested has no implementation for the requested operation
	; %YDB-E-ZBRKCNTNEGATIVE, Count [-2], of transits through a ZBREAK breakpoint before activating it, cannot be negative
