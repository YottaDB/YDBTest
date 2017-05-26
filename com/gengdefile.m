;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2013 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gengdefile(file)	;
	set unix=$zversion'["VMS"
	if unix set delim="-"
	if 'unix set delim="/"
	if '$data(inpdelim) set inpdelim="~"
	set ofile="gde"_$piece(file,"/",$length(file,"/"))
	open file:(readonly)
	open ofile:(newversion)
	use file
	for  use file read line quit:$zeof=1  do
	. set cmd=$translate(line,inpdelim,delim)
	. use ofile
	. if unix do
	. . set loc=0
	. . for  xecute "set loc=$find($zconvert(cmd,""U""),""$DEFAULT"",loc)" quit:'loc  set $extract(cmd,loc-8)=""
	. write cmd,!
	close file
	close ofile

