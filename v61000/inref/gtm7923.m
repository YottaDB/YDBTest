;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright 2013 Fidelity Information Services, Inc		;
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
gtm7923	; Test that long patterns give PATMAXLEN error (not SIG-11)
	;
	set jmaxwait=0
	set ^stop=0
	do ^job("child^gtm7923",4,"""""")
	hang 15	; let various patterns to be exercised in the child job for 15 seconds before stopping the test
	set ^stop=1
	do wait^job
	if $data(^error)  write "Test fail : See *.mjo*",!
	quit

child	;
	; 150373546,pattern+6^pattern,%YDB-E-PATMAXLEN, Pattern code exceeds maximum length
	set $etrap="do etrap"
	for  quit:^stop=1  do
	.	set pattern=$$getPattern()
	.	w """a""?"_pattern_" =  "_("a"?@pattern),!
	quit

getPattern()
	set patternSelection="ACELNPUacelnpu"
	set patternSelectionLength=$length(patternSelection)
	set maxfrag=1+$r(100),maxparen=1+$r(50)
	set fragmentCount=$random(maxfrag)+1
	set parenLevel=0
	set parenContent=0
	set return=""
	for i=1:1:fragmentCount do
	.	set comma=$select((parenContent&(0=$random(3))):",",1:"")
	.	set option=$random(4)+1
	.	set minimum=$random(5)+1
	.	set maximum=$random(5)+minimum
	.	set:(1=option) number=minimum_"."
	.	set:(2=option) number="."_maximum
	.	set:(3=option) number=minimum_"."_maximum
	.	set:(4=option) number=minimum
	.	set parenAdded=0
	.	if (i<fragmentCount)&(0=$random(4)) do
	.	.	if parenContent&(0<parenLevel)&(0=$random(2)) do
	.	.	.	set parenLevel=parenLevel-1
	.	.	.	set parenContent=$select((0<parenLevel):1,1:0)
	.	.	.	set parenAdded=1
	.	.	.	set return=return_")"
	.	.	else  if (maxparen>parenLevel) do
	.	.	.	set parenLevel=parenLevel+1
	.	.	.	set parenContent=0
	.	.	.	set parenAdded=1
	.	.	.	set return=return_comma_number_"("
	.	if ('parenAdded) do
	.	.	if $r(2) do
	.	.	.	set fragment=$extract(patternSelection,$random(patternSelectionLength)+1)
	.	.	else  do
	.	.	.	set fragment=""""_$$^%RANDSTR($random(64)+1)_""""
	.	.	set:(0<parenLevel) parenContent=1
	.	.	set return=return_comma_number_fragment
	set parens=""
	for i=1:1:parenLevel set parens=parens_")"
	set return=return_parens
	quit return

etrap
	set mnemonic=$piece($zstatus,",",3)
	if ("%YDB-E-PATMAXLEN"'=mnemonic) set ^error($j)=1 zshow "*" halt
	else  set $ecode=""
	quit
