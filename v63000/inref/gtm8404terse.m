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
	write "mylabel ; This is a comment",!
	write " write $TEXT(+12),!",!
	write "mylabel ; This is a comment",!
        write "",!
	write "mylabel2 ;"_$CHAR(9)_"This is a second label with a comment",!
	set A="mylabel2"
	write $TEXT(@A),!
	write "",!
	write "gtm8404verbose",!
	write " write $TEXT(mylabel2+-4),!",!
	write "",!
	set $ZPIECE(res,1)="gtm8404verbose"
	write res,!
mylabel2 ;	This is a second label with a comment
mylabel3 ; This comment comes after the previous, so we don't just end
