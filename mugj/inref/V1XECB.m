V1XECB	;XECUTE COMMAND -2-;YS-TS,,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1978
	S PASS=0,FAIL=0
	W !!,"V1XECB: TEST OF XECUTE COMMAND -2-",!
816	W !,"I-816  DO command in 2 levels nesting of XECUTE command"
	S ITEM="I-816  ",VCOMP=""
	X "S VCOMP=1 X ""S VCOMP=VCOMP_2 D F S VCOMP=VCOMP_4"" S VCOMP=VCOMP_5","S VCOMP=VCOMP_6"
	S VCORR="123456" D EXAMINER
	;
817	W !,"I-817  GOTO command in 2 levels nesting of XECUTE command"
	S ITEM="I-817  ",VCOMP=""
	X "S VCOMP=7 X ""S VCOMP=VCOMP_8 G G S VCOMP=VCOMP_""""ERROR 1 """""" S VCOMP=VCOMP_10","S VCOMP=VCOMP_11"
	S VCORR="7891011" D EXAMINER
	;
818	W !,"I-818  QUIT command in 2 levels nesting of XECUTE command"
	S ITEM="I-818  ",VCOMP=""
	X "S VCOMP=12 X ""S VCOMP=VCOMP_13 Q  S VCOMP=VCOMP_""""ERROR 2 """""" S VCOMP=VCOMP_14","S VCOMP=VCOMP_15"
	S VCORR="12131415" D EXAMINER
	;
819	W !,"I-819  FOR command in 2 levels nesting of XECUTE command"
	S ITEM="I-819.1  without postcondition",V=""
	X "S V=1 X ""F I=2:1:4 S V=V_I Q:I>2"" S V=V_4","S V=V_5"
	X "S V=V_6 X ""F I=7:1:9 D H Q:I>7"" S V=V_9","S V=V_10"
	X "S V=V_11 X ""F I=12:1:14 G I Q:I>12"" S V=V_13","S V=V_14"
	X "S V=V_15 X ""F I=16:1:17 D J G:I>16 L"" S V=V_19","S V=V_20"
	S VCOMP=V,VCORR="1234567891011121314151617181920" D EXAMINER
	;
	S ITEM="I-819.2  with postcondition",V=""
	X:0 "S V=V_"" ERROR """:1
	X:1 "S V=V_1 X ""F I=2:1:4 S V=V_I Q:I>2"" S V=V_4 Q  S V=V_""ERROR""","S V=V_5"
	X "S V=V_6 X ""F I=7:1 S V=V_I Q:I>99"":0,""S V=V_7"":1 S V=V_8","S V=V_9"
	K P,X,Q,R,S S P="S X=10 S V=V_X",Q="D M" X P,Q:X=10,R:X=10,S
	S VCOMP=V,VCORR="123456789101112" D EXAMINER
	;
820	W !,"I-820  XECUTE a variable whose data value contains KILL of"
	W !,"       that variable itself"
	S ITEM="I-820  ",VCOMP="",A="S VCOMP=$D(A) K A S VCOMP=VCOMP_$D(A)"
	X A S VCOMP=VCOMP_$D(A) S VCORR="100" D EXAMINER
	;
821	W !,"I-821  XECUTE a variable whose data value contains SETting"
	W !,"       the same variable name to a different value from the"
	W !,"       one set to be XECUTE"
	S ITEM="I-821  ",VCOMP="",A="S A=$J(1,10) S VCOMP=A"
	X A S VCORR="         1" D EXAMINER
	;
END	W !!,"END OF V1XECB",!
	S ROUTINE="V1XECB",TESTS=7,AUTO=7,VISUAL=0 D ^VREPORT
	K  Q
	;
EXAMINER	I VCORR=VCOMP S PASS=PASS+1 W !,"   PASS  ",ITEM W:$Y>55 # Q
	S FAIL=FAIL+1 W !,"** FAIL  ",ITEM W:$Y>55 #
	W !,"           COMPUTED =""",VCOMP,"""" W:$Y>55 #
	W !,"           CORRECT  =""",VCORR,"""" W:$Y>55 #
	Q
	;
F	S VCOMP=VCOMP_3 Q
G	S VCOMP=VCOMP_9 Q
H	S V=V_I Q
I	S V=V_I Q
J	S V=V_I Q
K	S V=V_I Q
L	S V=V_(I+1) Q
M	S R="***",X=0,S="S V=V_12" S V=V_11
