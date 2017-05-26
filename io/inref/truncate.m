;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2004, 2014 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
truncate ;Test the deviceparameter TRUNCATE
        set file="truncate.txt"
	set s32k=$$^longstr(32768)
	set s1mb=$$^longstr(1048576)
	write "TRUNCATE with OPEN on a non-existent file",!
	open file:(TRUNCATE:BIGRECORD:RECORDSIZE=1048576)
	use file:(WIDTH=1048576)
        write "BLAH, version 1",!
        write "MORE BLAH1, version 1",!
        write "MORE BLAH2, version 1",!
	write s32k,!
	write s1mb,!
	write "END OF FILE, version 1",!
	close file
	do type
	write "TRUNCATE with OPEN on an existing file",!
	open file:(TRUNCATE:BIGRECORD:RECORDSIZE=1048576)
	use file:(WIDTH=1048576)
        write "BLAH, version 2",!
        write "MORE BLAH1, version 2",!
        write "MORE BLAH2, version 2",!
        write "MORE BLAH3, version 2",!
        write "MORE BLAH4, version 2",!
	write s32k,!
	write s1mb,!
	write "END OF FILE, version 2",!
	close file
	do type
	write "TRUNCATE with USE on an existing file",!
	open file:(REWIND:BIGRECORD:RECORDSIZE=1048576)
	use file:(WIDTH=1048576)
	read line
	read line
	use file:(TRUNCATE)
	write "MORE BLAH1, version 3",!
	write "EVEN MORE BLAH2, version 3",!
	write s32k,!
	write s1mb,!
	write "END OF FILE, version 3",!
	close file
	do type
	write "TRUNCATE with USE on an existing file in FIXED mode",!
	open file:(REWIND:FIXED:BIGRECORD:RECORDSIZE=1048576)
	use file:(WIDTH=1048576)
	read line
	read line
	set $x=0
	use file:(TRUNCATE)
	write "MORE BLAH1, version 4",!
	write "EVEN MORE BLAH2, version 4",!
	write "END OF FILE, version 4",!
	close file
	do type
	write "TRUNCATE with USE on an existing file in FIXED mode and read#n",!
	open file:(REWIND:FIXED:BIGRECORD:RECORDSIZE=1048576)
	use file:(WIDTH=1048576)
	read line#1000000
	set $x=0
	read line
	use file:(TRUNCATE)
	write "MORE BLAH1, version 5",!
	write "EVEN MORE BLAH2, version 5",!
	write "END OF FILE, version 5",!
	close file
	do type
	quit
type
	open file:(READONLY:NOTRUNCATE:REWIND:BIGRECORD:RECORDSIZE=1048576)
	do readfile^filop(file,0)
	close file
	quit
