;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; YDB#1143 index block search index.
;
; The search index changes how a search FINDS a record, never which record it finds, so every check
; here is an ordinary correctness check. The test is that the answers are IDENTICAL whether or not a
; database has one, and the routine prints a single line per entry point for the caller to compare.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ydb1143	quit
	;
N()	quit 200000			; enough nodes for a tree several index blocks wide
	;
key(i,w)	; fixed width so keys collate in numeric order; w pads the key out to test long keys
	new k
	set k="k"_$translate($justify(i,10)," ","0")
	if w>11 set k=k_$justify("",w-11)
	quit k
	;
val(i)	quit i*7+3
	;
build(w)	; populate ^a with $$N() nodes whose keys are w bytes wide
	new i
	if '$data(w) set w=11
	kill ^a
	for i=1:1:$$N() set ^a($$key(i,w))=$$val(i)
	write "build width=",w," nodes=",$$N(),!
	quit
	;
verify(w)	; three access patterns, each of which must agree with $$val exactly
	new i,k,cnt,bad,sum
	if '$data(w) set w=11
	set (cnt,bad,sum)=0,k=""
	for  set k=$order(^a(k)) quit:""=k  do
	. set cnt=cnt+1,i=+$extract(k,2,11)
	. if ^a(k)'=$$val(i) set bad=bad+1
	. set sum=sum+^a(k)
	write "fwd cnt=",cnt," bad=",bad," sum=",sum
	set (cnt,bad)=0,k=""
	for  set k=$order(^a(k),-1) quit:""=k  do
	. set cnt=cnt+1,i=+$extract(k,2,11)
	. if ^a(k)'=$$val(i) set bad=bad+1
	write " | rev cnt=",cnt," bad=",bad
	; clue-defeating gets: every lookup descends from the root, so every index block is searched
	set bad=0,i=1
	for cnt=1:1:20000 do
	. set i=i+7919 set:i>$$N() i=i-$$N()	; stride co-prime with the range, so it wanders it all
	. if $get(^a($$key(i,w)))'=$$val(i) set bad=bad+1
	set cnt=cnt-1
	write " | get cnt=",cnt," bad=",bad,!
	quit
	;
edges(w)	; the boundary cases a sampled search is most likely to get wrong: the very first and last
	; keys, keys that are absent, and $ORDER/$ZPREVIOUS either side of both ends
	new bad,k
	if '$data(w) set w=11
	set bad=0
	if $get(^a($$key(1,w)))'=$$val(1) set bad=bad+1
	if $get(^a($$key($$N(),w)))'=$$val($$N()) set bad=bad+1
	if $data(^a($$key(0,w))) set bad=bad+1			; below the first key
	if $data(^a($$key($$N()+1,w))) set bad=bad+1		; above the last key
	if $order(^a(""))'=$$key(1,w) set bad=bad+1		; first key by $ORDER
	if $order(^a(""),-1)'=$$key($$N(),w) set bad=bad+1	; last key by reverse $ORDER
	if $order(^a($$key(1,w)),-1)'="" set bad=bad+1		; nothing before the first
	if $order(^a($$key($$N(),w)))'="" set bad=bad+1		; nothing after the last
	; a key that sorts between two existing ones must find neither
	set k=$$key(1,w)_"x"
	if $data(^a(k)) set bad=bad+1
	if $order(^a(k))'=$$key(2,w) set bad=bad+1
	write "edges bad=",bad,!
	quit
	;
chk	; verify what an older release wrote into ^c, in one line, for the upgrade subtest
	; deliberately simple : the point there is the file header fields and that searches still
	; find every record, not the sampling corner cases the entry points above cover
	new bad,cnt,k
	set (bad,cnt)=0,k=""
	for  set k=$order(^c(k)) quit:""=k  do
	. set cnt=cnt+1
	. if ^c(k)'=$$val(k) set bad=bad+1
	write "chk cnt=",cnt," bad=",bad,!
	quit
	;
mix	; keys of mixed length in one global, so a single index block holds both keys short enough to be
	; sampled and keys longer than the cap, which are deliberately not
	new i,bad,k,w
	kill ^b
	for i=1:1:20000 do
	. set w=11+(i#5*40)			; widths 11, 51, 91, 131, 171 - within the region key size
	. set ^b($$key(i,w))=$$val(i)
	set bad=0
	for i=1:1:20000 do
	. set w=11+(i#5*40)
	. if $get(^b($$key(i,w)))'=$$val(i) set bad=bad+1
	set (i,k)=0
	for  set k=$order(^b(k)) quit:""=k  set i=i+1
	write "mix cnt=",i," bad=",bad,!
	quit
	;
peek(reg,want)	; report whether THIS process holds a search index for region REG, from its own
	; sgmnt_addrs, which is the structure that decides whether a search uses one. WANT is 1 when the
	; caller expects the feature on for this process and 0 when it expects it off.
	;
	; This reads PRIVATE memory, so it can only ever describe the process that runs it. That is the
	; whole point for the positive case - it proves an ordinary process really does have an index,
	; which "the answers came out right" does not - and it is also why the MUPIP REORG case cannot be
	; reached this way: REORG clears the field in its OWN address space and no other process can see
	; that field.
	new base,size,mask,on
	set base=$$^%PEEKBYNAME("sgmnt_addrs.search_idx_base",reg)
	set size=$$^%PEEKBYNAME("sgmnt_addrs.search_idx_size",reg)
	set mask=$$^%PEEKBYNAME("sgmnt_addrs.search_idx_slotmask",reg)
	; a NULL base is what SEARCHIDX_AVAILABLE tests, and is how the feature reads as off
	set on='(base=0)&'(base="0x0000000000000000")
	write "search index in this process : ",$select(on:"present",1:"absent")
	write $select(on=want:", as expected",1:", WRONG, expected "_$select(want:"present",1:"absent"))
	write !
	if on write "slot size ",size," slot mask ",mask,$select((size>0)&(mask>0):" : both set, as expected",1:" : WRONG, expected both above zero"),!
	quit
