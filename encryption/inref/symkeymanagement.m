;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2014 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; A helper script employed in the encryption/sym_key_management
; test. It returns the randomly select operation for the driver
; script to attempt based on the scenario carried out.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

pickOperation1
pickOperation3
pickOperation4
pickOperation5
	new case
	set case=$random(3)
	write $select(0=case:"mupip_create",1=case:"db",1:"device")
	quit

pickOperation2
	new case
	set case=$random(2)
	write $select(0=case:"db",1:"device")
	quit
