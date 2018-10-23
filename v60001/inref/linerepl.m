;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This module is derived from FIS GT.M.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

linerepl	; Replace lines that do / don't contain a string
	;
	;  Usage mumps -run linerepl option... [file...]
	;  Options are either flag options or string options.
	;
	;  String options are of the form --<keyword=<delim><char>...<delim> where <char>... does not contain <delim>
	;    --match - a literal string to be matched (mandatory)
	;    --replace - replace string before output (not very useful with --negate)
	;
	;  Flags are
	;    --negate - output lines that do not match
	;    --case - match is case sensitive; default is case insensitive
	;    --verbose - provide information as it executes
	;
	;  If files are specified, output is directed to a temporary file that replaces the original file
	;  on completion of each file.  If no files are specified, works as a filter.
	;  The first matching substring is replaced - e.g., aa matches Aa in Aaa for case-insensitive matches.

	set $ztrap=""
	new arg,case,cmdline,dir,file,filegmode,fileumode,filewmodei,io,j,line,matches,matchstr,negate,randstr,replstr,stream,tmpfile,tmp,tmpline,verbose
	set cmdline=$zcmdline,(case,negate,verbose)=0,replstr="",stream=213
	for  quit:'$$trimleadingstr(.cmdline,"--")  do
	. if $$trimleadingstr(.cmdline,"case") set case=1
	. else  if $$trimleadingstr(.cmdline,"match=") set matchstr=$$trimleadingquotstr(.cmdline)
	. else  if $$trimleadingstr(.cmdline,"negate") set negate=1
	. else  if $$trimleadingstr(.cmdline,"replace=") set replstr=$$trimleadingquotstr(.cmdline),randstr=$$%RANDSTR^%RANDSTR(12)
	. else  if $$trimleadingstr(.cmdline,"verbose") set verbose=1
	. else  write "Illegal command line option(s) starting with --",cmdline,! zhalt 1
	. if $$trimleadingstr(.cmdline," ")
	if '$length($get(matchstr)) write "No match string specified",! zhalt 1
	; only filenames remain, no filename means read from and write to $princpal
	set io=$io
	set:'case matchstr=$zconvert(matchstr,"L")
	for i=1:1:$length(cmdline," ") do
	. set arg=$piece(cmdline," ",i)
	. if $length(arg) do
	. . set file=$zsearch(arg,stream) if '$length(file) write arg," does not exist.  Exiting",! zhalt 1
	. . write:verbose "Now processing ",file,!
	. . do modefile(file,.fileumode,.filegmode,.filewmode)
	. . write:verbose "Mode is user=",fileumode," group=",filegmode," world=",filewmode,!
	. . set dir=$zparse(file,"DIRECTORY"),tmpfile=dir_$$%RANDSTR^%RANDSTR(12)_"_"_$job_".tmp"
	. . write:verbose "tmpfile=",tmpfile,!
	. . open tmpfile:(newversion:owner=fileumode:group=filegmode:world=filewmode:stream:exception="use io write ""Unable to open temp file "",tmpfile,! zhalt 1")
	. . open file:(readonly:exception="use io write ""Unable to open source file "",file,! zhalt 1")
	. else  set (file,tmpfile)=$principal use $principal:(ctrap=$char(3)_$char(4):exception="halt")
	. for  use file:exception="" read line quit:$zeof  do
	. . set tmpline=$select(case:line,1:$zconvert(line,"L"))
	. . set (matches,tmp)=0 for  set tmp=$find(tmpline,matchstr,tmp) quit:'tmp  set matches=tmp-$length(matchstr)_" "_matches
	. . if matches do:'negate
	. . . if $length(replstr) for j=1:1:$length(matches," ") set tmp=$piece(matches," ",j) set:tmp $extract(line,tmp,tmp+$length(matchstr)-1)=replstr
	. . . use tmpfile:exception="" write line,!
	. . else  if negate use tmpfile write line,!
	. use io
	. if $length(arg) do
	. . close file:(delete:exception="use io write ""Unable to delete old file "",file,! zhalt 1")
	. . close tmpfile:(rename=file) ; This close should have an exception clause, but doesn't because of GTM-7002
	quit

modefile(f,u,g,w)	; get symbolic modes of file
	new i,stat,tmp
	do statfile^%POSIX(f,.stat)
	set tmp=stat("mode")
	set w=$select(tmp#2:"x",1:""),tmp=tmp\2,w=$select(tmp#2:"w",1:"")_w,tmp=tmp\2,w=$select(tmp#2:"r",1:"")_w,tmp=tmp\2
	set g=$select(tmp#2:"x",1:""),tmp=tmp\2,g=$select(tmp#2:"w",1:"")_g,tmp=tmp\2,g=$select(tmp#2:"r",1:"")_g,tmp=tmp\2
	set u=$select(tmp#2:"x",1:""),tmp=tmp\2,u=$select(tmp#2:"w",1:"")_u,tmp=tmp\2,u=$select(tmp#2:"r",1:"")_u
	quit

trimleadingquotstr(s)	; Remove leading quoted string from s
	new quote,tmp
	set quote=$extract(s,1)
	set tmp=$piece(s,quote,2)
	set s=$extract(s,$length(tmp)+3,$length(s))
	quit:$quit tmp quit

trimleadingstr(s,x)	; Return s without leading $length(x) characters; return 1/0 if called as function
	if x=$extract(s,1,$length(x)) set s=$extract(s,$length(x)+1,$length(s)) quit:$quit 1 quit
	else  quit:$quit 0 quit
