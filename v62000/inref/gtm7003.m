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
gtm7003	;	do transfers of different flavors to non-existant labels
	;
zgotolab
	zgoto $zlevel:nozgolabel	;zgoto resolves labels at run-time, so it always gives LABELMISSING errors
	quit
gotolab	goto nogolabel
	quit
dolab	do nodolabel
	quit
exfunlab
	if $$noexfunlabel
	quit
extexfunlab
	if $$noexfunlabel^gtm7003
	quit
autozllab
	do nolabel^gtm7003a
	quit
	;
breaklab
	break
eor	quit
