;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                               ;
; Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.       ;
; All rights reserved.                                          ;
;                                                               ;
;       This source code contains the intellectual property     ;
;       of its copyright holder(s), and is made available       ;
;       under a license.  If you do not know the terms of       ;
;       the license, please stop and do not read further.       ;
;                                                               ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
readeof;
	set file=$ZCMDLINE_".m"
	open file:(exception="goto done")
	set i=0
	for  use file  read line  do
        .       set j=$find(line,";")
        .       if 2'=j  do
	.	.	set i=i+1
	.	.	set mfile=$translate("tst"_$justify(i_".m",4)," ","0")
	.	.	open mfile:(newversion)
	.	.	use mfile
	.	.	write line,!
	.	.	close mfile
done    close file
