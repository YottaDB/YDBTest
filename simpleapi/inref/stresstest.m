;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2017 YottaDB LLC. and/or its subsidiaries.	;
; All rights reserved.	     	  	     			;
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
	; to the C program for it to do the same operation using ydb_set_s(). And at the end the
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
	open dev:(command="./stresstest >& genstresstest.log":stream:nowrap:exception="goto done")::"pipe"
	for i=8,16,24 set TWO(i)=2**i
	s YDBEOF=0,YDBSETS=1	; these mirror YDB_EOF/YDB_SET_S etc. in stresstest.c
	;
	; ------------------------------------------------------
	; Generate random sets of lvns in M and C programs
	;
	set loglen=1+$random(16)
	for i=1:1:$random(2**loglen) do helper
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
done	;
	;
	quit

helper	;
	new i,varname,nsubs,subs
	set varname=$$getvarname(),varnamelen=$length(varname)	; Generate random variable name to do set on
	set nsubs=$random(32),nsubslen=4 ; Randomly generate # of subscripts; Even 32 subscripts is an error so generate < 32
	set cumulsubstr=""
	for i=1:1:nsubs set subs(i)=$$getsubs(),cumulsubstr=cumulsubstr_$$num2bin($length(subs(i)))_subs(i) ; Randomly generate subscripts
	set value=$$getsubs(),valuelen=$length(value)
	;
	; Construct binary string to send to C program. 4-byte length will be known
	;
	set subslen=$length(cumulsubstr)
	set cumullen=(4+varnamelen)+nsubslen+subslen+(4+valuelen)
	set cumulstr=$$num2bin(varnamelen)_varname_$$num2bin(nsubs)_cumulsubstr_$$num2bin(valuelen)_value;
	;
	; write total length and 1 (to indicate this is ydb_set_s); need $x=0 set to avoid newline being inserted in middle of lines
	use dev  write $$num2bin(cumullen),$$num2bin(YDBSETS),cumulstr  set $x=0 use $p
	;
	; Write lvn set in M program
	use mfile
	write " set ",varname
	if nsubs do
	. write "("
	. for i=1:1:nsubs write $zwrite(subs(i)) if i'=nsubs write ","
	. write ")"
	write "="
	write $zwrite(value),!
	use $p
	;
	quit

getvarname();
	new loglen2,i,name
	if ('$data(varnamesetlen)) do
	. ; initialize "varnameset" array with choices of variable names
	. set loglen2=1+$random(7)
	. for i=1:1:1+$random(2**loglen2) set varnameset(i)=$$getvarnamehelper()
	. set varnamesetlen=i
	set name=varnameset(1+$random(varnamesetlen))
	if ($random(2)) quit name     ; local  variable name
	else            quit "^"_name ; global variable name
	quit

getvarnamehelper();
	; returns a random valid local variable name
	new first,firstlen,rest,restlen,firstletter,name,len,restletter,i
	set first="%abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"	; first letter can include %
	set firstlen=$length(first)
	set rest=$extract(first,2,99)_"0123456789"	; rest of letters cannot include %
	set restlen=$length(rest)
	set firstletter=$extract(first,1+$random(firstlen))
	set name=firstletter
	set len=$random(31)
	for i=1:1:len do
	. set restletter=$extract(rest,1+$random(restlen))
	. set name=name_restletter
	quit name

getsubs();
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

