;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2025-2026 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

storage ;
	new rlimit,rlimitfile,testnum
	for i=1:1:2  do
	. set:i=1 $ZMALLOCLIM=0
	. set:i=2 $ZMALLOCLIM=5000000
	. write "### Test "_i_": Check $STORAGE when:",!
	. write "# $ZMALLOCLIM="_$ZMALLOCLIM,!
	. write "# $ZREALSTOR="_$ZREALSTOR,!
	. if $ZMALLOCLIM'=0  do
	. . write "## Confirm $STORAGE=($ZMALLOCLIM-$ZREALSTOR), i.e. ""$ZMALLOCLIM if it has a non-zero value"" minus $ZREALSTOR:",!
	. . if ($STORAGE=($ZMALLOCLIM-$ZREALSTOR))  do
	. . . write "PASS: $STORAGE="""_$STORAGE_"""=($ZMALLOCLIM-$ZREALSTOR)=("_$ZMALLOCLIM_"-"_$ZREALSTOR_")",!
	. . else  do
	. . . write "FAIL: $STORAGE="""_$STORAGE_""", but ($ZMALLOCLIM-$ZREALSTOR)=("_$ZMALLOCLIM_"-"_$ZREALSTOR_")="_($ZMALLOCLIM-$ZREALSTOR),!
	. else  do
	. . write "## Confirm $STORAGE=((2**31)-$ZREALSTOR-1), i.e. ""the maximum of a 32-bit address space"" minus $ZREALSTOR:",!
	. . if ($STORAGE=((2**31)-$ZREALSTOR-1))  do
	. . . write "PASS: $STORAGE="""_$STORAGE_"""=((2**31)-$ZREALSTOR-1)=("_(2**31)_"-"_$ZREALSTOR_"-1"_")",!
	. . else  do
	. . . write "FAIL: $STORAGE="""_$STORAGE_""", but ((2**31)-$ZREALSTOR-1)="_((2**31)-$ZREALSTOR-1)_")",!
	. write !

	quit
