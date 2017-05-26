;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2014 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gtm8075	;
	;
	; Test that extfilterinflate.m/extfilterdeflate.m do not inflate/deflate
	; in case value part of the SET is not easily identifiable and does not start with a double-quote"
	set delim="="""
	set ^x(delim)="abcd"
	set ^x(delim,delim)="abcd"
	set ^x(delim)=$c(0,1)
	set ^x(delim,delim)=$c(0,1,2)
	;
	; Generate a transaction with 25,000 updates. Each of them will be transformed by the external filter
	; (chosen by the parent script gtm8075.csh) to around a 1000 byte string. For a total of 25Mb of external
	; filter data. We want to make sure this goes through source server and receiver server internal buffers
	; without issues
	tstart ():serial
	for i=1:1:25000 set ^x=i
	tcommit
	quit
