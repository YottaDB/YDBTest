;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
gtm8930
	quit

test1
	SET tab="    "

	WRITE tab_"$VIEW(""JNLPOOL"") with unopened JNLPOOL",!
	WRITE tab_"$VIEW(""JNLPOOL"")="_$VIEW("JNLPOOL"),!!

	WRITE tab_"Updating DB",!!
	SET ^Tenth="David Tennant"

	WRITE tab_"$VIEW(""JNLPOOL"") with opened JNLPOOL",!
	WRITE tab_"$VIEW(""JNLPOOL"")="_$VIEW("JNLPOOL"),!!

	quit

test2
	SET tab="    "

	WRITE tab_"$VIEW(""JNLPOOL"") with no replication instance file defined",!
	WRITE tab_"$VIEW(""JNLPOOL"")="_$VIEW("JNLPOOL"),!!

	quit

test3
	SET tab="    "

	WRITE tab_"$VIEW(""JNLPOOL"") with no file mapping and a garbage gtm_repl_instance",!
	WRITE tab_"$VIEW(""JNLPOOL"")="_$VIEW("JNLPOOL"),!!

	quit
