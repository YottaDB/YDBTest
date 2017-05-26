V1WR ;IW-YS-TS,VV1,MVTS V9.10;15/6/96;WRITE ALL CHARACTERS
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1978-1996
 W !!,"1---V1WR: Write all characters",!
 ;
 I $D(^VENVIRON("INPUT USE"))=1 U ^VENVIRON("INPUT USE")
 W !,"This routine (1---V1WR) contains 4 tests to be checked by OPERATOR."
REP W !!,"When you are ready, press ""Y/y"" and a <CR> : " S Y="Y"
 IF Y="Y" GOTO REP1
 IF Y="y" GOTO REP1
 GOTO REP
REP1 I $D(^VENVIRON("OUTPUT USE"))=1 U ^VENVIRON("OUTPUT USE")
 ;
802 W !,"I-802  Output of alphabetics"
 W !!,"I-802.1  Output of upper-case alphabetics (by OPERATOR)"
 W !,"         Following two lines should be identical:"
 S ^ABSN="10001",^ITEM="I-802.1  Output of upper-case alphabetics (by OPERATOR)",^NEXT="8022^V1WR,V1CMT^VV1" D ^V1PRESET
 WRITE !,"ABCDEFGHIJKLMNOPQRSTUVWXYZ"
 W !,"A","B","C","D","E","F","G","H","I","J","K","L","M"
 W "N","O","P","Q","R","S","T","U","V","W","X","Y","Z"
 D MANPF1^VEXAMINE I $D(RES)=1 I RES="AGAIN" G 802
 ;
8022 W !!,"I-802.2  Output of lower-case alphabetics (by OPERATOR)"
 W !,"         Following two lines should be identical:"
 S ^ABSN="10002",^ITEM="I-802.2  Output of lower-case alphabetics (by OPERATOR)",^NEXT="803^V1WR,V1CMT^VV1" D ^V1PRESET
 WRITE !,"abcdefghijklmnopqrstuvwxyz"
 W !,"a","b","c","d","e","f","g","h","i","j","k","l","m"
 W "n","o","p","q","r","s","t","u","v","w","x","y","z"
 D MANPF1^VEXAMINE I $D(RES)=1 I RES="AGAIN" G 8022
 ;
803 W !!,"I-803  Output of digits (by OPERATOR)"
 W !,"       Following two lines should be identical:"
 S ^ABSN="10003",^ITEM="I-803  Output of digits (by OPERATOR)",^NEXT="804^V1WR,V1CMT^VV1" D ^V1PRESET
 WRITE !,"1234567890"
 W !,"1","2","3","4","5","6","7","8","9","0"
 D MANPF1^VEXAMINE I $D(RES)=1 I RES="AGAIN" G 803
 ;
804 W !!,"I-804  Output of punctuation characters (by OPERATOR)"
 W !,"       Following two lines should be identical:"
 S ^ABSN="10004",^ITEM="I-804  Output of punctuation characters (by OPERATOR)",^NEXT="V1CMT^VV1" D ^V1PRESET
 WRITE !," !""#$%&'()+,-./:;<=>?@[\]^_`{|}~"
 W !," ","!","""","#","$","%","&","'","(",")","+",",","-",".","/",":",";"
 W "<","=",">","?","@","[","\","]","^","_","`","{","|","}","~"
 D MANPF1^VEXAMINE I $D(RES)=1 I RES="AGAIN" G 804
 ;
END W !!,"End of 1---V1WR",!
 Q
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
