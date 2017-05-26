mrgstp;
tpc1;
	SET $ZT="g ERROR^mrgstp"
        TSTART ():serial
	do in2^npfill("set",1,1)
	MERGE ^newvar("^arandomfilling")=^arandomfilling
	MERGE newvar("^brandomfilling")=^brandomfilling
	do in2^npfill("ver",1,1)
        TCOMMIT
	do in2^npfill("ver",1,1)
	K ^arandomfilling,^brandomfilling
	MERGE ^arandomfilling=^newvar("^arandomfilling"),^brandomfilling=newvar("^brandomfilling")
	K ^newvar
	do in2^npfill("ver",1,1)
	K ^arandomfilling,^brandomfilling
	W "1:PASS from TP MERGE with TCOMMIT",!
	;
tpr1;
	K
	SET $ZT="g ERROR^mrgstp"
        TSTART ():serial
	do in2^npfill("set",1,1)
	MERGE ^newvar("^arandomfilling")=^arandomfilling
	MERGE newvar("^brandomfilling")=^brandomfilling
	do in2^npfill("ver",1,1)
        TROLLBACK
	W "Nothing should be in ^newvar",!
	W "$DATA(^newvar)=",$data(^newvar),!
	do ^examine($data(^newvar),"0"," ^newvar")
	W "Something should be in newvar",!
	W "$DATA(newvar)=",$data(newvar),!
	do ^examine($data(newvar),"10"," newvar")
	W "2:PASS from TP MERGE with TROLLBAK",!
	;
tpc2;
	K
	SET $ZT="g ERROR^mrgstp"
        TSTART ():serial
	do in2^npfill("set",1,1)
	f i=1:1:5  MERGE ^newvar("^arandomfilling"_i)=^arandomfilling
	f i=1:1:5  MERGE newvar("^brandomfilling"_i)=^brandomfilling
	do in2^npfill("ver",1,1)
        TCOMMIT
	do in2^npfill("ver",1,1)
	K ^arandomfilling,^brandomfilling
	f i=1:1:5  MERGE ^arandomfilling=^newvar("^arandomfilling"_i)
	f i=1:1:5  MERGE ^brandomfilling=newvar("^brandomfilling"_i)
	K ^newvar
	do in2^npfill("ver",1,1)
	K ^arandomfilling,^brandomfilling
	W "3:PASS from TP MERGE with TCOMMIT",!
	Q
	;
	;
ERROR   ;	
	SET $ZT=""
        ZSHOW "*"
        ZM +$ZS
        IF $TLEVEL TROLLBACK
	Q
