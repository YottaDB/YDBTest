;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2017-2018 YottaDB LLC. and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
stresstest;
	;
	; This M program opens a pipe device to a C program.
	; For now, this program does a lot of SETs of local variables and passes the same information
	; to the C program for it to do the same operation using ydb_set_st(). And at the end the
	; M program and C program do a ZWRITE to verify both have the same Local variable state.
	; As other operations in the simpleAPI are implemented (ydb_get_s etc.), those would be added here.
	;
	; Set etrap first
	set $etrap="use $principal zshow ""*"" halt"
	;
	; ------------------------------------------------------
	; Do initializations
	set mfile="genstresstest.m"
	open mfile:(newversion)
	;
	set dev="mtocpipe"
	; open device in M mode to avoid BADCHAR errors if this test ran in UTF-8 mode
	open dev:(command="$PWD/stresstest >& genstresstest.log":stream:nowrap:chset="M")::"pipe"
	for i=8,16,24 set TWO(i)=2**i
	set maxsubs=(2**$random(6))
	set YDBEOF=0,YDBSET=1,YDBGET=2,YDBKILL=3,YDBZKILL=4	; these mirror YDBEOF/YDBSET etc. in stresstest.c
	set cmd(YDBSET)="set"
	set cmd(YDBKILL)="kill"
	set cmd(YDBZKILL)="zkill"
	;
	; ------------------------------------------------------
	; Generate random sets of lvns/gvns in M and C programs
	; Also do random kills of lvns/gvns.
	;
	set killchoice=$random(2)
	set loglen=1+$random(16)
	for i=1:1:1+$random(2**loglen) do helper
	;
	; Check some random nodes before halting that they are indeed what we expect them to be (test of ydb_get_st())
	; But if random choice is to do kills, then disable ydb_get_st() random spotcheck as it is not straightforward to
	; determine what the final expected state should be (ydb_delete_s could have deleted a node from a parent level kill)
	if 'killchoice do
	. use dev
	. for i=1:1:256  do
	. . set idx=1+$random(index)
	. . set cumulstr2=cumulstr2(idx)
	. . set cumullen=cumullen(idx)
	. . set value=value(idx)
	. . set valuelen=$length(value)
	. . write $$num2bin(cumullen),$$num2bin(YDBGET),cumulstr2_$$num2bin(valuelen)_value
	. . set $x=0
	;
	; Finish writing M program
	use mfile
	write " ; List all lvns created by us",!
	write " zwrite",!
	write " ; List all gvns created by us",!
	write " do ^gvnZWRITE",!
	close mfile
	;
	; Signal EOF to C program
	use dev  write $$num2bin(0),$$num2bin(YDBEOF)
	read x	; wait for C program to die at which point the read will return with no data
	use $p
	quit

helper	;
	new i,varname,nsubs,subs,optype
	set oprtype=$select(killchoice=0:9,1:$random(10))
	; oprtype=0       implies ZKILL i.e. ydb_delete_st(YDB_NOTTP, ..., YDB_DEL_NODE)
	; oprtype=1,2     implies KILL  i.e. ydb_delete_st(YDB_NOTTP, ..., YDB_DEL_TREE)
	; oprtype=3,...,9 implies SET   i.e. ydb_set_st()
	set optype=$select(oprtype=0:YDBZKILL,(oprtype=1)!(oprtype=2):YDBKILL,1:YDBSET)
	set varname=$$getvarname(),varnamelen=$length(varname)	; Generate random variable name to do set/kill on
	set nsubs=$random(maxsubs),nsubslen=4 ; Randomly generate # of subscripts; Even 32 subscripts is an error so generate < 32
	set cumulsubstr=""
	for i=1:1:nsubs set subs(i)=$$getsubs(),cumulsubstr=cumulsubstr_$$num2bin($length(subs(i)))_subs(i) ; Randomly generate subscripts
	set value=$$getsubs(),valuelen=$length(value)
	;
	; Construct binary string to send to C program. 4-byte length will be known
	;
	set subslen=$length(cumulsubstr)
	set cumullen=(4+varnamelen)+nsubslen+subslen+(4+valuelen)
	set cumulstr2=$$num2bin(varnamelen)_varname_$$num2bin(nsubs)_cumulsubstr
	set cumulstr=cumulstr2_$$num2bin(valuelen)_value
	;
	; write total length and optype (SET/KILL/ZKILL); need $x=0 set to avoid newline being inserted in middle of lines
	use dev  write $$num2bin(cumullen),$$num2bin(optype),cumulstr  set $x=0 use $p
	if optype=YDBSET do
	. ; verify immediately afterwards that a ydb_get_s of that exact same node returns the exact same value
	. use dev  write $$num2bin(cumullen),$$num2bin(YDBGET),cumulstr  set $x=0 use $p
	if 'killchoice do
	. ; store lvn/gvn for later ydb_get_s (at end of this M program)
	. if '$data(index(cumulstr2)) set index(cumulstr2)=$incr(index),idx=index
	. else                        set idx=index(cumulstr2)
	. set value(idx)=value,cumulstr2(idx)=cumulstr2,cumullen(idx)=cumullen
	;
	; Write lvn set/kill in M program
	use mfile
	write " "_cmd(optype)_" ",varname
	if nsubs do
	. write "("
	. for i=1:1:nsubs write $zwrite(subs(i)) if i'=nsubs write ","
	. write ")"
	if optype=YDBSET do
	. write "="
	. write $zwrite(value)
	write !
	use $p
	;
	quit

getvarname();
	new loglen2,i,name
	if ('$data(varnamesetlen)) do
	. ; initialize "varnameset" array with choices of variable names
	. set loglen2=$random(7)
	. for i=1:1:1+$random(2**loglen2) set varnameset(i)=$$getvarnamehelper()
	. set varnamesetlen=i
	set name=varnameset(1+$random(varnamesetlen))
	if ($random(2)) quit name     ; local  variable name
	else            quit "^"_name ; global variable name
	quit

getvarnamehelper();
	; returns a random valid local variable name
	new first,firstlen,rest,restlen,firstletter,name,len,restletter,i
	set restminusy="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXZ"
	set first="%"_restminusy_"Y"	; first letter can include %
	set firstlen=$length(first)
	set firstletter=$extract(first,1+$random(firstlen))
	set rest=restminusy_"0123456789"	; rest of letters cannot include %
	if (firstletter'="%") set rest=rest_"Y"	; Exclude %Y to avoid PCTYRESERVED error in case of globals
	set restlen=$length(rest)
	set name=firstletter
	set len=$random(31)
	for i=1:1:len do
	. set restletter=$extract(rest,1+$random(restlen))
	. set name=name_restletter
	quit name

getsubs();
	new loglen2,i,name
	if ('$data(subssetlen)) do
	. ; initialize "subsset" array with choices of variable names
	. set loglen2=$random(7)
	. for i=1:1:1+$random(2**loglen2) set subsset(i)=$$getsubshelper()
	. set subssetlen=i
	quit subsset(1+$random(subssetlen))

getsubshelper();
	; returns a random valid local variable subscript (integer or string)
	new sub,choice,intlen,i,declen
	set digits="0123456789",digitslen=$length(digits)
	set sub=""
	if ($random(2)) do
	. ; numeric subscript
	. if '$random(4) set sub="-"	; choose a negative number randomly
	. set intlen=1+$random(6)
	. for i=1:1:intlen set sub=sub_$extract(digits,1+$random(digitslen))
	. if $random(2) do
	. . ; randomly generate decimal number (decimal point and mantissa to right of decimal point)
	. . set sub=sub_"."
	. . set declen=1+$random(4)
	. . for i=1:1:declen set sub=sub_$extract(digits,1+$random(digitslen))
	. if '$random(10) do
	. . ; generate E notation suffix with 10% probability
	. . set sub=sub_"E"
	. . if $random(2) set sub=sub_"-"	; choose a negative exponent randomly
	. . set sub=sub_(1+$random(10))
	. ;
	else  do
	. ; string subscript
	. set strloglen=1+$random(5)
	. set strlen=$random(2**strloglen)
	. set string="%:;=>'`{}|~#$^*()+!~/abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	. set stringlen=$length(string)
	. for i=1:1:strlen set sub=sub_$extract(string,1+$random(stringlen))
	quit sub

num2bin(num)
	; write 4-byte number in little endian format
	quit $zch(num#256,num\TWO(8)#256,num\TWO(16)#256,num\TWO(24))

