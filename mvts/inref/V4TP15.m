V4TP15 ;IW-KO-YS-TS,VV4TP,MVTS V9.10;15/7/96;PART-94 Transaction
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1994-1996
 ;
 W !!,"146---V4TP15: 1 Transaction tests  -5-"
 ;
 W !!,"TSTART without transparameters"
 W !,"   with a restart before TCOMMIT",!
 ;
1 S ^ABSN="40884",^ITEM="IV-884  TSTART lname  ... TRESTART ... TCOMMIT"
 S ^NEXT="2^V4TP15,V4TP16^VV4TP" D ^V4PRETP1
 JOB 1^V4TPE15::60 S WAIT=$T
 L  F  Q:$$^V4GETSM
 S ^VCORR="#1^VA^VB(1)VAVB(1)10/#1^VA^VB(1)VA11/#1^VA^va^VB(1)^vb(1)VAvavb(1)00/*11/#M^VA^va^VB(1)^vb(1)00/"
 D ^V4TPCHKM D ^V4GETCOM D ^VEXAMINE
 ;
2 S ^ABSN="40885",^ITEM="IV-885  TSTART (lname,lname)  ... TRESTART ... TCOMMIT"
 S ^NEXT="3^V4TP15,V4TP16^VV4TP" D ^V4PRETP1
 JOB 2^V4TPE15::60 S WAIT=$T
 L  F  Q:$$^V4GETSM
 S ^VCORR="#1^va^vb(1)vavb(1)10/#1^va^vb(1)vavb(1)VB(2)11/#1^va^va(1)^vb(1)^vb(2)^vc(1,2)^vd(2)vava(1)vb(1)VB(2)vb(2)vc(1,2)vd(2)00/*11/#M^va^va(1)^vb(1)^vb(2)^vc(1,2)^vd(2)00/"
 D ^V4TPCHKM D ^V4GETCOM D ^VEXAMINE
 ;
3 S ^ABSN="40886",^ITEM="IV-886  TSTART * ... TRESTART ... TCOMMIT"
 S ^NEXT="4^V4TP15,V4TP16^VV4TP" D ^V4PRETP1
 JOB 3^V4TPE15::60 S WAIT=$T
 L  F  Q:$$^V4GETSM
 S ^VCORR="#1^va^vb(1)vavb(1)10/#1^va^vb(1)vavb(1)11/#1^va^vb(1)vavb(1)12/#1^va^VA^vb(1)^VB(1)vaVAvb(1)VB(1)00/*11/#M^va^VA^vb(1)^VB(1)00/"
 D ^V4TPCHKM D ^V4GETCOM D ^VEXAMINE
 ;
4 S ^ABSN="40887",^ITEM="IV-887  TSTART ()  ... TRESTART ... TCOMMIT"
 S ^NEXT="V4TP16^VV4TP" D ^V4PRETP1
 JOB 4^V4TPE15::60 S WAIT=$T
 L  F  Q:$$^V4GETSM
 S ^VCORR="#1^VA(1)^VB(1,2)^VC(2)^VD(1,2)VA(1)VB(1,2)VC(2)VD(1,2)10/#1^VA(1)^VB(1,2)^VC(2)^VD(1,2)11/#1^VA(1)^va(1)^VB(1,2)^vb(2)^vc(1,2)^VC(2)^VD(1,2)^vd(2)va(1)vb(2)vc(1,2)vd(2)00/*11/#M^VA(1)^va(1)^VB(1,2)^vb(2)^vc(1,2)^VC(2)^VD(1,2)^vd(2)00/"
 D ^V4TPCHKM D ^V4GETCOM D ^VEXAMINE
 ;
END W !!,"End of 146 --- V4TP15",!
 Q
 ;
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
