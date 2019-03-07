;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This module is derived from FIS GT.M.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
MPTNUM	;validation of %numeric conversions + string conversions
	S PASS=0,FAIL=0,ITEM=""
	W !!,"MPTNUM: TEST OF %NUMERIC CONVERSIONS and STRING CONVERSIONS"

153	W !,"I-152/153  decimal to hex and reverse conversion "
	S ITEM="I-152/153.0  decimal to hex and reverse - low natural"
	S %DL=2
	S %DH=0 D ^%DH S %HD=%DH  D ^%HD  S VCOMP=%DH_"-"_%HD_" "  S X=1
	F i=1:1:4  S X=X+X+X+X  S %DH=X  D ^%DH  S %HD=%DH  D ^%HD S VCOMP=VCOMP_%DH_"-"_%HD_" "
	S VCORR="00-0 04-4 10-16 40-64 100-256 "
	D EXAMINER
	S ITEM="I-152/153.1  decimal to hex and reverse - high natural"
	S %DL=4
	S VCOMP=""  S X=1024*32*X
	F i=9:1:12  S X=X+X+X+X  S %DH=X  D ^%DH  S %HD=%DH  D ^%HD S VCOMP=VCOMP_%DH_"-"_%HD_" "
	S VCORR="2000000-33554432 8000000-134217728 20000000-536870912 80000000-2147483648 "
	D EXAMINER
	;
	S ITEM="I-152/153.2  decimal to hex and reverse - low negative"
	S %DL=3
	S %DH=-1 D ^%DH S %HD=%DH  D ^%HD  S VCOMP=%DH_"-"_%HD_" "  S X=-1
	F i=1:1:4  S X=X+X+X+X  S %DH=X  D ^%DH  S %HD=%DH  D ^%HD S VCOMP=VCOMP_%DH_"-"_%HD_" "
 	S VCORR="FFF-4095 FFC-4092 FF0-4080 FC0-4032 F00-3840 "
	D EXAMINER
	S ITEM="I-152/153.3  decimal to hex and reverse - high negative - %DL=4"
	S %DL=4,saveX=X
	S VCOMP=""  S X=1024*32*X
	F i=9:1:12  S X=X+X+X+X  S %DH=X  D ^%DH  S %HD=%DH  D ^%HD S VCOMP=VCOMP_%DH_"-"_%HD_" "
	S VCORR="E000000-234881024 8000000-134217728 E0000000-3758096384 80000000-2147483648 "
	D EXAMINER
	S ITEM="I-152/153.4  decimal to hex and reverse - high negative - %DL=8"
	S %DL=8,X=saveX
	S VCOMP=""  S X=1024*32*X
	F i=9:1:12  S X=X+X+X+X  S %DH=X  D ^%DH  S %HD=%DH  D ^%HD S VCOMP=VCOMP_%DH_"-"_%HD_" "
	S VCORR="FE000000-4261412864 F8000000-4160749568 E0000000-3758096384 80000000-2147483648 "
	D EXAMINER
	;
154	W !,"I-152/154  decimal to octal and reverse conversion "
	S ITEM="I-152/154.0  decimal to octal and reverse - low natural"
	S %DL=2
	S %DO=0 D ^%DO S %OD=%DO  D ^%OD  S VCOMP=%DO_"-"_%OD_" "  S X=1
	F i=1:1:4  S X=X+X+X+X  S %DO=X  D ^%DO  S %OD=%DO  D ^%OD S VCOMP=VCOMP_%DO_"-"_%OD_" "
        S VCORR="00-0 04-4 20-16 100-64 400-256 "
	D EXAMINER
	S ITEM="I-152/154.1  decimal to octal and reverse - high natural"
	S %DL=4
	S VCOMP=""  S X=1024*32*X
	F i=9:1:12  S X=X+X+X+X  S %DO=X  D ^%DO  S %OD=%DO  D ^%OD S VCOMP=VCOMP_%DO_"-"_%OD_" "
	S VCORR="200000000-33554432 1000000000-134217728 4000000000-536870912 20000000000-2147483648 "
	D EXAMINER
	;
	S ITEM="I-152/154.2  decimal to octal and reverse - low negative"
	S %DL=3
	S %DO=-1 D ^%DO S %OD=%DO  D ^%OD  S VCOMP=%DO_"-"_%OD_" "  S X=-1
	F i=1:1:4  S X=X+X+X+X  S %DO=X  D ^%DO  S %OD=%DO  D ^%OD S VCOMP=VCOMP_%DO_"-"_%OD_" "
 	S VCORR="777-511 774-508 760-496 700-448 400-256 "
	D EXAMINER
	S ITEM="I-152/154.3  decimal to octal and reverse - high negative - %DL=4"
	S %DL=4,saveX=X
	S VCOMP=""  S X=1024*32*X
	F i=9:1:12  S X=X+X+X+X  S %DO=X  D ^%DO  S %OD=%DO  D ^%OD S VCOMP=VCOMP_%DO_"-"_%OD_" "
	S VCORR="600000000-100663296 7000000000-939524096 4000000000-536870912 60000000000-6442450944 "
	D EXAMINER
	S ITEM="I-152/154.4  decimal to octal and reverse - high negative - %DL=11"
	S %DL=11,X=saveX
	S VCOMP=""  S X=1024*32*X
	F i=9:1:12  S X=X+X+X+X  S %DO=X  D ^%DO  S %OD=%DO  D ^%OD S VCOMP=VCOMP_%DO_"-"_%OD_" "
	S VCORR="77600000000-8556380160 77000000000-8455716864 74000000000-8053063680 60000000000-6442450944 "
	D EXAMINER
	;

155	W !,"I-152/155  octal to hex and reverse conversion "
	S ITEM="I-152/155.0  octal to hex and reverse - low "
	S %DL=2
	S %OH=0 D ^%OH S %HO=%OH  D ^%HO  S VCOMP=%OH_"-"_%HO_" "  S X=1
	F i=1:1:4  S X=X+X+X+X  S %OH=X  D ^%OH  S %HO=%OH  D ^%HO S VCOMP=VCOMP_%OH_"-"_%HO_" "
	S VCORR="0-0 4-4 E-16 34-64 AE-256 "
	D EXAMINER
	S ITEM="I-152/155.1  octal to hex and reverse - high "
	S %DL=4
	S VCOMP=""  S X=2500000
	F i=9:1:12  S X=X+X+X+X  S %OH=X  D ^%OH  S %HO=%OH  D ^%HO S VCOMP=VCOMP_%OH_"-"_%HO_" "
	S VCORR="200000-10000000 800000-40000000 1C00000-160000000 6800000-640000000 "
	D EXAMINER
	;
156	W !,"I-152/156  exponentiation - "
	S ITEM="I-152/156.0  exponentiation"
	S VCOMP=""
	F K=0:1:2  S %I=0,%J=K  D ^%EXP S VCOMP=VCOMP_"0^"_K_"="_%I_" "
	F K=0:1:2  S %I=1,%J=K  D ^%EXP S VCOMP=VCOMP_"1^"_K_"="_%I_" "
	F K=0:1:4  S %I=2,%J=K  D ^%EXP S VCOMP=VCOMP_"2^"_K_"="_%I_" "
	S VCORR="0^0=1 0^1=0 0^2=0 1^0=1 1^1=1 1^2=1 2^0=1 2^1=2 2^2=4 2^3=8 2^4=16 "
	D EXAMINER
	;
157	W !,"I-152/157  Lower/Upper case conversions - "
	S ITEM="I-152/157.0  Mixed to Lower then to Upper"
	S X2345678="Es komm der Tag, Eine Hertzliche Gew"_$Char(252)_"nsche"
	S X234567890123456789012345678901="This is the Value of a LONG NAME variable"
	S VCOMP=X2345678_"."_$$FUNC^%LCASE(X2345678)_"."_$$FUNC^%UCASE(X2345678)
	S VCORR="Es komm der Tag, Eine Hertzliche Gew"_$Char(252)_"nsche.es komm der tag, eine hertzliche gew"_$Char(252)_"nsche.ES KOMM DER TAG, EINE HERTZLICHE GEW"_$Char(220)_"NSCHE"
	D EXAMINER
	S ITEM="I-152/157.1  Mixed to Lower then to Upper using Long Name"
	S VCOMP=X234567890123456789012345678901_"."_$$FUNC^%LCASE(X234567890123456789012345678901)_"."_$$FUNC^%UCASE(X234567890123456789012345678901)
	S VCORR="This is the Value of a LONG NAME variable.this is the value of a long name variable.THIS IS THE VALUE OF A LONG NAME VARIABLE"
	D EXAMINER

END	W !!,"END OF MPTNUM",!
	K  Q
	;
EXAMINER
	I VCORR=VCOMP S PASS=PASS+1 W !,"   PASS  ",ITEM W:$Y>55 # Q
	S FAIL=FAIL+1 W !,"** FAIL  ",ITEM W:$Y>55 #
	W !,"           COMPUTED =""",VCOMP,"""" W:$Y>55 #
	W !,"           CORRECT  =""",VCORR,"""" W:$Y>55 #
