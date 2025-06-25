;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2025 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ydbMR1702 ;
	write "## See commit message of YDB@1df7180b0 for test case details",!
	set x=$ztrigger("item","-*")
	write "# Add a trigger named a1"
	set x=$ztrigger("item","+^a(1) -commands=S -xecute=""w 123"" -name=a1")
	write "# Attempt to add another trigger named a1. Expect a [trigger named a1 already exists] error."
	set x=$ztrigger("item","+^a(2) -commands=S -xecute=""w 123"" -name=a1")
	write "# Verify that t_tries is not 3 at this point by concurrently running [dse crit -seize]",!
	write "# And trying to run [$ztrigger(""select"")]"
	write "# Before YDB@1df7180b0, this would hang. After that, it would run without any hang (expected behavior)",!
	set dev="dse"
	do dseCritSeize(dev)
	set x=$ztrigger("select","^a")
	do dseCritRelease(dev)
	quit

dseCritSeize(dev);
	open dev:(command="$gtm_dist/dse")::"PIPE"
	use dev
	for i=1:1:4 read out(i)
	write "crit -seize",!
	for i=5:1:7 read out(i)
	use $p
	quit

dseCritRelease(dev);
	use dev
	write "crit -release",!
	for i=8:1:10 read out(i)
	write "quit",!
	close dev
	use $p
	quit
