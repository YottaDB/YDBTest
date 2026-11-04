;#################################################################
;#								#
;# Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	#
;# All rights reserved.						#
;#								#
;#	This source code contains the intellectual property	#
;#	of its copyright holder(s), and is made available	#
;#	under a license.  If you do not know the terms of	#
;#	the license, please stop and do not read further.	#
;#								#
;#################################################################
ydb1367	; $ZTRIGGER("ITEM") with a line that does not start with + or -, then a SET of a global, 3 times [YDB#1367]
	for i=1:1:3 set x=$ztrigger("item","x") set ^b(i)=i write "$reference=",$reference,!
	quit
