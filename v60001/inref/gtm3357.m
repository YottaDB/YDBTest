;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2012, 2015 Fidelity National Information	;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gtm3357	;
	; zmessage must not allow certain error conditions to be triggered
	;
	write "Making sure the following zmessages are disallowed",!
	set $ETRAP="do ^incretrap"
	new $estack,incretrap
	set incretrap("INTRA")="do handler^gtm3357(%MYSTAT)"
	; The error message returned when ZMESSAGE disallow an error condition
	set expect="SPCLZMSG"
	zmessage 150376098
	zmessage 150379522
	zmessage 150373738
	zmessage 150379522
	zmessage 150376098
	zmessage 150380274
	zmessage 150375330
	zmessage 150372515
	zmessage 150372507
	zmessage 150372498:2
	zmessage 150372507
	zmessage 150382874
	; An allowed message which is also caused by using ZMESSAGE
	set expect="CMD"
	write !,"Now an allowed error message",!
	zmessage 150372458
	write "Done Testing",!
	quit

handler(stat)
	write:(stat[expect) "Correctly generated: ",$piece($piece(stat,",",2,100),"-",3,100),!
	quit
