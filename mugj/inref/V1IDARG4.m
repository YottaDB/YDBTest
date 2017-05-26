V1IDARG4	;ARGUMENT LEVEL INDIRECTION -4-;KO-MM-YS-TS,V1IDARG,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1978
	S PASS=0,FAIL=0
	W !!,"V1IDARG4: TEST OF ARGUMENT LEVEL INDIRECTION -4-"
WRITE	W !!,"WRITE command" W:$Y>55 #
444	W !!,"I-444  indirection of writeargument except format  (visual)" W:$Y>55 #
	W !,"       following two lines should be identical"
	S ITEM="I-444  "
	S A="B",B="WRITE"
	W !,"   WRITE"
	W !?3,@A
	;
445	W !!,"I-445  indirection of writeargument list  (visual)" W:$Y>55 #
	W !,"       following two lines should be identical"
	S ITEM="I-445  "
	S A="B",B=" ** ",C="""DOT"""
	W !,"    **  ** DOT"
	W !?3,@A,@A,@C
	;
446	W !!,"I-446  indirection of format control parameters  (visual)" W:$Y>55 #
	W !,"       following two lines should be identical"
	S ITEM="I-446  "
	S A="!?3,""AB"""
	W !,"   AB" W @A
	;
447	W !!,"I-447  2 levels of writeargument indirection  (visual)" W:$Y>55 #
	W !,"       following two lines should be identical"
	S ITEM="I-447  "
	S B(1)="@B(2),@B(3)",B(2)="!?3,1",B(3)="?3,B(4)",B(4)=" LINE"
	S C="C(1)",C(1)="C(2)",C(2)=" PAGE"
	W !,"   1 LINE PAGE"
	W @B(1),@@C
	;
448	W !!,"I-448  3 levels of writeargument indirection  (visual)" W:$Y>55 #
	W !,"       following two lines should be identical"
	S ITEM="I-448  " K B,C
	S B="B(1)",B(1)="B(2)",B(2)="?3,B(3)_B(4)",B(3)="#",B(4)="%% "
	S C="@C(1),@C(2)",C(1)="@C(3)",C(2)="@C(4)",C(3)="D,D+D",C(4)="$E(0.123,2,3)"
	S D=12.3
	W !,"   #%% 12.324.612"
	W !,@@@B,@C
	;
449	W !!,"I-449  Value of indirection contains name level indirection  (visual)" W:$Y>55 #
	W !,"       following two lines should be identical"
	S ITEM="I-449  "
	W !,"   101"
	S A="@B+1",B="C",C=100
	W !?3,@A
	;
450	W !!,"I-450  Value of indirection contains operators  (visual)" W:$Y>55 #
	W !,"       following two lines should be identical"
	S ITEM="I-450  "
	W !?3,1
	W !?3,@''10
	;
451	W !!,"I-451  Value of indirection contains function  (visual)" W:$Y>55 #
	W !,"       following two lines should be identical"
	S ITEM="I-451  "
	S BC(1)="*****"
	W !,"   *****"
	W !?3,@($E("ABCDEFGHIJK",2,3)_"(1)")
	;
452	W !!,"I-452  Value of indirection is numeric literal  (visual)" W:$Y>55 #
	W !,"       following two lines should be identical"
	S ITEM="I-452  "
	W !,"   987.56"
	S A="+09875.600E-1" W !?3,@A
	;
END	W !!,"END OF V1IDARG4",!
	S ROUTINE="V1IDARG4",TESTS=9,AUTO=0,VISUAL=9 D ^VREPORT
	K  Q
