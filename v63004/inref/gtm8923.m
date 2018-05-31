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
gtm8923

        do ^job("child^gtm8923",2,"""""")     ; start 2 jobs ; .
	quit

child
	ZSHOW "V"
	SET encodings="UTF-16 UTF-16BE UTF-16LE"

	FOR I=1:1:$L(encodings," ") DO
	. SET chset=$P(encodings," ",I)
	.
	. IF jobindex=1 DO  ;
	. . OPEN "gtm8923file":(CONNECT="gtm8923.file:LOCAL":attach="attach_file":CHSET=chset):10
	. . OPEN "gtm8923socket":(CONNECT="gtm8923.socket:LOCAL":attach="attach_socket":CHSET=chset):10:"SOCKET"
	. . USE "gtm8923file"
	. . WRITE "TEST WRITE",!
	. . USE "gtm8923socket"
	. . WRITE "TEST WRITE",!
	.
	. ELSE  IF jobindex=2 DO
	. . OPEN "gtm8923file":(LISTEN="gtm8923.file:LOCAL":attach="attach_file":CHSET=chset):10
	. . OPEN "gtm8923socket":(LISTEN="gtm8923.socket:LOCAL":attach="attach_socket":CHSET=chset):10:"SOCKET"
	. . USE "gtm8923file"
	. . write /wait
	. . READ text
	. . USE $P
	. . WRITE "gtm8923file READ: "_text,!
	. .
	. . USE "gtm8923socket"
	. . write /wait
	. . READ text
	. . USE $P
	. . WRITE "gtm8923file READ: "_text,!
	.
	. ELSE  DO
	. . WRITE "INVALID JOBINDEX",!
	. . WRITE "jobindex= "_jobindex,!

	;open "socket":(LISTEN=${portno}_":TCP":attach="server"):10:"SOCKET"
	quit


;tprestart       ;
;        set ^stop=0,jmaxwait=0                  ; signal child processes to proceed
;        do ^job("child^tprestart",5,"""""")     ; start 5 jobs
;        hang 10                                 ; let child run for 10 seconds
;        set ^stop=1                             ; signal child processes to stop
;        do wait^job                             ; wait for child processes to die
;        quit
;


;child  ;
;        for i=1:1  quit:^stop=1  do
;        .       tstart ():serial
;        .       set x=$incr(^c)
;        .       if $r(2) set ^a($j,x)=$j(1,220)
;        .       if $r(2) set ^b($j,x)=$j(2,220)
;        .       if $r(2) set ^c($j,x)=$j(3,220)
;        .       tcommit
;        quit

;checkRegion()
;
;	WRITE "Check for open region files:",!
;
;	; Filters the file names from the ls output
;	ZSYSTEM "ls -l /proc/"_$job_"/fd | $grep '.dat$' | awk -F '/' '{print $(NF)}' | sort"
;
;
;	; .gst files start with an RNG number, so the file names themselves require additional filtering
;
;	set line1="ls -l /proc/"_$job_"/fd | $grep '.gst$' | "
;	set line2="awk -F '/' '{print $(NF)}'  | "
;	set line3="awk -F '.' 'BEGIN { ORS="""" }; {print ""xxx""; for (i = 2; i <= NF ; i++) { print ""."" ; print $i } print ""\n""}' | "
;	set line4=" sort"
;
;	ZSYSTEM line1_line2_line3_line4
;
;	WRITE !,"Check Sharing Status:",!
;
;	set reg=""
;	for  set reg=$view("GVNEXT",reg) quit:reg=""  DO
;	. WRITE "STATSHARE "_reg_": "
;	. WRITE $VIEW("STATSHARE",reg),!
;
;	WRITE "STATSHARE: "
;	WRITE $VIEW("STATSHARE"),!
;
;	WRITE "^%YGS : ",!
;	IF $data(^%YGS)  DO
;	. ZWR ^%YGS
;
;	ELSE  DO
;	. WRITE "NO REGION"
;
;	quit
;
