;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2014, 2015 Fidelity National Information	;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
; Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Provides cases for zlink test.
;
; The general pattern is:
;	preptest(<expected error>,<amount routines cycle number should increase during test case>)
;	gen* routine call -- this sets up the enviroment for the zlink, e.g., .o, .m.
;	zlink
;	verifytest(<name of test case>, <source file to be verified>)
;
; Globals for the test cases:
;	autorelinkinuse 	- are we running with autorelink
;	usefullpathonzlink 	- indicates that we should use full path on the zlink command
;	targetdir		- where the .o and/or .m should be replaced
;	iteration		- which "pass" of the test cases are we running
;

zlinkcases
	new errno
	new $etrap,$estack
	set $ecode="",$etrap="do err"
	set rselcnt=0
; Cases:
	set testbasename="objnewernoext"
	write "Case a1: No extension, both .o and .m present, but .o is newer",!
	write "Expected behavior = link only",!
	write "testbasename="_iteration_testbasename,!
	do preptest("",1)
	do genbothwithobjectnewer(testbasename)
	zlink $$getzlinktarget(testbasename)
	do verifytest(testbasename,"pass.m")

	set testbasename="objnewernoextzlink"
	write "Case a2: No extension, both .o and .m present, but .o is newer with intermediate zlink",!
	write "Expected behavior = link only",!
	write "testbasename="_iteration_testbasename,!
	do preptest("",0)
	do genbothwithobjectnewerzlink(testbasename)
	zlink $$getzlinktarget(testbasename)
	do verifytest(testbasename,"pass.m")

	set testbasename="srcnewernoext"
	write "Case b1: No extension, both .o and .m present, but .o is older",!
	write "Expected behavior = compile and link",!
	write "testbasename="_iteration_testbasename,!
	do preptest("",1)
	do genbothwithsourcenewer(testbasename)
	zlink $$getzlinktarget(testbasename)
	do verifytest(testbasename,"pass.m")

	set testbasename="srcnewernoextzlink"
	write "Case b2: No extension, both .o and .m present, but .o is older with intermediate zlink",!
	write "Expected behavior = compile and link",!
	write "testbasename="_iteration_testbasename,!
	do preptest("",1)
	do genbothwithsourcenewerzlink(testbasename)
	zlink $$getzlinktarget(testbasename)
	do verifytest(testbasename,"pass.m")

	set testbasename="srcnewernoextunch"
	write "Case b5: No extension, both .o and .m present, source newer but unchanged",!
	write "Expected behavior = compile and link",!
	write "testbasename="_iteration_testbasename,!
	do preptest("",0)
	do genbothwithsourcenewernochange(testbasename)
	zlink $$getzlinktarget(testbasename_".m")
	do verifytest(testbasename,"pass.m")

	set testbasename="srconlynoext"
	write "Case c: No extension, only .m is found",!
	write "Expected behavior = compile and link",!
	write "testbasename="_iteration_testbasename,!
	do preptest("",1)
	do genonlysource(testbasename)
	zlink $$getzlinktarget(testbasename)
	do verifytest(testbasename,"pass.m")

	set testbasename="objonlynoext"
	write "Case d1: No extension, only .o is found",!
	write "Expected behavior = link only",!
	write "testbasename="_iteration_testbasename,!
	do preptest("",1)
	do genonlyobject(testbasename)
	zlink $$getzlinktarget(testbasename)
	do verifytest(testbasename,"pass.m")

	set testbasename="objonlynoextzlink"
	write "Case d2: No extension, only .o is found with intermediate zlink",!
	write "Expected behavior = link only",!
	write "testbasename="_iteration_testbasename,!
	do preptest("",0)
	do genonlyobjectzlink(testbasename)
	zlink $$getzlinktarget(testbasename)
	do verifytest(testbasename,"pass.m")

	set testbasename="nonothing"
	write "Case e. No extension, neither .o nor .m is found",!
	write "Expected behavior = error",!
	write "testbasename="_iteration_testbasename,!
	do preptest("ZLINKFILE",0)
	do gennothing(testbasename)
	zlink $$getzlinktarget(testbasename)
	do verifytest("","")

	set testbasename="useobjobjext"
	write "Case f1. With .o extension, .o is found (and .m exists)",!
	write "Expected behavior = link only",!
	write "testbasename="_iteration_testbasename,!
	do preptest("",1)
	do genbothuseobject(testbasename)
	zlink $$getzlinktarget(testbasename_".o")
	do verifytest(testbasename,"pass.m")

	set testbasename="useobjobjextzlink"
	write "Case f2. With .o extension, .o is found (and .m exists) with intermediate zlink",!
	write "Expected behavior = link only",!
	write "testbasename="_iteration_testbasename,!
	do preptest("",0)
	do genbothuseobjectzlink(testbasename)
	zlink $$getzlinktarget(testbasename_".o")
	do verifytest(testbasename,"pass.m")

	set testbasename="objonlyobjext"
	write "Case f3. With .o extension, .o is found",!
	write "Expected behavior = link only",!
	write "testbasename="_iteration_testbasename,!
	do preptest("",1)
	do genonlyobject(testbasename)
	zlink $$getzlinktarget(testbasename_".o")
	do verifytest(testbasename,"pass.m")

	set testbasename="objonlyobjext"
	write "Case f4. With .o extension, .o is found with intermediate zlink",!
	write "Expected behavior = link only",!
	write "testbasename="_iteration_testbasename,!
	do preptest("",0)
	do genonlyobjectzlink(testbasename)
	zlink $$getzlinktarget(testbasename_".o")
	do verifytest(testbasename,"pass.m")

	set testbasename="noobj"
	write "Case g1. With .o extension, .o is missing",!
	write "Expected behavior = error",!
	write "testbasename="_iteration_testbasename,!
	do preptest("ZLINKFILE",0)
	do gennothing(testbasename)
	zlink $$getzlinktarget(testbasename_".o")
	do verifytest(testbasename,"")

	set testbasename="srconlyobjext"
	write "Case g2. With .o extension, .o is missing (and .m exists)",!
	write "Expected behavior = error",!
	write "testbasename="_iteration_testbasename,!
	do preptest("ZLINKFILE",0)
	do genonlysource(testbasename)
	zlink $$getzlinktarget(testbasename_".o")
	do verifytest(testbasename,"")

	set testbasename="usesrcmext"
	write "Case h1. With .m extension, .m is found (and .o exists)",!
	write "Expected behavior = compile and link",!
	write "testbasename="_iteration_testbasename,!
	do preptest("",1)
	do genbothusesource(testbasename)
	zlink $$getzlinktarget(testbasename_".m")
	do verifytest(testbasename,"pass.m")

	set testbasename="usesrcmextzlink"
	write "Case h2. With .m extension, .m is found (and .o exists) with intermediate zlink",!
	write "Expected behavior = compile and link",!
	write "testbasename="_iteration_testbasename,!
	do preptest("",1)
	do genbothusesourcezlink(testbasename)
	zlink $$getzlinktarget(testbasename_".m")
	do verifytest(testbasename,"pass.m")

	set testbasename="srconlysrcext"
	write "Case h3. With .m extension, .m is found",!
	write "Expected behavior = compile and link",!
	write "testbasename="_iteration_testbasename,!
	do preptest("",1)
	do genonlysource(testbasename)
	zlink $$getzlinktarget(testbasename_".m")
	do verifytest(testbasename,"pass.m")

	set testbasename="nosrc"
	write "Case i1. With .m extension, .m is missing",!
	write "Expected behavior = error",!
	write "testbasename="_iteration_testbasename,!
	do preptest("ZLINKFILE",0)
	do gennothing(testbasename)
	zlink $$getzlinktarget(testbasename_".m")
	do verifytest("",testbasename_".m")

	set testbasename="objonlysrcext"
	write "Case i2. With .m extension, .m is missing (and .o exists)",!
	write "Expected behavior = error",!
	write "testbasename="_iteration_testbasename,!
	do preptest("ZLINKFILE",0)
	do genonlyobject(testbasename)
	zlink $$getzlinktarget(testbasename_".m")
	do verifytest("",testbasename_".m")

	set testbasename="objonlysrcextzlink"
	write "Case i3. With .m extension, .m is missing (and .o exists) with intermediate zlink",!
	write "Expected behavior = error",!
	write "testbasename="_iteration_testbasename,!
	do preptest("ZLINKFILE",0)
	do genonlyobjectzlink(testbasename)
	zlink $$getzlinktarget(testbasename_".m")
	do verifytest("",testbasename_".m")
	zwrite rselcnt
	write !
	quit

;
;	Generate argument to be passed to the zlink command and also check that ^%RSEL works with auto-relink directories
;
getzlinktarget(basename)
	new %RSELname,%ZR,ext,fullpathname,i,name
	set name=""
	do &ydbposix.realpath(".",.fullpathname,.errno)	; always maintain fullpathname because we need it for ^%RSEL checking
	set fullpathname=fullpathname_"/"
	if usefullpathonzlink set name=fullpathname
	if targetdir'="" set name=name_targetdir_"/",fullpathname=fullpathname_targetdir_"/"
	set name=name_iteration_basename,fullpathname=fullpathname_iteration_basename
	set i=$find(basename,".")			; now we have the name check that ^%RSEL agrees
	set %RSELname=iteration_$select(i:$extract(basename,1,i-2),1:basename)
	set ext=$select(i:$extract(basename,i-1,$length(basename)),1:"")
	do SILENT^%RSEL(%RSELname)
	do:%ZR
	. set %RSELname=%ZR(%RSELname)_%RSELname_ext
	. if %RSELname=fullpathname,$increment(rselcnt)
	. else  write !,"^%RESL name mismatch",! zwrite name,fullpathname,%RSELname,%ZR
	quit name

;
;	Generate argument to be used by copy.
;
getcptarget(basename)
	set basename=iteration_basename
	if targetdir="" quit basename
	else  quit targetdir_"/"_basename
	quit

;
;	Compile a routine
;
compile(basename)
	set basename=iteration_basename
	set:(targetdir'="") origdir=$zdir
	set:(targetdir'="") $zdir=targetdir
	zcompile basename
	set:(targetdir'="") $zdir=origdir
	quit

;
;	Get an object's checksum
;
getobjectcksum(basename)
        set basename=iteration_basename
        set:(targetdir'="") origdir=$zdir,$zdir=targetdir
        set objcksum=$view("RTNCHECKSUM",basename)
        set:(targetdir'="") $zdir=origdir
        quit objcksum

;
;	Prepare for running a test case including any expected errors and
;	whether the routines cycle number is expected to change.
;
preptest(expectederror,expcycnumchg)
	set erroroccurred=0,origcyclenum="",expectcyclenumber2change=expcycnumchg
	if expectederror="" set errorexpected=0
	else  set errorexpected=1 set expect=expectederror
	quit

;
;	Validate the results of running a test case. This includes ensuring we produced
;	the object we expected and verifying any expected cycle number changes.
;	If we expect an error the exception handler will do the actual display.
;
verifytest(objname,srcname)
	if 'errorexpected do
	.	if ($$getobjectcksum(objname)=$$getfilehash(srcname))&'erroroccurred do
	.	.	if (origcyclenum="")!(autorelinkinuse=0) do
	.	.	.	write "Pass",!
	.	.	else  do
	.	.	.	set currcyclenum=$$getrtncyclenum(objname)
	.	.	.	if expectcyclenumber2change do
	.	.	.	.	if currcyclenum=(origcyclenum+expectcyclenumber2change) write "Pass",!
	.	.	.	.	else  write "Fail(expected cycle number="_(origcyclenum+expectcyclenumber2change)_" actual cycle num="_currcyclenum_")",!
	.	.	.	else  do
	.	.	.	.	if currcyclenum'=origcyclenum write "Fail(expected cycle number="_origcyclenum_" actual cycle num="_currcyclenum_")",!
	.	.	.	.	else  write "Pass",!
	.	else  write "Fail: erroroccurred="_erroroccurred_" object cksum=#"_$$getobjectcksum(objname)_"# source cksum=#"_$$getfilehash(srcname)_"#",!
	else  do
	.	; exception handler issues Pass/Fail
	.	if 'erroroccurred write "Expected error("_expect_") did not occur",! write "Fail",!
	write !
	quit

;
;	Wait enough time to ensure a re-compilation
;
waitfor1timeinterval
	hang .1
	quit

;
;	The below gen* routines set up the envirmonment to run a particular test case
;

;
;	Generate both a .m and .o with the object being newer
;
genbothwithobjectnewer(basename)
	set filenamebase=$$getcptarget(basename)
	if $&ydbposix.cp("pass.m",filenamebase_".m",.errno) write "copyFile(pass.m "_filenamebase_".m)"
	do compile(basename_".m")
	if $&ydbposix.cp("fail.m",filenamebase_".m",.errno) write "copyFile(fail.m "_filenamebase_".m)"
	do waitfor1timeinterval ; ensure object file time is interpreted as greater than source file time
	if $&ydbposix.utimes(filenamebase_".o",.errno) write "touchFile("_filenamebase_".o)"
	quit

;
;	Generate both a .m and .o with the object being newer and perform an intermediate zlink
;
genbothwithobjectnewerzlink(basename)
	set filenamebase=$$getcptarget(basename)
	if $&ydbposix.cp("pass.m",filenamebase_".m",.errno) write "copyFile(pass.m "_filenamebase_".m)"
	do compile(basename_".m")
	zlink filenamebase
	set origcyclenum=$$getrtncyclenum(basename)
	if $&ydbposix.cp("fail.m",filenamebase_".m",.errno) write "copyFile(fail.m "_filenamebase_".m)"
	do waitfor1timeinterval ; ensure object file time is interpreted as greater than source file time
	if $&ydbposix.utimes(filenamebase_".o",.errno) write "touchFile("_filenamebase_".o)"
	quit

;
;	Generate both a .m and .o. Compile the .m then set it up so another compile will
;	cause an incorrect result to be detected, i.e., verify there is no additional compilation.
;
genbothuseobject(basename)
	set filenamebase=$$getcptarget(basename)
	if $&ydbposix.cp("pass.m",filenamebase_".m",.errno) write "copyFile(pass.m "_filenamebase_".m)"
	do compile(basename_".m")
	do waitfor1timeinterval ; ensure source file time is interpreted as greater than object file time
	if $&ydbposix.cp("fail.m",filenamebase_".m",.errno) write "copyFile(fail.m "_filenamebase_".m)"
	quit

;
;	Generate both a .m and .o. Compile the .m then set it up so another compile will
;	cause an incorrect result to be detected, i.e., verify there is no additional compilation.
;	Perform an intermediate zlink.
;
genbothuseobjectzlink(basename)
	set filenamebase=$$getcptarget(basename)
	if $&ydbposix.cp("pass.m",filenamebase_".m",.errno) write "copyFile(pass.m "_filenamebase_".m)"
	do compile(basename_".m")
	zlink filenamebase
	set origcyclenum=$$getrtncyclenum(basename)
	do waitfor1timeinterval ; ensure source file time is interpreted as greater than source file time
	if $&ydbposix.cp("fail.m",filenamebase_".m",.errno) write "copyFile(fail.m "_filenamebase_".m)"
	quit

;
;	Generate both a .m and .o with the source being newer.
;
genbothwithsourcenewer(basename)
	set filenamebase=$$getcptarget(basename)
	if $&ydbposix.cp("fail.m",filenamebase_".m",.errno) write "copyFile(fail.m "_filenamebase_".m)"
	do compile(basename_".m")
	do waitfor1timeinterval ; ensure source file time is interpreted as greater than object file time
	if $&ydbposix.cp("pass.m",filenamebase_".m",.errno) write "copyFile(pass.m "_filenamebase_".m)"
	if $&ydbposix.utimes(filenamebase_".m",.errno) write "touchFile("_filenamebase_".m)"
	quit

;
;	Generate both a .m and .o with the source being newer and perform an intermediate zlink.
;	Perform an intermediate zlink.
;
genbothwithsourcenewerzlink(basename)
	set filenamebase=$$getcptarget(basename)
	if $&ydbposix.cp("fail.m",filenamebase_".m",.errno) write "copyFile(fail.m "_filenamebase_".m)"
	do compile(basename_".m")
	zlink filenamebase_".m"
	set origcyclenum=$$getrtncyclenum(basename)
	do waitfor1timeinterval ; ensure source file time is interpreted as greater than object file time
	if $&ydbposix.cp("pass.m",filenamebase_".m",.errno) write "copyFile(pass.m "_filenamebase_".m)"
	if $&ydbposix.utimes(filenamebase_".m",.errno) write "touchFile("_filenamebase_".m)"
	quit

;
;	Generate both a .m and .o with the source being newer and the source matching the object.
;
genbothwithsourcenewernochange(basename)
	set filenamebase=$$getcptarget(basename)
	if $&ydbposix.cp("pass.m",filenamebase_".m",.errno) write "copyFile(pass.m "_filenamebase_".m)"
	do compile(basename_".m")
	set origcyclenum=$$getrtncyclenum(basename)
	do waitfor1timeinterval ; ensure source file time is interpreted as greater than object file time
	if $&ydbposix.utimes(filenamebase_".m",.errno) write "touchFile("_filenamebase_".m)"
	quit

;
;	Generate both a .m and .o. Set up to verify there is additional compilation.
;
genbothusesource(basename)
	set filenamebase=$$getcptarget(basename)
	if $&ydbposix.cp("fail.m",filenamebase_".m",.errno) write "copyFile(fail.m "_filenamebase_".m)"
	do compile(basename_".m")
	do waitfor1timeinterval ; ensure source file time is interpreted as greater than object file time
	if $&ydbposix.cp("pass.m",filenamebase_".m",.errno) write "copyFile(pass.m "_filenamebase_".m)"
	quit

;
;	Generate both a .m and .o. Set up to verify there is additional compilation.
;	Perform an intermediate zlink.
;
genbothusesourcezlink(basename)
	set filenamebase=$$getcptarget(basename)
	if $&ydbposix.cp("fail.m",filenamebase_".m",.errno) write "copyFile(fail.m "_filenamebase_".m)"
	do compile(basename_".m")
	zlink filenamebase_".m"
	set origcyclenum=$$getrtncyclenum(basename)
	do waitfor1timeinterval ; ensure source file time is interpreted as greater than object file time
	if $&ydbposix.cp("pass.m",filenamebase_".m",.errno) write "copyFile(pass.m "_filenamebase_".m)"
	quit

;
;	Generate both .m only.
;
genonlysource(basename)
	set filenamebase=$$getcptarget(basename)
	if $&ydbposix.cp("pass.m",filenamebase_".m",.errno) write "copyFile(pass.m "_filenamebase_".m)"
	quit

;
;	Generate both .o only, i.e., remove the .m.
;
genonlyobject(basename)
	set filenamebase=$$getcptarget(basename)
	if $&ydbposix.cp("pass.m",filenamebase_".m",.errno) write "copyFile(pass.m "_filenamebase_".m)"
	do compile(basename_".m")
	if $&relink.removeFile(filenamebase_".m") write "removeFile("_filenamebase_".m)"
	quit
;
;	Generate both .o only, i.e., remove the .m.
;	Perform an intermediate zlink.
;
genonlyobjectzlink(basename)
	set filenamebase=$$getcptarget(basename)
	if $&ydbposix.cp("pass.m",filenamebase_".m",.errno) write "copyFile(pass.m "_filenamebase_".m)"
	do compile(basename_".m")
	if $&relink.removeFile(filenamebase_".m") write "removeFile("_filenamebase_".m)"
	zlink filenamebase
	set origcyclenum=$$getrtncyclenum(basename)
	quit

;
;	In this case there is neither .m nor .o.
;
gennothing(filenamebase)
	quit

;
;	Get a source file's hash.
;
getfilehash(filename)
	quit $&relink.murmurHash(srcname)

;
;	Get a routines cycle number (considering iteration and target directory).
;
getrtncyclenum(rtnname)
        new file,cyclenum,line
        set file=iteration_rtnname_".rctldump"
        set cyclenum=""
	set objdir=""
        open file:newversion
        use file
	zshow "A"
        close file
        open file
        use file
        for  read line quit:$zeof!(cyclenum'="")  do
	.	if line["Object Directory" set objdir=$piece($p(line," ",12),"/zlink/",2)
        .	if ((objdir=targetdir)&(line[(iteration_rtnname_" "))) set cyclenum=$piece(line," ",10)
        close file
        use $p
        quit cyclenum

;
;	Error handler that displays all errors (including expected ones).
;
err
	if $estack write:'$stack !,"error handling failed",!,$zstatus zgoto @($zlevel-1_":"_$zposition)
	for lev=$stack:-1:0 set loc=$stack(lev,"PLACE") quit:$stack(lev,"PLACE")[("^"_$text(+0))
	set next=$zl_":"_$p(loc,"+")_"+"_($piece(loc,"+",2)+1)_"^"_$piece(loc,"^",2)
	set status=$zstatus
	write $piece(status,",",3),!
	set erroroccurred=1
	if status[$get(expect)&errorexpected write "Pass",!
	else  write "Fail",!
	if status'[$get(expect)!(""=$get(expect)),$increment(cnt) set io=$i write !,$stack(lev,"MCODE"),!,$zstatus use io
	set $ecode=""
	zgoto @next
	write !,"oops",!,$zstatus
	zhalt 4	; in case of error within err
