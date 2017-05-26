;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2013 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
dlrkey;
	write "------------------------------",!
	write "Enter Newline Character: "
	; read the key from terminal.Key entered will be $c(10)
	read x
	write ! zwr $zb,$key
	use $p:(escape)
	write "------------------------------",!
	write "Enter F8 key: "
	; read the key from terminal.Key entered will be F8
	read x
	write ! zwr $zb,$key
	write "------------------------------",!
	write "Enter character 'M': "
	; read single character from terminal from terminal.Key entered will be 'M'
	read x#1
	write ! zwr $zb,$key
	write "------------------------------",!
	quit
