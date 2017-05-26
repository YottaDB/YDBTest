V3TR07 ;IW-KO-YS-TS,V3TR,MVTS V9.10;15/6/96;PART-90
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1990-1996
 W !!,"13---V3TR07: $TRANSLATE function -7-"
 ;
1 S ^ABSN="30176",^ITEM="III-176  2 successive middle substrings are changed"
 S ^NEXT="2^V3TR07,V3TR08^V3TR,V3TEXT^VV3" D ^V3PRESET
 S ^VCOMP=$TR("ABCDEFEFDCBA","FED","fed")
 S ^VCORR="ABCdefefdCBA" D ^VEXAMINE
 ;
2 S ^ABSN="30177",^ITEM="III-177  The tailing 1 char is changed"
 S ^NEXT="3^V3TR07,V3TR08^V3TR,V3TEXT^VV3" D ^V3PRESET
 S ^VCOMP=$TR("ABCDEFGH","HIJ","hij")
 S ^VCORR="ABCDEFGh" D ^VEXAMINE
 ;
3 S ^ABSN="30178",^ITEM="III-178  The tailing 2 chars are changed"
 S ^NEXT="4^V3TR07,V3TR08^V3TR,V3TEXT^VV3" D ^V3PRESET
 S ^VCOMP=$TR("ABCDEFGH","GHI","ghi")
 S ^VCORR="ABCDEFgh" D ^VEXAMINE
 ;
4 S ^ABSN="30179",^ITEM="III-179  The tailing 3 chars are changed"
 S ^NEXT="5^V3TR07,V3TR08^V3TR,V3TEXT^VV3" D ^V3PRESET
 S ^VCOMP=$TR("ABCDEFGH","FGH","fgh")
 S ^VCORR="ABCDEfgh" D ^VEXAMINE
 ;
5 S ^ABSN="30180",^ITEM="III-180  The tailing substring is changed"
 S ^NEXT="6^V3TR07,V3TR08^V3TR,V3TEXT^VV3" D ^V3PRESET
 S ^VCOMP=$TR("ABCCBADEFFED","DEF","def")
 S ^VCORR="ABCCBAdeffed" D ^VEXAMINE
 ;
6 S ^ABSN="30181",^ITEM="III-181  The heading 1 and tailing 1 chars are changed"
 S ^NEXT="7^V3TR07,V3TR08^V3TR,V3TEXT^VV3" D ^V3PRESET
 S ^VCOMP=$TR("ABCDEFGH","ABH","abh")
 S ^VCORR="abCDEFGh" D ^VEXAMINE
 ;
7 S ^ABSN="30182",^ITEM="III-182  The heading 2 and tailing 2 chars are changed"
 S ^NEXT="8^V3TR07,V3TR08^V3TR,V3TEXT^VV3" D ^V3PRESET
 S ^VCOMP=$TR("ABCDDCBA","ABE","abe")
 S ^VCORR="abCDDCba" D ^VEXAMINE
 ;
8 S ^ABSN="30183",^ITEM="III-183  The heading 3 and tailing 3 chars are changed"
 S ^NEXT="9^V3TR07,V3TR08^V3TR,V3TEXT^VV3" D ^V3PRESET
 S ^VCOMP=$TR("ABCDEFFEDCBA","ABC","abc")
 S ^VCORR="abcDEFFEDcba" D ^VEXAMINE
 ;
9 S ^ABSN="30184",^ITEM="III-184  The heading and last substrings are changed"
 S ^NEXT="10^V3TR07,V3TR08^V3TR,V3TEXT^VV3" D ^V3PRESET
 S ^VCOMP=$TR("ABCCBADEFABCCBA","ABC","abc")
 S ^VCORR="abccbaDEFabccba" D ^VEXAMINE
 ;
10 S ^ABSN="30185",^ITEM="III-185  The heading and middle 1 char are changed"
 S ^NEXT="11^V3TR07,V3TR08^V3TR,V3TEXT^VV3" D ^V3PRESET
 S ^VCOMP=$TR("ABCDEFGH","ACI","aci")
 S ^VCORR="aBcDEFGH" D ^VEXAMINE
 ;
11 S ^ABSN="30186",^ITEM="III-186  The heading 2 and middle 2 chars are changed"
 S ^NEXT="12^V3TR07,V3TR08^V3TR,V3TEXT^VV3" D ^V3PRESET
 S ^VCOMP=$TR("ABCDAEFG","ABE","abe")
 S ^VCORR="abCDaeFG" D ^VEXAMINE
 ;
12 S ^ABSN="30187",^ITEM="III-187  The heading 3 and middle 3 chars are changed"
 S ^NEXT="13^V3TR07,V3TR08^V3TR,V3TEXT^VV3" D ^V3PRESET
 S ^VCOMP=$TR("ABCDEFCBAGH","ABC","abc")
 S ^VCORR="abcDEFcbaGH" D ^VEXAMINE
 ;
13 S ^ABSN="30188",^ITEM="III-188  The heading and middle substrings are changed"
 S ^NEXT="14^V3TR07,V3TR08^V3TR,V3TEXT^VV3" D ^V3PRESET
 S ^VCOMP=$TR("ABCCBADEFFEDABCCBAGHIIHG","ABC","abc")
 S ^VCORR="abccbaDEFFEDabccbaGHIIHG" D ^VEXAMINE
 ;
14 S ^ABSN="30189",^ITEM="III-189  2 non successive middle chars are changed"
 S ^NEXT="15^V3TR07,V3TR08^V3TR,V3TEXT^VV3" D ^V3PRESET
 S ^VCOMP=$TR("ABCDEFGH","CEI","cei")
 S ^VCORR="ABcDeFGH" D ^VEXAMINE
 ;
15 S ^ABSN="30190",^ITEM="III-190  2 non successive middle substrings are changed"
 S ^NEXT="16^V3TR07,V3TR08^V3TR,V3TEXT^VV3" D ^V3PRESET
 S ^VCOMP=$TR("AABBCCDDEEFFGGHH","DFI","dfi")
 S ^VCORR="AABBCCddEEffGGHH" D ^VEXAMINE
 ;
16 S ^ABSN="30191",^ITEM="III-191  The heading char, a middle char, and tailing chars are changed"
 S ^NEXT="17^V3TR07,V3TR08^V3TR,V3TEXT^VV3" D ^V3PRESET
 S ^VCOMP=$TR("ABCDEFGH","ADH","adh")
 S ^VCORR="aBCdEFGh" D ^VEXAMINE
 ;
17 S ^ABSN="30192",^ITEM="III-192  The 2 heading chars, 2 middle chars and tailing 2 chars are changed"
 S ^NEXT="18^V3TR07,V3TR08^V3TR,V3TEXT^VV3" D ^V3PRESET
 S ^VCOMP=$TR("ABCDAEFGBE","ABE","abe")
 S ^VCORR="abCDaeFGbe" D ^VEXAMINE
 ;
18 S ^ABSN="30193",^ITEM="III-193  The first, the middle and tailing substrings are changed"
 S ^NEXT="19^V3TR07,V3TR08^V3TR,V3TEXT^VV3" D ^V3PRESET
 S ^VCOMP=$TR("ABCCBADEFABCCBADEFFEDCBAABC","ABC","abc")
 S ^VCORR="abccbaDEFabccbaDEFFEDcbaabc" D ^VEXAMINE
 ;
19 S ^ABSN="30194",^ITEM="III-194  A middle and the tailing char are changed"
 S ^NEXT="20^V3TR07,V3TR08^V3TR,V3TEXT^VV3" D ^V3PRESET
 S ^VCOMP=$TR("ABCDEFGH","DHI","dhi")
 S ^VCORR="ABCdEFGh" D ^VEXAMINE
 ;
20 S ^ABSN="30195",^ITEM="III-195  2 middle chars and the tailing 2 chars are changed"
 S ^NEXT="V3TR08^V3TR,V3TEXT^VV3" D ^V3PRESET
 S ^VCOMP=$TR("ABCDABDE","CDE","cde")
 S ^VCORR="ABcdABde" D ^VEXAMINE
 ;
END W !!,"End of 13 --- V3TR07",!
 K  Q
 ;
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
