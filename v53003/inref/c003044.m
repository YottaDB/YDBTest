;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2008-2015 Fidelity National Information		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
c003044	; ZSHOW "G" implements process-private GVSTATS
	quit
test1a;
	write "------ Testcase 1a ------",!
	;  1a) At process startup,   ZSHOW "G" should show 0 for ALL statistics AND only the *,* line.
	zshow "G"
	; 2) Test that $VIEW("GVSTATS",<reg>) shows shared statistics.
	;    a) Test that statistics are 0 at database creation time.
	do viewgvstats("ZERO")
	quit;
test1b;
	new val
	write "------ Testcase 1b ------",!
	;  1b) After opening one db, ZSHOW "G" should show a few statistics AND two lines (one *,* and one for REG that was opened)
	set ^a1=1	; open AREG of default gbldir mumps.gld
	zshow "g":val	; use lowercase "g" intentionally to test that works too
	; filter out all journal related categories as journaling is randomly turned on or off and also all crit categories
	do out^zshowgfilter(.val,"DFL,DFS,JFL,JFS,JBB,JFB,JFW,JRL,JRP,JRE,JRI,JRO,CAT,CFE,CFS,CFT,CQS,CQT,CYS,CYT")
	zwrite val
	quit
test1c;
	write "------ Testcase 1c ------",!
	;  1c) After using an extended reference to access a different db, ZSHOW "G" should show statistics for 3 lines
	set ^|"alternate.gld"|b1=1	; open BREG of alternate gbldir alternate.gld which is same db as BREG of mumps.gld
	new val
	zshow "G":val
	; filter out all journal related categories as journaling is randomly turned on or off and also all crit categories
	do out^zshowgfilter(.val,"DWT,DFL,DFS,JFL,JFS,JBB,JFB,JFW,JRL,JRP,JRE,JRI,JRO,CAT,CFE,CFS,CFT,CQS,CQT,CYS,CYT")
	zwrite val
	quit
test1d;
	write "------ Testcase 1d ------",!
	;  1d) Use an extended reference AND regular reference to access previously accessed dbs. Test following line in func spec.
	;       If two or more regions (in the same or different global directories) map to the same physical database file, the
	;       ZSHOW "G" statistics for those two regions will be identical but will be counted only once towards the aggregated
	;       statistics across all database files i.e. in the line beginning with GLD:*,REG:*.
	new val
	set val=$get(^|"alternate.gld"|a1) ; open AREG of alternate gbldir alternate.gld which is same db as AREG of mumps.gld
	set val=$get(^b1) 	; open BREG of mumps.gld which is same db as AREG of alternate.gld
	kill val
	zshow "G":val
	; filter out all journal related categories as journaling is randomly turned on or off and also all crit categories
	do out^zshowgfilter(.val,"DWT,DFL,DFS,JFL,JFS,JBB,JFB,JFW,JRL,JRP,JRE,JRI,JRO,CAT,CFE,CFS,CFT,CQS,CQT,CYS,CYT")
	zwrite val
	quit
test1e;
	write "------ Testcase 1e ------",!
	new val,readwrite,readonly
	;  1e) Test that (*,*) output is the SUM of the individual outputs.
	;      Make sure a few operations are over 10 so we check that output is decimal (not hexadecimal).
	set readwrite=1
	set readonly=1
	do test1ex
	quit
test1ex	;
	set nontpsets=100
	set tpsets=200
	view "RESETGVSTATS"	; start afresh
	; ------------------------------------------------------------
	; Ensure following counters get non-zero values
	; ------------------------------------------------------------
	; SET : # of SET   operations (tp and non-tp)
	; KIL : # of KILl  operations (kill as well as zwithdraw, tp and non-tp)
	; GET : # of GET   operations (tp and non-tp)
	; DTA : # of DaTA  operations (tp and non-tp)
	; ORD : # of ORDer operations (tp and non-tp)
	; ZPR : # of ZPRevious (reverse order) operations (tp and non-tp)
	; QRY : # of QueRY operations (tp and non-tp)
	; NTW : # of Non-tp committed Transactions that were read-Write on this database
	; NTR : # of Non-tp committed Transactions that were Read-only on this database
	; TTW : # of Tp committed Transactions that were read-Write on this database
	; TTR : # of Tp committed Transactions that were Read-only on this database
	;
	; Note the following points from the spec
	; -----------------------------------------
	; $Order(xxx,1) operations get recorded under the ORD category while $Order(xxx,-1) operations get recorded under ZPR.
	;
	; The following counters should have non-zero values and are automatically tested by the below db operations.
	; CTN : Current Transaction Number of the database for the last committed read-write transaction (tp or non-tp)
	; DRD : # of Disk ReaDs from the database file by this process (tp and non-tp, committed and rolled-back)
	; DWT : # of Disk WriTes to the database file by this process (tp and non-tp, committed and rolled-back)
	; NBW : # of Non-tp committed transaction induced Block Writes on this database
	; NBR : # of Non-tp committed transaction induced Block Reads on this database
	; TBW : # of Tp transaction induced Block Writes on this database
	; TBR : # of Tp transaction induced Block Reads on this database
	;
	; The following line from the func spec is also automatically tested by the ZSHOW "G" below.
	; The aggregated statistics line in the ZSHOW "G" output (GLD:*,REG:* line) will always have the value for the CTN
	; category set to 0 as this statistic makes sense only for individual database files.
	; ------------------------------------------------------------
	if readwrite f i=1:1:nontpsets  set ^anontp(i)="Non-TP SET"		; should increment SET, NTW
	if readonly f i=1:2:nontpsets  set val=$get(^anontp(i))			; should increment GET, NTR
	if readonly f i=1:3:nontpsets  set val=$data(^anontp(i))		; should increment DTA, NTR
	if readonly f i=1:5:nontpsets  set val=$order(^anontp(i))		; should increment ORD, NTR
	if readonly f i=1:7:nontpsets  set val=$order(^anontp(i),-1)		; should increment ZPR, NTR
	if readonly f i=1:11:nontpsets  set val=$zprevious(^anontp(i))		; should increment ZPR, NTR
	if readonly f i=1:13:nontpsets set val=$query(^anontp(i))		; should increment QRY, NTR
	if readonly merge val=^anontp						; should increment GET, NTR
	if readwrite f i=1:17:nontpsets kill ^anontp(i)				; should increment KIL, NTW
	if readwrite f i=1:19:nontpsets zwithdraw ^anontp(i)			; should increment KIL, NTW
	if readwrite merge ^merge=val						; should increment SET, NTW
	if readwrite merge ^merge=^anontp					; should increment SET, GET, NTR, NTW
	kill val
	zshow "G":val
	; filter out all journal related categories as journaling is randomly turned on or off and also all crit categories
	do out^zshowgfilter(.val,"DWT,DFL,DFS,JFL,JFS,JBB,JFB,JFW,JRL,JRP,JRE,JRI,JRO,CAT,CFE,CFS,CFT,CQS,CQT,CYS,CYT")
	if readwrite'=readonly do out^zshowgfilter(.val,"CTN:")	; filter out CTN category as it could contain varying output
	zwrite val
	if readwrite f i=1:1:tpsets tstart ():serial set ^atp(i)="TP SET" tcommit 	     ; should increment SET, TTW
	if readonly f i=1:2:tpsets tstart ():serial set val=$get(^atp(i)) tcommit 	     ; should increment GET, TTR
	if readonly f i=1:3:tpsets tstart ():serial set val=$data(^atp(i)) tcommit 	     ; should increment DTA, TTR
	if readonly f i=1:5:tpsets tstart ():serial set val=$order(^atp(i)) tcommit  	     ; should increment ORD, TTR
	if readonly f i=1:7:tpsets tstart ():serial set val=$order(^atp(i),-1) tcommit 	     ; should increment ZPR, TTR
	if readonly f i=1:11:tpsets tstart ():serial set val=$zprevious(^atp(i)) tcommit     ; should increment ZPR, TTR
	if readonly f i=1:11:tpsets tstart ():serial set val=$query(^atp(i)) tcommit 	     ; should increment QRY, TTR
	if readonly if readwrite f i=1:13:tpsets tstart ():serial kill ^atp(i) tcommit 	     ; should increment KIL, TTW
	if readonly if readwrite f i=1:17:tpsets tstart ():serial zwithdraw ^atp(i) tcommit  ; should increment KIL, TTW
	kill val
	zshow "G":val
	; filter out all journal related categories as journaling is randomly turned on or off and also all crit categories
	do out^zshowgfilter(.val,"DWT,DFL,DFS,JFL,JFS,JBB,JFB,JFW,JRL,JRP,JRE,JRI,JRO,CAT,CFE,CFS,CFT,CQS,CQT,CYS,CYT")
	if readwrite'=readonly do out^zshowgfilter(.val,"CTN:")	; filter out CTN category as it could contain varying output
	zwrite val
	quit
test1f;
	write "------ Testcase 1f ------",!
	new val
	; ------------------------------------------------
	; Implement the following line from the func spec
	; ------------------------------------------------
	; KILL/GET/DATA/QUERY/ORDER/ZPREVIOUS operations on globals that never existed are not counted
	; (nor were they previously) while the same operations on globals that once existed but have
	; since been killed are counted (as they were previously).
	;
	view "RESETGVSTATS"	; start afresh
	set val=$get(^nonexist(i))				   ; should NOT increment GET, NTR
	set val=$data(^nonexist(i))				   ; should NOT increment DTA, NTR
	set val=$order(^nonexist(i))				   ; should NOT increment ORD, NTR
	set val=$order(^nonexist(i),-1)				   ; should NOT increment ZPR, NTR
	set val=$zprevious(^nonexist(i))			   ; should NOT increment ZPR, NTR
	set val=$query(^nonexist(i))				   ; should NOT increment QRY, NTR
	kill ^nonexist(i)					   ; should NOT increment KIL, NTW
	zwithdraw ^nonexist(i)				 	   ; should NOT increment KIL, NTW
	zshow "G":val
	do out^zshowgfilter(.val,"DWT:")	; filter out DWT category as it could contain varying output
	write val("G",0),!
	tstart ():serial set val=$get(^nonexist(i)) tcommit 	   ; should NOT increment GET, TTR
	tstart ():serial set val=$data(^nonexist(i)) tcommit 	   ; should NOT increment DTA, TTR
	tstart ():serial set val=$order(^nonexist(i)) tcommit 	   ; should NOT increment ORD, TTR
	tstart ():serial set val=$order(^nonexist(i),-1) tcommit   ; should NOT increment ZPR, TTR
	tstart ():serial set val=$zprevious(^nonexist(i)) tcommit  ; should NOT increment ZPR, TTR
	tstart ():serial set val=$query(^nonexist(i)) tcommit 	   ; should NOT increment QRY, TTR
	tstart ():serial kill ^nonexist(i) tcommit 		   ; should NOT increment KIL, TTW
	tstart ():serial zwithdraw ^nonexist(i) tcommit  	   ; should NOT increment KIL, TTW
	zshow "G":val
	do out^zshowgfilter(.val,"DWT:")	; filter out DWT category as it could contain varying output
	write val("G",0),!
	;
	; A view "RESETGVSTATS" is done below to start at a fresh point. This also serves as a test
	; for the view command that is described as follows in the test plan.
	;
	; 4) Test VIEW "RESETGVSTATS" command.
	;    Do ZSHOW "G". It should show zero stats.
	;    Do lots of db operations. Do ZSHOW "G". It should show non-zero stats.
	;    Now do VIEW "RESETGVSTATS". It should show zero stats.
	;
	view "RESETGVSTATS"	; start afresh
	set ^onceexist=""
	kill ^onceexist
	set val=$get(^onceexist(i))				    ; should increment GET, NTR
	set val=$data(^onceexist(i))				    ; should increment DTA, NTR
	set val=$order(^onceexist(i))				    ; should increment ORD, NTR
	set val=$order(^onceexist(i),-1)			    ; should increment ZPR, NTR
	set val=$zprevious(^onceexist(i))			    ; should increment ZPR, NTR
	set val=$query(^onceexist(i))				    ; should increment QRY, NTR
	kill ^onceexist(i)					    ; should increment KIL, NTW
	zwithdraw ^onceexist(i)				 	    ; should increment KIL, NTW
	zshow "G":val
	; filter out all journal related categories as journaling is randomly turned on or off and also all crit categories
	do out^zshowgfilter(.val,"DWT,DFL,DFS,JFL,JFS,JBB,JFB,JFW,JRL,JRP,JRE,JRI,JRO,CAT,CFE,CFS,CFT,CQS,CQT,CYS,CYT")
	write val("G",0),!
	tstart ():serial set val=$get(^onceexist(i)) tcommit 	    ; should increment GET, TTR
	tstart ():serial set val=$data(^onceexist(i)) tcommit 	    ; should increment DTA, TTR
	tstart ():serial set val=$order(^onceexist(i)) tcommit 	    ; should increment ORD, TTR
	tstart ():serial set val=$order(^onceexist(i),-1) tcommit   ; should increment ZPR, TTR
	tstart ():serial set val=$zprevious(^onceexist(i)) tcommit  ; should increment ZPR, TTR
	tstart ():serial set val=$query(^onceexist(i)) tcommit 	    ; should increment QRY, TTR
	tstart ():serial kill ^onceexist(i) tcommit 		    ; should increment KIL, TTW
	tstart ():serial zwithdraw ^onceexist(i) tcommit  	    ; should increment KIL, TTW
	zshow "G":val
	; filter out all journal related categories as journaling is randomly turned on or off and also all crit categories
	do out^zshowgfilter(.val,"DWT,DFL,DFS,JFL,JFS,JBB,JFB,JFW,JRL,JRP,JRE,JRI,JRO,CAT,CFE,CFS,CFT,CQS,CQT,CYS,CYT")
	write val("G",0),!
	quit
test1g;
	write "------ Testcase 1g ------",!
	new val
	; ------------------------------------------------------------
	; Implement the following line from the func spec
	; ------------------------------------------------
	; Name-level ORDER/ZPREVIOUS operations (e.g. $ORDER(^a) with no subscripts) increment the count for each transition
	; into a region as they process the global directory map up to the point they find a global with data (as they
	; were previously).
	;
	view "RESETGVSTATS"	; start afresh
	set val=$order(^%)					; should increment ORD more than once
	set val=$zprevious(^z)					; should increment ZPR more than once
	tstart ():serial set val=$order(^%) tcommit 		; should increment ORD more than once
	tstart ():serial set val=$zprevious(^z) tcommit 	; should increment ZPR more than once
	kill val
	zshow "G":val
	do out^zshowgfilter(.val,"DWT:")	; filter out DWT category as it could contain varying output
	zwrite val
	quit
test1h;
	write "------ Testcase 1h ------",!
	new val
	; ------------------------------------------------------------
	; Implement the following line from the func spec
	; ------------------------------------------------
	; These statistics report on global variable operations performed by a process. If an operation is performed inside a
	; transaction, and not committed as a consequence of a rollback, or an explicit or implicit restart, it is still counted.
	;
	set jmaxwait=0
	set jmjoname="test1hhelper"	; set this so we can use existing test1jhelper label but with output to a different file
	set jnolock=1 ; to skip the thread syncronization feature which can obtain non-deterministic number of locks
	set ^childlocked=0
	do ^job("test1jhelper^c003044",1,"""""")
	kill jmjoname	; so later subtests are not fixated on this job name
	for i=1:1:301 quit:^childlocked=1  hang 1
	if 301=i write "GTM-E-TESTFAIL, c003044 parent timed out"
	view "RESETGVSTATS"	; start afresh
	set restart=0
	tstart ():serial  do
	. tstart ():serial do
	. . set ^btp($trestart)="This is ROLLED BACK"
	. . set restart=restart+1
	. . if restart<6 do	 ; try various commands that will induce restarts. try lock type restarts only in final retry
	. . . if restart<4 trestart
	. . . if restart=4 lock +^f:1	; this & next line following should give TPNOTACID, which the test does not currently check
	. . . if restart=5 zallocate ^f:2
	. . trollback $tl-1
	. set ^btp($trestart)="This is COMMITTED"
	. tcommit
	lock
	zdeallocate
	set ^childlocked=0
	do wait^job	; wait for child to terminate
	kill val
	zshow "G":val
	; filter out all journal related categories as journaling is randomly turned on or off and also all crit categories
	do out^zshowgfilter(.val,"DWT,DFL,DFS,JFL,JFS,JBB,JFB,JFW,JRL,JRP,JRE,JRI,JRO,CAT,CFE,CFS,CFT,CQS,CQT,CYS,CYT")
	do out^zshowgfilter(.val,"LKF:")	; filter out LKF category as it could contain varying output
	zwrite val
	quit
test1i;
	write "------ Testcase 1i ------",!
	new val
	; ------------------------------------------------------------
	; Ensure following counters get non-zero values
	; ------------------------------------------------------------
	; TRB : # of Tp read-only or read-write transactions that got Rolled Back (incremental rollbacks are not counted)
	; "incremental rollbacks are not counted in TRB" is already checked as part of the previous test
	;
	view "RESETGVSTATS"	; start afresh
	; rollback TP read-only transaction
	tstart ():serial
	set val=$get(^btp($trestart))
	trollback
	zshow "G":val
	write val("G",0),!
	; rollback TP read-write transaction
	tstart ():serial
	set ^btp($trestart)="This is ROLLED BACK"
	trollback
	kill val
	zshow "G":val
	do out^zshowgfilter(.val,"DWT:")	; filter out DWT category as it could contain varying output
	write val("G",0),!
	quit
test1j;
	write "------ Testcase 1j ------",!
	new val
	; ------------------------------------------------------------
	; Ensure following counters get non-zero values
	; ------------------------------------------------------------
	; LKS : # of LocK calls (mapped to this db) that Succeeded
	; LKF : # of LocK calls (mapped to this db) that Failed
	;
	; 6) Test that ZSHOW "L" shows MLG and MLT outputs.
	;    a) Do some lock operations and ensure MLG is non-zero.
	;    b) Do some lock operations and ensure MLT is non-zero.
	;    c) Test ZSHOW "L":lcl
	;    d) Test ZSHOW "L":^gbl

	view "RESETGVSTATS"	; start afresh
	lock +^a,+^b	; will increment LKS and MLG (only once even though 2 locks)
	tstart ():serial  lock +^c,+^d	tcommit  ; will increment LKS and MLG (only once even though 2 locks)
	; to increment LKF, we need to spawn off another process that holds a lock and we should try to acquire the same
	set jmaxwait=0
	set jnolock=1 ; to skip the thread syncronization feature which can obtain non-deterministic number of locks
	set ^childlocked=0
	do ^job("test1jhelper^c003044",1,"""""")
	for i=1:1:301 quit:^childlocked=1  hang 1
	if 301=i write "GTM-E-TESTFAIL, c003044 parent timed out"
	lock +(^e,^f):1	; will fail and increment LKF, MLT
	set ^childlocked=0
	do wait^job	; wait for child to terminate
	lock +(^e,^f):1	; will succeed and increment LKS, MLG
	write "  -- Test of zshow GL --",!
	; since the # of LKF operations could be non-deterministic, we dont want to print the entire zshow "G" output
	; but instead check that the LKS and LKF both are non-zero.
	zshow "G":val
	do in^zshowgfilter(.val,"LKF,LKS")
	set fail=$find(val("G",0),":0")
	if fail=0 write "PASS : All of LKS, LKF are non-zero",!
	else      write "FAIL : One of LKS, LKF is zero",!  zwrite val
	zshow "L"
	;    1g) ZSHOW "G":lcl should be tested.
	write "  -- Test of zshow G:v --",!
	zshow "G":v
	; filter out all journal related categories as journaling is randomly turned on or off and also all crit categories
	do out^zshowgfilter(.v,"DWT,DFL,DFS,JFL,JFS,JBB,JFB,JFW,JRL,JRP,JRE,JRI,JRO,CAT,CFE,CFS,CFT,CQS,CQT,CYS,CYT")
	do out^zshowgfilter(.v,"LKF:")	; filter out LKF category as it could contain varying output
	do out^zshowgfilter(.v,"GET,NTR,NBR")	; filter out GET, NTR and NBR categories as they could vary due to "do ^job"
	do out^zshowgfilter(.v,"NR0:")	; filter out NR0 category as we could have restarted due to stepping on ourselves
	zwrite v
	write "  -- Test of zshow L:v --",!
	kill v
	zshow "l":v	; use lower case 'l' intentionally to test that is equivalent to "L"
	zwrite v
	;    1i) ZSHOW "*":lcl should be tested. Check that "G" output is also part of it.
	write "  -- Test of zshow *:lcl containing G output --",!
	zshow "*":lcl
	; filter out all journal related categories as journaling is randomly turned on or off and also all crit categories
	do out^zshowgfilter(.lcl,"DWT,DFL,DFS,JFL,JFS,JBB,JFB,JFW,JRL,JRP,JRE,JRI,JRO,CAT,CFE,CFS,CFT,CQS,CQT,CYS,CYT")
	do out^zshowgfilter(.lcl,"LKF:")	; filter out LKF category as it could contain varying output
	do out^zshowgfilter(.lcl,"GET,NTR,NBR")	; filter out GET, NTR and NBR categories as they could vary due to "do ^job"
	do out^zshowgfilter(.lcl,"NR0:")	; filter out NR0 category as we could have restarted due to stepping on ourselves
	zwrite lcl("G",*)
	;    1k) ZSHOW @x where x="y" and y="G" should also be tested that it does the same thing as ZSHOW "G".
	write "  -- Test of zshow @ evaluating to G --",!
	view "RESETGVSTATS"	; start afresh because we have variable output
	new x,y
	set x="y"
	set y="G"
	zshow "G"
	kill v
	zshow @x:v
	zwrite v
	kill v
	new a
	set a="""G"":v"
	zshow @a
	zwrite v
	kill v
	new t
	set t="v"
	zshow "G":@t
	zwrite v
	kill v
	zshow @x:@t
	zwrite v
	;
	; Move all testcases, where target is a global to the end as that causes least disturbance to the reference file.
	;
	;    1h) ZSHOW "G":^gbl should be tested.
	write "  -- Test of zshow GL:^v --",!
	zshow "GL":^v
	kill temp
	merge temp=^v
	; filter out all journal related categories as journaling is randomly turned on or off and also all crit categories
	do out^zshowgfilter(.temp,"DFL,DFS,JFL,JFS,JBB,JFB,JFW,JRL,JRP,JRE,JRI,JRO,CAT,CFE,CFS,CFT,CQS,CQT,CYS,CYT")
	zwrite temp
	;    1j) ZSHOW "*":^gbl should be tested. Check that "G" output is also part of it.
	write "  -- Test of zshow *:^gbl containing G output --",!
	zshow "*":^gbl
	kill temp
	merge temp=^gbl
	; Since zsh "*" includes the entire process environment (including local variables, test output directory names etc.)
	; the output could vary in length for each test run. Therefore the number of GDS blocks read/written could be different.
	; So filter out NBR and NBW.
	; filter out all journal related categories as journaling is randomly turned on or off and also all crit categories
	do out^zshowgfilter(.temp,"DWT,DFL,DFS,JFL,JFS,JBB,JFB,JFW,JRL,JRP,JRE,JRI,JRO,CAT,CFE,CFS,CFT,CQS,CQT,CYS,CYT")
	do out^zshowgfilter(.temp,"NBR,NBW,DRD")	; filter out NBR, NBW and DRD categories as they could contain varying output
	zwrite temp("G",*)
	quit
	;
test1jhelper;
	lock +^f
	set ^childlocked=1
	for i=1:1:601 quit:^childlocked=0  hang 1
	if 601=i write "GTM-E-TESTFAIL, c003044 child timed out"
	quit
test1k  ;
	write "------ Testcase 1k ------",!
	new val
	; ------------------------------------------------------------
	; Ensure following counters get non-zero values
	; ------------------------------------------------------------
	; NR0 : # of Non-tp transaction Restarts at try 0
	; NR1 : # of Non-tp transaction Restarts at try 1
	; NR2 : # of Non-tp transaction Restarts at try 2
	; NR3 : # of Non-tp transaction Restarts at try 3
	;
	; We need to trigger lots of restarts. Create contention by jobbing off processes that do concurrent updates.
	set ^stop=0
	set jmaxwait=0
	do ^job("test1khelper^c003044",5,"""""")
	for i=1:1  quit:^stop=1  set ^x=$get(^x)+1  if i#1000=0 do
	.	zshow "G":val
	.	if $piece($piece(val("G",0),"NR2:",2),",",1)'=0  set ^stop=1
	do wait^job	; wait for children to terminate
	; since the # of database operations needed to get NR2 non-zero is not deterministic, we dont want to
	; print the entire zshow "G" output but instead check that the NR0, NR1 and NR2 counters are non-zero.
	zshow "G":val
	do in^zshowgfilter(.val,"NR0,NR1,NR2")
	set fail=$find(val("G",0),":0")
	if fail=0 write "PASS : All of NR0, NR1, NR2 are non-zero",!
	else      write "FAIL : One of NR0, NR1, NR2 is zero",!  zwrite val
	quit
	;
test1khelper;
	for  quit:^stop=1  set ^x=$get(^x)+1
	quit
	;
test1l	;
	write "------ Testcase 1l ------",!
	new val
	; ------------------------------------------------------------
	; Ensure following counters get non-zero values
	; ------------------------------------------------------------
	; TR0 : # of Tp transaction Restarts at try 0 (counted for all regions participating in restarting tp transaction)
	; TR1 : # of Tp transaction Restarts at try 1 (counted for all regions participating in restarting tp transaction)
	; TR2 : # of Tp transaction Restarts at try 2 (counted for all regions participating in restarting tp transaction)
	; TR3 : # of Tp transaction Restarts at try 3 (counted for all regions participating in restarting tp transaction)
	; TR4 : # of Tp transaction Restarts at try 4 and above (restart counted for all regions participating in restarting tp transaction)
	; TC0 : # of Tp transaction Conflicts at try 0 (counted only for that region which caused the tp transaction restart)
	; TC1 : # of Tp transaction Conflicts at try 1 (counted only for that region which caused the tp transaction restart)
	; TC2 : # of Tp transaction Conflicts at try 2 (counted only for that region which caused the tp transaction restart)
	; TC3 : # of Tp transaction Conflicts at try 3 (counted only for that region which caused the tp transaction restart)
	; TC4 : # of Tp transaction Conflicts at try 4 and above (counted only for that region which caused the tp transaction restart)
	;
	; We need to trigger lots of restarts. Create contention by jobbing off processes that do concurrent updates.
	; Do parent updates in TP and child updates outside of TP thereby increasing the chances of the parent
	; encountering non-zero values of TC2 and TR2 sooner.
	;
	set ^stop=0
	set jmaxwait=0
	do ^job("test1lhelper^c003044",4,"""""")
	for i=1:1  quit:^stop=1  tstart ():serial set ^x=$get(^x)+1,^y=$get(^y)+1,^z=$get(^z)+1 tcommit  if i#100=0 do
	.	zshow "G":val
	.	if ($piece($piece(val("G",0),"TC2:",2),",",1)'=0)&($piece($piece(val("G",0),"TR2:",2),",",1)'=0)  set ^stop=1
	do wait^job	; wait for children to terminate
	; since the # of database operations needed to get TC2 non-zero is not deterministic, we dont want to
	; print the entire zshow "G" output but instead check that the TC0-2 and TR0-2 counters are non-zero.
	zshow "G":val
	do in^zshowgfilter(.val,"TC0,TC1,TC2,TR0,TR1,TR2")
	set fail=$find(val("G",0),":0")
	if fail=0 write "PASS : All of TC0, TC1, TC2, TR0, TR1, TR2 are non-zero",!
	else      write "FAIL : One of TC0, TC1, TC2, TR0, TR1, TR2 is zero",!  zwrite val
	; Test following line from Test Plan
	;    2b) Test that statistics are non-zero after ALL sorts of db operations are done
	do viewgvstats("NONZERO")
	quit
	;
test1lhelper;
	for  quit:^stop=1  do
	.	set ^x=$get(^x)+1
	.	set ^y=$get(^y)+1
	.	set ^z=$get(^z)+1
	quit
	;
test2d	;
	;   2d) Test that processes with read-only access to the database have their global access statistics counted
	;       in the database file header as long as the last process to shut down the database has read-write access.
	;
	; Parent process should open DEFAULT and AREG but update counters in DEFAULT region only.
	; Child process which has read-only access to AREG region should update counters in that region only.
	;
	write "------ Testcase 2d ------",!
	new val
	set val=$order(^%)	; opens both AREG and DEFAULT in parent process
	;
	; Perform read-write operations on AREG to be later used for read-only operations by the child process
	new readwrite,readonly
	set readwrite=1
	set readonly=0
	do test1ex
	; Now make AREG read-only. Current process will continue to have write-access as we have already opened the file
	set unix=$ZVersion'["VMS"
	if unix  zsystem "chmod -w "_$VIEW("GVFILE","AREG")_" >& chmod.out"
	if 'unix zsystem "set file/prot=(owner:re,group:re,world:re) "_$VIEW("GVFILE","AREG")
	; Spawn off child and wait for it to finish
	set jmaxwait=300
	do ^job("test2dhelper^c003044",1,"""""")
	do viewgvstats^c003044("READONLY")
	; restore read-write permissions
	if unix  zsystem "chmod +w "_$VIEW("GVFILE","AREG")_" >& chmod.out"
	if 'unix zsystem "set file/prot=(owner:rwed,group:rwed,world:re) "_$VIEW("GVFILE","AREG")
	quit

test2dhelper	;
	new readwrite,readonly
	set readwrite=0
	set readonly=1
	; Do a variety of READ operations on AREG
	do test1ex
	quit

viewgvstats(type);
	new reg,var,num,piece,piece1,piece2,fail,subs
	set reg=$view("GVFIRST")
	; Test that cumulative statistics are ZERO or NON-ZERO depending on incoming <type>
	for  quit:reg=""  do
	.	set var=$VIEW("GVSTATS",reg)
	.	; var is a string of the form SET:3,KIL:1,GET:0,...
	.	; Create subscripts for each operation and store the counts there.
	.	for num=1:1  set piece=$piece(var,",",num)  quit:piece=""  do
	.	.	set piece1=$piece(piece,":",1)
	.	.	set piece2=$piece(piece,":",2)
	.	.	set var(piece1)=$get(var(piece1))+piece2
	.	set reg=$VIEW("GVNEXT",reg)
	if "ZERO"=type do
	.	; the following indices are exempt from the check since they will be non-zero
	.	kill var("CTN")	; will be 1 at db creation time
	.	kill var("DFL") ; will be 1 when mupip set jnl is done
	.	kill var("CAT")
	if "NONZERO"=type do
	.	; the following indices are exempt from the check since we cannot reliably get them to be non-zero
	.	kill var("LKS"),var("LKF")
	.	kill var("NR3")
	.	kill var("TC3"),var("TC4")
	.	kill var("TR3"),var("TR4")
	.	kill var("CFE"),var("CFS"),var("CFT"),var("CQS"),var("CQT"),var("CYS"),var("CYT")
	.	kill var("ZTR")	; no ztrigger commands in this test
	.	; if running with MM, the DWT counter will be 0 always so skip that from the nonzero check as well
	.	if $ztrnlnm("acc_meth")="MM" kill var("DWT")
	.	; the following stats are journaling related and this test only randomly enables journaling
	.	kill var("DFS"),var("JFL"),var("JFS"),var("JBB"),var("JFB"),var("JFW"),var("JRL"),var("JRP"),var("JRE"),var("JRI"),var("JRO")
	.	; extensions might not have happened
	.	kill var("JEX"),var("DEX")
	.	; we cannot guarantee a db flush (i.e. wcs_flu) to have happened in the time that it takes a given test to run
	.	kill var("DFL")
	if "READONLY"=type do
	.	; the following indices are exempt from the check for this type
	.	kill var("CAT"),var("CFE"),var("CFS"),var("CFT"),var("CQS"),var("CQT"),var("CYS"),var("CYT")
	.	kill var("SET"),var("KIL")
	.	kill var("LKS"),var("LKF")
	.	kill var("CTN")
	.	kill var("DWT")
	.	kill var("NTW"),var("NBW")
	.	kill var("NR0"),var("NR1"),var("NR2"),var("NR3")
	.	kill var("TRB")
	.	kill var("TTW"),var("TBW")
	.	kill var("TR0"),var("TR1"),var("TR2"),var("TR3"),var("TR4")
	.	kill var("TC0"),var("TC1"),var("TC2"),var("TC3"),var("TC4")
	.	kill var("ZTR")
	.	; the following stats are journaling related and read-only processes dont increment these counters so skip
	.	kill var("DFS"),var("JFL"),var("JFS"),var("JBB"),var("JFB"),var("JFW"),var("JRL"),var("JRP"),var("JRE"),var("JRI"),var("JRO")
	.	; extensions might not have happened
	.	kill var("JEX"),var("DEX")
	set fail=0
	set subs="" for  set subs=$order(var(subs))  quit:subs=""  do
	.	if "ZERO"=type if var(subs)'=0  set fail=fail+1
	.	if "NONZERO"=type if var(subs)=0  set fail=fail+1
	.	if "READONLY"=type if var(subs)=0  set fail=fail+1
	if fail=0 write "$view(""GVSTATS"",*) : type=",type," : PASS",!
	if fail'=0 write "$view(""GVSTATS"",*) : type=",type," : FAIL",! zshow "V"
	quit
