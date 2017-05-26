;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2010, 2014 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
symmetry
	quit

all
	do drive^symmetry("symmetry")
	do drive^symmetry("namesymmetry")
	do drive^symmetry("namesymmetryagain")
	do drive^symmetry("renamesymmetry")
	do drive^symmetry("simplesetUP")
	do drive^symmetry("simplesetDOWN")
	do drive^symmetry("simplekillUP")
	do drive^symmetry("simplekillDOWN")
	do drive^symmetry("simpleFAIL")
	do drive^symmetry("simpleFAILredux")
	do drive^symmetry("simpleFAILredux")
	do drive^symmetry("nameconflict1")
	do drive^symmetry("nameconflict2")
	do drive^symmetry("nameconflict3")
	do drive^symmetry("usernamevsautoname")
	do drive^symmetry("autonamevsusername")
	do drive^symmetry("consolidate1")
	do drive^symmetry("consolidate2")
	do drive^symmetry("consolidate3")
	do drive^symmetry("setconsolidation1")
	do drive^symmetry("setconsolidation2")
	do drive^symmetry("setconsolidation3")
	do drive^symmetry("setconsolidation4")
	do drive^symmetry("killconsolidation")
	quit

symmetrytfile
	;-*
	;; These two trigger specifications produce 2 triggers,
	;; Trigger 1 with S,K,ZK and Trigger 2 with S.
	;; Trigger 2 only has S because piece/delim have no meaning for K/ZK, so the
	;; K,ZK from the second specification are ignored as duplicates
	;+^a -commands=S,K,ZK -pieces=1:20 -delim=";" -xecute="do ^twork"
	;+^a -commands=S,K,ZK -pieces=2:30 -delim=":" -xecute="do ^twork"
	;
	;; this tests that these 4 specifications are merged into 2 triggers
	;+^a(acn=:,1,acn2=?1"%".ULN) -commands=S -zdelim="|" -pieces="2:6;8" -xecute="Do ^mrtn"
	;+^b(acn=:,2,acn2=?1"%".ULN) -commands=K -options=NOC -xecute="Do ^mrtn"
	;+^a(acn=:,1,acn2=?1"%".ULN) -commands=K -xecute="Do ^mrtn"
	;+^b(acn=:,2,acn2=?1"%".ULN) -commands=S -options=NOC -zdelim="|" -pieces="2:6;8" -xecute="Do ^mrtn"
	quit

namesymmetrytfile
	;; this should attempt to rename the trigger for ^a (see above) with S,K,ZK
	;+^a -commands=S,K,ZK -pieces=1:20 -delim=";" -xecute="do ^twork" -name=Again
	;; using the same name should not work
	;+^a -commands=S      -pieces=2:30 -delim=":" -xecute="do ^twork" -name=Again
	quit

	; this test explicity loads the same triggers with different names+pieces+delim
	; to show that while the two trigger specifications look different, their
	; signatures for Kill/ZKill are identical. With named triggers, this creates
	; an ambiguous trigger addition, which is disallowed.
namesymmetryagaintfile
	;; this should attempt to rename the trigger for ^a (see above) with S,K,ZK
	;+^a -commands=S,K,ZK -pieces=1:20 -delim=";" -xecute="do ^twork" -name=again
	;; using the same name should not work
	;+^a -commands=S,K,ZK -pieces=2:30 -delim=":" -xecute="do ^twork" -name=AGAIN
	quit

renamesymmetrytfile
	;; try some renames, the last rename should always take precedence
	;+^a -commands=S,K,ZK -pieces=1:20 -delim=";" -xecute="do ^twork" -name=rogain
	;+^a -commands=S      -pieces=2:30 -delim=":" -xecute="do ^twork" -name=yetAgain
	;+^a -commands=S,K,ZK -pieces=1:20 -delim=";" -xecute="do ^twork" -name=replAce
	;+^a -commands=S      -pieces=2:30 -delim=":" -xecute="do ^twork" -name=replAceAgain
	;+^a(acn=:,1,acn2=?1"%".ULN) -commands=S,K -zdelim="|" -pieces="2:6;8"              -xecute="Do ^mrtn" -name=renew1
	;+^a(acn=:,1,acn2=?1"%".ULN) -commands=K,S -zdelim="|" -pieces="2:6;8"              -xecute="Do ^mrtn" -name=renew1rename
	;+^b(acn=:,2,acn2=?1"%".ULN) -commands=K,S -zdelim="|" -pieces="2:6;8" -options=NOC -xecute="Do ^mrtn" -name=renew2
	;+^b(acn=:,2,acn2=?1"%".ULN) -commands=S,K -zdelim="|" -pieces="2:6;8" -options=NOC -xecute="Do ^mrtn" -name=renew2rename
	quit

	; ------------------------------------------------------------------------------
	; These are the new trigger matching and consolidation tests. Symmetry meant the
	; symmetry between added and deleted triggers.

	; this drives most trigger tests
drive(lbl)
	do ^echoline
	write "$gtm_exe/mumps -run %XCMD 'do drive^symmetry(""",lbl,""")'",!
	set fname=lbl_".trg"
	do text^dollarztrigger(lbl_"tfile^symmetry",fname)
	set res=$ztrigger("file",fname)
	write "The last command ",$select(res=1:"PASSED",1:"FAILED"),!,!
	do all^dollarztrigger
	do ^echoline
	quit


simplesetUPtfile
	;-*
	;; Simple testing of SET matching, in total we are adding and manipulating only 3 triggers
	;+^a(:)             -commands=SET   -xecute="set a=1"
	;+^a(:)             -commands=SET   -xecute="set a=1"   -delim="|"
	;+^a(:)             -commands=SET   -xecute="set a=1"   -delim="|"  -piece=2
	;
	;; now change the names
	;+^a(:)             -commands=SET   -xecute="set a=1"                        -name=a1
	;+^a(:)             -commands=SET   -xecute="set a=1"   -delim="|"           -name=a2
	;+^a(:)             -commands=SET   -xecute="set a=1"   -delim="|"  -piece=2 -name=a3
	;
	;; now change the options AND change the name, don't use the name and with the original name
	;+^a(:)             -commands=SET   -xecute="set a=1"                        -name=a   -options=noi
	;+^a(:)             -commands=SET   -xecute="set a=1"   -delim="|"                     -options=i
	;+^a(:)             -commands=SET   -xecute="set a=1"   -delim="|"  -piece=2 -name=a3  -options=c
	;
	quit

simplesetDOWNtfile
	;; Simple testing of SET matching, in total we are adding and manipulating only 3 triggers
	;; Delete all triggers added above:
	;; delete dropping name and options
	;-^a(:)             -commands=SET   -xecute="set a=1"
	;; delete complete match
	;-^a(:)             -commands=SET   -xecute="set a=1"   -delim="|"  -piece=2 -name=a3  -options=c
	;; delete by name
	;-a3
	quit

simplekillUPtfile
	;-*
	;; Simple testing of KILL matching, in total we are adding and manipulating only 2 triggers
	;; add a new kill type trigger
	;+^a    -commands=ZTR      -xecute="do A^symmetry"
	;; add overlapping commands with a new name
	;+^a    -commands=ZTR,ZK   -xecute="do A^symmetry"  -name=killa
	;; add overlapping commands with one new command
	;+^a    -commands=ZTR,ZK,K -xecute="do A^symmetry"
	;; add overlapping commands in different orderwith a new name
	;+^a    -commands=ZTR,K,ZK -xecute="do A^symmetry"  -name=killab
	;
	;; add a full trigger to delete with name and options
	;+^b    -commands=ZTR,K,ZK -xecute="do A^symmetry"  -name=killb  -options=noi
	quit

simplekillDOWNtfile
	;; Simple testing of KILL matching, in total we are adding and manipulating only 2 triggers
	;; delete by commands
	;-^a    -commands=ZK       -xecute="do A^symmetry"  -name=killab
	;; delete by command with bogus option
	;-^a    -commands=K        -xecute="do A^symmetry"  -name=killab -option=isolation
	;; delete by command with bogus name
	;-^a    -commands=ZTR      -xecute="do A^symmetry"  -name=killa
	;
	;; add a full trigger to delete with name and options
	;-^b    -commands=ZTR,K,ZK -xecute="do A^symmetry"  -name=killb  -options=noi
	quit

simpleFAILtfile
	;-*
	;; this is the example that demonstrated the kill type consolidation bug. It ended up with
	;; three ZTR type triggers for the same trigger. We should see 3 SET type triggers and only
	;; 1 KILL type trigger with ZTR
	;+^a    -commands=SET,ZTR      -xecute="do A^symmetry"
	;+^a    -commands=SET,ZTR      -xecute="do A^symmetry"    -delim=$char(61)
	;+^a    -commands=SET,ZTR      -xecute="do A^symmetry"    -delim=$char(32)
	quit

simpleFAILreduxtfile
	;-*
	;; That last ZTK overlap was possible due to the kill type consolidation bug. Loading this
	;; trigger file now fails
	;+^a    -commands=SET,ZTR      -xecute="do A^symmetry"
	;+^a    -commands=SET,ZTR,K    -xecute="do A^symmetry"    -delim=$char(61)
	;+^a    -commands=SET,ZTR,ZK   -xecute="do A^symmetry"    -delim=$char(32)
	;+^a    -commands=SET,ZTK      -xecute="do A^symmetry"    -delim=$char(32)
	quit

consolidate1tfile
	;-*
	;; simple consolidation test, we should end up with 3 SET type triggers and one of the SETs
	;; has all the KILL types associated with it.  Note that the simplest SET type, which matches
	;; the kill types exactly does not had the KILLs associated with it
	;+^a    -commands=SET,KILL,ZTR -xecute="do A^symmetry"    -delim=$char(32)
	;+^a    -commands=SET,KILL     -xecute="do A^symmetry"    -delim=$char(32)
	;+^a    -commands=ZTR,ZKILL    -xecute="do A^symmetry"
	;+^a    -commands=SET,ZTR,ZK   -xecute="do A^symmetry"
	;+^a    -commands=ZTR          -xecute="do A^symmetry"
	;+^a    -commands=SET,ZTR      -xecute="do A^symmetry"    -delim=$char(61)
	;+^a    -commands=SET,KILL,ZTR -xecute="do A^symmetry"    -delim=$char(32)
	quit

consolidate2tfile
	;; second simple consolidation test, should just match the above consolidate1tfile
	;+^a    -commands=SET,KILL     -xecute="do A^symmetry"    -delim=$char(32)
	;+^a    -commands=SET,ZTR,ZK   -xecute="do A^symmetry"
	;+^a    -commands=SET,ZTR      -xecute="do A^symmetry"    -delim=$char(61)
	;+^a    -commands=SET,KILL,ZTR -xecute="do A^symmetry"    -delim=$char(32)
	quit

consolidate3tfile
	;; yet another simple consolidation test, except that the simple SET has all the KILL type
	;; triggers. The second SET with the delimiter should have no KILL types
	;+^a    -commands=SET,ZTR	-xecute="do A^symmetry"
	;+^a    -commands=ZTR,K		-xecute="do A^symmetry"
	;+^a    -commands=SET,K,ZTR	-xecute="do A^symmetry"		-delim="|"
	;+^a    -commands=SET,K,ZK	-xecute="do A^symmetry"		-delim="|"
	quit

nameconflict1tfile
	;; cause a name conflict where a trigger spec matches two different triggers, one KILL type and one SET type
	;; add a trigger with SET and KILL types
	;+^a    -commands=SET,ZTR	-xecute="do A^symmetry"	-name=name1
	;; change the above triggers name while adding more KILL type commands
	;+^a    -commands=SET,ZTR,K		-xecute="do A^symmetry"	-name=name2
	;; add a new SET type trigger without a name, shoul not cause a conflict
	;+^a    -commands=SET,ZK	-xecute="do A^symmetry"			-delim="|"
	;; add a new SET type trigger, but this fails because it has a name specified
	;+^a    -commands=SET,K,ZK	-xecute="do A^symmetry"	-name=name4	-delim="."
	quit

nameconflict2tfile
	;; changing trigger name needs ALL commands to be listed
	;; add a trigger with SET and KILL types
	;+^a    -commands=SET,ZTR	-xecute="do A^symmetry"	-name=name1
	;; change the above triggers name while adding more KILL type commands
	;; should error out because trigger in db has SET command and that was not specified as part of the name change
	;+^a    -commands=ZTR,K		-xecute="do A^symmetry"	-name=name2
	quit

nameconflict3tfile
	;; changing trigger name needs ALL commands to be listed
	;; add a trigger with SET and KILL types
	;+^a    -commands=ZTR,K	-xecute="do A^symmetry"	-name=name1
	;; change the above triggers name while adding more KILL type commands
	;; should error out because trigger in db has SET command and that was not specified as part of the name change
	;+^a    -commands=SET,K		-xecute="do A^symmetry"	-name=name2
	quit

setconsolidationt1file
	;-*
	;; This is the initial trigger configuration
	;; create a bare set which should have identical KILL/SET hash values
	;+^set	-command=SET	-xecute="set set=1"
	;; update the name
	;+^set	-command=SET	-xecute="set set=1"	-name=cleanset
	;; update the options
	;+^set	-command=SET	-xecute="set set=1"	-options=noi
	;
	;
	;; create a set with only a delimiter which should have differing identical KILL/SET hash values
	;; the kill type hashes for the second SET should match the first, but not the SET
	;+^set	-command=SET	-xecute="set set=1"	-delim="|"
	;; update the name
	;+^set	-command=SET	-xecute="set set=1"	-delim="|"	-name=delimset
	;; update the options
	;+^set	-command=SET	-xecute="set set=1"	-delim="|"	-options=noi
	;
	;
	;; create a set with only a delimiter which should have differing identical KILL/SET hash values
	;; the kill type hashes for the third SET should match the first, but not the SET
	;+^set	-command=SET	-xecute="set set=1"	-delim="|"	-piece=1
	;; update the name
	;+^set	-command=SET	-xecute="set set=1"	-delim="|"	-piece=1	-name=piecedelimset
	;; update the options
	;+^set	-command=SET	-xecute="set set=1"	-delim="|"	-piece=1	-options=noi
	;
	;; layer on the KILL types.  They should all layer onto the first KILL
	;+^set	-command=K,ZK,ZTR -xecute="set set=1"
	quit

setconsolidationt2file
	;; delete the KILL type layer on the first trigger WITH the SET clauses to kill remaining SET triggers
	;; note the lack of -name and -options, this does not work
	;; need -name -> TODO Ask Roger
	;; need -options because the delete code is bad TODO
	;-^set	-command=SET,K	  -xecute="set set=1"                        -name=cleanset
	;-^set	-command=SET,ZK	  -xecute="set set=1"  -delim="|"            -name=delimset      -options=noi
	;-^set	-command=SET,ZTR  -xecute="set set=1"  -delim="|"   -piece=1 -name=piecedelimset -options=noi
	quit

setconsolidationt3file
	;; re-add the deleted triggers without the names
	;+^set	-command=SET,K	  -xecute="set set=1"
	;+^set	-command=SET,ZK	  -xecute="set set=1"	-delim="|"
	;+^set	-command=SET,ZTR  -xecute="set set=1"	-delim="|"	-piece=1
	quit

setconsolidationt4file
	;; delete the KILL type layer on the first trigger WITH the SET clauses to kill remaining SET triggers
	;; not the lack of -name and -options, this should still work
	;-^set	-command=SET,K	  -xecute="set set=1"
	;-^set	-command=SET,ZK	  -xecute="set set=1"	-delim="|"
	;-^set	-command=SET,ZTR  -xecute="set set=1"	-delim="|"	-piece=1
	quit

killconsolidationtfile
	;-*
	;; Kill type consolidation, note the differing XECUTE string
	;; In this sequence triggers kill1 trigger specs worked correctly, but the kill2 trigger specs did not
	;; create a bunch of kill type triggers
	;+^kill  -command=K,ZK,ZTR	-xecute="set kill=1"
	;+^kill2 -command=K	 	-xecute="set kill=2"
	;+^kill2 -command=ZK	 	-xecute="set kill=2"
	;+^kill2 -command=ZTR	 	-xecute="set kill=2"
	;
	;; layer on some SET types that match the KILL types
	;+^kill  -command=S,K,ZK,ZTR	-xecute="set kill=1"
	;+^kill2 -command=SET,K		-xecute="set kill=2"
	;+^kill2 -command=SET,ZK		-xecute="set kill=2"
	;+^kill2 -command=SET,ZTR	-xecute="set kill=2"
	;
	;; layer on some SET types that do not match the KILL types
	;+^kill  -command=S,K,ZK,ZTR	-xecute="set kill=1" -delim="|"
	;+^kill  -command=S,K,ZK,ZTR	-xecute="set kill=1" -delim="|"	-piece=1
	;+^kill2 -command=SET,K		-xecute="set kill=2" -delim="|"
	;+^kill2 -command=SET,ZK	-xecute="set kill=2" -delim="|"	-piece=1
	;+^kill2 -command=SET,ZTR	-xecute="set kill=2" -delim="."	-piece=2
	;
	;; try various delete combinations to make sure deletes work
	;; note that you can't do this with NAMEd triggers
	;-^kill  -command=S,K		-xecute="set kill=1"
	;-^kill  -command=ZK		-xecute="set kill=1"
	;-^kill2 -command=SET,ZTR	-xecute="set kill=2" -delim="."	-piece=2
	;-^kill  -command=S,ZTR		-xecute="set kill=1" -delim="|"
	;-^kill  -command=S,ZTR		-xecute="set kill=1" -delim="|"
	quit

usernamevsautonametfile
	;-*
	;; This test case PASSES because it is a conflict if and only if the trigger spec
	;; is attempting to change the name of two triggers
	;+^a    -commands=SET,ZTR	-xecute="do ^A"	-name=uname1
	;+^a    -commands=ZTR,SET,K	-xecute="do ^A"	-name=uname2
	;; try to change the triggers without a user defined name
	;+^a    -commands=SET,K,ZTR	-xecute="do ^A"              -delim="|"
	;+^a    -commands=SET,K,ZK	-xecute="do ^A"              -delim="|"
	quit

autonamevsusernametfile
	;-*
	;; This test case FAILS because it is a conflict if and only if the trigger spec
	;; is attempting to change the name of two triggers
	;+^a    -commands=SET,ZTR	-xecute="do ^A"
	;+^a    -commands=ZTR,K		-xecute="do ^A"
	;; try to change the name
	;+^a    -commands=SET,ZK	-xecute="do ^A"              -delim="|"
	;+^a    -commands=SET,K,ZK	-xecute="do ^A" -name=uname4 -delim="|"
	quit
