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
; Send one deliberately malformed GT.CM GNP message to a running gtcm_gnp_server and report what
; the server did with it. Speaks the GNP wire protocol over a plain TCP socket so it can send byte
; sequences no real client would produce.
;
; $ZCMDLINE : <port> <database file> <case>
;
; Writes exactly one verdict line, "<case> : <verdict>", so the reference file stays stable. The
; verdict names the outcome rather than quoting the server's error text, both to keep the output
; independent of message wording and to keep "%YDB-E-" strings out of a file the test framework
; scans for unexpected errors. The server's own copy of the error is checked in cmerr*.log by the
; driver script.
;
gnpfuzz	;
	set port=$piece($zcmdline," ",1)
	set dbf=$piece($zcmdline," ",2)
	set case=$piece($zcmdline," ",3)
	set sock="gnpsock",rdtmo=5
	; Every "unsigned short" inside a GNP message is in the server's native byte order: the handlers
	; read them with GET_USHORT, a plain unaligned load, and never convert. Only the 2-byte frame
	; prefix is network order. "hand()" below learns the server's byte order from the byte the
	; handshake reply carries at CM_ENDIAN_OFFSET, the same byte gtcm_is_big_endian() reads, so this
	; works against a server of either endianness. Assume little endian until then; nothing before
	; the handshake completes contains an "unsigned short".
	set le=1
	do @case
	quit
	;
; ------------------------------------------------------------------ verdicts
verdict(v)	; the single line this program exists to produce
	use $principal write case_" : "_v,!
	quit
	;
judge(want)	; read the server's answer to the malformed message and classify it
	; "want" is "reject" (expect the message refused with BADGTMNETMSG) or "close" (expect the
	; server to tear the link down). Anything else is a failure and says so.
	new e,got,t0,v
	set t0=$zut
	set got=$$rcv()
	set e=$zut-t0
	if got'="" do
	. if $zascii(got,1)=1 do  quit
	. . if $zfind($zextract(got,14,$zlength(got)),"BADGTMNETMSG") set v="rejected with BADGTMNETMSG" quit
	. . set v="rejected, but not with BADGTMNETMSG - WRONG"
	. set v="ACCEPTED, server replied with message type "_$zascii(got,1)_" - WRONG"
	else  if e<(rdtmo*500000) set v="link closed by the server"
	else  set v="link left hanging, no reply and no close - WRONG"
	; whatever happened to this connection, the server has to still be serving other clients
	if v'["WRONG",'$$serving() set v=v_", but SERVER NO LONGER SERVING - WRONG"
	if v'["WRONG" do
	. if (want="reject")&(v'["rejected") set v=v_" - WRONG, expected a rejection"
	. if (want="close")&(v'["closed") set v=v_" - WRONG, expected the link to be closed"
	if v'["WRONG" set v=v_", server still serving"
	do verdict(v)
	quit
	;
serving()	; a brand new connection must still get through the handshake
	new ok
	do dis()
	set ok=0
	if $$conn(),$$hand() set ok=1
	do dis()
	quit ok
	;
; ------------------------------------------------------------------ plumbing
us(v)	; "unsigned short" in the server's native byte order
	quit $select(le:$zchar(v#256,v\256#256),1:$zchar(v\256#256,v#256))
	;
conn()	; open a connection to the server
	; ICHSET/OCHSET must be "M" so the bytes below travel untranslated, and they have to be given
	; on the OPEN: setting them on a later USE does not apply to a socket already created.
	open sock:(connect="127.0.0.1:"_port_":TCP":delim="":ichset="M":ochset="M"):5:"SOCKET"
	if '$test quit 0
	use sock
	quit 1
	;
dis()	;
	close sock
	quit
	;
snd(m)	; frame "m" with the 2-byte network-order length prefix and send it
	use sock write $zchar($zlength(m)\256,$zlength(m)#256),m
	quit
	;
raw(m)	; send bytes with no framing, used to split the length prefix across two sends
	use sock write m
	quit
	;
rdn(n)	; read up to "n" bytes, giving up when the server sends nothing for "rdtmo" seconds
	new s,x
	set s=""
	for  quit:$zlength(s)'<n  do  quit:x=""
	. set x=""
	. use sock read x#(n-$zlength(s)):rdtmo
	. set s=s_x
	quit s
	;
rcv()	; read one framed message
	new n,s
	set s=$$rdn(2)
	if $zlength(s)'=2 quit ""
	set n=$zascii(s,1)*256+$zascii(s,2)
	quit $$rdn(n)
	;
proto()	; a protocol string the server accepts whatever its version. Only the 3 bytes at
	; CM_TYPE_OFFSET and the 3 at CM_LEVEL_OFFSET are examined by gtcm_protocol_match(); "999"
	; is at or above every level the server can be running, so this does not need maintaining.
	quit "X86LNXGTM071GCM999"_$select(le:" ",1:"B")_"              "
	;
zeros(n)	;
	new s
	set s="" for  quit:$zlength(s)'<n  set s=s_$zchar(0)
	quit $zextract(s,1,n)
	;
hand()	; CMMS_S_INITPROC handshake, 1 on success
	; 88 is SIZEOF(jnl_process_vector): 4 + 4 + 8 + 8 + JPV_LEN_NODE 16 + JPV_LEN_USER 12 +
	; JPV_LEN_PRCNAM 16 + JPV_LEN_TERMINAL 15 + 1 + 4 filler. gtcmtr_initproc() asserts the client
	; sent no more than that, so this length is part of a well formed handshake.
	new r
	do snd($zchar(33)_$$proto()_$$zeros(88))
	set r=$$rcv()
	if $zascii(r,1)'=37 quit 0
	; reply is CMMS_T_INITPROC then the 33 byte protocol string, so CM_ENDIAN_OFFSET (18) sits at
	; $EXTRACT position 1 + 1 + 18 = 20. GTCM_BIG_ENDIAN_INDICATOR is "B", little endian sends " ".
	set le=($zextract(r,20)'="B")
	quit 1
	;
ireg()	; CMMS_S_INITREG on the real database file, region number or -1
	new r
	do snd($zchar(34)_$$us($zlength(dbf))_dbf)
	set r=$$rcv()
	if $zascii(r,1)'=38 quit -1
	quit $zascii(r,2)
	;
key(sub)	; a well formed gv_key blob for ^<sub>: top, end, prev, then base
	new b
	set b=sub_$zchar(0,0)
	quit $$us(1024)_$$us($zlength(b)-1)_$$us(0)_b
	;
setup()	; connect, handshake, INITREG ; region number or -1
	if '$$conn() quit -1
	if '$$hand() quit -1
	quit $$ireg()
	;
noreg()	; the cases that need a region but could not open one
	do verdict("could not open a region on the server - TEST SETUP FAILED")
	quit
	;
; ------------------------------------------------------------------ cases
sanity	; a well formed exchange, so a failure below means the message and not the harness
	new regnum
	set regnum=$$setup()
	if regnum<0 do noreg() quit
	do snd($zchar(17)_$$us(1+$zlength($$key("x")))_$zchar(regnum)_$$key("x"))
	if $zascii($$rcv(),1)'=32 do verdict("a $GET of undefined ^x did not return CMMS_R_UNDEF - WRONG") quit
	if '$$serving() do verdict("server stopped serving after a valid exchange - WRONG") quit
	do verdict("valid handshake, INITREG and $GET all answered, server still serving")
	quit
	;
bigframe	; cmj_read_start() : a length prefix larger than the server's message buffer
	if '$$conn() do verdict("could not connect - TEST SETUP FAILED") quit
	do raw($zchar(234,96))	; announce 60000 bytes, then send none of them
	do judge("close")
	quit
	;
splitframe	; cmj_read_interrupt() : the same announcement with the 2-byte prefix split in two,
	; which is the path a client reaches by writing the prefix one byte at a time
	new i,junk
	if '$$conn() do verdict("could not connect - TEST SETUP FAILED") quit
	do raw($zchar(234))
	hang 1
	do raw($zchar(96))
	hang 1
	set junk="" for i=1:1:300 set junk=junk_"AAAAAAAAAA"	; 3000 bytes into a 532 byte buffer
	do raw(junk)
	do judge("close")
	quit
	;
longdbname	; gtcmd_ini_reg() : an INITREG naming a database file longer than MAX_FN_LEN
	new i,nm
	if '$$conn() do verdict("could not connect - TEST SETUP FAILED") quit
	if '$$hand() do verdict("handshake failed - TEST SETUP FAILED") quit
	set nm="/" for i=1:1:399 set nm=nm_"Z"
	do snd($zchar(34)_$$us($zlength(nm))_nm)
	do judge("reject")
	quit
	;
keylenbig	; gtcmtr_get_key() : a $GET whose declared key length exceeds the bytes sent
	new regnum
	set regnum=$$setup()
	if regnum<0 do noreg() quit
	do snd($zchar(17)_$$us(1+600)_$zchar(regnum)_$$key("x"))
	do judge("reject")
	quit
	;
keylenzero	; CM_GET_REGNUM() : a declared length of 0, which the pre-fix "len--" turned into 65535
	new regnum
	set regnum=$$setup()
	if regnum<0 do noreg() quit
	do snd($zchar(17)_$$us(0)_$zchar(regnum)_$$key("x"))
	do judge("reject")
	quit
	;
keyshape	; gtcmtr_get_key() : a key that fits but whose "end" points outside it
	new blob,regnum
	set regnum=$$setup()
	if regnum<0 do noreg() quit
	set blob=$$us(1024)_$$us(60000)_$$us(0)_"x"_$zchar(0,0)
	do snd($zchar(17)_$$us(1+$zlength(blob))_$zchar(regnum)_blob)
	do judge("reject")
	quit
	;
bufflush	; gtcmtr_bufflush() : 255 key bytes written at offset 255 of gv_currkey
	new i,k,regnum
	set regnum=$$setup()
	if regnum<0 do noreg() quit
	set k="" for i=1:1:255 set k=k_"A"
	do snd($zchar(50)_$$us(1)_$zchar(regnum,255,255,0)_k_$$us(0))
	do judge("reject")
	quit
	;
locklen	; gtcml_lklist() : a lock entry of declared length 0, which the pre-fix "len--" thrice
	; turned into 65533, sizing both an allocation and a copy out of a 532 byte buffer
	new regnum
	set regnum=$$setup()
	if regnum<0 do noreg() quit
	do snd($zchar(7,0,1,1)_$$us(0)_$zchar(regnum,0,1)_$zchar(3)_"abc")
	do judge("reject")
	quit
	;
locksubcnt	; gtcml_lklist() : a subscript count larger than the subscripts actually sent, which
	; walks MLK_PVTBLK_SUBHASH_GEN() off the end of the block just allocated
	new nref,regnum
	set regnum=$$setup()
	if regnum<0 do noreg() quit
	set nref=$zchar(3)_"abc"
	do snd($zchar(7,0,1,1)_$$us(3+$zlength(nref))_$zchar(regnum,0,9)_nref)
	do judge("reject")
	quit
	;
locktrail	; gtcml_lklist() : subscripts that parse but stop short of the declared length, leaving
	; a trailing byte the lock name reference does not account for
	new nref,regnum
	set regnum=$$setup()
	if regnum<0 do noreg() quit
	set nref=$zchar(3)_"abc"_$zchar(0)
	do snd($zchar(7,0,1,1)_$$us(3+$zlength(nref))_$zchar(regnum,0,1)_nref)
	do judge("reject")
	quit
	;
locknolistlen	; gtcml_lklist() : a message that ends before the byte holding the number of lock
	; entries, which the walk below reads without it having been received
	new regnum
	set regnum=$$setup()
	if regnum<0 do noreg() quit
	do snd($zchar(7,0,1))
	do judge("reject")
	quit
	;
lockshortentry	; gtcml_lklist() : one lock entry announced, but fewer than the 5 bytes its length,
	; region number, transaction level and subscript count occupy
	new regnum
	set regnum=$$setup()
	if regnum<0 do noreg() quit
	do snd($zchar(7,0,1,1)_$$us(8)_$zchar(regnum))
	do judge("reject")
	quit
	;
lockshortnref	; gtcml_lklist() : an entry whose declared length runs past the bytes received, which
	; sizes both the MLK_PVTBLK_ALLOC() and the memcpy() out of the message buffer
	new nref,regnum
	set regnum=$$setup()
	if regnum<0 do noreg() quit
	set nref=$zchar(3)_"abc"
	do snd($zchar(7,0,1,1)_$$us(3+20)_$zchar(regnum,0,1)_nref)
	do judge("reject")
	quit
	;
bufflushnotrans	; gtcmtr_bufflush() : a message that ends before the two byte count of buffered
	; transactions it carries, which the loop below reads without it having been received
	new regnum
	set regnum=$$setup()
	if regnum<0 do noreg() quit
	do snd($zchar(50))
	do judge("reject")
	quit
	;
bufflushnohdr	; gtcmtr_bufflush() : one transaction announced, but none of the four bytes its region
	; number, key length, common count and previous offset occupy
	new regnum
	set regnum=$$setup()
	if regnum<0 do noreg() quit
	do snd($zchar(50)_$$us(1))
	do judge("reject")
	quit
	;
bufflushshortkey	; gtcmtr_bufflush() : a key length longer than the key bytes that follow it, which
	; sizes the memcpy() into gv_currkey out of the message buffer
	new regnum
	set regnum=$$setup()
	if regnum<0 do noreg() quit
	do snd($zchar(50)_$$us(1)_$zchar(regnum,20,0,0)_"abc")
	do judge("reject")
	quit
	;
shortproto	; gtcmtr_initproc() : a handshake that ends inside the protocol string, which
	; gtcm_protocol_match() reads whole
	if '$$conn() do verdict("could not connect - TEST SETUP FAILED") quit
	do snd($zchar(33)_$zextract($$proto(),1,10))
	do judge("reject")
	quit
	;
initregnolen	; gtcmd_ini_reg() : an INITREG that ends before the two byte length of the database
	; file name it names
	if '$$conn() do verdict("could not connect - TEST SETUP FAILED") quit
	if '$$hand() do verdict("handshake failed - TEST SETUP FAILED") quit
	do snd($zchar(34))
	do judge("reject")
	quit
	;
initregshort	; gtcmd_ini_reg() : a database file name length longer than the name bytes that follow
	; it, which sizes the memcpy() into "buff" out of the message buffer
	if '$$conn() do verdict("could not connect - TEST SETUP FAILED") quit
	if '$$hand() do verdict("handshake failed - TEST SETUP FAILED") quit
	do snd($zchar(34)_$$us(50)_"/tmp/x")
	do judge("reject")
	quit
	;
shortjpv	; gtcmtr_initproc() : a handshake carrying less of a jnl_process_vector than the server
	; has room for, which the server has to accept and zero fill. Before the fix the subtraction
	; that sizes the copy was done on an "unsigned short" and went negative, so the clamp never
	; fired and the whole 88 bytes were copied out of a partly filled buffer.
	if '$$conn() do verdict("could not connect - TEST SETUP FAILED") quit
	do snd($zchar(33)_$$proto()_$$zeros(40))
	if $zascii($$rcv(),1)'=37 do verdict("a handshake carrying 40 of 88 jpv bytes was refused - WRONG") quit
	if '$$serving() do verdict("server stopped serving after a short handshake - WRONG") quit
	do verdict("short INITPROC accepted, server still serving")
	quit
	;
keylentiny	; gtcmtr_get_key() : a key too short to hold even its own top/end/prev header
	new regnum
	set regnum=$$setup()
	if regnum<0 do noreg() quit
	do snd($zchar(17)_$$us(1+6)_$zchar(regnum)_$$zeros(6))
	do judge("reject")
	quit
	;
keynoname	; gtcmtr_get_key() : a key of the right shape whose global variable name is empty.
	; gtcm_bind_name() takes the bytes before the first <NUL> as the name and needs a valid mident.
	new blob,regnum
	set regnum=$$setup()
	if regnum<0 do noreg() quit
	set blob=$$us(1024)_$$us(2)_$$us(0)_$$zeros(200)
	do snd($zchar(17)_$$us(1+$zlength(blob))_$zchar(regnum)_blob)
	do judge("reject")
	quit
	;
keylongname	; gtcmtr_get_key() : a global variable name longer than MAX_MIDENT_LEN
	new b,blob,i,nm,regnum
	set regnum=$$setup()
	if regnum<0 do noreg() quit
	set nm="" for i=1:1:40 set nm=nm_"a"
	set b=nm_$zchar(0,0)
	set blob=$$us(1024)_$$us($zlength(b)-1)_$$us(0)_b
	do snd($zchar(17)_$$us(1+$zlength(blob))_$zchar(regnum)_blob)
	do judge("reject")
	quit
	;
keybadname	; gtcm_bind_name() : a name of a legal length whose bytes are not an M name. A client
	; that gets one of these accepted creates a global MUPIP INTEG reports as DBBADKYNM, "Bad key
	; name", and that M code cannot reference: $ORDER at the name level returns it and any attempt
	; to use what came back raises GBLNAME.
	do badname("a-b")
	quit
	;
keydigitname	; gtcm_bind_name() : a name whose first byte is a digit, which is legal in a subscript
	; but not at the front of a name
	do badname("1ab")
	quit
	;
badname(nm)	; a $GET on ^<nm>, whose name is the right length but not a valid mident
	new b,blob,regnum
	set regnum=$$setup()
	if regnum<0 do noreg() quit
	set b=nm_$zchar(0,0)
	set blob=$$us(1024)_$$us($zlength(b)-1)_$$us(0)_b
	do snd($zchar(17)_$$us(1+$zlength(blob))_$zchar(regnum)_blob)
	do judge("reject")
	quit
	;
; ---- CM_GET_REGNUM() : the declared length of 0 that "keylenzero" sends to CMMS_Q_GET, sent to
; every other handler that reads the same prefix. The check is a macro expanded separately in each
; of them, so one case per handler.
lenzerodata	do lenzero(16) quit
lenzerokill	do lenzero(18) quit
lenzeroorder	do lenzero(19) quit
lenzerozprev	do lenzero(20) quit
lenzeroput	do lenzero(21) quit
lenzeroquery	do lenzero(22) quit
lenzerozwith	do lenzero(23) quit
lenzeroincr	do lenzero(53) quit
lenzerorevqry	do lenzero(55) quit
	;
lenzero(op)	; message type "op" with a declared length of 0
	new regnum
	set regnum=$$setup()
	if regnum<0 do noreg() quit
	do snd($zchar(op)_$$us(0)_$zchar(regnum)_$$key("x"))
	do judge("reject")
	quit
	;
; ---- gtcmtr_bufflush() : the assembled key has to be checked a piece at a time, so each rejection
; below stops at a different point in that check.
bufflushlenzero	; a key length of 0
	new regnum
	set regnum=$$setup()
	if regnum<0 do noreg() quit
	do snd($zchar(50)_$$us(1)_$zchar(regnum,0,0,0)_$$us(0))
	do judge("reject")
	quit
	;
bufflushend	; a key whose "end" points at a <NUL> but whose byte before it is not one, so the key
	; is not <NUL> terminated even though "end" looks plausible
	new regnum
	set regnum=$$setup()
	if regnum<0 do noreg() quit
	do snd($zchar(50)_$$us(1)_$zchar(regnum,3,0,0)_"xy"_$zchar(0)_$$us(0))
	do judge("reject")
	quit
	;
bufflushprev	; a <NUL> terminated key whose "prev" points past its "end"
	new regnum
	set regnum=$$setup()
	if regnum<0 do noreg() quit
	do snd($zchar(50)_$$us(1)_$zchar(regnum,3,0,5)_"x"_$zchar(0,0)_$$us(0))
	do judge("reject")
	quit
	;
bufflushnoname	; a key of the right shape whose global variable name is empty
	new regnum
	set regnum=$$setup()
	if regnum<0 do noreg() quit
	do snd($zchar(50)_$$us(1)_$zchar(regnum,3,0,0)_$zchar(0,0,0)_$$us(0))
	do judge("reject")
	quit
	;
bufflushnodata	; a well formed key with the value length missing altogether
	new regnum
	set regnum=$$setup()
	if regnum<0 do noreg() quit
	do snd($zchar(50)_$$us(1)_$zchar(regnum,3,0,0)_"x"_$zchar(0,0))
	do judge("reject")
	quit
	;
bufflushbigdata	; a well formed key followed by a value length larger than the bytes that follow it
	new regnum
	set regnum=$$setup()
	if regnum<0 do noreg() quit
	do snd($zchar(50)_$$us(1)_$zchar(regnum,3,0,0)_"x"_$zchar(0,0)_$$us(60000))
	do judge("reject")
	quit
	;
; ---- The reply side. The two cases below are the only ones that expect an answer rather than a
; rejection. They go through the raw socket rather than a real GT.CM client because a real client
; grows the server's message buffer with CMMS_B_BUFRESIZE before it can ask for a reply this large,
; which is exactly the case the fix is not about.
orderbigreply	; gtcmtr_order() : a $ORDER whose answer does not fit in the message buffer. The key is
	; the one op_gvorder() sends, ie GVKEY_INCREMENT_ORDER() applied to ^big("A"): the first of the
	; two terminating <NUL>s replaced by a 1 and a <NUL> appended. gtcmtr_order() asserts on that.
	do bigreply(19,27,"A"_$zchar(1))
	quit
	;
zprevbigreply	; gtcmtr_zprevious() : the same for $ZPREVIOUS, which sends the key unaltered
	do bigreply(20,28,"z")
	quit
	;
bigreply(op,want,sub)	; "op" on ^big(<sub>), whose neighbouring subscript is long enough that the
	; reply exceeds the CM_MSG_BUF_SIZE + CM_BUFFER_OVERHEAD (532) byte message buffer that both
	; handlers built their reply straight into before the fix. "prev" is the offset of the last
	; subscript, which is the STR_SUB_PREFIX byte right after the global name and its <NUL>; both
	; handlers take a "prev" of 0 to mean a name level operation instead.
	new b,blob,r,regnum
	set regnum=$$setup()
	if regnum<0 do noreg() quit
	set b="big"_$zchar(0,255)_sub_$zchar(0,0)
	set blob=$$us(1024)_$$us($zlength(b)-1)_$$us($zlength("big")+1)_b
	do snd($zchar(op)_$$us(1+$zlength(blob))_$zchar(regnum)_blob)
	set r=$$rcv()
	if $zascii(r,1)'=want do verdict("expected reply type "_want_", got "_$zascii(r,1)_" - WRONG") quit
	if $zlength(r)'>532 do verdict("reply was only "_$zlength(r)_" bytes, the buffer was not grown - WRONG") quit
	if '$$serving() do verdict("server stopped serving after a large reply - WRONG") quit
	do verdict("reply larger than the message buffer returned intact, server still serving")
	quit
