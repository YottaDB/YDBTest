;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2015 Fidelity National Information 		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
zutcheck(systemtime)
	set now=$zut/1E6
	set maxdelay=10
	set diff=now-systemtime
	if (diff>=maxdelay)!(diff<0) write "TEST-E-FAIL $ZUT is different than system time systemtime="_systemtime_" $ZUT="_now,! halt
	quit

; This works in UTC only because of daylight saving time issues
zhorologcheck(systemtime)
	set nowzh=$zhorolog
	set maxdelay=10
	set mepochdays=$piece(nowzh,",",1)
	set mepochseconds=$piece(nowzh,",",2)
	set ms=$piece(nowzh,",",3)
	set zone=$piece(nowzh,",",4)
	; Verify all fields of $zhorolog are numbers
	for i="mepochdays","mepochseconds","ms","zone" if @i'=+(@i) write "TEST-E-FAIL "_i_" field has a non-integer value "_@i,! halt
	set unixtimestamp=$$hor2unix(mepochdays,mepochseconds)
	set diff=unixtimestamp-systemtime
	if (diff>=maxdelay)!(diff<0) write "TEST-E-FAIL $zhorolog is different than system time systemtime="_systemtime_" unixtimestamp="_unixtimestamp,! halt
	if ((ms>=1000000)&(ms<0)) write "TEST-E-FAIL The microsecond field is out of range ms="_ms,! halt
	write:0'=zone "TEST-E-FAIL time zone filed is incorrect",!
	quit

; Converts horolog to unix timestamp
hor2unix(mepochdays,mepochseconds)
	; 86400 seconds in a day
	; 47117 days difference between the unix epoch and mumps epoch
	quit (mepochdays-47117)*86400+mepochseconds

comparehorologs(h1,h2)
	set maxdelay=10
	set diff=$$hor2unix($piece(h2,",",1),$piece(h2,",",2))-$$hor2unix($piece(h1,",",1),$piece(h1,",",2))
	if (diff>=maxdelay)!(diff<0) write "TEST-E-FAIL $horolog is different between the two versions: h1="_h1_" h2="_h2,! halt
	quit
