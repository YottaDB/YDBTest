;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2013, 2014 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
utfseekinit
	; initialize some files for use by utfseek.m
	; This file is started via a PIPE device in utfseek.m and operates in M mode
	; It uses the global ^a to respond to requests from utfseek.m
	set ^a=0
	new x,p
	set utf8bom=$char(239)_$char(187)_$char(191)
	set utf8str=$char(213)_$char(135)_$char(213)_$char(136)_$char(213)_$char(137)_$char(65)_$char(66)
	set utf8str=utf8str_$char(67)_$char(213)_$char(143)_$char(213)_$char(144)
	set utf8str=utf8str_utf8str_utf8str
	set p="useek8withbom"
	open p:(write:newversion)
	use p
	; create file with 100 lines starting with utf8 bom
	write utf8bom
	set $x=0
	for i=0:1:99 write $justify(i_" - "_utf8str,46),!
	close p

	set p="useek8nobom"
	open p:(write:newversion)
	use p
	; create file with 100 lines with no utf8 bom
	for i=0:1:99 write $justify(i_" - "_utf8str,46),!
	close p

	new x,p
	set p="useek8fixwithbom"
	open p:(write:newversion)
	use p
	w utf8bom
	; create file with 100 records starting with utf8 bom
	set $x=0
	for i=0:1:99 write $justify(i_" - "_utf8str,46)
	set $x=0
	close p

	set p="useek8fixnobom"
	open p:(write:newversion)
	use p
	; create file with 100 records with no utf8 bom
	set $x=0
	for i=0:1:99 write $justify(i_" - "_utf8str,46)
	set $x=0
	close p

	set p="useek16withbom"
	set utf16bom=$char(254)_$char(255)
	set utf16str=$char(5)_$char(71)_$char(5)_$char(72)_$char(5)_$char(73)_$char(5)_$char(74)_$char(5)_$char(75)
	set utf16str=utf16str_$char(5)_$char(76)_$char(5)_$char(77)_$char(5)_$char(78)_$char(5)_$char(79)
	set utf16str=utf16str_utf16str_$char(0)
	open p:(write:newversion)
	use p
	w utf16bom
	set $x=0
	; create file with 100 records starting with utf16 bom
	for i=0:1:99 write $char(5)_$char(30+i)_utf16str,!
	set $x=0
	close p

	set p="useek16nobom"
	open p:(write:newversion)
	use p
	; create file with 100 records with no utf16 bom
	for i=0:1:99 write $char(5)_$char(30+i)_utf16str,!
	set $x=0
	close p

	set p="useek16fixwithbom"
	set utf16str=$char(5)_$char(71)_$char(5)_$char(72)_$char(5)_$char(73)_$char(5)_$char(74)_$char(5)_$char(75)
	set utf16str=utf16str_$char(5)_$char(76)_$char(5)_$char(77)_$char(5)_$char(78)_$char(5)_$char(79)
	set utf16str=utf16str_utf16str
	open p:(write:newversion)
	use p
	w utf16bom
	set $x=0
	; create file with 100 records starting with utf16 bom
	for i=0:1:99 write $char(5)_$char(30+i)_utf16str
	set $x=0
	close p

	set p="useek16fixnobom"
	open p:(write:newversion)
	use p
	; create file with 100 records with no utf16 bom
	for i=0:1:99 write $char(5)_$char(30+i)_utf16str
	set $x=0
	close p

	;done with initializing files
	set ^a=1
	do wait(2)
	set p="useek8withbom"
	open p:(write:append)
	use p
	write $justify(102_" - "_utf8str,46),!
	set $x=0
	close p

	do wait(3)
	set p="useek8nobom"
	open p:(write:append)
	use p
	write $justify(102_" - "_utf8str,46),!
	set $x=0
	close p

	do wait(4)
	set p="useek16withbom"
	open p:(write:append)
	use p
	set line102=$char(0)_$char(49)_$char(0)_$char(48)_$char(0)_$char(50)_$char(0)_$char(32)_$char(0)_$char(45)_$char(0)_$char(32)
	write line102_$char(5)_$char(130)_utf16str_$char(0),!
	set $x=0
	close p

	do wait(5)
	set p="useek16nobom"
	open p:(write:append)
	use p
	set line102=$char(0)_$char(49)_$char(0)_$char(48)_$char(0)_$char(50)_$char(0)_$char(32)_$char(0)_$char(45)_$char(0)_$char(32)
	write line102_$char(5)_$char(130)_utf16str_$char(0),!
	set $x=0
	close p

	do wait(6)
	set p="useek8fixnobom"
	open p:(write:append)
	use p
	write $justify(102_" - "_utf8str,46)
	set $x=0
	close p

	do wait(7)
	set p="useek16fixnobom"
	open p:(write:append)
	use p
	write $char(0)_$char(51)_utf16str
	set $x=0
	close p

	do wait(8)
	set p="useek8fixwithbom"
	open p:(write:append)
	use p
	write $justify(102_" - "_utf8str,46)
	set $x=0
	close p

	do wait(9)
	set p="useek16fixwithbom"
	open p:(write:append)
	use p
	write $char(0)_$char(51)_utf16str
	set $x=0
	close p
	quit

wait(avalue)
	for  hang 1 quit:avalue=^a
	quit
