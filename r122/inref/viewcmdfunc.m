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

test1
	set gblname="^a"
	for i=1:1:1024 set gblname=gblname_"0"
	set xstr="view ""NOISOLATION"":"""_gblname
	set xstr=xstr_""""
	xecute xstr
	set agbl=$extract(gblname,1,32)
	write "$view(""NOISOLATION"","""_agbl_""") = ",$view("NOISOLATION",agbl),!
	quit

test2
	view "NOISOLATION":"abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyz"
	quit

test3
	set regname="a"
	for i=1:1:80000 set regname=regname_"0"
	write $view("GVFILE",regname)
	quit

test4
	set reglist="a"
	for i=1:1:800000 set reglist=reglist_"0"
	view "STATSHARE":reglist
	quit

test5
	set reglist="DEFAULT"
	for i=1:1:15 set reglist=reglist_","_reglist
	view "STATSHARE":reglist
	quit

test6
	write $view("GVSTATS",""),!
	quit

test7
	write $view("GVFILE",""),!
	quit

; Note: A lot of $view commands where a region name is expected in the second argument will SIG-11 if "" is specified
; Only 2 of them are tested above (test6 and test7).

