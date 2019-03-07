;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2017,2018 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
signals()
	; special extrinsic variable to return value of SIGUSR1 signal associated with current platform
	; example from gtm: set ^signum=$$^signals
	; This routine will be nixed when $ZSIGPROC() is updated to accept signal names as an argument.
	if $ZVersion["x86" do
	. if $ZVersion["CYGWIN" set platform="x86cygwin"
	. else  if $ZVersion["64" set platform="x8664"
	. else  set platform="x86"
	else  if $ZVersion["AIX" set platform="aix"
	else  if $ZVersion["OSF1" set platform="osf"
	else  if $ZVersion["Solaris" set platform="solaris"
	else  if $ZVersion["HP-PA" set platform="hppa"
	else  if $ZVersion["IA64" do
	. if $ZVersion["HP-UX" set platform="hpuxia64"
	. else  set platform="linuxia64"
	else  If $ZVersion["S390" do
	. if $ZVersion["Linux" set platform="linuxs390"
	. else  set platform="s390"
	else  if $ZVersion["armv7l" set platform="armvxl"
	else  if $ZVersion["armv6l" set platform="armvxl"
	else  if $ZVersion["aarch64" set platform="aarch64"
	else  set platform="default"
	quit $PIECE($TEXT(@platform+1),"#",2)

	; for each platform enter signum as shown below

x86	;x86 which is not CYGWIN
	;signum #10

x8664	;x86_64
	;signum #10

x86cygwin	;x86 which is CYGWIN
	;signum #30

aix	;an AIX
	;signum #30

osf	;OSF1
	;signum #30

solaris	;Solaris
	;signum #16

hppa	;HP-PA
	;signum #16

hpuxia64	;IA64 and UP-UX
	;signum #16

linuxia64	;IA64 and Linux
	;signum #10

s390	;S390 and not Linux
	;signum #16

linuxs390	;S390 and Linux
	;signum #10

armvxl	;ARMV7L or ARMV6L
	;signum #10

aarch64	;AARCH64
	;signum #10

default	;default platform
	;signum #16
