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

shellfn
	set pid=$j
	write "# Zsystem calls the shell specified by the SHELL environment variable",!
	zsystem "echo $SHELL"
	zsystem "ps --forest -f |& tail -7 |& head -3 |& $tst_awk '{print $7,$8,$9,$10,$11,$12,$13}'"
	quit

quotesfn
	write "# Old quotes system",!
	zsystem "echo '""hello world""'"
	write "# Simplified quotes system",!
	zsystem "echo 'hello world'"
	quit
