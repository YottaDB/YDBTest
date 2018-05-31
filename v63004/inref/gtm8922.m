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
generalTest
	SET dbFlush="DBFLUSH n_dsk_write"
	SET dbSync="DBSYNC n_db_fsync"
	SET jnlFlush="JNLFLUSH n_jnl_flush|n_jnl_fsync"
	SET epoch="EPOCH n_db_flush|n_jrec_epoch_regular"
	SET flush="FLUSH n_db_flush|n_jrec_epoch_regular"

	; the params string takes the following form
	; "<VIEW OPTIONS> <STAT ARG>[ <VIEW OPTIONS> <STAT ARG>...]
	SET params=dbFlush_" "_dbSync_" "_jnlFlush_" "_epoch_" "_flush

	;loops through words in params to call VIEW on each option and showBuffer() on each stat arg
	FOR I=1:1:$L(params," ") DO
	. SET keyword=$P(params," ",I) ; option passed to VIEW
	. SET stats=$P(params," ",I+1)  ; PEEKBYNAME field names to use in showBUFFER to verify VIEW operation
	. WRITE "TESTING KEYWORD: "_keyword,!
	. WRITE "--------------------------",!
	. SET ^DefTmp="MOE"_I
	. SET ^AregTmp="LARRY"_I
	. SET ^BregTmp="CURLY"_I
	.
	. FOR J=1:1:$L(stats,"|") DO  ;stats is a list of multiple '|' delimited fields
	. . DO showBuffer($P(stats,"|",J))
	. WRITE "VIEW """_keyword_""":""BREG,BREG,AREG""",!
	. VIEW keyword:"BREG,BREG,AREG"
	.
	. FOR J=1:1:$L(stats,"|") DO  ;stats is a list of multiple '|' delimited fields
	. . DO showBuffer($P(stats,"|",J))
	. WRITE "VIEW """_keyword_"""",!
	. VIEW keyword
	.
	. FOR J=1:1:$L(stats,"|") DO  ;stats is a list of multiple '|' delimited fields
	. . DO showBuffer($P(stats,"|",J))
	. SET I=I+1 ; make for loop start next cycle on next keyword
	. WRITE !!

	; VIEW POOLLIMIT requires an extra expression when called and
	; updates a field other than sgmnt_addrs.gvstats_rec... , which
	; showBuffer() accesses, so it can not be called in the FOR loop
	WRITE "TESTING KEYWORD: POOLLIMIT",!
	WRITE "--------------------------",!
	SET ^DefTmp="JAKE"
	SET ^AregTmp="ZACK"
	SET ^BregTmp="JIM"
	DO showPoolLimit()
	WRITE "VIEW ""POOLLIMIT"":""AREG,BREG,BREG"":""30""",!
	VIEW "POOLLIMIT":"AREG,BREG,BREG":"30"
	DO showPoolLimit()
	WRITE !!

	quit

gvsResetTest
	;VIEW GVSRESET requires use of the zshow "G" command to test
	;Once run zshow "G" should be wiped to a state of all 0s
	WRITE "TESTING KEYWORD: GVSRESET",!
	WRITE "-------------------------",!

	NEW run1
	NEW run2
	NEW run3

	SET ^DefTmp="JAKE"
	SET ^AregTmp="ZACK"
	SET ^BregTmp="JIM"

	WRITE "Running First ZSHOW ""G"" ",!
	ZSHOW "G":run1

	WRITE "VIEW ""GVSRESET"":""AREG,BREG,AREG,BREG""",!
	VIEW "GVSRESET":"AREG,BREG,AREG,BREG"

	WRITE "Running Second ZSHOW ""G"" ",!
	ZSHOW "G":run2

	WRITE "---Run1 Run2 Comparison---",!
	SET reg=""
	SET I="0"
	FOR  set reg=$view("GVNEXT",reg) quit:reg=""  DO
	. SET I=I+1
	. IF run1("G",I)=run2("G",I) WRITE "-NO CHANGE IN "_reg,!
	. ELSE  WRITE "-CHANGE IN "_reg_": ",!,run2("G",I),!

	WRITE "VIEW ""GVSRESET"":""DEFAULT,AREG,BREG,DEFAULT,BREG,AREG""",!
	VIEW "GVSRESET":"DEFAULT,AREG,BREG,DEFAULT,BREG,AREG"

	WRITE "Running Third ZSHOW ""G"" ",!
	ZSHOW "G":run3

	WRITE "---Run1 Run3 Comparison---",!
	SET reg=""
	SET I="0"
	FOR  set reg=$view("GVNEXT",reg) quit:reg=""  DO
	. SET I=I+1
	. IF run1("G",I)=run3("G",I) WRITE "-NO CHANGE IN "_reg,!
	. ELSE  WRITE "-CHANGE IN "_reg_": ",!,run3("G",I),!



	WRITE !!

	quit
openRegionsTest
	; The openRegionsTest will run a VIEW command using our cmdline args
	; as its VIEW options. Options are passed in as such:
	;		<option>:<exp1>:<exp2>

	SET CMD=$ZCMDLINE

	SET numArgs=$L(CMD,":")

	SET option=$P(CMD,":",1)
	SET exp1=$P(CMD,":",2)

	IF exp1="" SET exp1="*"

	;exp2 wont always have anything specified for it
	IF numArgs>"2"
	SET exp2=$P(CMD,":",3)


	; if exp2 is empty we need to make sure that our VIEW command
	; doesn't end up with a dangling ":"
	IF numArgs="2" DO
	. WRITE "TESTING REGIONS OPENED BY:  VIEW "_option_":"_exp1,!
	. WRITE "------------------------------------------------------------",!
	. WRITE "VIEW "_option_":"_exp1,!
	. VIEW option:exp1
	ELSE  DO
	. WRITE "TESTING REGIONS OPENED BY:  VIEW "_option_":"_exp1_":"_exp2,!
	. WRITE "------------------------------------------------------------",!
	. WRITE "VIEW "_option_":"_exp1_":"_exp2,!
	. VIEW option:exp1:exp2


	WRITE "---Check for open region files---",!

	; Filters the file names from the ls output
	ZSYSTEM "ls -l /proc/"_$job_"/fd | $grep '.dat$' | awk -F '/' '{print $(NF)}' | sort"

	; .gst files start with an RNG number, so the file names themselves require additional filtering
	set line1="ls -l /proc/"_$job_"/fd | $grep '.gst$' | "
	set line2="awk -F '/' '{print $(NF)}'  | "
	set line3="awk -F '.' 'BEGIN { ORS="""" }; {print ""xxx""; for (i = 2; i <= NF ; i++) { print ""."" ; print $i } print ""\n""}' | "
	set line4=" sort"

	ZSYSTEM line1_line2_line3_line4

	WRITE !

	quit


showBuffer(stat)
	set reg=""
	FOR  SET reg=$view("GVNEXT",reg) quit:reg=""  DO
	. SET x=$$^%PEEKBYNAME("sgmnt_addrs.gvstats_rec."_stat,reg)
	. WRITE stat_" Buffer ("_reg_"): ",x,!
	quit

showPoolLimit()
	set reg=""
	FOR  SET reg=$view("GVNEXT",reg) quit:reg=""  DO
	. SET x=$$^%PEEKBYNAME("sgmnt_addrs.gbuff_limit",reg)
	. WRITE "gbuff_limit Buffer ("_reg_"): ",x,!
	. WRITE "$VIEW(""POOLLIMIT"",reg): "
	. WRITE $VIEW("POOLLIMIT",reg),!

	WRITE !

	quit
