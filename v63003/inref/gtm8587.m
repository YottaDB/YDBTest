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
gtm8839
        set file=$zcmdline
        open file:(readonly)
        use file:(TERMINATOR="")
	read line
        set device=$device
        close file
	write line
        ;kill line
        use $principal
        write "$DEVICE=",device,!
	write "$KEY=",$key,!
	write "Length of $DEVICE=",$length($DEVICE)
	quit
