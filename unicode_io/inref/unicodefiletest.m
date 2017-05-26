unicodefiletest(encoding) 
	;test various deviceparameters for sequential FILE's
	; if notype is defined, the file will not be printed
	; if nofinfo is define, the file information (dir/full) will not be printed
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;;The output of this routine will change a lot if another test is added or removed.
	;;;To check the output's correctness, first look for any TEST-E-FAIL errors, as that
	;;;will be printed if a test expected to fail passed, or vice versa.
	set $ZTRAP="do error^unicodefiletest"
	set mainlvl=$ZLEVEL
	if '$DATA(unix) set unix=$ZVERSION'["VMS"
        set filebase="test"
	set fileext="txt"
	set FAIL="FAIL"
	;
	set notype=1
	do itera("ALLOCATION=100:EXTENSION=100","WIDTH=50","",70)
	do itera("ALLOCATION=1000:EXTENSION=1000","","",70)
	do itera("ALLOCATION=100000:EXTENSION=100000","","",70)
	do itera("EXTENSION=65535","WIDTH=50","",70)
	do itera("EXTENSION=65536","WIDTH=50","",70)
	if 'unix do itera("ALLOCATION=-1","","",70,FAIL)
	do itera("EXTENSION=-1","","",70)
	do itera("CONTIGUOUS","","",100)
	do itera("RECORDSIZE=-1","","",1,FAIL)
	do itera("RECORDSIZE=0","","",1,FAIL)
	do itera("RECORDSIZE=32767","","",1)
	do itera("BIGRECORD:RECORDSIZE=32767","","",1)
	do itera("BIGRECORD:RECORDSIZE=1048576","","",1)
	do itera("BIGRECORD:RECORDSIZE=1048580","","",1,FAIL)
	do itera("","LENGTH=-1","",1,FAIL)
	do itera("","LENGTH=0","",1)
	do itera("","LENGTH=32767","",1)
	do itera("","LENGTH=1048576","",1)
	do itera("","LENGTH=1048580","",1)
	do itera("","WIDTH=-1","",1,FAIL)
	do itera("","WIDTH=0","",1,FAIL)
	do itera("","WIDTH=32767","",1)
	do itera("","WIDTH=1048576","",1)
	if unix do itera("","WIDTH=1048580","",1,FAIL)
	kill notype
	;
	if 'unix do itera("BIGRECORD","","",32767)
	if 'unix do itera("BIGRECORD","","",32769)
	do itera("ALLOCATION=0:EXTENSION=0","","",1048)
	do itera("FIXED:RECORDSIZE=50","WIDTH=70","",70)
	do itera("FIXED:RECORDSIZE=70","WIDTH=50","",70)
	do itera("FIXED:RECORDSIZE=100","WIDTH=100","",100)
	do itera("FIXED:BIGRECORD:RECORDSIZE=1048576","WIDTH=1048576","",1048576) 
	do itera("BIGRECORD:RECORDSIZE=32768","WIDTH=32768","",32768)
	;
	set nofinfo=1
	if unix do itera("RECORDSIZE=1048576","WIDTH=1048576","",1048576)
	if 'unix do itera("RECORDSIZE=1048576","WIDTH=1048576","",1048576,FAIL)
	do itera("BIGRECORD:RECORDSIZE=1048576","WIDTH=1048576","",1048576)
	do itera("RECORDSIZE=32767","WIDTH=32767","",32767)
	if 'unix do itera("RECORDSIZE=32768","WIDTH=32768","",32768,FAIL)
	do itera("BIGRECORD:RECORDSIZE=1048576","WIDTH=1048576","",1048576)
	do itera("VARIABLE:RECORDSIZE=70","WIDTH=50","",70)
	do itera("RECORDSIZE=70","WIDTH=50","",70)
	do itera("BIGRECORD:RECORDSIZE=1048576","WIDTH=50","",60)
	do itera("RECORDSIZE=70","WIDTH=50","",70)
	do itera("RECORDSIZE=70:RECORDSIZE=60","WRAP:NOWRAP","",80)
	do itera("RECORDSIZE=70:WRAP","WIDTH=70","",80)
	do itera("RECORDSIZE=70:NOWRAP","WIDTH=70","",80)
	do itera("RECORDSIZE=70:WRAP","WIDTH=70:WRAP","",80)
	do itera("RECORDSIZE=70","WIDTH=70:NOWRAP","",80)
	do itera("BIGRECORD:RECORDSIZE=1048575","WIDTH=1048575","",1048576)
	kill nofinfo
	set notype=1
	do itera("GROUP","","",10,FAIL)
	set badperm="READ"
	do itera("SYSTEM=badperm","","",10,FAIL)
	do itera("OWNER=badperm","","",10,FAIL)
	do itera("GROUP=badperm","","",10,FAIL)
	do itera("WORLD=badperm","","",10,FAIL)
	set ro="r"
	do itera("SYSTEM=""r"":OWNER=ro:GROUP=ro:WORLD=ro","","",10,FAIL)  ; cannot write to a readonly file
	do itera("","","SYSTEM=""r"":OWNER=""rw"":GROUP=ro:WORLD=ro",10)
	if unix set rwxd="rwx"
	else  set rwxd="rwed"
	do itera("SYSTEM=rwxd:OWNER=rwxd:GROUP=rwxd:WORLD=rwxd","","SYSTEM=rwxd:OWNER=rwxd:GROUP=rwxd:WORLD=rwxd",10)
	if 'unix do itera("SYSTEM=""d"":OWNER=""rwe""","","GROUP=""rwed"":WORLD=""rwd""",10)
	if unix do itera("OWNER=""rw""","","GROUP=""r"":WORLD=""rwx""",10)
	do itera("READONLY","","",10,FAIL)
	kill notype
	quit
itera(openpararametertocontrolbehavior,usepar,closepar,len,expfail) ;
	;;;If any arguments are added to itera(), please update the places where the
	;;;arguments are printed out
	if '$DATA(filebase),'$DATA(fileext) write "TEST-E-TSSERT, set filebase and fileext",! quit
	if '$DATA(filecnt) set filecnt=1
	set file=filebase_filecnt_"."_fileext
	set filecnt=filecnt+1
	new prevdev
	set prevdev=$IO
	set semiline=";;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;"
	use $PRINCIPAL
	write "===============================================================",!
	do wrtargs
	new alloc
	write "Test file: ",file," ",!
	write "OPEN parameters:  ",openpararametertocontrolbehavior,!
	write "USE parameters:   ",usepar,!
	write "CLOSE parameters: ",closepar,!
	write "write strings of length: ",len,!
	;determine if allocation was requested
	if ""'=openpararametertocontrolbehavior do 
	. set allocstr="ALLOCATION="
	. set l1=$FIND(openpararametertocontrolbehavior,allocstr)
	. if l1 set l2=$FIND(openpararametertocontrolbehavior,":",l1)
	. if l1,l2 set alloc=$PIECE($EXTRACT(openpararametertocontrolbehavior,l1,l2),":",1)
	. ;ALLOCATION=100:EXTENSION=100
	. ;          1^  2^
	;;;;;;
	if ""'=openpararametertocontrolbehavior do open^io(file,"NEWVERSION:"_openpararametertocontrolbehavior,encoding)
	if ""=openpararametertocontrolbehavior do open^io(file,"NEWVERSION",encoding)
	do showdev^io(file)
	do use^io(file,usepar)
	write semiline,!
	write ";;;;file open'd with: ",openpararametertocontrolbehavior,!
	write ";;;;use'd with: ",usepar,!
	write $$^ulongstr(len),!
	write semiline,!
	do close^io(file,closepar)
        if ""'=openpararametertocontrolbehavior do open^io(file,"APPEND:"_openpararametertocontrolbehavior,encoding)
        if ""=openpararametertocontrolbehavior do open^io(file,"APPEND",encoding)
	do use^io(file,usepar)
	write ";;;;append to file",!
	write $$^ulongstr(len),!
	write semiline,!
	close file
        if ""'=openpararametertocontrolbehavior do open^io(file,"REWIND:"_openpararametertocontrolbehavior,encoding)
        if ""=openpararametertocontrolbehavior do open^io(file,"REWIND",encoding)
	if '$DATA(notype) do readfile^filop(file,0)	; TODO: Consider some trick to avoid huge output
	if '$DATA(nofinfo)  do
	. if 'unix do dirdev^filop(file_";")
	. if unix do dirdev^filop(file)
	if '$DATA(expfail) set expfail="NOFAIL"
	if "FAIL"=expfail write "TEST-E-FAIL, this test was expected to fail!",!
	use prevdev
	quit
error	;
	; go back to the top, and continue with the next test.
	new $ZTRAP
	set $ZTRAP="write ""TEST-E-ASSERT, should not get an error here"",! halt"
	use $PRINCIPAL
	write "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!",!
	write "Got an error while testing: itera(openpararametertocontrolbehavior,usepar,closepar,len,expfail):",!
	do wrtargs
	write $ZSTATUS,!
	zshow "S"
	if '$DATA(nofinfo)  do
	. if 'unix do dirdev^filop(file_";")
	. if unix do dirdev^filop(file)
	write "Will continue with the rest of the tests...",!
	if '$DATA(expfail) set expfail="NOFAIL"
	if "FAIL"'=expfail write "TEST-E-FAIL, was not expecting an error!",! 
	if "FAIL"=expfail write "TEST-I-OK, was expecting an error",! 
	kill expfail	; reset expect fail
	write "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!",!
	zgoto mainlvl
	quit ;;dead code
wrtargs ;
	write "--> itera(""",openpararametertocontrolbehavior,""",""",usepar,""",""",closepar,""",",len
	if $DATA(expfail) write ",",expfail
	write ")",!
	quit
