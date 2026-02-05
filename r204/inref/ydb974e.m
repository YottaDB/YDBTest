;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; File for zroutines_wildcard-ydb974 to test that non-shared library files are not picked up by glob pattern.
START
	w "# Check that zroutines will not match a file that is not a shared library file.",!
	w "# We should have already created fakeLibraryFile.so for this. We will check fake*LibraryFile.so",!
	w "# If zroutines does try to match the fake library file, "
	w "that should cause an error, so if no error follows, all is well.",!
	set $zroutines="fake*LibraryFile.so $gtm_dist"
