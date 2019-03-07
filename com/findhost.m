;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2004-2016 Fidelity National Information		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
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
	;;; findhost.m
	; 	-- If flag=1 then
	;		Return the host name from list of GG machines. Returns first 8 character of hostname
	;		If machine name is not below in list, it returns string "other"
	;	-- If flag=0
	;		Return first 8 characters of the host name
	;	-- If flag=2
	;		Return host name string
	;
findhost(flag)
	new hostn,fn,$ztrap,aixnov6
	set $ztrap="g HOSTERR"
	set hostn=$piece($ztrnlnm("HOST"),".",1)
	if flag=0 quit $extract(hostn,1,31)
	if flag=2 quit hostn
	set randhost=hostn
	if '+$ztrnlnm("test_no_ipv6_ver"),'+$ztrnlnm("gtm_ipv4_only"),'+$ztrnlnm("ydb_ipv4_only") do
	.  if flag=3 set randhost="127.0.0.1" quit
	.  if flag=4 set randhost="[::1]" quit
	.  if flag=5 set randhost="[::ffff:127.0.0.1]" quit
	.  if flag=6 set randhost="localhost" quit
	else  quit hostn
	quit randhost
	;
HOSTERR;
	use $P
	write "Cannot find the hostname."
	zshow "*"
	halt
