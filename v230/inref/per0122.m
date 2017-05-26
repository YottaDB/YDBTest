;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2002-2015 Fidelity National Information 	;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
per0122	; ; ; per0122 - no flushing of the principal device I/O before zsystem
	;
	Write !,"this comes first"
	ZSYSTEM $Select($ZVersion["VMS":"write sys$output",1:"echo")_" ""this comes second"""
	Write !,"this is the end of the flush before ZSYSTEM test"
	Quit
