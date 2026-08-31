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
;
; Stand in for a gtcm_gnp_server and answer one GT.CM GNP client with a reply of our choosing.
; This is the other direction from inref/gnpfuzz.m: there the server is under test and this program
; is the client, here the client is under test and this program is the server. GT.CM GNP clients and
; their servers are designed to run within the same security zone, so this is not about a hostile
; server: it is about the client not walking off the end of its own buffers when a reply does not
; have the shape it expects.
;
; $ZCMDLINE : <port> <case>
;
; Answers CMMS_S_INITPROC and CMMS_S_INITREG so the client opens the region, then answers its first
; CMMS_Q_QUERY with whatever the case asks for and exits. Writes progress to $PRINCIPAL; the verdict
; comes from the client, in inref/gnpcli.m.
;
gnpsrv	;
	set port=$piece($zcmdline," ",1)
	set case=$piece($zcmdline," ",2)
	set sock="gnpsrvsock",rdtmo=30
	set le=1	; a GT.CM server reads the "unsigned short" fields in its own byte order, and this
			; program only ever answers a client on the same machine
	do listen
	if 'ok do say("could not accept a connection") do done quit
	do handshake
	if 'ok do dis() do done quit
	do reply
	; stay up briefly so the client's CMMS_S_TERMINATE at HALT has somewhere to go, otherwise a
	; case that the client accepts ends with a network error that has nothing to do with the test
	set rdtmo=3
	if $zlength($$rcv())
	do dis()
	do done
	quit
	;
done	; tell the driver the port is free again, so the next case can have it
	open "done":(newversion) use "done" write "done",! close "done"
	use $principal
	quit
	;
say(t)	use $principal write "  gnpsrv: "_t,! use:$data(connected) sock
	quit
	;
us(v)	quit $select(le:$zchar(v#256,v\256#256),1:$zchar(v\256#256,v#256))
	;
listen	; accept one connection
	new handle
	set ok=0
	open sock:(listen=port_":TCP":delim="":ichset="M":ochset="M":attach="listener"):5:"SOCKET"
	if '$test do say("could not listen on port "_port) quit
	; tell the driver the socket exists so it can start the client without guessing a sleep
	open "ready":(newversion) use "ready" write "ready",! close "ready"
	use sock write /wait(rdtmo)
	if $key="" do say("no client connected within "_rdtmo_" seconds") quit
	set handle=$piece($key,"|",2)
	use sock:(socket=handle)
	set connected=1,ok=1
	quit
	;
dis()	;
	close sock
	kill connected
	quit
	;
snd(m)	use sock write $zchar($zlength(m)\256,$zlength(m)#256),m
	quit
	;
raw(m)	; bytes with no framing, used to send a length prefix the reply does not back up
	use sock write m
	quit
	;
tell(f)	; create a file the client half waits on, the same way "ready" and "done" tell the driver
	open f:(newversion) use f write f,! close f
	use sock
	quit
	;
rdn(n)	new s,x
	set s=""
	for  quit:$zlength(s)'<n  do  quit:x=""
	. set x=""
	. use sock read x#(n-$zlength(s)):rdtmo
	. set s=s_x
	quit s
	;
rcv()	new n,s
	set s=$$rdn(2)
	if $zlength(s)'=2 quit ""
	set n=$zascii(s,1)*256+$zascii(s,2)
	quit $$rdn(n)
	;
proto()	; the protocol string we claim. Level "999" is at or above anything the client requires, so
	; the client enables long names, standard null collation and $QUERY-as-QUERYGET.
	quit "X86LNXGTM071GCM999"_$select(le:" ",1:"B")_"              "
	;
handshake	; answer CMMS_S_INITPROC then CMMS_S_INITREG
	new m
	set ok=0
	set m=$$rcv()
	if $zascii(m,1)'=33 do say("expected CMMS_S_INITPROC, got message type "_$zascii(m,1)) quit
	do snd($zchar(37)_$$proto()_$$us(1))			; CMMS_T_INITPROC, procnum 1
	set m=$$rcv()
	if $zascii(m,1)'=34 do say("expected CMMS_S_INITREG, got message type "_$zascii(m,1)) quit
	; CMMS_T_REGNUM: regnum, null_subs, max_rec_size, max_key_size, std_null_coll
	do snd($zchar(38,0,0)_$$us(4096)_$$us(255)_$zchar(1))
	set ok=1
	quit
	;
reply	; answer the client's first CMMS_Q_QUERY with what "case" asks for
	new base,keylen,m,oldtop,val
	set m=$$rcv()
	if $zascii(m,1)'=22 do say("expected CMMS_Q_QUERY, got message type "_$zascii(m,1)) quit
	; Echo back the "top" the client sent us, at offset 4 of its request. gvcmz_doop() asserts in a
	; DEBUG build that what comes back equals its own gv_altkey->top, so inventing one fails there
	; for a reason that has nothing to do with what is being tested.
	set oldtop=$zascii(m,5)+($zascii(m,6)*256)
	set val="e"
	do @case
	quit
	;
rqry(base,end,prev,oldtop,val)	; send a well formed CMMS_R_QUERY carrying the given key and value
	; key_len is gv_altkey->end + 3 "unsigned short"s + 1, and the length on the wire is one more
	; than that. The key itself occupies "end" + 1 bytes, which is what gtcmtr_query() copies.
	new keylen,m
	set keylen=$zlength(base)
	set m=$zchar(30)_$$us(end+8)_$zchar(0)_$$us(oldtop)_$$us(end)_$$us(prev)_base
	set m=m_$$us($zlength(val))_val
	do snd(m)
	quit
	;
gkey()	; a gv_key "base" for ^etpr("subaaa"): name, <NUL>, then the subscript introduced by
	; STR_SUB_PREFIX (0xFF) so it decodes as a string rather than as a number, then the two <NUL>
	; bytes that terminate a key. "end" is the offset of the second of those, ie $ZLENGTH minus 1.
	quit "etpr"_$zchar(0,255)_"subaaa"_$zchar(0,0)
	;
; ---------------------------------------------------------------- cases
srvstaleprev	; a well formed reply whose "prev" is larger than "end", which is what a real server
	; sends: gvcst_query() and gvcst_queryget() never assign gv_altkey->prev, so for CMMS_R_QUERY
	; the server passes on whatever the previous operation in that process left there. The client
	; has to accept this. 32 and 12 are the values seen from a real server.
	do say("sending a well formed reply with prev=32, end="_($zlength($$gkey())-1))
	do rqry($$gkey(),$zlength($$gkey())-1,32,oldtop,val)
	quit
	;
srvbadlen	; a length below the 1 + three "unsigned short"s that the key header alone occupies.
	; "keylen" is a "short" in gvcmz_doop(), so this used to make it zero or negative and the
	; memcpy() count enormous.
	do say("sending a reply with a declared length of 4")
	do snd($zchar(30)_$$us(4)_$zchar(0)_$$us(oldtop))
	quit
	;
srvshortkey	; a length that claims more bytes than the reply actually carries
	do say("sending a reply that declares a 200 byte key and carries "_$zlength($$gkey()))
	do snd($zchar(30)_$$us(200)_$zchar(0)_$$us(oldtop)_$$us($zlength($$gkey())-1)_$$us(0)_$$gkey())
	quit
	;
srvbadshape	; a key whose "end" does not point at the second of the two <NUL> bytes that terminate
	; a key. The caller indexes "base" with "end".
	do say("sending a key whose end does not point at a NUL terminator")
	do rqry("etprXXsubaaaXX",13,0,oldtop,val)
	quit
	;
srvbigkey	; a key longer than the client's gv_altkey can hold
	new i,long
	set long="etpr"_$zchar(0)
	for i=1:1:1100 set long=long_"a"
	set long=long_$zchar(0,0)
	do say("sending a key of "_$zlength(long)_" bytes, larger than the client's key buffer")
	do rqry(long,$zlength(long)-1,0,oldtop,val)
	quit
	;
srvneglen	; a well formed key followed by a value length with its high bit set. gvcmz_doop() reads
	; that length into a "short", so it arrives negative and used to reach the memmove() below it
	; as an enormous unsigned count.
	new b,e
	set b=$$gkey(),e=$zlength(b)-1
	do say("sending a reply whose value length is negative")
	do snd($zchar(30)_$$us(e+8)_$zchar(0)_$$us(oldtop)_$$us(e)_$$us(0)_b_$$us(32768))
	quit
	;
srvnolen	; a reply that stops after its message type, with none of the two byte key length the
	; client reads next
	do say("sending a reply carrying nothing but its message type")
	do snd($zchar(30))
	quit
	;
srvnovallen	; a well formed key and then nothing. With $QUERY answered as QUERYGET the client goes
	; on to read a two byte value length that this reply does not carry.
	new b,e
	set b=$$gkey(),e=$zlength(b)-1
	do say("sending a reply that ends after the key, with no value length")
	do snd($zchar(30)_$$us(e+8)_$zchar(0)_$$us(oldtop)_$$us(e)_$$us(0)_b)
	quit
	;
srvshortval	; a value length longer than the value bytes that follow it, which sizes the memmove()
	; below it out of the client's message buffer
	new b,e
	set b=$$gkey(),e=$zlength(b)-1
	do say("sending a reply that declares a 50 byte value and carries 2")
	do snd($zchar(30)_$$us(e+8)_$zchar(0)_$$us(oldtop)_$$us(e)_$$us(0)_b_$$us(50)_"ab")
	quit
	;
srvbigframe	; cmj_read_interrupt() : a length prefix larger than the client's own message buffer,
	; and then none of the bytes it announces. The client posts its read before sending the request
	; that this answers, so the announcement arrives with a read already outstanding and is seen on
	; the asynchronous path, the same one the server reaches for "bigframe" in inref/gnpfuzz.m.
	; Before the fix the client was left in CM_CLB_READ with no read outstanding and no event
	; posted, which hung it rather than failing it.
	do say("announcing a 60000 byte reply and sending none of it")
	do raw($zchar(234,96))
	quit
	;
srvidleframe	; cmj_read_start() : the same oversized announcement as srvbigframe, but queued on the
	; link while the client is idle rather than while it is waiting for a reply. A GT.CM client
	; leaves no read outstanding between operations, so these two bytes sit in its socket buffer
	; until its next cmi_read(), whose recv() hands them back on the spot. That is the synchronous
	; path in cmj_read_start(). srvbigframe cannot reach it: there the read is already posted when
	; the bytes arrive, so they come in through cmj_read_interrupt() instead.
	do say("answering the first $QUERY, then announcing a 60000 byte reply and sending none of it")
	do rqry($$gkey(),$zlength($$gkey())-1,0,oldtop,val)
	; Let the client take in the reply above first. If these two bytes reach it in the same read
	; they are counted as part of that reply rather than announcing the next one.
	hang 1
	do raw($zchar(234,96))
	do tell("queued")	; the client waits for this before it issues its second $QUERY
	quit
