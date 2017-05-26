;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2016 Fidelity National Information		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
checkcorruptall
	set $ETRAP="set x=$zjobexam(),$ecode="""" halt"
	write $$^%PEEKBYNAME("sgmnt_data.file_corrupt","DEFAULT")
	write $$^%PEEKBYNAME("sgmnt_data.file_corrupt","AREG")
	write $$^%PEEKBYNAME("sgmnt_data.file_corrupt","BREG")
	write $$^%PEEKBYNAME("sgmnt_data.file_corrupt","CREG")
	write $$^%PEEKBYNAME("sgmnt_data.file_corrupt","DREG")
        quit
