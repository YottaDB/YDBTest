V4SSUB2 ;IW-KO-TS,VV4,MVTS V9.10;15/6/96;STRING SUBSCRIPT -2-
 ;
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1984-1996
 W !!,"124---V4SSUB2: String subscript -2-",!
 ;
1 W !,"IV-764  Naked reference when the total length of global variable is 255 characters"
 ;(title corrected in V7.4;16/9/89)
 S ^ABSN="40764",^ITEM="IV-764  Naked reference when the total length of global variable is 255 characters"
 S ^NEXT="2^V4SSUB2,V4JOB^VV4" D ^V4PRESET
 S MAX="" F I=1:1:255 S MAX=MAX_"*"
 S D="ABCDEFGHIJKLMNO",D13="ABCDEFGHIJKLM"
 S ^V(D,D,D,D,D,D,D,D,D,D,D,D,D,D13)=MAX
 S ^("ABCDEFGHIJKL1")=5,VCOMP=^("ABCDEFGHIJKL1"),^("ABCDEFGHIJKL2")=MAX
 S VCOMP=VCOMP_^V(D,D,D,D,D,D,D,D,D,D,D,D,D,"ABCDEFGHIJKL1")
 S VCOMP=VCOMP_(^(D13)=^("ABCDEFGHIJKL2"))
 S VCOMP=VCOMP_(^V(D,D,D,D,D,D,D,D,D,D,D,D,D,D13)=^("ABCDEFGHIJKL2"))
 S ^VCOMP=VCOMP,^VCORR="5511" D ^VEXAMINE K ^V
 ;
2 W !,"IV-765  Minimum (-.999999999999999E25) to maximum (.999999999999999E25) number of one subscript of local variable"
 ;(title corrected in V7.4;16/9/89)
 S ^ABSN="40765",^ITEM="IV-765  Minimum (-.999999999999999E25) to maximum (.999999999999999E25) number of one subscript of local variable"
 S ^NEXT="3^V4SSUB2,V4JOB^VV4" D ^V4PRESET
 S VCOMP="" S A(-.999999999999999E25)=6,A(-999999999999999E-25)=7,A(999999999999999E-25)=8,A(.999999999999999E25)=9
 SET VCOMP=A(-.999999999999999E+25)_A(-999999999999999E-25)_A(999999999999999E-25)_A(.999999999999999E+25)
 S ^VCOMP=VCOMP,^VCORR="6789" D ^VEXAMINE
 ;
3 W !,"IV-766  Minimum (-.999999999999999E25) to maximum (.999999999999999E25) number of one subscript of global variable"
 ;(title corrected in V7.4;16/9/89)
 S ^ABSN="40766",^ITEM="IV-766  Minimum (-.999999999999999E25) to maximum (.999999999999999E25) number of one subscript of global variable"
 S ^NEXT="4^V4SSUB2,V4JOB^VV4" D ^V4PRESET
 S VCOMP="" S ^VV(-.999999999999999E25)=10,^VV(-999999999999999E-25)=11,^VV(999999999999999E-25)=12,^VV(.999999999999999E25)=13
 S VCOMP=^VV(-.999999999999999E+25)_^VV(-999999999999999E-25)_^VV(999999999999999E-25)_^VV(.999999999999999E+25)
 S ^VCOMP=VCOMP,^VCORR="10111213" D ^VEXAMINE K ^VV
 ;
;**MVTS LOCAL CHANGE**
 ; GT.M only allows 31 subscripts
; 10/2001 SE
4 ;W !,"IV-767  Total number of local variable subscripts is 79"
 ;(title corrected in V7.4;16/9/89)
 ;S ^ABSN="40767",^ITEM="IV-767  Total number of local variable subscripts is 79"
 ;S ^NEXT="5^V4SSUB2,V4JOB^VV4" D ^V4PRESET
 ;S M="#" F I=0:2:252 S M=M_"QW"
 ;s A(1,2,3,4,5,6,7,8,9,0,"K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z",1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,"END")=14
 ;S V=A(1,2,3,4,5,6,7,8,9,0,"K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z",1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,"END")
 ;s A(1,2,3,4,5,6,7,8,9,0,"K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z",1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,"END")=M
 ;S X=A(1,2,3,4,5,6,7,8,9,0,"K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z",1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,"END")=M
 ;S V=V_X
 ;S ^VCOMP=V,^VCORR="141" D ^VEXAMINE
 ;
;**MVTS LOCAL CHANGE**
 ; GT.M only allows 31 subscripts
; 10/2001 SE
5 ;W !,"IV-768  Total number of global variable subscripts is 78"
 ;(title corrected in V7.4;16/9/89)
 ;S ^ABSN="40768",^ITEM="IV-768  Total number of global variable subscripts is 78"
 ;S ^NEXT="V4JOB^VV4" D ^V4PRESET K  K ^V
 ;S M="#" F I=0:2:252 S M=M_"QW"
 ;s ^V(1,2,3,4,5,6,7,8,9,0,"L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z",1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,"END")=15
 ;S ^("end")=16
 ;S V=^V(1,2,3,4,5,6,7,8,9,0,"L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z",1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,"END")
 ;S V=V_^("end")
 ;s ^V(1,2,3,4,5,6,7,8,9,0,"L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z",1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,"END")=M
 ;S ^("end")=M
 ;S X=^V(1,2,3,4,5,6,7,8,9,0,"L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z",1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,"END")=M
 ;S V=V_X
 ;S V=V_(^("end")=M)
 ;S ^VCOMP=V,^VCORR="151611" D ^VEXAMINE K ^V
 ;
END W !!,"End of 124 --- V4SSUB2",!
 K  K ^VV,^V Q
 Q
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
