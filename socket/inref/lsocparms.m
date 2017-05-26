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
lsocparms(path)
	; Test file related device parameters for LOCAL sockets
	; All are only processed for LISTENING sockets
	; On OPEN, NEWversion, GROUP, OWNER, WORLD, UIC
	; On CLOSE, DELETE
	If '$d(path) Set path="local.sock"
	Set socdev="socdev"
	Open socdev:::"SOCKET"
	Write "Testing NEWversion and DELETE",!
	Open socdev:(LISTEN=path_":LOCAL":attach="lx"):1:"SOCKET"
	Else  Write "FAIL: Open at "_$ZPOS_" failed",! Halt
	Zsystem "ls -la "_path_">& lsocdevparms.outx"
	If $Zsystem Write "FAIL: LOCAL socket file "_path_" not found at "_$ZPOS,! Halt
	Use socdev:detach="lx"		; Leave device open
	; Try opening with an existing path - do in DO for error handling
	Set zs=""
	Do
	. Open socdev:(LISTEN=path_":LOCAL":attach="l":ioerror="t":excep="set zs=$zstatus Quit"):1:"SOCKET"
	If zs="" Write "FAIL: Open at "_$ZPOS_" succeeded",! zshow "D" Halt
	Zsystem "ls -la "_path_">>& lsocdevparms.outx"
	If $Zsystem Write "LOCAL socket file "_path_" not found at "_$ZPOS,! Halt
	; Try opening with an existing path with NEWversion
	Open socdev:(LISTEN=path_":LOCAL":attach="l":NEW:except=""):1:"SOCKET"
	Else  Write "FAIL: Open at "_$ZPOS_" failed",! Halt
	Zsystem "ls -la "_path_">>& lsocdevparms.outx"
	If $Zsystem Write "LOCAL socket file "_path_" not found at "_$ZPOS,! Halt
	Close socdev
	Zsystem "ls -la "_path_">>& lsocdevparms.outx"
	If $Zsystem=0 Write "LOCAL socket file "_path_" not removed at "_$ZPOS,! Halt
	; Try opening with an existing path with NEWversion
	Open socdev:(LISTEN=path_":LOCAL":attach="ly"):1:"SOCKET"
	Use socdev:detach="ly"
	Open socdev:(LISTEN=path_":LOCAL":attach="l":NEW):1:"SOCKET"
	Else  Write "FAIL: Open at "_$ZPOS_" failed",! Halt
	Zsystem "ls -la "_path_">>& lsocdevparms.outx"
	If $Zsystem Write "LOCAL socket file "_path_" not found at "_$ZPOS,! Halt
	Close socdev:(socket="l")
	Zsystem "ls -la "_path_">>& lsocdevparms.outx"
	If $Zsystem=0 Write "FAIL: LOCAL socket file "_path_" found at "_$ZPOS_" after delete",! Halt
	; Try setting permission and group
	Write "Setting permission and group",!
	; Get our uid and the gid for gtmtest
	Set p="p" o p:(shell="/bin/sh":command="id")::"pipe"
	; id:  uid=uu(uname) gid=gg(gname) groups=sgn1(sgname1),...
	Use p Read id Close p
	Set uid=$extract(id,5,$find(id,"(")-2)	;not "(" and first letter of user name
	Set sgroups=$piece(id,"=",4,9999),sgstart=1
	For index=1:1 Quit:($data(sgid)!($get(sg,"first")=""))  Do
	. Set sg=$piece(sgroups,")",index)
	. If sg["gtmtest" Set sgid=$extract($piece(sg,"("),sgstart,999) Quit
	. Set sgstart=2		; past comma
	If '$data(sgid) Write "FAIL: gtmtest not in groups = ",sgroups,! Halt
	Set of="lsocdevparms.outx" Open of:read Use of Read olsla Close of
	Set molsla=$$^%MPIECE(olsla)	; strip multiple spaces
	Set group=$piece(molsla," ",4)
	If group["gtmtest" Use $P Write "FAIL: default group ("_group_" contains gtmtest",! Halt
	For index=2,5,8 Do	; type then rwx for owner, group, other
	. Set uic=$select(index=5:":uic=uid_"",""_sgid",1:"")	; only for GROUP
	. Set currperm=$extract(olsla,index,index+2)
	. Set wantperm=$select(currperm="rwx":"rw",1:"rwx")	; if current perm already rwx set it to just rw
	. Set whichperm=$select(index=2:"OWNER",index=5:"GROUP",index=8:"WORLD")
	. Set permarg=whichperm_"="""_wantperm_""""
	. Set openarg="socdev:(LISTEN=path_"":LOCAL"":attach=""l"":NEW:ioerror=""t"":"_permarg_uic_"):1:""socket"""
	. Open @openarg
	. Zsystem "ls -la "_path_">& lsocdevperm"_index_".outx"
	. Set f="lsocdevperm"_index_".outx" open f:read use f read lsla close f
	. Set nowperm=$translate($extract(lsla,index,index+2),"-")
	. If nowperm'=wantperm Write "FAIL: "_path_" "_whichperm_" permission expected "_wantperm_" but was ",nowperm,! Halt
	. Close socdev
	. If index=5 Do
	. . Set mlsla=$$^%MPIECE(lsla)	; strip multiple spaces
	. . Set group=$piece(mlsla," ",4)
	. . If group'["gtmtest" Write "FAIL: "_path_" group expected to be gtmtest but was "_group,! Halt
	. . Quit
	Write "lsocparms.m done",!
	Quit
