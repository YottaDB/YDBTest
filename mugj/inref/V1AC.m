V1AC	;$ASCII AND $CHAR FUNCTIONS DRIVER;YS-TS,V1AC,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1978
	new xstr,unix
	set unix=$ZVersion'["VMS"
	if unix do
	.	set xstr="view ""NOBADCHAR""" ; switch off default BADCHAR behavior 
	.	xecute xstr
V1AC1	W !!,"V1AC1" D ^V1AC1
V1AC2	W !!,"V1AC2" D ^V1AC2
	Q
