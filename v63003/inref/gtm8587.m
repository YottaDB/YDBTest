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
;
dollarkey
	set $ztrap="goto incrtrap^incrtrap"
        set file=$zcmdline
        open file:(readonly)
        use file:TERM="\r"
	read line
	set device=$device
	set key=$key
        close file
        use $principal
	;write line,!
	;write "# Check $KEY contains the terminating character",!
	zwrite device
	zwrite key
	kill line
	quit

dollardevice
        set $ztrap="goto incrtrap^incrtrap"
        zsystem "mkdir tmpdir"
        set file="tmpdir/tmp.txt"
        open file:(newversion)
        zsystem "chmod -w tmpdir"
        close file:delete
        use file
        set device=$device
	set key=$key
        use $principal
        ;write "# Check $DEVICE to see if it has the error detail and $KEY is an empty string",!
	zwrite device
        zwrite key
        zsystem "chmod +w tmpdir"
        close file:delete
        zsystem "rm -rf tmpdir"
        quit

