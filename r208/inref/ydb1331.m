;#################################################################
;#								#
;# Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	#
;# All rights reserved.						#
;#								#
;#	This source code contains the intellectual property	#
;#	of its copyright holder(s), and is made available	#
;#	under a license.  If you do not know the terms of	#
;#	the license, please stop and do not read further.	#
;#								#
;#################################################################
;
; RECORDSIZE of a device with a UTF-8 or UTF-16 CHSET, for r208/recsize_utf_min-ydb1331
;
; $gtm_dist/mumps -run utf^ydb1331   runs the UTF-8 mode cases
; $gtm_dist/mumps -run m^ydb1331     runs the M mode cases
;
; Each case either expects an error, whose mnemonic it names, or names the bytes the file must hold, in hex. Table lines
; are ;<case>;<expected error, or the expected bytes>;<description>
;
ydb1331
	quit

utf	do run("utftable") quit
m	do run("mtable") quit

run(table)
	new i,line,case,exp,desc,got
	for i=1:1 set line=$text(@table+i) quit:line'[";"  do
	. set case=$piece(line,";",2),exp=$piece(line,";",3),desc=$piece(line,";",4)
	. set got=$$try(case)
	. write $select(got=exp:"PASS",1:"FAIL")," : ",case," : ",desc," : ",got
	. write:got'=exp " (expected ",exp,")"
	. write !
	quit

try(case)	; Returns the mnemonic of the error the case issues, or what the case returns
	new $etrap,result
	set $etrap="use $principal set result=$piece($piece($zstatus,"","",3),""-"",3),$ecode="""" quit:$quit result quit"
	set result=$$@case
	quit result

bytes(file)	; Returns the bytes in the file, in hex
	new x,hex,i
	open file:(readonly:fixed:recordsize=1:chset="M")
	use file
	set hex=""
	for  read x quit:$zeof  set hex=hex_$select(""=hex:"",1:" ")_$$hex($zascii(x))
	use $principal
	close file
	quit hex

devparms(dev)	; Returns the RECORDSIZE, ICHSET and OCHSET of the device as ZSHOW "D" shows them ("ICHSET=" or "OCHSET="
	; if it shows none)
	new x,i,line,rec,ich,och
	zshow "d":x
	set line="",rec="REC=",ich="ICHSET=",och="OCHSET="
	for i=1:1 quit:'$data(x("D",i))  if $piece(x("D",i)," ",1)=dev set line=x("D",i) quit
	for i=1:1:$length(line," ") do
	. if $piece(line," ",i)?1"REC="1.N set rec=$piece(line," ",i)
	. if $piece(line," ",i)?1"ICHSET=".E set ich=$piece(line," ",i)
	. if $piece(line," ",i)?1"OCHSET=".E set och=$piece(line," ",i)
	quit rec_" "_ich_" "_och

fds()	; Returns the number of file descriptors the process has open
	new x
	zsystem "ls /proc/"_$job_"/fd | wc -l > fds.txt"
	open "fds.txt":readonly use "fds.txt" read x use $principal close "fds.txt"
	quit +x

hex(n)	quit $extract("0123456789abcdef",n\16+1)_$extract("0123456789abcdef",n#16+1)

utftable	; UTF-8 mode
	;fixed1;RECSIZETOOSMALL;OPEN of a FIXED file with RECORDSIZE=1
	;var3;RECSIZETOOSMALL;OPEN of a VARIABLE file with RECORDSIZE=3
	;stream2;RECSIZETOOSMALL;OPEN of a STREAM file with RECORDSIZE=2
	;utf16be2;RECSIZETOOSMALL;OPEN of a FIXED file with RECORDSIZE=2 and OCHSET="UTF-16BE"
	;utf16be3;RECSIZENOTEVEN;OPEN of a FIXED file with RECORDSIZE=3 and OCHSET="UTF-16BE"
	;utf16le2;RECSIZETOOSMALL;OPEN of a FIXED file with RECORDSIZE=2 and ICHSET="UTF-16LE"
	;ichonly;RECSIZETOOSMALL;OPEN of a FIXED file with RECORDSIZE=1, ICHSET="UTF-8" and OCHSET="M"
	;msgtext;RECORDSIZE [2] needs to be at least 4;OPEN of a FIXED file with RECORDSIZE=2 (the text of the error)
	;recsize0;RMWIDTHPOS;OPEN of a FIXED file with RECORDSIZE=0
	;pipe2;RECSIZETOOSMALL 0 eof;OPEN of a PIPE with RECORDSIZE=2 (open file descriptors added, what the command saw)
	;usechset;RECSIZETOOSMALL REC=1 ICHSET=M OCHSET=M 61 62;USE with OCHSET="UTF-8" of a device with OCHSET="M" and RECORDSIZE=1
	;reopen;RECSIZETOOSMALL c6 90 20 20;OPEN with RECORDSIZE=1 again with RECORDSIZE=4, then WRITE $CHAR(400)
	;openfail;RECSIZETOOSMALL IONOTOPEN 0 0;OPEN of a new file with RECORDSIZE=1, then USE ($ZSEARCH(), file descriptors added)
	;openchset;RECSIZETOOSMALL REC=1 ICHSET=M OCHSET=M 61 62;OPEN with OCHSET="UTF-8" of an open M device with RECORDSIZE=1
	;openrec;RECSIZETOOSMALL REC=8 ICHSET=M OCHSET=M;OPEN, RECORDSIZE=2 and CHSET="UTF-8", of an open M device with RECORDSIZE=8
	;fixed4;f0 90 80 80 c6 90 20 20;FIXED file with RECORDSIZE=4, WRITE $CHAR(65536),$CHAR(400),!
	;utf16be4;d8 00 dc 00;FIXED file with RECORDSIZE=4 and OCHSET="UTF-16BE", WRITE $CHAR(65536),!
	;pipe4;1 400;PIPE with RECORDSIZE=4 to cat, WRITE $CHAR(400),! and READ it back ($LENGTH and $ASCII)
	;pipeerr;1 err;FIXED PIPE with STDERR and no RECORDSIZE, READ a line from STDERR ($TEST, line)
	;pipeerr16;1 er;PIPE with STDERR and ICHSET="UTF-16LE", READ a line from STDERR ($TEST, line)
	;pipeerrvar;1 err;PIPE that is not FIXED, with STDERR, READ a line from STDERR ($TEST, line)
	;pipeerrrec;REC=8 1 abcdefgh;FIXED PIPE with STDERR, RECORDSIZE=8, READ from STDERR (REC=, $TEST, record)
	;mchset1;61 62;FIXED file with RECORDSIZE=1 and OCHSET="M", WRITE "ab"

mtable	; M mode
	;mfixed1;61 62;FIXED file with RECORDSIZE=1, WRITE "ab"
	;mvar1;61 0a 62 0a;VARIABLE file with RECORDSIZE=1, WRITE "ab",!
	;mutf1;c8;FIXED file with RECORDSIZE=1 and OCHSET="UTF-8" (ignored in M mode), WRITE $CHAR(200)
	;pipeerr;1 err;FIXED PIPE with STDERR and no RECORDSIZE, READ a line from STDERR ($TEST, line)

fixed1()	open "f1.txt":(newversion:fixed:recordsize=1) close "f1.txt" quit "opened"
var3()	open "v3.txt":(newversion:variable:recordsize=3) close "v3.txt" quit "opened"
stream2()	open "s2.txt":(newversion:stream:recordsize=2) close "s2.txt" quit "opened"
utf16be2()	open "u2.txt":(newversion:fixed:recordsize=2:ochset="UTF-16BE") close "u2.txt" quit "opened"
utf16be3()	open "u3.txt":(newversion:fixed:recordsize=3:ochset="UTF-16BE") close "u3.txt" quit "opened"
utf16le2()	open "l2.txt":(newversion:fixed:recordsize=2:ichset="UTF-16LE") close "l2.txt" quit "opened"
ichonly()	open "i1.txt":(newversion:fixed:recordsize=1:ichset="UTF-8":ochset="M") close "i1.txt" quit "opened"
msgtext()	; Returns the text of the error after the mnemonic, up to " if"
	new $etrap,result
	set $etrap="use $principal set result=$piece($piece($zstatus,"", "",2,99),"" if"",1),$ecode="""" quit:$quit result quit"
	open "m2.txt":(newversion:fixed:recordsize=2) close "m2.txt"
	quit "opened"
recsize0()	open "z0.txt":(newversion:fixed:recordsize=0) close "z0.txt" quit "opened"
pipe2()	; The failed OPEN must leave no file descriptor open, and the command, which has already started, must see
	; the end of its input
	new err,fds,i,x
	set fds=$$fds
	set err=$$try("pipe2a")
	set fds=$$fds-fds
	for i=1:1:600 quit:""'=$zsearch("p2.txt",-1)  hang 0.1
	set x="none"
	if ""'=$zsearch("p2.txt",-1) open "p2.txt":readonly use "p2.txt" read x use $principal close "p2.txt"
	quit err_" "_fds_" "_x
pipe2a()	open "p":(shell="/bin/sh":command="cat; echo eof > p2.txt":recordsize=2)::"pipe" close "p" quit "opened"
usechset()	; The USE must fail, and leave the device with OCHSET="M" and RECORDSIZE=1 (ZSHOW "D", then WRITE "ab")
	new err
	open "c.txt":(newversion:fixed:recordsize=1:ochset="M":ichset="M")
	set err=$$usech
	set err=err_" "_$$devparms("c.txt")
	use "c.txt" write "ab" use $principal close "c.txt"
	quit err_" "_$$bytes("c.txt")
usech()	new $etrap
	set $etrap="use $principal set result=$piece($piece($zstatus,"","",3),""-"",3),$ecode="""" quit:$quit result quit"
	use "c.txt":(ochset="UTF-8") use $principal
	quit "used"
reopen()	; A failed OPEN can be followed by one with a RECORDSIZE that is large enough
	new err
	set err=$$try("reopen1")
	open "r.txt":(newversion:fixed:recordsize=4) use "r.txt" write $char(400) use $principal close "r.txt"
	quit err_" "_$$bytes("r.txt")
reopen1()	open "r.txt":(newversion:fixed:recordsize=1) close "r.txt" quit "opened"
openfail()	; The failed OPEN must leave the device closed, must not create the file, and must leave no file descriptor open
	new err,fds
	set fds=$$fds
	set err=$$try("openfail1")
	quit err_" "_$$try("openfail2")_" "_(""'=$zsearch("of.txt",-1))_" "_($$fds-fds)
openfail1()	open "of.txt":(newversion:fixed:recordsize=1) close "of.txt" quit "opened"
openfail2()	use "of.txt" use $principal quit "used"
openchset()	; The OPEN must fail, and leave the device open with OCHSET="M" and RECORDSIZE=1 (ZSHOW "D", then WRITE "ab")
	new err
	open "oc.txt":(newversion:fixed:recordsize=1:ochset="M":ichset="M")
	set err=$$try("openchset1")
	set err=err_" "_$$devparms("oc.txt")
	use "oc.txt" write "ab" use $principal close "oc.txt"
	quit err_" "_$$bytes("oc.txt")
openchset1()	open "oc.txt":(ochset="UTF-8") quit "opened"
openrec()	; The OPEN must fail, and leave the device open with its RECORDSIZE, ICHSET and OCHSET (ZSHOW "D")
	new err
	open "or.txt":(newversion:fixed:recordsize=8:ochset="M":ichset="M")
	set err=$$try("openrec1")
	set err=err_" "_$$devparms("or.txt")
	close "or.txt"
	quit err
openrec1()	open "or.txt":(recordsize=2:chset="UTF-8") quit "opened"
fixed4()	open "d.txt":(newversion:fixed:recordsize=4)
	use "d.txt" write $char(65536),$char(400),! use $principal close "d.txt"
	quit $$bytes("d.txt")
utf16be4()	open "e.txt":(newversion:fixed:recordsize=4:ochset="UTF-16BE")
	use "e.txt" write $char(65536),! use $principal close "e.txt"
	quit $$bytes("e.txt")
pipe4()	new x
	open "q":(command="cat":recordsize=4)::"pipe" use "q" write $char(400),! read x use $principal close "q"
	quit $length(x)_" "_$ascii(x)
pipeerr()	; The STDERR device gets the RECORDSIZE of the PIPE
	new x,t
	open "s":(shell="/bin/sh":command="echo err 1>&2":fixed:stderr="serr")::"pipe"
	use "serr" read x:10 set t=$test use $principal close "s"
	quit t_" "_$translate(x,$char(10))
pipeerr16()	; The STDERR device rounds the default RECORDSIZE down to even, as the PIPE does
	new x,t
	open "u":(shell="/bin/sh":command="printf ""e\\000r\\000\\n\\000"" 1>&2":ichset="UTF-16LE":stderr="uerr")::"pipe"
	use "uerr" read x:10 set t=$test use $principal close "u"
	quit t_" "_x
pipeerrvar()	; A PIPE that is not FIXED reads its STDERR device as before
	new x,t
	open "v":(shell="/bin/sh":command="echo err 1>&2":stderr="verr")::"pipe"
	use "verr" read x:10 set t=$test use $principal close "v"
	quit t_" "_x
pipeerrrec()	; A RECORDSIZE deviceparameter sets the RECORDSIZE of both devices. ZSHOW "D" does not show the STDERR
	; device, so a READ from it must return a record of RECORDSIZE bytes.
	new x,t,rec
	open "r":(shell="/bin/sh":command="echo abcdefghijk 1>&2":fixed:recordsize=8:stderr="rerr")::"pipe"
	set rec=$piece($$devparms("r")," ",1)
	use "rerr" read x:10 set t=$test use $principal close "r"
	quit rec_" "_t_" "_x
mchset1()	open "f.txt":(newversion:fixed:recordsize=1:ochset="M":ichset="M")
	use "f.txt" write "ab" use $principal close "f.txt"
	quit $$bytes("f.txt")
mfixed1()	open "g.txt":(newversion:fixed:recordsize=1) use "g.txt" write "ab" use $principal close "g.txt"
	quit $$bytes("g.txt")
mutf1()	open "k.txt":(newversion:fixed:recordsize=1:ochset="UTF-8") use "k.txt" write $char(200) use $principal close "k.txt"
	quit $$bytes("k.txt")
mvar1()	open "h.txt":(newversion:variable:recordsize=1) use "h.txt" write "ab",! use $principal close "h.txt"
	quit $$bytes("h.txt")
