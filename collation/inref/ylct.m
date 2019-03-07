;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2017-2018 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; This is a helper M script for testing various local collation features used in ylct subtest.
;
setparmwithlcl
	set $ztrap="goto incrtrap^incrtrap"
	set incrtrapNODISP=1
	set incrtrapPOST="write $zstatus,!"
	set a(1)=1
setparm
	view "YLCT":1:-1:-1
	write "Collation: "_$view("YLCT")_"; ncol: "_$view("YLCT","ncol")_"; nct: "_$view("YLCT","nct"),!
	view "YLCT":-1:1:-1
	write "Collation: "_$view("YLCT")_"; ncol: "_$view("YLCT","ncol")_"; nct: "_$view("YLCT","nct"),!
	view "YLCT":-1:-1:1
	write "Collation: "_$view("YLCT")_"; ncol: "_$view("YLCT","ncol")_"; nct: "_$view("YLCT","nct"),!
	view "YLCT":1:1:1
	write "Collation: "_$view("YLCT")_"; ncol: "_$view("YLCT","ncol")_"; nct: "_$view("YLCT","nct"),!
	view "YLCT":0:-1:-1
	write "Collation: "_$view("YLCT")_"; ncol: "_$view("YLCT","ncol")_"; nct: "_$view("YLCT","nct"),!
	view "YLCT":-1:0:-1
	write "Collation: "_$view("YLCT")_"; ncol: "_$view("YLCT","ncol")_"; nct: "_$view("YLCT","nct"),!
	view "YLCT":-1:-1:0
	write "Collation: "_$view("YLCT")_"; ncol: "_$view("YLCT","ncol")_"; nct: "_$view("YLCT","nct"),!
	view "YLCT":0:0:0
	write "Collation: "_$view("YLCT")_"; ncol: "_$view("YLCT","ncol")_"; nct: "_$view("YLCT","nct"),!
	if $$set^%LCLCOL(1)
	write "Collation: "_$$get^%LCLCOL_"; ncol: "_$$getncol^%LCLCOL_"; nct: "_$$getnct^%LCLCOL,!
	if $$set^%LCLCOL(,1)
	write "Collation: "_$$get^%LCLCOL_"; ncol: "_$$getncol^%LCLCOL_"; nct: "_$$getnct^%LCLCOL,!
	if $$set^%LCLCOL(,,1)
	write "Collation: "_$$get^%LCLCOL_"; ncol: "_$$getncol^%LCLCOL_"; nct: "_$$getnct^%LCLCOL,!
	if $$set^%LCLCOL(1,1,1)
	write "Collation: "_$$get^%LCLCOL_"; ncol: "_$$getncol^%LCLCOL_"; nct: "_$$getnct^%LCLCOL,!
	if $$set^%LCLCOL(0)
	write "Collation: "_$$get^%LCLCOL_"; ncol: "_$$getncol^%LCLCOL_"; nct: "_$$getnct^%LCLCOL,!
	if $$set^%LCLCOL(,0)
	write "Collation: "_$$get^%LCLCOL_"; ncol: "_$$getncol^%LCLCOL_"; nct: "_$$getnct^%LCLCOL,!
	if $$set^%LCLCOL(,,0)
	write "Collation: "_$$get^%LCLCOL_"; ncol: "_$$getncol^%LCLCOL_"; nct: "_$$getnct^%LCLCOL,!
	if $$set^%LCLCOL(0,0,0)
	write "Collation: "_$$get^%LCLCOL_"; ncol: "_$$getncol^%LCLCOL_"; nct: "_$$getnct^%LCLCOL,!
	quit

sortsafter
	; Use @y to evaluate the ]] operator as otherwise compiling it causes literal expressions to be evaluated
	; at compile time which might be incorrect for example when called from "sortsafterwithoutcolwithnct"
	; when "nct" is set to 1 (causing numbers to be treated as strings).
	for y="0]]8","1]]7","""0""]]8","0]]""8""","""0""]]""8""","""0.0""]]8","0]]""08""","0]]""00""","""0""]]""00""","0]]$char(0)","""a""]]5","""a""]]""8""","""a""]]""b""" do
	. write y," = ",@y,!
	quit

sortsafterwithoutcol
	if $$set^%LCLCOL(0)
	do sortsafter
	quit

sortsafterwithcol
	if $$set^%LCLCOL(1)
	do sortsafter
	quit

sortsafterwithoutcolwithnct
	if $$set^%LCLCOL(0,,1)
	do sortsafter
	quit

sortsafterwithcolwithnct
	if $$set^%LCLCOL(1,,1)
	do sortsafter
	quit
