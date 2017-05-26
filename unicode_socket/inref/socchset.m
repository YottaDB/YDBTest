;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2014 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
socchset(host,port)	; check changing chset not allowed if socket already in socket device
        set:$data(port)=0 port=6666
        set:$data(host)=0 host="localhost"
	set s="socdev",errors=0
	open s:(listen=port_":TCP":attach="listen":chset="M")::"socket"
	set lchset0=$$getchset^gethandle(s,0)
	if lchset0'="M" set errors=$i(errors) do
	. use 0 write "TEST-E-FAIL lchset0 expected = M, got = "_lchset0,!
	close s:destroy
	open s:chset="UTF-16BE"::"socket"
	open s:(listen=port_":TCP":attach="listen")::"socket"
	set lchset=$$getchset^gethandle(s,0)
	if lchset'="UTF-16BE" set errors=$i(errors) do
	. use 0 write "TEST-E-FAIL lchset expected = UTF-16BE, got = "_lchset,!
	. zshow "D"
	open s:(connect=host_":"_port_":TCP":attach="conn":chset="UTF-16BE")::"socket"
	set cchset=$$getchset^gethandle(s,1)
	if cchset'="UTF-16BE" set errors=$i(errors) do
	. use 0 write "TEST-E-FAIL cchset expected = UTF-16BE, got = "_cchset,!
	set $ztrap="new $ztrap goto trapit"
	do	; the following should error
	. open s:(connect=host_":"_port_":TCP":attach="conn2":chset="M")::"socket"
	. use 0 write "TEST-E-FAIL changing chset didn't produce an error",!
	. set errors=$i(errors)
	. zshow "D"
	if errors>0 use 0 zshow "D" zwrite
	else  use 0 write "PASS",!
	quit
trapit	use 0
	if $zstatus["CHSETALREADY" do
	. write "Expected error:",!
	. zwrite $zstatus
	else  do
	. write "TEST-E_FAIL unexpected error",!
	. zwrite zstatus
	. set errors=$i(errors)
	quit
