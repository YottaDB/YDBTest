V1HANG	;HANG COMMAND;KO-TS,,VLIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1978
	W:$Y>45 #
	W !!,"V1HANG: TEST OF HANG COMMANDS"
	W !!,"EACH TEST CONSISTS OF THREE STEPS."
	W !," 1ST: HANG COMMANDS TO BE EXECUTED APPEAR."
	W !," 2ND: HANG COMMANDS ARE EXECUTED WITH THE START CARRET '>'"
	W !,"      AND END WITH THE STOP CARRET '<'."
	W !," 3RD: EXPECTED & MEASURED HANG DURATIONS APPEAR."
	W !!,"HANG TIME IS MEASURED WITH $HOROLOG IN THIS ROUTINE."
	W !," WITH A VIEW TO TESTING $HOROLOG,"
	W !," IT WOULD BE BETTER TO USE STOP-WATCH SIMULTANEOUSLY."
	;
401	W !!,"I-401  HANG duration by $H  (visual)" W:$Y>55 #
	S ITEM="I-401  "
	S CMD="HANG 10",TM=10 D START HANG 10 D STOP
	;
402	W !!,"I-402  List of hangargument  (visual)" W:$Y>55 #
	S ITEM="I-402  "
	S CMD="H 0,1,2,3",TM=6 D START H 0,1,2,3 D STOP
	;
403	W !!,"I-403  HANG in FOR scope  (visual)" W:$Y>55 #
	S ITEM="I-403  "
	S CMD="F I=1:1:10 H 1",TM=10 D START F I=1:1:10 H 1
	D STOP
	;
404	W !!,"I-404  HANG with postconditional  (visual)" W:$Y>55 #
	S ITEM="I-404  "
	S CMD="H:0 10",TM=0 D START H:0 10 D STOP
	S CMD="H:1+1 5",TM=5 D START H:1+1 5 D STOP
	;
405	W !!,"I-405  argument level indirection  (visual)" W:$Y>55 #
	S ITEM="I-405  "
	S CMD="S A=0 H @1,@A",TM=1,A=0 D START H @1,@A D STOP
	;
406	W !!,"I-406  name level indirection  (visual)" W:$Y>55 #
	S ITEM="I-406  "
	S CMD="S A=""B"",B=2 H @A",TM=2,A="B",B=2 D START H @A D STOP
	;
	W !!,"HANG numexpr"
407	W !!,"I-407  numexpr is integer  (visual)" W:$Y>55 #
	S ITEM="I-407  "
	S CMD="HANG 10.00",TM=10 D START HANG 10.00 D STOP
	S CMD="H 1",TM=1 D START H 1 D STOP
	S CMD="XECUTE ""H 2""",TM=2,X="H 2" D START XECUTE X D STOP
	;
408	W !!,"I-408  numexpr=0  (visual)" W:$Y>55 #
	S ITEM="I-408  "
	S CMD="H 0",TM=0 D START H 0 D STOP
	;
409	W !!,"I-409  numexpr<0  (visual)" W:$Y>55 #
	S ITEM="I-409  "
	S CMD="H -10",TM=0 D START H -10 D STOP
	;
410	W !!,"I-410  numexpr is non-integer positive numeric literal  (visual)" W:$Y>55 #
	S ITEM="I-410  "
	S CMD="H 100E-2",TM=1 D START H 100E-2 D STOP
	;
411	W !!,"I-411  numexpr is greater than zero and less than one  (visual)" W:$Y>55 #
	S ITEM="I-411  "
	S CMD="H .99999",TM=1 D START H .99999 D STOP
	;
412	W !!,"I-412  numexpr is string literal  (visual)" W:$Y>55 #
	S ITEM="I-412  "
	S CMD="H ""A""",TM=0 D START H "A" D STOP
	S CMD="H ""2ABCDE""",TM=2 D START H "2ABCDE" D STOP
	;
413	W !!,"I-413  numexpr is empty string  (visual)" W:$Y>55 #
	S ITEM="I-413  "
	S CMD="H """"",TM=0 D START H "" D STOP
	;
414	W !!,"I-414  numexpr is lvn  (visual)" W:$Y>55 #
	S ITEM="I-414  "
	S CMD="S A(2)=3 H A(2)",TM=3,A(2)=3 D START H A(2) D STOP
	;
415	W !!,"I-415  numexpr contains unary operator  (visual)" W:$Y>55 #
	S ITEM="I-415  "
	S CMD="H -'0",TM=0 D START H -'0 D STOP
	;
416	W !!,"I-416  numexpr contains binary operator  (visual)" W:$Y>55 #
	S ITEM="I-416  "
	S CMD="H 1.2+2.8",TM=3 D START H 1.2+2.8 D STOP
	S CMD="H 0_1_1",TM=11 D START H 0_1_1 D STOP
	;
END	W !!,"END OF V1HANG",!
	S ROUTINE="V1HANG",TESTS=16,AUTO=0,VISUAL=16 D ^VREPORT
	K  Q
	;
START	I $Y>55 W #
	W !,"       ",CMD,?35,">" S H=$H Q
STOP	S H=$$^difftime($H,H) W "<  EXPECTED:",TM,?55,"MEASURED:",H Q
