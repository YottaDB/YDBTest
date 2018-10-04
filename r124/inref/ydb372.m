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
	set (x,@y(1E47))=1
	set (x,@^y(1E47))=1
        set ($iv,@y(1E47))=1
	set ($iv,@^y(1E47))=1
        set ($iv,@g($iz))=1
	set ($iv,@^g($iz))=1
        set ($iv,@y(2))=1
	set ($iv,@^y(2))=1
        set ($x,@y(2))=1
	set ($x,@^y(2))=1
        set ($x,$iv,@y(2))=1
	set ($x,$iv,@^y(2))=1
        set y(2)="x" set ($x,$iv,@y(2))=1
	set ^y(2)="x" set ($x,$iv,@^y(2))=1
	kill z set (z,$p(x,"|",1E48))=(1!$s($$^true&0:"","1E47":"ok",1:1)) zwrite z
        kill z set (z,$iv)=(1!$s($$^true&0:"","1E47":"ok",1:1)) zwrite z
