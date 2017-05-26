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
	; isvstacking, test the nesting and chaining of intrinsic special variables related to triggers
	; There are several sections to this test.  In each section the name of the test is output along with initial values.
	; Final values are output after each section.
	; The first section is called "ISVSTACKING Test" and does the majority of nesting and some chaining tests.
	; In particular is shows modifications of the following ISV's:
	;
	; $REFERENCE (stacked)
	; $REFERENCE changes with referenced GVNs.  At the start of the trigger, it is always the GVN
	; of the trigger.  If a trigger fires another trigger, then when it returns from the nested invocation, it should be the value
	; of the GVN associated with the nested trigger. This also applies to the naked reference, ^()
	;
	; $TEST (stacked)
	; Should be the same at the start of each nested and chained trigger update.  If changed in a nested or chained trigger
	; it has no effect on the value in the parent or chained trigger
	;
	; $ZTVALUE (stacked)
	; Contains the value which fired the trigger.  In the case of multiple nested triggers, the stacked value is restored
	; for each parent.  In the case of chained triggers a modification of $ZTVALUE is seen in chained triggers.
	;
	; $ZTOLDVAL (stacked)
	; Contains the value which fired the trigger.  In the case of multiple nested triggers, the stacked value is restored
	; for each parent
	;
	; $ZTDATA (stacked)
	; $ZTDATA is different when represented between SETs and KILLs.
	; for a SET, it is $Data(@$REFERENCE)#2
	; for a [Z]KILL it is $Data(@$REFERENCE)
	; In the case of multiple nested triggers, the stacked value is restored for each parent.  There are examples of SET and KILL
	; with decendents to show the difference.  The SET produces a 1 and the KILL produces an 11.
	;
	; $ZTRIGGEROP (stacked)
	; Contains the operation (S,K,ZK) which caused the trigger to fire.
	; In the case of multiple nested triggers, the stacked value is restored for each parent
	;
	; $ZTWORMHOLE (not stacked)
	; The last modification to $ZTWORMHOLE is seen in a chained or parent trigger
	;
	; The trigger layout for this test is shown below with indentation showing $ZTLEVEL
	;
	; BEGIN Trigger do ^TRIGa invoked for ^CIF(1)
	;  BEGIN Trigger do ^chain invoked for ^CIF(2)
	;  End Trigger do ^chain invoked for ^CIF(2)
	;  BEGIN Trigger do ^TRIGa invoked for ^CIF(2)
	;  End Trigger do ^TRIGa invoked for ^CIF(2)
	;  BEGIN Trigger do ^TRIGb invoked for ^DIF(1)
	;   BEGIN Trigger do ^TRIGc invoked for ^EIF(1)
	;    BEGIN Trigger do ^TRIGd invoked for ^FIF(1)
	;    End Trigger do ^TRIGd invoked for ^FIF(1)
	;    BEGIN Trigger do ^TRIGd invoked for ^GIF(1)
	;    End Trigger do ^TRIGd invoked for ^GIF(1)
	;   End Trigger do ^TRIGc invoked for ^GIF(2)
	;  End Trigger do ^TRIGb invoked for ^EIF(1)
	; End Trigger do ^TRIGa invoked for ^DIF(1)
	; BEGIN Trigger do ^chain invoked for ^CIF(1)
	; End Trigger do ^chain invoked for ^CIF(1)
	;
	; As can be seen from this layout, TRIGa and chain are chained triggers based on modifications to ^CIF()
	; The others are nested.
	; The test sets the initial value of $test to 1 and fired triggers set it to 0 to verify its stacking
	; The test sets $ZTWORMHOLE to "initial value", and each trigger modifies it to the current $ZTLEVEL
	; The following is an example of the information output before and after nested triggers are fired:
	; BEGIN Trigger do ^TRIGa invoked for ^CIF(1)
	; $ztoldval=
	; $ztval=6
	; $test=1
	; $ztdata=0
	; $ztriggerop=S
	; $ztwormhole=initial value
	; naked reference=6
	; ...(triggers fired)
	; $ztoldval=
	; $ztval=6
	; $test=1
	; $ztdata=0
	; $ztriggerop=S
	; $ztwormhole=ztlevel:4
	; End Trigger do ^TRIGa invoked for ^DIF(1)
	; As can be seen, all the values are stacked except $ztwormhole which is set to the last modification, and
	; $REFERENCE which is set to the GVN of the last fired trigger
	; The $ztdata is 0 in this example as ^CIF(1) did not exist.  There are also examples where the value did exist
	; prior to a SET and a KILL to demonstrate the difference in $ztdata in each case.
	;
	; The next 3 sections are associated with $ZTUPDATE
	;
	; $ZTUPDATE (stacked) restored for nested triggers, modified for chained triggers.
	;
	; The first test is called "$ZTUPDATE Test" and shows nesting modifications.  TRIGe is invoked for this test
	;
	; The next test is called "$ZTUPDATE Chain Test" and shows chained modifications to $ztvalue which are reflected in the chained
	; trigger.  $ztupdate is also modified in the chained trigger to 1,2 to show changes to both the first and second fields.
	;
	; The next test is called the "KILL Chain Test" and shows ^KILL1 and KILL2 both fired for the kill of ^HIF(1) - both
	; show the same isv values
	;
	; The final test is called the "ZKILL Chain Test" and shows ^KILL1 and KILL2 both fired for the zkill of ^ZKIF(1) - both
	; show the same isv values
isvstacking
	do ^echoline
	write "ISVSTACKING Test",!
	set $ztwormhole="initial value"
	zwrite ^CIF
	zwrite ^DIF
	zwrite ^EIF
	zwrite ^FIF
	zwrite ^GIF
	if 1
	; do a set to fire triggers
	set ^CIF(1)=6
	zwrite ^CIF
	zwrite ^DIF
	zwrite ^EIF
	zwrite ^FIF
	zwrite ^GIF
	do testWztwormhole^isvstacking
	do ^echoline
	write "$ZTUPDATE Test",!
	set $ztwormhole="initial value"
	write "INITIAL VALUES:",!
	zwrite ^a
	write !
	; do a set to fire triggers
	set ^a="a|b|c|4"
	zwrite ^a
	do ^echoline
	write "$ZTUPDATE Chain Test",!
	set $ztwormhole="initial value"
	write "INITIAL VALUES:",!
	zwrite ^b
	write !
	; do a set to fire triggers
	set ^b="1|b|c|d"
	zwrite ^b
	do ^echoline
	write "KILL Chain Test",!
	set $ztwormhole="initial value"
	write "INITIAL VALUES:",!
	zwrite ^HIF
	write !
	; do a kill to fire triggers
	kill ^HIF(1)
	zwrite ^HIF
	do testWztwormhole^isvstacking
	do ^echoline
	write "ZKILL Chain Test",!
	set $ztwormhole="initial value"
	write "INITIAL VALUES:",!
	zwrite ^ZKIF
	write !
	; do a zkill to fire triggers
	zkill ^ZKIF(1)
	zwrite ^ZKIF
	do testWztwormhole^isvstacking
	; do a set to file jack/jill triggers to test NEW $ZTWO and $ZTSLATE
	do ^echoline
	set $ztwormhole="initial value"
	set ^JACK("hill")="This is gonna hurt"
	zwrite ^JACK,^JILL
	do testWztwormhole^isvstacking
	write !
	quit

	;-------------------------------------------------------
	; routines to test stacking and output the results
outztslate
	write indent,"$ztslate=",$ztslate,!
	quit
outztval
	write indent,"$ztoldval=",$ztoldval,!
	write indent,"$ztval=",$ztvalue,!
	quit
stack
	do outztslate^isvstacking
	do outztval^isvstacking
	write indent,"$test=",$test,!
	write indent,"$ztdata=",$ztdata,!
	write indent,"$ztriggerop=",$ztriggerop,!
	write indent,"$ztwormhole=",$ztwormhole,!
	quit
stackWnaked(ind)
	do stack^isvstacking
	write indent,"naked reference=",^(ind),!
	quit
forceWstackWnaked(ind)
	do stackWnaked^isvstacking(ind)
	write indent,"force $test to 0",!
	quit
testWztwormhole
	write "$test=",$test,!
	write "$ztwormhole=",$ztwormhole,!
	quit

	;-------------------------------------------------------
	; trigger routines
TRIGa
chain
	set $piece(indent," ",$ztlevel)="",ztname=$ztname,$piece(ztname,"#",2)="X"
	write indent,"BEGIN Trigger ",ztname," invoked for ",$reference,!
	; need to setup ind for the output routine to access the corresponding naked reference
	if "^CIF(1)"=$reference set ind=1
	else  set ind=2
	do stackWnaked^isvstacking(ind)
	set $ztwormhole="ztlevel:"_$ztlevel
	write indent,"$ztwormhole=",$ztwormhole,!
	if "^CIF(1)"=$reference set x=$INCR(^CIF(2)) set x=$INCR(^DIF(1)) do stack^isvstacking
	write indent,"End Trigger ",ztname," invoked for ",$reference,!
	quit
TRIGb
	set $piece(indent," ",$ztlevel)=""
	write indent,"BEGIN Trigger ",$ztname," invoked for ",$reference,!
	do stackWnaked^isvstacking(1)
	set $ztwormhole="ztlevel:"_$ztlevel
	write indent,"$ztwormhole=",$ztwormhole,!
	set x=$INCR(^EIF(1))
	do stack^isvstacking
	write indent,"force $test to 0",!
	if 0
	write indent,"$test=",$test,!
	write indent,"End Trigger ",$ztname," invoked for ",$reference,!
	quit
TRIGc
        set $piece(indent," ",$ztlevel)=""
	write indent,"BEGIN Trigger ",$ztname," invoked for ",$reference,!
	do stackWnaked^isvstacking(1)
	set $ztwormhole="ztlevel:"_$ztlevel
	write indent,"$ztwormhole=",$ztwormhole,!
	kill ^FIF(1)
	do forceWstackWnaked^isvstacking(2)
	zkill ^GIF(1)
	do forceWstackWnaked^isvstacking(2)
	if 0
	write indent,"$test=",$test,!
	write indent,"End Trigger ",$ztname," invoked for ",$reference,!
	quit
TRIGd
	set $piece(indent," ",$ztlevel)=""
	write indent,"BEGIN Trigger ",$ztname," invoked for ",$reference,!
	write indent,"$ztwormhole=",$ztwormhole,!
	set $ztwormhole="ztlevel:"_$ztlevel
	do forceWstackWnaked^isvstacking(1)
	if 0
	write indent,"$test=",$test,!
	write indent,"End Trigger ",$ztname," invoked for ",$reference,!
	quit
TRIGe
	set $piece(indent," ",$ztlevel)=""
	write indent,"BEGIN Trigger ",$ztname," invoked for ",$reference,!
	do outztval^isvstacking
	write indent,"$ztupdate=",$ztupdate,!
	if 4=$ztupdate do
	. set ^a="a|5|c|4"
	. do outztval^isvstacking
	. write indent,"$ztupdate=",$ztupdate,!
	if 2=$ztupdate do
	. set ^a="6|7|c|8"
	. do outztval^isvstacking
	. write indent,"$ztupdate=",$ztupdate,!
	write indent,"End Trigger ",$ztname," invoked for ",$reference,!
	quit
	; in the previous test case, UPDATE1 and UPDATE2 were identical trigger
	; routines, with different names.  By using different names, the XECUTE
	; string of the following triggers differed which let use create identical
	; chained triggers.
	;+^b -zdelim="|" -pieces=1;2 -commands=SET -xecute="do UPDATE1^isvstacking"
	;+^b -zdelim="|" -pieces=1;2 -commands=SET -xecute="do UPDATE2^isvstacking"
	; The same is true for KILL[12] and ZKILL[12]
UPDATE1
UPDATE2
        set $piece(indent," ",$ztlevel)="",ztname=$ztname,$piece(ztname,"#",2)="X"
	write indent,"BEGIN Trigger ",ztname," invoked for ",$reference,!
	do outztval^isvstacking
	write indent,"$ztupdate=",$ztupdate,!
	if 1=$ztupdate do
	. set $ztvalue="1|2|c|d"
	. do outztval^isvstacking
	. write indent,"$ztupdate=",$ztupdate,!
	write indent,"End Trigger ",ztname," invoked for ",$reference,!
	quit
KILL1
KILL2
	set $piece(indent," ",$ztlevel)="",ztname=$ztname,$piece(ztname,"#",2)="X"
	write indent,"BEGIN Trigger ",ztname," invoked for ",$reference,!
	do stackWnaked^isvstacking(1)
	set $ztwormhole="ztlevel:"_$ztlevel
	write indent,"$ztwormhole=",$ztwormhole,!
	if 0
	write indent,"$test=",$test,!
	write indent,"End Trigger ",ztname," invoked for ",$reference,!
	quit
ZKILL1
ZKILL2
        set $piece(indent," ",$ztlevel)="",ztname=$ztname,$piece(ztname,"#",2)="X"
	write indent,"BEGIN Trigger ",ztname," invoked for ",$reference,!
	do stackWnaked^isvstacking(1)
	set $ztwormhole="ztlevel:"_$ztlevel
	write indent,"$ztwormhole=",$ztwormhole,!
	if 0
	write indent,"$test=",$test,!
	write indent,"End Trigger ",ztname," invoked for ",$reference,!
	quit
jacktrig
	; Test $ZTWOrmhole can be NEW'd and $ZTSLate cleared at $TLEVEL 0->1 transition
        set $piece(indent," ",$ztlevel)=""
	write indent,"BEGIN Trigger ",$ztname," invoked for ",$reference,!
	do stack^isvstacking
	do
	. new $ZTWOrmhole
	. set $ZTWOrmhole="internal reference"
	. set $ZTSLate="trancendental euphemism"
	. do stack^isvstacking
	write indent,"stack popped - $ZTWOmhole should revert",!
	do stack^isvstacking
	set ^JILL(1)="trigger me"
	do stack^isvstacking
	write indent,"End Trigger ",$ztname," invoked for ",$reference,!
	quit
jilltrig
        set $piece(indent," ",$ztlevel)=""
	write indent,"BEGIN Trigger ",$ztname," invoked for ",$reference,!
	do stack^isvstacking
	set $ZTWOrmhole="Jack fell down"
	set $ZTSlate="And broke his tookus"
	do stack^isvstacking
	write indent,"End Trigger ",$ztname," invoked for ",$reference,!
	quit

	;-------------------------------------------------------
	;
setup
	do ^echoline
	write "Pre-load some data",!
	set ^CIF(2)=11
	set ^DIF(1)=15
	set ^EIF(1)=6
	set ^EIF(1,1)=16
	set ^FIF(1)=8
	set ^FIF(2)=9
	set ^GIF(1)=13
	set ^GIF(1,1)=14
	set ^GIF(2)=23
	set ^a="a|b|c|d"
	set ^b="a|b|c|d"
	set ^HIF(1)=1
	set ^HIF(2)=1
	set ^ZKIF(1)=1
	set ^ZKIF(2)=1
	do ^echoline
	write "Load triggers",!
	do text^dollarztrigger("tfile^isvstacking","trigisvstacking.trg")
	do file^dollarztrigger("trigisvstacking.trg",1)
	do ^echoline
	do all^dollarztrigger
	quit


	;-------------------------------------------------------
tfile
	;
	;+^CIF(:) -commands=SET    -xecute="do TRIGa^isvstacking"
	;+^CIF(:) -commands=SET    -xecute="do chain^isvstacking"
	;+^DIF(:) -commands=SET    -xecute="do TRIGb^isvstacking"
	;+^EIF(:) -commands=SET    -xecute="do TRIGc^isvstacking"
	;+^FIF(:) -commands=KILL   -xecute="do TRIGd^isvstacking"
	;+^GIF(:) -commands=ZKILL  -xecute="do TRIGd^isvstacking"
	;+^a -zdelim="|" -pieces=1;2;4 -commands=SET -xecute="do TRIGe^isvstacking"
	;+^b -zdelim="|" -pieces=1;2 -commands=SET -xecute="do UPDATE1^isvstacking"
	;+^b -zdelim="|" -pieces=1;2 -commands=SET -xecute="do UPDATE2^isvstacking"
	;+^HIF(:)  -commands=KILL  -xecute="do KILL1^isvstacking"
	;+^HIF(:)  -commands=KILL  -xecute="do KILL2^isvstacking"
	;+^ZKIF(:) -commands=ZKILL -xecute="do ZKILL1^isvstacking"
	;+^ZKIF(:) -commands=ZKILL -xecute="do ZKILL2^isvstacking"
	;+^JACK(:) -commands=SET   -xecute="do jacktrig^isvstacking"
	;+^JILL(:) -commands=SET   -xecute="do jilltrig^isvstacking"
