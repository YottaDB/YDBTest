;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2013-2016 Fidelity National Information		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
mylabel ; This is a comment
	write $TEXT(+12),!
	write $TEXT(mylabel+1),!
	write $TEXT(mylabel+0),!
	write $TEXT(mylabel+1024),!
	write $TEXT(mylabel2),!
	set A="mylabel2"
	write $TEXT(@A),!
	write $TEXT(mylabel+1234),!
	write $TEXT(mylabel+-12),!
	write $TEXT(mylabel2+-4),!
	write $TEXT(mylabel3+1),!
	set $ZPIECE(res,1)=$TEXT(+0)
	write res,!
mylabel2 ;	This is a second label with a comment
mylabel3 ; This comment comes after the previous, so we don't just end
