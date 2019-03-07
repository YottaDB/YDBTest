;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;

gtm5754
	set lv1=+($stack(-1)+1)
	set lv2=+($stack(-1)+2)
	write "Current Stack Level = ",$stack(-1),!
	write "Xecutes that precompile will have a stack level of ",lv1,!
	write "Xecutes that compile at runtime will have a stack level of ",lv2,!,!,!
	write "# Testing Normal Xecute",!
	do xecutefn
	write !,"# Testing Xecute containing a QUIT",!
	do quitfn
	write !,"# Testing Xecute containing a GOTO",!
	do gotofn
	write !,"# Testing Xecute containing a NEW",!
	do newfn
	write !,"# Testing Xecute containing a nested XECUTE",!
	do nestedxfn
	write !,"# Testing Xecute containing indirection",!
	do indirfn
	write !,"# Testing Xecute containing a QUIT which never gets executed",!
	do ifwquitfn
	write !,"# Testing Xecute containing a QUIT which breaks a forloop",!
	do forwquitfn
	quit
xecutefn
	write "stack level = "
	xecute "write $stack(-1),!"
	quit

quitfn
	write "stack level = "
	xecute "write $stack(-1),!  quit"
	quit

gotofn
	write "stack level = "
	xecute "write $stack(-1),!  goto gotofn+3^gtm5754"
	quit

newfn
	write "stack level = "
	xecute "write $stack(-1),!  new x"
	quit

nestedxfn
	write "stack level = "
	xecute "xecute ""write $stack(-1),!"""
	quit

indirfn
	set str="""write $stack(-1),!"""
	write "stack level = "
	xecute @str
	quit

ifwquitfn
	write "stack level = "
	xecute "write $stack(-1),!  if 0  quit"
	quit

forwquitfn
	write "stack level = "
	xecute "for  write $stack(-1),!  quit"
	quit
