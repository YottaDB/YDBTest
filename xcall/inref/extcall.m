extcall	; Test external calls from GT.M, Unix edition

	Set $ZTRAP="Goto pktst"

nopk	; First, outside of package.

	Write "Do &pk0pm0",!			Do &pk0pm0		; no package, no parameters
	Write "Do &pk0pm1(""one"")",!		Do &pk0pm1("one")	; no package, one parameter
	Write "Do &pk0pm2(1,""two"")",!		Do &pk0pm2(1,"two")	; no package, two parameters



pktst	; Same tests as above, except the external routines are in a named package.

	Set $ZTRAP="B"

	Write "Do &pk1pm0.pk",!				Do &pk1pm0.pk		; no package, no parameters
	Write "Do &pk1pm1.pk(""one"")",!		Do &pk1pm1.pk("one")	; no package, one parameter
	Write "Do &pk1pm2.pk(1,""two"")",!		Do &pk1pm2.pk(1,"two")	; no package, two parameters
