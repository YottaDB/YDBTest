;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;  Multi-region test with simplistic pseudo-bank thing - Build database
;
;	Global ACCT holds account balance.
;	Global JNL hold delta (transaction) amounts in history
;	Global ACNM hold name on account
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

mrtstbld	;

	; If new database, populate with accounts
	
	Set acntcnt=5000
	SET multibytestr=$$^getunitemplate()
	Set alphas="ABCDEFGHIJKLMNOPQRSTUVWXYZ"_multibytestr_"abcdefghijklmnopqrstuvwxyz";
	set alphaslen=$length(alphas)

	If $Get(^ACCT(0))="" Do
	. ; Write $ZDate($Horolog,"24:60:SS")," Initializing database",! 
	. Write " Initializing database",!
	. For acct=1:1:acntcnt Do	; Create some accounts
	. . ; Generate a random "name" for the account
	. . Set name=""
	. . For j=1:1:$Random(15)+1 Do 	; Fifteen or few characters
	. . . Set ranchar=$Random(alphaslen)+1
	. . . Set name=name_$Extract(alphas,ranchar,ranchar)
	. . 
	. . ; Generate a random "balance" for the account
	. . Set balance=$Random(1000000)
	. . TStart ()
	. . Set ^ACCT(acct)=balance
	. . Set ^ACCT(acct,0)=balance	; Opening balance
	. . Set ^ACNM(acct)=name
	. . Set ^JNL(acct,0)=0
	. . TCommit
	. . If acct#10000=0 Write ".. processed ",acct," accounts..",!
	. Set ^ACCT(0)=acntcnt
	. ; Write $ZDate($Horolog,"24:60:SS")," Initialization complete",!
	. Write " Initialization complete",!
	Else  Write "Database is already initialized -- Nothing done",!

	Quit
