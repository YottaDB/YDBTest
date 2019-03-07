;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
gtm8926	;
	set ^A="Value"
	set ^Ac=0
	set ^Ad=0
	set ^Ae=0
	set ^An=0
	do ^job("exter^gtm8926",2,"""""")
	zwrite ^A
	quit

exter	;
	if jobindex=1  do
	.	set ^A($increment(^An))="1: In gtm8926.m: job 1"
	.	set ^A($increment(^An))="1: Calling gtm8926.c"
	.	set ^X="True"
	.	do &callout()
	if jobindex=2  do
	.	for  quit:$get(^Ar)="Ready"  Hang 0.1
	.	; verify flush hasn't happened
	.	; if flush didn't happen  set ^A="True"
	.	set ^A($increment(^An))="2: In gtm8926.m: job 2"
	.	set ^A($increment(^An))="2: Hanging in intervals of 1 second, peeking the value of Disk Writes to see if it has changed"
	.	for  quit:^Ac>0  Do
	.	.	Hang 1
	.	.	set ^Ad=$$FUNC^%HD($$^%PEEKBYNAME("sgmnt_data.gvstats_rec.n_dsk_write","DEFAULT"))
	.	.	if ^Ad>0  set ^Ac=1
	.	.	if $increment(^Ae)>5  set ^Ac=1
	.	if ^Ad=0  set ^A="True"  set ^A($increment(^An))="2: After 5 intervals, No Flush has occured"
	.	else  set ^A="False"  set ^A($increment(^An))="2: A Flush has occured"
