;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								 ;
;	Copyright 2010, 2013 Fidelity Information Services, Inc. ;
;								 ;
;	This source code contains the intellectual property	 ;
;	of its copyright holder(s), and is made available	 ;
;	under a license.  If you do not know the terms of	 ;
;	the license, please stop and do not read further.	 ;
;								 ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Note this is an early version of this routine resident in the gtmpcat test because gtmpcat runs against all
; production versions >= V51000. Many of the earlier versions did not have have this routine in $gtm_dist so
; we use it here. Note cannot be put in $gtm_test/T*/com ahead of $gtm_dist which would prevent the REAL 
; version of this routine from being usable in the test system for all tests.
;
%XCMD	; utility to execute a shell command and return a non-zero status on error
	;
	set $ztrap=""
	xecute $zcmdline
	quit
