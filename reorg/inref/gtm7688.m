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
gtm7688	;
	set numjobs=8
	do ^job("child^gtm7688",numjobs,"""""")
	quit

child	;
	; Write high-valued bytes (near 255) overtop GDS blocks' record headers. REORG interprets two bytes as the record size and
	; computes a memory location to access. But REORG should not access memory past the end of the file, which SIG-11's in MM.
	; BG can also SIG-11, but a test case is more difficult. This test is designed for MM.
	;
	set loops=50000
	set n=20		; number of nodes
	set val=$j("",400)	; each node fills up half a GVT leaf block
	set ^x=val
	for iter=1:1:loops do
	.	kill ^x($$subscript($r(n)))
	.	for j=1:1:3 set ^x($$subscript($r(n)),j)=val
	quit

subscript(k)
	quit $tr($j("",2*k+20)," ",$char(255-k))
