;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2015 Fidelity National Information 		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; A helper program for the gv_altkey_corruption test to attempt to induce
; gv_altkey corruption that leads to bad $zprevious() results.
gvaltkeyverif
 set (^x(2,3),^x(2,4),^x(2,5),^x(2,6),^x(2,7))="whatever"
 ; do a search in the middle of REG2
 write $zprevious(^x(2,4)),!
 ; cause an index block split, so that gv_altkey is changed
 for i=1:1:43 set ^a(i)="hey there"_$justify("abc",400)
 ; do a search in the top half of REG2, which should invoke gvcst_search_tail()
 set x=$zprevious(^x(2,6))
 write x,!
 for i=1:1:10 set x=$zprevious(^x(2,x)) write x,!
 quit
