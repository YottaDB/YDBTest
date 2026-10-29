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
; This module is derived from FIS GT.M.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

shortutf
	; Test short utf-8 inputs both with and without bom for disk, fifo, and pipe reads
	; disk tests
	; streaming mode
	w !,"DISK TESTS",!
	set fin="uout_with_bom"
	open fin
	use fin
	read x
	use $P
	write "-",x,"-",!
	close fin
	set fin="uout_without_bom"
	open fin
	use fin
	read x
	use $P
	write "-",x,"-",!
	close fin

	; fixed mode. A UTF-8 device needs a RECORDSIZE of at least 4, so the input is shorter than a record.
	set fin="uout_with_bom"
	open fin:(fixed:recordsize=4)
	use fin
	read x
	use $P
	write "-",x,"-",!
	close fin
	set fin="uout_without_bom"
	open fin:(fixed:recordsize=4)
	use fin
	read x
	use $P
	write "-",x,"-",!

	; pipe tests
	; streaming mode
	w !,"PIPE TESTS",!
	set p1="test1"
	open p1:(command="cat -u uout_with_bom")::"pipe"
	use p1
	read x
	use $P
	write "-",x,"-",!
	close p1
	open p1:(command="cat -u uout_without_bom")::"pipe"
	use p1
	read x
	use $P
	write "-",x,"-",!
	close p1

	; fixed mode
	set p1="test1"
	open p1:(command="cat -u uout_with_bom | strip_cr":fixed:recordsize=4)::"pipe"
	use p1
	read x
	use $P
	write "-",x,"-",!
	close p1
	open p1:(command="cat -u uout_without_bom | strip_cr":fixed:recordsize=4)::"pipe"
	use p1
	read x
	use $P
	write "-",x,"-",!
	close p1

	; fifo tests
	; streaming mode
	set p1="fifo.test"
	w !,"FIFO TESTS",!
	open p1:(fifo:newversion)
	use p1
	zsystem "cat -u uout_with_bom > fifo.test"
	read x
	use $P
	write "-",x,"-",!
	close p1
	set p1="fifo.test"
	open p1:(fifo:newversion)
	use p1
	zsystem "cat -u uout_without_bom > fifo.test"
	read x
	use $P
	write "-",x,"-",!
	close p1

	; fixed mode
	open p1:(fifo:newversion:fixed:recordsize=4)
	use p1
	; A timed READ of a UTF-8 FIFO with RECORDSIZE=4 that holds only "^" returns nothing, so keep the newline that
	; strip_cr would remove. The FIFO stays open, so a READ of a record shorter than RECORDSIZE returns only when
	; it times out.
	zsystem "cat -u uout_with_bom > fifo.test"
	read x:1
	use $P
	write "-",x,"-",!
	close p1
	set p1="fifo.test"
	open p1:(fifo:newversion:fixed:recordsize=4)
	use p1
	zsystem "cat -u uout_without_bom > fifo.test"
	read x:1
	use $P
	write "-",x,"-",!
	close p1

	quit
