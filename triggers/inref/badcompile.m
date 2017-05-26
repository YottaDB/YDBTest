;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2010-2016 Fidelity National Information		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
badcompile
	set $ETrap="w $c(9),""$ZSTATUS="",$zstatus,! s $ecode="""""
	set ztname=$ZTName,$piece(ztname,"#",$length(ztname,"#"))=""  ; nullify region disambigurator
	set x=$increment(^fired(ztname))
	badcommand
	quit

