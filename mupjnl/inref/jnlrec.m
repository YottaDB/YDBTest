jnlrec;
	s unix=$zv'["VMS"
	K ^acn
	h 1
	if unix zsy "date +""%d-%b-%Y %H:%M:%S"" > time1.txt"
	else  zsy "pipe show time > time1.txt"
	h 1
	w "SET,TSET,USET,GSET,FSET",!
	S ^acn(1)="this is SET"
	TS
	S ^acn(2)="this is TSET"
	S ^acn(3)="this is USET"
	S ^acn(3,1)="this is USET"
	if unix zsy "date +""%d-%b-%Y %H:%M:%S"" > time2.txt"
	else  zsy "pipe show time > time2.txt"
	TC
	ZTS
	S ^acn(5)="this is FSET"
	S ^acn(6)="this is GSET"
	S ^acn(6,1)="this is GSET"
	if unix zsy "date +""%d-%b-%Y %H:%M:%S"" > time3.txt"
	else  zsy "pipe show time > time3.txt"
	ZTC
	;
	w "KILL,TKILL,UKILL,GKILL,FKILL",!
	K ^acn(1)
	TS
	K ^acn(2)
	K ^acn(3)
	K ^acn(3,1)
	TC
	ZTS
	K ^acn(5)
	K ^acn(6)
	K ^acn(6,1)
	ZTC
	if $data(^acn)=0 w "Passed SET and KILL",!
	;
	w "SET,TSET,USET,GSET,FSET",!
	S ^acn(10)="this is SET"
	TS
	S ^acn(11)="this is TSET"
	S ^acn(11,11)="this is USET"
	S ^acn(12)="this is USET"
	S ^acn(12,12)="this is USET"
	TC
	ZTS
	S ^acn(13)="this is FSET"
	S ^acn(13,13)="this is GSET"
	S ^acn(14)="this is GSET"
	S ^acn(14,14)="this is GSET"
	if unix zsy "date +""%d-%b-%Y %H:%M:%S"" > time4.txt"
	else  zsy "pipe show time > time4.txt"
	ZTC
	;
	w "ZKILL,TZKILL,UZKILL,GZKILL,FZKILL",!
	ZKILL ^acn(10)
	TS
	ZKILL ^acn(11)
	ZKILL ^acn(12)
	TC
	ZTS
	ZKILL ^acn(13)
	ZKILL ^acn(14)
	if unix zsy "date +""%d-%b-%Y %H:%M:%S"" > time5.txt"
	else  zsy "pipe show time > time5.txt"
	ZTC
	zts
	s ^acn(15)="this is in broken file"
	s ^acn(16)="this is in broken file"
	;ztc
	W "Check that only ^acn(11,11),^acn(12,12),^acn(13,13),^acn(14,14) are present",!
	ZWR ^acn
	q
