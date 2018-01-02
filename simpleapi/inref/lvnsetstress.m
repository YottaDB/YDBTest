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
lvnsetstress;
	; We are going to generate an M program and a corresponding C program and check that outputs of both are identical.
	; Open these two files.
	;
	set mfile="genlvnsetstress.m"
	open mfile:(newversion)
	;
	set cfile="genlvnsetstress.c"
	open cfile:(newversion)
	;
	use cfile
	; write C file header first
	write "#include ""libyottadb.h""",!
	write "",!
	write "#include <stdio.h>",!
	write "",!
	write "#define ERRBUF_SIZE 1024",!
	write "",!
	write "int main()",!
	write "{",!
	write " int status;",!
	write " char errbuf[ERRBUF_SIZE];",!
	write " ydb_string_t zwrarg;",!
	write "",!
	;
	; Generate random sets of lvns in M and C programs
	; But take into account total system memory before deciding the maximum number of lvn sets that are generated
	; This is particularly needed as otherwise the generated C program becomes too big for the system memory to handle
	; and takes the system down (at least on the Raspberry Pi where memory is limited, at least currently).
	set totmeminkb=+$zcmdline
	set totmeminmb=totmeminkb\1024\2
	for maxmem=1:1  quit:((2**maxmem)>totmeminmb)
	set loglen=1+$random(maxmem)
	for i=1:1:$random(2**loglen) do lvnsetstresshelper
	;
	; Apply finishing touches to M and C programs
	;
	use mfile
	write " zwrite",!
	close mfile
	;
	use cfile
	write " zwrarg.address = NULL;",!
	write " zwrarg.length = 0;",!
	write " status = ydb_ci(""driveZWRITE"", &zwrarg);",!
	write " if (YDB_OK != status) { ydb_zstatus(errbuf, ERRBUF_SIZE); printf(""driveZWRITE() : %s\n"", errbuf); fflush(stdout); }",!
	write " return status;",!
	write "}",!
	close cfile
	quit

lvnsetstresshelper	;
	new i,varname,nsubs,subs
	set varname=$$getvarname()	; Generate random variable name to do set on
	set nsubs=$random(32)		; Randomly generate # of subscripts; Even 32 subscripts is an error so generate < 32
	for i=1:1:nsubs set subs(i)=$$getsubs()	; Randomly generate subscripts
	set value=$$getsubs()
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
	;
	; Write lvn set in C program
	use cfile
	write " {",!
	write "  ydb_buffer_t basevar;",!
	write "  ydb_buffer_t value;",!
	write "  ydb_buffer_t subscr["_nsubs_"];",!
	write "",!
	write "  YDB_STRLIT_TO_BUFFER(&basevar, "_$zwrite(varname)_");",!
	write "  YDB_STRLIT_TO_BUFFER(&value, "_$$forcequote($zwrite(value))_");",!
	for i=0:1:(nsubs-1) write "  YDB_STRLIT_TO_BUFFER(&subscr["_i_"], "_$$forcequote($zwrite(subs((i+1))))_");",!
	write "",!
	write "  status = ydb_set_s(&basevar, "_nsubs_", subscr, &value);",!
	write "  if (YDB_OK != status) { ydb_zstatus(errbuf, ERRBUF_SIZE); printf(""ydb_set_s() : %s\n"", errbuf); fflush(stdout); }",!
	write " }",!
	quit

forcequote(str);
	; if "str" is already quoted, then do nothing. otherwise surround it with quotes.
	if $extract(str,1)="""" quit str
	quit """"_str_""""

getvarname();
	; returns a random valid local variable name
	new first,firstlen,rest,restlen,firstletter,name,i,len,restletter
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
	new digits,digitslen,sub,intlen,i,declen,strloglen,strlen,string,stringlen
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

