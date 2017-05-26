lockwake;	Test if children do wake up properly

	Set unix=$ZVersion'["VMS"
	w "Starting lockwake.m",!

	L +^TEST
	For I=1:1:3 Do
	. S ^child(I)="false"
	. If unix J @("S"_I_"^lockwake:(output=""lockwake.mjo"_I_""":error=""lockwake.mje"_I_""")")
	. Else    J @("S"_I_"^LOCKWAKE:(NODETACHED:STARTUP=""STARTUP.COM"":OUTPUT=""LOCKWAKE.MJO"_I_""":ERROR=""LOCKWAKE.MJE"_I_""")")
	. H 1
	f i=1:1:3 Do	; wait for the children to actually start
	. f j=1:1:100 Do  Q:^child(i)="true"
	. . h 1
        L -^TEST        ; All job starts at the same time
        h 0             ; Wake the jobs waiting for lock
	f i=1:1:120  L ^TEST:0 Q:'$T  L -^TEST H 1
	if i=120 w "children did not wake up! Was not able to test",!
	for i=1:1:100 Do
	. h 1
	L ^TEST
	w "End lockwake.m",!
	Quit

S1	;
	set ^child(1)="true"
	L +^TEST(1)
	for i=1:1:10 Do
	. h 1
	w "S1 DONE",!
	Quit

S2	;
	set ^child(2)="true"
	L +^TEST(2)
	for i=1:1:10 Do
	. h 1
	w "S2 DONE",!
	Quit

S3	;
	set ^child(3)="true"
	L +^TEST(3)
	for i=1:1:10 Do
	. h 1
	w "S3 DONE",!
	Quit
