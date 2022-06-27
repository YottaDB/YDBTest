;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2022 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Test for GTM-9238 - This particular routine tests that once we get a STPCRIT, the next time we hit an out
; of space condition, we get the STPOFLOW error instead of another STPCRIT. Successive STPCRITs are possible
; if a new (larger) value for $zstrpllim is set but otherwise the next error is STPOFLOW which is a fatal
; error.
;
gtm9238
	set pad=75
	set $etrap="zshow ""*"" zhalt 1"
	set maxLoops=20				; Maximum times to see STPCRIT in a row before we terminate test
	    					; (this is important if test ever runs on pre-V63012 in which case
						; it is an eternal loop unless it hits the spsize maximum first.
	set iter=0
	set $zstrpllim=128*1024			; Set to 128K bytes (slightly larger than minimum)
	write "Running loop consuming stringpool expecting first an STPCRIT error (which causes a table",!
	write "to be printed containing stringpool stats from $view(""spsize"") and then an STPOFLOW error",!
	write "which will stop the test because it is a fatal error (cannot be caught). Note if run on a",!
	write "version without GTM-9238, the loop below won't get a STPOFLOW but instead get an indefinite",!
	write "number of STPCRIT errorsand end only due to the maximum of 20 loops we allow.",!!
	zwrite $zstrpllim
	write !,"Stringpool before the loop ($view(""spsize"")): ",$view("spsize"),!
	write !,"Iteration",?12,"SPSize",?25,"SPUsed",?37,"SPResv",!
	write "---------",?12,"------",?25,"------",?37,"------",!
	for i=1:1:maxLoops  do			; Max of maxLoops loops
	. do chewStringPool
	. set strPlSize=$view("spsize")
	. set spsize=$zpiece(strPlSize,",",1)
	. set spused=$zpiece(strPlSize,",",2)
	. set spresv=$zpiece(strPlSize,",",3)
	. write $increment(iter),?12,$fnumber(spsize,","),?25,$fnumber(spused,","),?37,$fnumber(spresv,","),!
	. set:(spsize>400000) i=maxLoops	; Exit loop if stringpool gets too big.
	write:(i<maxLoops) !,"Complete",!
	write:(i>=maxLoops) !,"Loop ended due to limiting factor - no STPOFLOW seen",!
	quit

; Routine to eat the stringpool up and cause an STPCRIT error
chewStringPool
	new a,i,baseLevel,$etrap		; 'a' is allocated here and freed on return
	set baseLevel=$zlevel
	set $etrap="do chewDone"
	for i=1:1 set a(i)=$justify(i,pad)
	; Won't ever get here as loop is eternal until heap space dies
	write !,"*** No idea how we got here (chewStringPool).. FAIL",!
	zhalt 1

; Routine driven when an error is driven when expanding the stringpool. Verify the message was as expected else
; fail the test by writing out an unexpected error.
chewDone
	new $etrap
	set $etrap="set $ecode="""" zhalt 2"	; New etrap for the duration of this entry point
	if ($ZSTATUS+0)'=150384274 do		; If message is NOT STPCRIT, something weird happened so exit
	. write !!,"Unexpected error: ",$ZSTATUS,!
	. zhalt 1
	set $ecode=""				; Clear error indication (we expect this error)
	zgoto baseLevel-1			; Returns from chewStringPool()

; A small routine we call directly from gtm9238.csh to show $zstrpllim values on startup (with $ydb_string_pool_limit
; set to 40K) and then we explicitly set it to 30K and again display $zstrpllim. Note while *most* invocations
; get an STPCRIT error (that can be ignored), some of those invocations do NOT cause this error so we put up a
; handler to ignore STPCRIT to keep the reference file stable. The cause of the random failures is one of a few
; different test randomization options that can cause a difference in the rate consumption of the stringpool.
showzstrpllim
	; Note, $ydb_etrap sets the initial etrap to be "do showzstrpllimHandler" but without causing stringpool use
	do zwrzstrpllim
	do setzstrpllim
	do zwrzstrpllim
	quit

; A routine to show current $zstrpllim - if causes an $etrap can be easily returned from
zwrzstrpllim
	zwrite $zstrpllim
	quit

; A routine to set a given value into zstrpllim - if this causes an $etrap to be triggered, we can return easily
setzstrpllim
	set $zstrpllim=30000
	quit

; A routine to trap and ignore STPCRIT messages
showzstrpllimHandler
	set $zstrpllim=0			; Disable ZSTRPLLIM
	set err=$zpiece($zstatus,",",3)		; Fetch error name
	set err=$zpiece(err,"-",3)
	if "STPCRIT"'=err do
	. write "Unexpected error occurred: ",$zstatus,!!
	. zshow "*"
	. zhalt 1
	set $ecode=""				; Clear error status
	quit					; Ignore STPCRIT
