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
; This module is derived from FIS GT.M.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

zprev	; Test of $ZPrevious.
	New
	Do begin^header($TEXT(+0))

; Test for PER 002320:
	Set errstep=errcnt
	Set x(0)=""
	Do ^examine($ZPREVIOUS(x(30.1)),0,"PER 002320")
	If errstep=errcnt Write "   PASS - PER 002320",!

	Set errstep=errcnt
	Do ^examine($ZPREVIOUS(X),"","No previous variable: X")
	Do ^examine($ZPREVIOUS(X(1)),"","No previous variable: X(1)")
	Do ^examine($ZPREVIOUS(X("XXX",123.4)),"","No previous variable: X(""XXX"",123.4)")

	Set X="x",Y="y",Z="z"
	Do ^examine($ZPREVIOUS(Y),"X","No subscripts: Y")
	Do ^examine($ZPREVIOUS(Z1),"Z","No subscripts: Z1")
	Do ^examine($ZPREVIOUS(Y("ABC")),"","No subscripts: Y(""ABC"")")
	Do ^examine($ZPREVIOUS(Z("")),"","No subscripts: Z("""")")

	Set X("")="",X(1)=1,X(1.125)=.125,X(9999)=9999,X("Abcde")="Abcde"
	Set X("ABCDE")="ABCDE"
	Do ^examine($ZPREVIOUS(X("")),"Abcde","Null subscript: X("""")")
	Do ^examine($ZPREVIOUS(X(0)),"","No previous subscript: X(0)")
	Do ^examine($ZPREVIOUS(X(2)),1.125,"Fractional subscript: X(2)")
	Do ^examine($ZPREVIOUS(X(3.111)),1.125,"Fractional subscript: X(3.111)")
	if '$$getncol^%LCLCOL do
	.	Do ^examine($ZPREVIOUS(X("A")),"","Null subscript: X(""A"")")
	.	Kill X("")
	Do ^examine($ZPREVIOUS(X("A")),9999,"No Null subscript: X(""A"")")
	Do ^examine($ZPREVIOUS(X("Ab")),"ABCDE","X(""Ab"")")
	Do ^examine($ZPREVIOUS(X("Ac")),"Abcde","X(""Ac"")")
	Do ^examine($ZPREVIOUS(X("AB","CD")),"","X(""AB"",""CD"")")
	Do ^examine($ZPREVIOUS(X("AB",123,"CD")),"","X(""AB"",123,""CD"")")

	Set X(123,"ABC","XYZ")="123ABCXYZ",X(123,"ABC",500)="123ABC500"
	Do ^examine($ZPREVIOUS(X(123,"ABC",1)),"","X(123,""ABC"",1)")
	Do ^examine($ZPREVIOUS(X(123,"ABC","A")),500,"X(123,""ABC"",""A"")")
	Do ^examine($ZPREVIOUS(X(123,"ABC","a")),"XYZ","X(123,""ABC"",""a"")")

	Set ^AAAAAAA0=0,^AAAAAAA1=1,^AAAAAAA2=2,^AAAAAAA3=3
	Do ^examine($ZPREVIOUS(^AAAAAAA3),"^AAAAAAA2","^AAAAAAA3")
	Do ^examine($ZPREVIOUS(^AAAAAAA1),"^AAAAAAA0","^AAAAAAA1")

	Kill ^aA
	Set ^aA(5)=5,^aA("XXX")="XXX",^aA("AAA","BBB")="AAABBB"
	Do ^examine($ZPREVIOUS(^aA(1)),"","^aA(1)")
	Do ^examine($ZPREVIOUS(^aA("A")),5,"^aA(""A"")")
	Do ^examine($ZPREVIOUS(^aA("a")),"XXX","^aA(""a"")")
	Do ^examine($ZPREVIOUS(^aA(25,"XYZ")),"","^aA(25,""XYZ"")")
	Do ^examine($ZPREVIOUS(^aA("AAA","A")),"","^aA(""AAA"",""A"")")
	Do ^examine($ZPREVIOUS(^aA("AAA","z")),"BBB","^aA(""AAA"",""z"")")

	;same as above, in a different region
	Kill ^bA
	Set ^bA(5)=5,^bA("XXX")="XXX",^bA("AAA","BBB")="AAABBB"
	Do ^examine($ZPREVIOUS(^bA(1)),"","^bA(1)")
	Do ^examine($ZPREVIOUS(^bA("A")),5,"^bA(""A"")")
	Do ^examine($ZPREVIOUS(^bA("a")),"XXX","^bA(""a"")")
	Do ^examine($ZPREVIOUS(^bA(25,"XYZ")),"","^bA(25,""XYZ"")")
	Do ^examine($ZPREVIOUS(^bA("AAA","A")),"","^bA(""AAA"",""A"")")
	Do ^examine($ZPREVIOUS(^bA("AAA","z")),"BBB","^bA(""AAA"",""z"")")

	If errstep=errcnt  Write "   PASS",!
	Do end^header($TEXT(+0))
	Quit
