;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;  Multi-region verify of the pseudo-bank database
;
;	Global ACCT holds account balance.
;	Global JNL hold delta (transaction) amounts in history
;	Global ACNM hold name on account
;
;	For each "account", apply the accumulated journal records to the
;       opening balance and see if we end up with the current balance.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

mrverify	;
	Write " PBank verify started",!
	Set $ZTrap="goto ERROR"
	Set accnts=^ACCT(0)
	For acct=1:1:accnts Do
	. Set cbalance=^ACCT(acct,0)	;opening balance
	. Set jnlrecs=^JNL(acct,0)
	. For i=1:1:jnlrecs Do 
	. . Set cbalance=cbalance+^JNL(acct,i)
	. If cbalance'=^ACCT(acct) Write "*** Error: Acct ",acct," expected balance ",^ACCT(0)," got ",cbalance,!
	.  If acct#10000=0 Write ".. processed ",acct," accounts..",!
	Write " PBank verify ended",! 
	Quit

ERROR	Set $ZTrap=""
	ZShow "*"
	ZM +$ZS
