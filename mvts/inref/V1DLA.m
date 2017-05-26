V1DLA ;IW-YS-TS,VV1,MVTS V9.10;15/6/96;$DATA AFTER SETTING AND KILLING UNSUBSCRIPT LVN
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1978-1996
 W !!,"109---V1DLA: $DATA after SETting and KILLing unsubscript lvn",!
824 W !,"I-824  KILLing undefined unsubscripted local variables"
 S ^ABSN="11486",^ITEM="I-824  KILLing undefined unsubscripted local variables",^NEXT="211^V1DLA,V1DLB^VV1" D ^V1PRESET
 K  S ^VCOMP="" D DATA K A K A,B,C D DATA
 S ^VCORR="0 0 0 0 0 0 0 ********/0 0 0 0 0 0 0 ********/" D ^VEXAMINE
 ;
211 W !,"I-211/212  SETting unsubscripted local variable and its $DATA value"
 S ^ABSN="11487",^ITEM="I-211/212  SETting unsubscripted local variable and its $DATA value",^NEXT="213^V1DLA,V1DLB^VV1" D ^V1PRESET
 K  S A=1,F="F" S ^VCOMP="" D DATA
 S ^VCORR="1 0 0 0 0 1 0 *1*****F**/" D ^VEXAMINE
 ;
213 W !,"I-213/214  KILLing unsubscripted local variable and its $DATA value"
 S ^ABSN="11488",^ITEM="I-213/214  KILLing unsubscripted local variable and its $DATA value",^NEXT="215^V1DLA,V1DLB^VV1" D ^V1PRESET
 K  S A=100,G="GGG" S ^VCOMP="" D DATA K A,B,C,D,E,F,G,H,I,J,K D DATA
 S ^VCORR="1 0 0 0 0 0 1 *100******GGG*/0 0 0 0 0 0 0 ********/" D ^VEXAMINE
 ;
215 W !,"I-215  Assign string literal to unsubscripted local variables"
 S ^ABSN="11489",^ITEM="I-215  Assign string literal to unsubscripted local variables",^NEXT="216^V1DLA,V1DLB^VV1" D ^V1PRESET
 K  S A="ABC",D="DDD",C="C" S ^VCOMP="" D DATA K A,B,C D DATA
 S ^VCORR="1 0 1 1 0 0 0 *ABC**C*DDD****/0 0 0 1 0 0 0 ****DDD****/" D ^VEXAMINE
 ;
216 W !,"I-216  Assign numeric literal to unsubscripted local variables"
 S ^ABSN="11490",^ITEM="I-216  Assign numeric literal to unsubscripted local variables",^NEXT="217^V1DLA,V1DLB^VV1" D ^V1PRESET
 K  S C=333,D=0020.030,G=0.020,^VCOMP="" D DATA K D,G,A D DATA
 S ^VCORR="0 0 1 1 0 0 1 ***333*20.03***.02*/0 0 1 0 0 0 0 ***333*****/" D ^VEXAMINE
 ;
217 W !,"I-217  KILL all local variable"
 S ^ABSN="11491",^ITEM="I-217  KILL all local variable",^NEXT="218^V1DLA,V1DLB^VV1" D ^V1PRESET
 K  S B=2,C="CCC",A=1,E=5,F="FFF",D="DDD",^VCOMP="" D DATA
 K  D DATA
 S ^VCORR="1 1 1 1 1 1 0 *1*2*CCC*DDD*5*FFF**/0 0 0 0 0 0 0 ********/" D ^VEXAMINE
 ;
218 W !,"I-218  Exclusive KILL"
 S ^ABSN="11492",^ITEM="I-218  Exclusive KILL",^NEXT="219^V1DLA,V1DLB^VV1" D ^V1PRESET
 K  S B=2,C="CCC",A=1,E=5,F="FFF" S ^VCOMP="" D DATA
 K (E,F,G) D DATA
 S ^VCORR="1 1 1 0 1 1 0 *1*2*CCC**5*FFF**/0 0 0 0 1 1 0 *****5*FFF**/" D ^VEXAMINE
 ;
219 W !,"I-219  $DATA for allowed local variable name"
 ;(title corrected in V7.4;16/9/89)
 S ^ABSN="11493",^ITEM="I-219  $DATA for allowed local variable name",^NEXT="V1DLB^VV1" D ^V1PRESET
 K  S %1234567=" %1234567 ",ABC123DE=" ABC123DE "
 S ^VCOMP=$D(%1234567)_%1234567_$D(ABC123DE)_ABC123DE
 S ^VCORR="1 %1234567 1 ABC123DE " D ^VEXAMINE
 ;
END W !!,"End of 109---V1DLA",!
 K  Q
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
 ;
DATA S ^VCOMP=^VCOMP_$D(A)_" "_$D(B)_" "_$D(C)_" "_$D(D)_" "_$D(E)_" "_$D(F)_" "_$D(G)_" "
 S ^VCOMP=^VCOMP_"*" I $D(A)#10=1 S ^VCOMP=^VCOMP_A
 S ^VCOMP=^VCOMP_"*" I $D(B)#10=1 S ^VCOMP=^VCOMP_B
 S ^VCOMP=^VCOMP_"*" I $D(C)#10=1 S ^VCOMP=^VCOMP_C
 S ^VCOMP=^VCOMP_"*" I $D(D)#10=1 S ^VCOMP=^VCOMP_D
 S ^VCOMP=^VCOMP_"*" I $D(E)#10=1 S ^VCOMP=^VCOMP_E
 S ^VCOMP=^VCOMP_"*" I $D(F)#10=1 S ^VCOMP=^VCOMP_F
 S ^VCOMP=^VCOMP_"*" I $D(G)#10=1 S ^VCOMP=^VCOMP_G
 S ^VCOMP=^VCOMP_"*/" Q
