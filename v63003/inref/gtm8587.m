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
	write line,!
	write "# Check $DEVICE to see it is 0 and $KEY contains the terminating character",!
        write "$DEVICE=",device,!
	write "$KEY=",key,"     (In previous versions, this would be an empty string)",!,!
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
        set k1=$device
	set k2=$key
        use $principal
        write "# Check $DEVICE to see if it has the error detail and $KEY is an empty string",!
        write "$DEVICE=",k1,"     (In previous versions, this would be an empty string)",!
	write "$KEY=",k2,!
        zsystem "chmod +w tmpdir"
        close file:delete
        zsystem "rm -rf tmpdir"
        quit
