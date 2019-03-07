;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright 2014 Fidelity Information Services, Inc		;
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
; This test routine exists to excersize MUMPS language features that require
; $gtm_dist. It is not directly callable. Each routine label was written with
; the expectation that it would be driven via the call-in interface.
;
; The call-in interface cannot do as robust of a validation of $gtm_dist as
; regular GT.M executables. Each label below exists to invoke a feature that
; requires $gtm_dist.
gtm7926callins
	quit

; The JOB command use $gtm_dist under the hood
job
	set $ETRAP="zwrite $zstatus halt"
	set dist=$ztrnlnm("gtm_dist")
	set out="jobcmd"_$select($length(dist)=0:"undef",dist="/no/such/path":"nosuchpath",1:"")_".out"
	set cmd="^%XCMD:(cmdline=""write $zversion"":output="""_out_""":error="""_out_""")"
	job @(cmd)
	quit

; Attempting to SET a global in a read-only database will make MUMPS call out
; to $gtm_dist/gtmsecshr
secshr
	set $ETRAP="zwrite $zstatus halt"
	set ^a=1
	quit

; The PARSE pipe device parameter causes MUMPS to search $gtm_dist for commands
; that do not use absolute paths.
iopi
	set $ETRAP="zwrite $zstatus halt"
	set pipe="pipe"
	open pipe:(shell="/usr/local/bin/tcsh":command="id -un | sed 's/'$user'/other/g'":parse)::"PIPE"
	use pipe
	read euid
	close pipe
	use $p
	write euid,!
	quit

