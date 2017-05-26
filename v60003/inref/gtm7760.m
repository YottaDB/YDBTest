;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2013-2015 Fidelity National Information 	;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gtm7760	;
	; Attach a trigger to global ^x. Generate some stringpool churn to
	; make sure SET ^x=value protects 'value' from garbage collection.
	;
	set $etrap="do etr"
	if $ztrigger("item","-*")
	if $ztrigger("item","+^x(:) -command=set -xecute=""quit""")
	set n=1000
	set alpha="abcefghijklmnopqrstuvwxyz",alphalen=$l(alpha)
	for i=1:1:n set lcl(i)=$$string(i)
	for i=1:1:n set val=$$sink(i),val=lcl(i),^x=val do:^x'=val error
	write "All pass!",!
	quit

string(k)
	new %,j,s
	set s=""
	for j=1:1:k#200 set %=$r(alphalen)+1,s=s_$e(alpha,%,%)
	quit s

sink(k); errors out 50% of the time and cores out about 33% of the time
	set k=$random(999999999)
	quit k

error	;
	write "TEST-F-FAIL : ^x not equal to val ",i,!
	zwrite ^x
	zwrite val
	set file="localdmp.log" open file use file
	zwrite
	close file
	halt

etr	;
	write $zstatus,!
	zshow "S"
	quit
