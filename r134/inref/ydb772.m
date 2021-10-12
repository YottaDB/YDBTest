;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2021 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ydb772	; test $$SRCDIR^%RSEL
	new %ZR,io,line,out,ydbrou,zro,absdir
	set io=$io
	;
	; Note: Removing this line as it varies a lot due to test system randomization
	; write "# $zroutines set by the test system: "_$zroutines,!
	;
	write "# Test SILENT^%RSEL, looking for %RSEL",!
	do SILENT^%RSEL("^%RSEL")  ; get source directory for %RSEL
	if '$data(%ZR("%RSEL")) write "FAIL - No directory for %RSEL",! quit
	write "%RSEL found in "_%ZR("%RSEL"),!!
	;
	write "# Various tests for SRCDIR^%RSEL",!
	zsystem "mkdir -p objdir srcdir1 srcdir2 srcdir.so o abc.so r/def.so ghi.so p q/r q/s t sodir.so also"
	for ydbrou="objdir(srcdir.so)","objdir(srcdir1 srcdir.so)","objdir(srcdir1 srcdir.so srcdir2)","objdir(srcdir.so srcdir2)","o(abc.so r/def.so ghi.so) p q(q/r q/s) t* sodir.so","also" do
	. for absdir=0,1 do
	.. set zro=""
	.. set zro=$select(absdir:$zparse($zdir),1:"")
	.. set zro=zro_ydbrou_" $ydb_dist/"_$select("UTF-8"=$zchset:"utf8/",1:"")_"libyottadbutil.so"
	.. write "# Test $$SRCDIR^%RSEL with "_zro,!
	.. open "pipe":(shell="/bin/sh":command="ydb_routines="""_zro_""" $ydb_dist/yottadb -run %XCMD 'write $$SRCDIR^%RSEL',!":readonly)::"pipe"
	.. use "pipe" read line use io close "pipe"
	.. write "$$SRCDIR^%RSEL returns "_line,!
	.. write !
	quit
