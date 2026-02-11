;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This module is derived from FIS GT.M.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2021-2026 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;
makecopies	; Create a script to make copies of the source code
		; then execute the script and compile the routines
	N copies,cpfile,debug,ldcmd,libext,ldfile,libinc,libsuf,numlibs,origperlib,osz,rnc,rno,rtnarray,rtncnt,rtnsuf,rtnperlib
	S copies=+$P($ZCM," ",1) S:(2>copies) copies=2 ; no longer used - computed base on need
	S rtnperlib=+$P($ZCM," ",2) S:(1>rtnperlib) rtnperlib=1000	; S:(rtnperlib>ldtocmax) rtnperlib=ldtocmax
	S debug=+$P($ZCM," ",3)
	W:debug copies," copies of each routine and new library every ",rtnperlib," routines",!
	V "NOLVNULLSUBS"
	; compile all original routines
	ZSY "cd o;find ../r -name \*.m | xargs -P 0 -n 64 -I % $gtm_dist/mumps % >&/dev/null;cd ..;du -sk o >osize.txt"
	O "osize.txt":READONLY U "osize.txt" R osz C "osize.txt"
	; Get list of routines and finalize number of original routines per library
	F rtncnt=0:1 S rno=$P($ZSEARCH("r/*.m"),".",1) Q:""=rno  S rtnarray($P(rno,"/",$L(rno,"/")))=""
	S copies=5000000/osz+1\1,numlibs=rtncnt*copies/rtnperlib\1
	S origperlib=rtncnt/numlibs\1
	;
	; Build shell script to make copies of files and list of files for ld
	S cpfile="makecopies"_$I(libcp)_".sh" O cpfile:(newversion:OWNER="RWX") U cpfile W "#!/usr/local/bin/tcsh",!
	S rnc="",rtncnt=0,rno="",ldfile="ldcmds"_$I(libsuf)
	O ldfile:newversion
	F rtnsuf=0:1:copies-1 D
	.F  S rnc=$O(rtnarray(rnc)) Q:""=rnc  D
	..I 0=(($I(rtncnt)+origperlib)#rtnperlib) D cpld(1)
	..S mrtn=rnc_"QWQ"_rtnsuf_".m"
	..U cpfile
	..W "cp -f r/",rnc,".m o/",mrtn,!,"cd o",!,"$gtm_dist/mumps ",mrtn," >&/dev/null",!,"rm -f ",mrtn,!,"cd ..",!
	..U ldfile W "o/",rnc,"QWQ",rtnsuf,".o",!
	D cpld(2) ; on the last call to cpld ask for twice as many original routines to ensure we get them all
	C cpfile:delete,ldfile:delete
	;
	do getnproc(.nproc)		; nproc contains the # of CPUs in the system
	if $increment(libsuf,-1)	; fix libsuf to remove last incomplete one
	set ^jobvar("libsuf")=libsuf
	set ^jobvar("nproc")=nproc
	do ^job("childcompile^makecopies",nproc,"""""")
	do ^job("childlink^makecopies",nproc,"""""")
	Q

cpld(i,cmd) ; Make copies of files, compile them
	U ldfile
	F rtncnt=rtncnt:1:rtncnt+(origperlib*i) S rno=$O(rtnarray(rno)) Q:""=rno  W "o/",rno,".o",!
	C cpfile,ldfile
	I debug U $P W "Copying and compiling routines with ",!
	S cpfile="makecopies"_$I(libcp)_".sh" O cpfile:(newversion:OWNER="RWX") U cpfile W "#!/usr/local/bin/tcsh",!
	S ldfile="ldcmds"_$I(libsuf)
	O ldfile:newversion
	Q

getnproc(nproc);
	new dev
	set dev="nproc"
	open dev:(command="nproc":readonly)::"PIPE"
	use dev
	read nproc
	close dev
	quit

childcompile	;
	set nproc=^jobvar("nproc")
	set libsuf=^jobvar("libsuf")
	for i=jobindex:nproc:libsuf zsystem "./makecopies"_i_".sh"
	quit

childlink	;
	set nproc=^jobvar("nproc")
	set libsuf=^jobvar("libsuf")
	for i=jobindex:nproc:libsuf do
	. set cmd="$gt_ld_m_shl_linker -fPIC -shared -z noexecstack -o largelib"_i_".so @ldcmds"_i
	. zsystem cmd
	quit

