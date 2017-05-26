V1OV	;GOTO (OVERLAY) COMMAND;YS-TS,V1OV,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1978
	S PASS=0,FAIL=0
	W !!,"V1OV: TEST OF GOTO (OVERLAY) COMMAND",!
	D 677
	D 678
	W !!,"GOTO label^routineref",!
	D 679
	D 680
	D 681
	D 682
	D 683
	D 684
	D 687
	W !!,"GOTO label+intexpr^routineref",!
	D 688
	D 689 D 690
	D 691 D 692 D 693
	D 694 D 695 D 829 D 830 D 831
END	W !!,"END OF V1OV",!
	S ROUTINE="V1OV",TESTS=20,AUTO=20,VISUAL=0 D ^VREPORT
	K  K ^V1OV1 Q
	;
677	W !,"I-677  postconditional of argument"
	S ITEM="I-677  ",VCOMP="",VCORR="E2 "
	S A=0 G E1^V1OV1:A=1 G E2^V1OV1:A=0 G E3^V1OV1
	;
678	W !,"I-678  GOTO ^routineref"
	S ITEM="I-678  ",VCOMP="",VCORR="^V1OV1 "
	G ^V1OV1
	;
679	W !,"I-679/685  label is alpha"
	S ITEM="I-679/685  ",VCOMP="",VCORR="ABC "
	G ABC^V1OV1
	;
680	W !,"I-680/686  label is intlit"
	S ITEM="I-680/686  ",VCOMP="",VCORR="0012 "
	G 0012^V1OV1
	;
681	W !,"I-681  label is ""%"""
	S ITEM="I-681  ",VCOMP="",VCORR="% "
	G %^V1OV1
	;
682	W !,"I-682  label is ""%"" and alpha"
	S ITEM="I-682  ",VCOMP="",VCORR="%ALPHA "
	G %ALPHA^V1OV1
	;
683	W !,"I-683  label is ""%"" and digit"
	S ITEM="I-683  ",VCOMP="",VCORR="%009900 "
	G %009900^V1OV1
	;
684	W !,"I-684  label is ""%"" and combination of alpha and digit"
	S ITEM="I-684  ",VCOMP="",VCORR="%ZZ0090A "
	G %ZZ0090A^V1OV1
	;
687	W !,"I-687  label is combination of alpha and digit"
	S ITEM="I-687  ",VCOMP="",VCORR="ZERO0 "
	G ZERO0^V1OV1
	;
688	W !,"I-688  intexpr is positive integer"
	S ITEM="I-688  ",VCOMP="",VCORR="000 "
	G %+00003^V1OV1
	;
689	W !,"I-689  intexpr is zero"
	S ITEM="I-689  ",VCOMP="",VCORR="XYZ 012 "
	G XYZ+0^V1OV1
	S VCOMP=VCOMP_"***"
R689	G 012+0^V1OV1
	;
690	W !,"I-690  intexpr is non-integer numeric"
	S ITEM="I-690  ",VCOMP="",VCORR="00120 690 00 "
	G 000+2.9999999^V1OV1
	S VCOMP=VCOMP_"690 " G 000+"4ABC"^V1OV1
	;
691	W !,"I-691  intexpr contains binary operators"
	S ITEM="I-691  ",VCOMP="",VCORR="0+2 690 6901 "
	G 00+1-12+15^V1OV1
	S VCOMP=VCOMP_"690 ",A=999 G 691+A/9-11/19^V1OV
	S VCOMP=VCOMP_"@@@ "
	S VCOMP=VCOMP_"6901 " G EXAMINER^V1OV1
	;
692	W !,"I-692  intexpr contains unary operators"
	S ITEM="I-692  ",VCOMP="",VCORR="0 "
	G 0+-+-+'-'0^V1OV1
	;
693	W !,"I-693  intexpr is function"
	S ITEM="I-693  ",VCOMP="",VCORR="0+1 "
	S A(1,1)=11 G ZERO0+$D(A(1))-$L(0.20)^V1OV1
	;
694	W !,"I-694  intexpr is gvn"
	S ITEM="I-694  ",VCOMP="",VCORR="0+3 "
	S ^V1OV1=3 G 0+^V1OV1^V1OV1
	;
695	W !,"I-695  intexpr contains gvn as expratom"
	S ITEM="I-695  ",VCOMP="",VCORR="E4+4 "
	S ^V1OV1(0)=1,^(1)=3 G E4+^V1OV1(1)+^(0)^V1OV1
	;
829	W !,"I-676/829  argument list ^routineref without postcondition"
	S ITEM="I-676/829  ",VCOMP="",VCORR="^V1OV1 "
	G ^V1OV1,^V1OV1
	;
830	W !,"I-676/830  argument list label^routineref without postcondition"
	S ITEM="I-676/830  ",VCOMP="",VCORR="E4 "
	G E4^V1OV1,ABD^V1OV1,E4^V1OV1
	;
831	W !,"I-676/831  argument list label+intexpr^routineref without postcondition"
	S ITEM="I-676/831  ",VCOMP="",VCORR="E4+2 "
	G E4+2^V1OV1,E4+3^V1OV1,E4+1^V1OV1
