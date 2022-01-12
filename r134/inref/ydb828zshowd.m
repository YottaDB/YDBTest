;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2022 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ydb828zshowd; Test that ZSHOW "D" on PIPE device does not SIG-11 if device parameters are specified multiple times
	;
	open "p":(command="pwd":stderr="":stderr="x")::"pipe" zshow "d"
	open "p":(command="pwd":command="x")::"pipe" zshow "d"
	open "p":(command="pwd":shell="/bin/sh":shell="/bin/sh")::"pipe" zshow "d"
	open "p":(command="pwd":shell="/bin/sh":shell="/bin/sh":stderr="x":stderr="y":command="x")::"pipe" zshow "d"
	quit
