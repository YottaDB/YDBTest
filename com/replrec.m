replrec;
	; Use all kinds of replication currently supported
set;
	w "Start Set",!
	K ^acnfill
	S ^acnfill(1)="this is SET"
	TS
	S ^acnfill(2)="this is TSET"
	S ^acnfill(3)="this is USET"
	S ^acnfill(3,1)="this is USET"
	S ^acnfill(2,2)="this is USET"
	S ^acnfill(3,1,1)="this is USET"
	TC
	K ^acnfill(1)	; KILL
	TS
	K ^acnfill(2)	; TKILL
	K ^acnfill(3)	; UKILL
	K ^acnfill(3,1)	; UKILL
	TC
	S ^acnfill(4)="this is SET"
	TS
	S ^acnfill(5)="this is TSET"
	S ^acnfill(5,2)="this is USET"
	S ^acnfill(5,2,3)="this is USET"
	S ^acnfill(6)="this is USET"
	S ^acnfill(6,2)="this is USET"
	S ^acnfill(6,2,3)="this is USET"
	S ^acnfill(7)="this is USET"
	S ^acnfill(7,2)="this is USET"
	S ^acnfill(7,2,3)="this is USET"
	TC
	ZKILL ^acnfill(5)	; ZKILL
	TS
	ZKILL ^acnfill(6,2)	; TZKILL
	ZKILL ^acnfill(7)	; UZKILL
	ZKILL ^acnfill(7,2)	; UZKILL
	TC
	do ver
	q
ver;
	IF ^acnfill(4)'="this is SET" w "TEST-E-Verify Failed for ^acnfill(4)",!  h
	IF ^acnfill(5,2)='"this is USET" w "TEST-E-Verify Failed for ^acnfill(5,2)",!  h
	IF ^acnfill(5,2,3)='"this is USET" w "TEST-E-Verify Failed for ^acnfill(5,2,3)",!  h
	IF ^acnfill(6)='"this is USET" w "TEST-E-Verify Failed for ^acnfill(6)",!  h
	IF ^acnfill(6,2,3)'="this is USET" w "TEST-E-Verify Failed for ^acnfill(6,2,3)",!  h
	IF ^acnfill(7,2,3)'="this is USET" w "TEST-E-Verify Failed for ^acnfill(7,2,3)",!  h
	;
	K ^acnfill(4),^acnfill(5,2),^acnfill(5,2,3),^acnfill(6),^acnfill(6,2,3),^acnfill(7,2,3) 
	If $data(^acnfill) w "TEST-E-Verify Fail for ^acnfill",!
	Q
