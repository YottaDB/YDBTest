;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

test	;
	;
	write "# Enable stats",!
	view "statshare"
	;
	write "# Execute ^%YGBLSTAT",!
	set result=$$STAT^%YGBLSTAT("*","","","DEFAULT")
	;
	write "# Check variables",!
	;
	set tokenlist="WRL PRG WFL WHE"
	;
	set found=0
	for i=1:1 set item=$piece(result,",",i) quit:item=""  do
	. set token=$piece(item,":",1)
	. if tokenlist'[token quit
	. set found=1+found
	. set itemlist(token)=item
	;
	for i=1:1 set token=$piece(tokenlist," ",i) quit:token=""  do
	. write " ",$get(itemlist(token),"missing: "_token),!
	;
	write found,"/4 variables found",!
	quit
