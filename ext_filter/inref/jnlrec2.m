jnlrec;
	K ^acn
	w "SET,TSET,USET",!
	S ^acn(1)="this is SET"
	TS
	S ^acn(2)="this is TSET"
	S ^acn(3)="this is USET"
	S ^acn(3,1)="this is USET"
	TC
	TS
	S ^acn(5)="this is TSET"
	S ^acn(6)="this is USET"
	S ^acn(6,1)="this is USET"
	TC
	;
	w "KILL,TKILL,UKILL",!
	K ^acn(1)
	TS
	K ^acn(2)
	K ^acn(3)
	K ^acn(3,1)
	TC
	TS
	K ^acn(5)
	K ^acn(6)
	K ^acn(6,1)
	TC
	if $data(^acn)=0 w "Passed SET and KILL",!
	h 2
	;
	w "SET,TSET,USET",!
	S ^acn(10)="this is SET"
	TS
	S ^acn(11)="this is TSET"
	S ^acn(11,11)="this is USET"
	S ^acn(12)="this is USET"
	S ^acn(12,12)="this is USET"
	TC
	TS
	S ^acn(13)="this is TSET"
	S ^acn(13,13)="this is USET"
	S ^acn(14)="this is USET"
	S ^acn(14,14)="this is USET"
	TC
	;
	w "ZKILL,TZKILL,UZKILL",!
	ZKILL ^acn(10)
	TS
	ZKILL ^acn(11)
	ZKILL ^acn(12)
	TC
	TS
	ZKILL ^acn(13)
	ZKILL ^acn(14)
	TC
	W "Check that only ^acn(11,11),^acn(12,12),^acn(13,13),^acn(14,14) are present",!
	ZWR ^acn
	q
