;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2020 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;This tests for the new optional fourth parameter in PEEKBYNAME
;to where the directory of gtmhelp.gld and gtmhelp.dat reside.
;Previous versions did not accept a fourth parameter.

;Using PEEKBYNAME without a fourth parameter
	write "# Testing ^%PEEKBYNAME with just three parameters",!
	write $$^%PEEKBYNAME("gd_region.max_key_size","DEFAULT",""),!

;Using PEEKBYNAME with a fourth parameter
	write "# Testing ^%PEEKBYNAME with the fourth parameter",!
	write "# and using the global directory with a max_key_size of 64",!
	set gdir=$ztrnlnm("ydb_dist")
	write $$^%PEEKBYNAME("gd_region.max_key_size","DEFAULT","",gdir),!

;Using PEEKBYNAME with a fourth parameter and using the local gld
        write "# Testing ^%PEEKBYNAME with the optional fourth parameter",!
        write "# and using the local directory with a max_key_size of 22.",!
	write "# the local directory has to include gtmhelp instead of",!
	write "# ydbhelp since it is hard coded in. Since the local gtmhelp",!
	write "# has not been populated an error occurs",!
	set gdir=$ztrnlnm("tst_working_dir")
        write $$^%PEEKBYNAME("gd_region.max_key_size","DEFAULT","",gdir),!


