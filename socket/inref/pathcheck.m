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
	; see if path in zshow "D" and if so return R for remote, L for local
	; if handle present, restrict check to handle
pathcheck(path,handle) ;performs a ZSHOW device
	new foundpath,lhandle,prevdev,showtmp,thandle,tmp,tmp1,where
	set foundpath="",lhandle=$get(handle)
	set prevdev=$IO
	ZSHOW "D":showtmp
	use $PRINCIPAL
	set tmp="showtmp"
	for  set tmp=$QUERY(@tmp) quit:tmp=""  do:@tmp["SOCKET["
	. set tmp1=@tmp
	. If lhandle'="" Do  Quit:lhandle'=thandle	; Skip if not requested handle
	. . Set where=$zfind(tmp1,"]=")			; SOCKET[index]=handle
	. . Set thandle=$extract(tmp1,where,$zlength(tmp1))
	. . Set thandle=$piece(thandle," ")		; just the handle
	. Set where=$zfind(tmp1,"="_path) Do:where
	. . Set where=where-$zlength(path)-2		; before =
	. . Set tmp1=$extract(tmp1,where)		; should be last letter of REMOTE or LOCAL
	. . Set foundpath=$select(("E"=tmp1):"R",("L"=tmp1):"L",1:"")
	if foundpath="" write path_" NOT FOUND",!,"BEGIN Full ZSHOW ""D""",!  zwrite showtmp  write "END Full ZSHOW ""D""",!
	use prevdev
	quit foundpath
;
;	Version using $zsocket
zpathcheck(dev,path,handle) ;check for path using $zsocket
	New foundpath,lhandle,prevdev,index
	Set foundpath="",foundhandle="",lhandle=$get(handle)
	Set prevdev=$IO
	Use dev
	If lhandle'="" Do
	. Set index=$zsocket("","INDEX",lhandle)
	. If index="" Quit
	. If $zsocket("","LOCALADDRESS",index)=path Set foundpath="L" Quit
	. If $zsocket("","REMOTEADDRESS",index)=path Set foundpath="R" Quit
	Else  Do
	. For index=0:1:$zsocket("","NUMBER") Do  Quit:foundpath'=""
	. . If $zsocket("","LOCALADDRESS",index)=path Set foundpath="L" Quit
	. . If $zsocket("","REMOTEADDRESS",index)=path Set foundpath="R" Quit
	If foundpath="" Do
	. Use $PRINCIPAL
	. Write "FAIL: "_path_" NOT FOUND",!,"BEGIN Full ZSHOW ""D""",!
	. Zshow "D"  Write "END Full ZSHOW ""D""",!
	Use prevdev
	Quit foundpath

