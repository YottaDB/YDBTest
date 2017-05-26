d001624	; ; ; test tn crossing the signed boundary
	;
	New (act)
	If '$Data(act) New act Set act="W !,$ZS,!"
	Set cnt=0
	Kill ^a
	For i=1:1:250 Set ^a(i_$j(i,40))=$j(i,200)
	Set sd="d001624.com"
	Open sd:NEWVERSION
	Use sd
	If $ZVersion'["VMS" Do
	. Write "$gtm_dist/dse << zxy",!
	. Write "change -fileheader -current_tn=7FFFFFFF",!
	. Write "zxy",!
	. Close sd
	. ZSYStem "source "_sd
	Else  Do
	. Write "$ DSE",!
	. Write "CHANGE /FILEHEADER /CURRENT_TN=7FFFFFFF",!
	. Write "$ EXIT",!
	. Close sd
	. ZSYStem "@"_sd
	New $ZTrap
	Set $ZTrap="S $ZT="""",cnt=cnt+1 X act G exit"
	For i=i:1:500 Set ^a(i_$j(i,40))=$j(i,200)
exit	Open sd
	;Close sd:delete
	Close sd
	Write !,$Select(cnt:"FAIL",1:"PASS")," from ",$Text(+0)
	Quit
