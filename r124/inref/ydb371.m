;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                               ;
; Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.      ;
; All rights reserved.                                          ;
;                                                               ;
;       This source code contains the intellectual property     ;
;       of its copyright holder(s), and is made available       ;
;       under a license.  If you do not know the terms of       ;
;       the license, please stop and do not read further.       ;
;                                                               ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
	if $select(1:1,1:10*10*(10**45),1:3)  write "Hello "
	if $select(1:1,1:1E47,1:3)  write "Hello "
	if $select(1:1,($zchset="UTF-8"):$INVALIDISV,1:3)
	if $select(1:1,1:1/0,1:3)  write "Hello "
	if $select(0:1,($zchset="UTF-8"):$INVALIDISV,1:3)
	if $select(0:1,0:1E47,1:3)
	if $select(0:1E47,1:3)
	if $select(0:$INVALID,1:3)
	if $select(1:1,1:"1E47"&1)
        if $select(1:1,1:$char(65535))
	write 1!$$^echoAndRet("Hello",0)!$S($$^echoAndRet("World",0):5)
	write 1!'$s($$^true:5)
