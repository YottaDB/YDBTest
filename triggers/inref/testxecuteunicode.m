;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2010-2016 Fidelity National Information		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; Testing the subscript matching during execution with unicode characters
	;
	; * subscript matching
	; * subscript range matching
	; * subscript pattern matching
testxecuteunicode
	do set
	do ranges
	do patterns
	do compound
	do subscrange
	quit

	; test exact matches on single subscripts
	; tests use unicode characters directly and $[z]char
set
	do ^echoline
	write "match single subscripts",!
	set ^names("અમિ")="અમિ"
	set ^($char(2693,2734,2754,2738))=$char(2693,2734,2754,2738)
	set ^($char(2693,2734,2754))="does not match"
	set ^names($char(2693,2735,2754))="still does not match"
	set ^hindinum($char(2406))="0"
	set ^hindinum($char(2407))="1"
	kill ^names
	zwrite ^fired kill ^fired
	do ^echoline
	quit

	; test exact matches in a collated rangee
	; tests use unicode characters directly and $char
ranges
	do ^echoline
	write !,"match ranges",!
	set ^generic("મિલન")=2008
	set ^generic("અમૂલ")=2008
	zwrite ^fired kill ^fired
	;
	write !,"start from Hindi zero to nine",!
	write "zero won't fire a trigger",!
	for i=2406:1:2415 set ^hindinum($char(i))=i
	zwrite ^fired kill ^fired
	;
	write !,"start from Gujarati zero to nine.",!
	write "zero fires no trigger. 1 fires one triggers. 2-9 fire an extra trigger",!
	for i=2688:1:2799 set ^gujaratinum($char(i))=i
	zwrite ^fired kill ^fired
	do ^echoline
	quit

	; test unicode characters and pattern matching
	; without unicode numeric pattern matching enabled, the triggers
	; match differently and some do not fire
patterns
	do ^echoline
	if "UTF-8"'=$ztrnlnm("gtm_patnumeric") write "Unicode numeric pattern matching disabled",!
	write !,"patterns",!
	set ^gujaratipat("५")="six"
	set ^gujaratipat("૨૦૦૦")="two thousand"
	set ^gujaratipat("૨૨૨-५५-૦૦૦૦")="fake SSN"
	set ^gujaratipat("૨૨-૧૧૧૧૧૧૧")="fake TIN"
	set ^gujaratipat("૨૨૨-५५-૦૦૦૦","અમૂલ")="fake SSN"
	set zero2nine=-1
	for i=2406:1:2415 set ^hindipat($char(i))=$increment(zero2nine)
	for i=2406:1:2415 set ^hindipat($char(i,i))=$increment(zero2nine)
	zwrite ^fired kill ^fired
	do ^echoline
	quit

	; test with more than on matching subscript
	; tests use unicode characters directly and $[z]char
compound
	do ^echoline
	write !,"compound",!
	set ^hindi($char(2408),$char(2407,2406))="2,10"
	set ^hindi($char(2408),$char(2409))="2,3"
	set ^gujaratipat("૨૨૨-५५-૦૦૦૦","અમૂલ")="fake SSN"
	zwrite ^fired kill ^fired
	do ^echoline
	quit

	; use the unisubscrange GVN which has the subscripts listed
	; opposite to the default collation order
subscrange
	do ^echoline
	new $estack,expect
	set $etrap="do ^incretrap",expect="TRIGSUBSCRANGE"
	write !,"Go against encoding to get a subscript range error",!
	set ^unisubscrange(1,"૯")="should be an error"
	set ^unisubscrange(2,"९")="should be an error"
	if $data(^fired) write "FAIL",! zwrite ^fired kill ^fired
	do ^echoline
	quit

	;--------------------------------------------------------------
rtn(prefix)
	set ref=$reference
	set ztname=$piece($ZTNAme,"#",1,2)_"#" ; strip region disambigurator
	set x=$increment(^fired(ztname))
	if $data(prefix) set $piece(^fired(ztname,x)," ",$i(i))=prefix
	set $piece(^fired(ztname,x)," ",$i(i))=ref
	if $data(lvn) set $piece(^fired(ztname,x)," ",$i(i))=lvn
	if $data(lvn1) set $piece(^fired(ztname,x)," ",$i(i))=lvn1
	if $data(lvn2) set $piece(^fired(ztname,x)," ",$i(i))=lvn2
	quit

