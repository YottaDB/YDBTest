;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Copyright (c) 2023-2024 YottaDB LLC and/or its subsidiaries.
; All rights reserved.
;
;	This source code contains the intellectual property
;	of its copyright holder(s), and is made available
;	under a license.  If you do not know the terms of
;	the license, please stop and do not read further.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; test print status of terminal device as OPEN (it is impossible to close $principal)
viewTerminal
	write $view("device",$zpin),!
	write $view("device",$zpout),!
	quit

viewFile
	open "f.txt"
	write $view("device","f.txt"),!
	close "f.txt":nodestroy
	write $view("device","f.txt"),!
	quit

viewFifo
	set f="f.fifo"
	open f:fifo
	write $view("device",f),!
	close f:nodestroy
	write $view("device",f),!
	quit

viewPipe
	set f="f.pipe"
	open f:(command="sleep 1":independent)::"PIPE"
	write $view("device",f),!
	close f:nodestroy
	write $view("device",f),!
	quit

socketListen
	set f="f.socket"
	open f:(listen="f.sock:LOCAL")::"SOCKET"
	use f read *x use $p
	quit

socketConnect
	set f="f.socket"
	open f:(connect="f.sock:LOCAL"):10:"SOCKET"
	write $view("device",f),!
	use f write "c" use $p
	close f
	w $view("device",f),!
	quit

viewNull
	set f="/dev/null"
	open f
	write $view("device",f),!
	close f
	write $view("device",f),!
	quit
