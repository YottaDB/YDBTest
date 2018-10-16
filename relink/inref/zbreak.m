;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2014, 2015 Fidelity National Information	;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
; Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; This program attempts to exhaustively test the ZBREAK functionality in conjunction with various GT.M operating modes (such as
; autorelink and recursive relink). It produces a number of M scripts along with the outputs expected from their execution. Each
; M script contains the following lines:
;
;    view "link":"recursive"						Enable recursive relink (optional).
;    set $zroutines="dir(dir)"						Have dir autorelink-enabled or not.
;    zlink "rtn"							ZLINK the routine before execution (optional).
;    zbreak rtn+2^rtn:"write ""driving ZBREAK"",!"			Set the ZBREAK on the routine (optional).
;    write "After installation:",!
;    zshow "B"								Print the active ZBREAKs.
;    do ^rtn("callback^"_$text(+0))					Invoke the routine, argument (if present) telling it what
;        								callback function to invoke.
;   callback
;    set $zroutines="dir(dir)"						Change or keep dir's autorelink status.
;    quit:($stack=0)							Do not continue in the base frame (optional).
;    hang 0.01 if $&ydbposix.cp("dir/rtn.m.copy","dir/rtn.m",.errno)	Replace rtn.m with a new version (optional).
;    do
;    . new $etrap
;    . set $etrap="write ""ZLINK FAILED: ..."",! set $ecode="""""
;    . zlink "rtn"							Relink the routine (optional).
;    do ^rtn()								Invoke the routine without the callback (optional).
;    write "In callback:",!
;    zshow "B"								Print the active ZBREAKs.
;    quit
;
zbreak
	new TRUE,FALSE,PLAIN,STARRED,SHARED,LIBSUFFIX
	new i,fmode,dir,rtn,errno,lines,file,sharedLibSuffix
	new LINKEDFROMTYPE,ALREADYLINKED,RECURSIVERELINK,ZBREAKINSTALLED,RECURSE
	new LINKNEWFROMTYPE,CONTINUEINBASEFRAME,UPDATERTN,RELINKRTN,EXECUTERTN

	set TRUE=1,FALSE=0
	set PLAIN=1,STARRED=2,SHARED=3
	set LIBSUFFIX=$ztrnlnm("gt_ld_shl_suffix")
	set:(""=LIBSUFFIX) LIBSUFFIX=".so"

	if $&ydbposix.umask(0,,.errno)
	set fmode=511
	set dir="dir"
	set rtn="rtn"
	if $&ydbposix.mkdir(dir,fmode,.errno)

	do generateRoutine(dir_"/rtn.m","write ""This is rtn"",!")
	do generateRoutine(dir_"/rtn.m.orig","write ""This is rtn"",!")
	do generateRoutine(dir_"/rtn.m.copy","write ""This is rtn copy"",!")

	set i=0
	for RECURSIVERELINK=TRUE,FALSE for LINKEDFROMTYPE=PLAIN,STARRED,SHARED for ALREADYLINKED=TRUE,FALSE for ZBREAKINSTALLED=TRUE,FALSE for RECURSE=TRUE,FALSE do
	.	for LINKNEWFROMTYPE=PLAIN,STARRED,SHARED for CONTINUEINBASEFRAME=TRUE,FALSE for UPDATERTN=TRUE,FALSE for RELINKRTN=TRUE,FALSE for EXECUTERTN=TRUE,FALSE do
	.	.	; We could not have linked in some "special" way if we have not linked at all.
	.	.	quit:(PLAIN'=LINKEDFROMTYPE)&(FALSE=ALREADYLINKED)
	.	.
	.	.	; If we are not recursing into the routine, we better continue past the invocation.
	.	.	quit:('CONTINUEINBASEFRAME)&('RECURSE)
	.	.
	.	.	; Are we allowing recursive relinks?
	.	.	set lines(1)=$select(RECURSIVERELINK:" view ""link"":""recursive""",1:"")
	.	.
	.	.	; Should we choose a shared library, we are starting with the original version.
	.	.	set sharedLibSuffix=".orig"
	.	.
	.	.	; If we linked the routine already, was it from an autorelink-enabled directory or shared library?
	.	.	if (STARRED=LINKEDFROMTYPE) do
	.	.	.	set lines(2)=" set $zroutines="""_dir_"*("_dir_")"""
	.	.	else  if (SHARED=LINKEDFROMTYPE) do
	.	.	.	set lines(2)=" set $zroutines="""_dir_"/lib"_rtn_sharedLibSuffix_LIBSUFFIX_""""
	.	.	else  do
	.	.	.	set lines(2)=" set $zroutines="""_dir_"("_dir_")"""
	.	.
	.	.	; Did we link the routine already?
	.	.	set lines(3)=$select(ALREADYLINKED:" zlink """_rtn_"""",1:"")
	.	.
	.	.	; Are we going to install a ZBREAK?
	.	.	set lines(4)=$select(ZBREAKINSTALLED:" zbreak "_rtn_"+2^"_rtn_":""write """"driving ZBREAK"""",!""",1:"")
	.	.	set lines(5)=" write ""After installation:"",!"
	.	.	set lines(6)=" zshow ""B"""
	.	.
	.	.	; Will we recurse to ZLINK (and possibly execute) a potentially new version of this routine?
	.	.	set lines(7)=" do ^"_rtn_"("_$select(RECURSE:"""callback^""_$text(+0)",1:"")_")"
	.	.	set lines(8)=$select(RECURSE:"callback",1:"")
	.	.
	.	.	; Will we relink/reexecute from an autorelink-enabled directory or shared library?
	.	.	if (STARRED=LINKNEWFROMTYPE) do
	.	.	.	set lines(9)=" set $zroutines="""_dir_"*("_dir_")"""
	.	.	else  if (SHARED=LINKNEWFROMTYPE) do
	.	.	.	set lines(9)=" set $zroutines="""_dir_"/lib"_rtn_sharedLibSuffix_LIBSUFFIX_""""
	.	.	else  do
	.	.	.	set lines(9)=" set $zroutines="""_dir_"("_dir_")"""
	.	.
	.	.	; Should we continue executing instructions under the callback label upon returning from rtn?
	.	.	set lines(10)=$select(('CONTINUEINBASEFRAME):" quit:($stack=0)",1:"")
	.	.
	.	.	; Will we update the routine before it is potentially relinked?
	.	.	if ('UPDATERTN) do
	.	.	.	set lines(11)=""
	.	.	else  if (SHARED=LINKNEWFROMTYPE) do
	.	.	.	; With shared libraries we cannot simply replace one file with another because that results in erroneous
	.	.	.	; behavior (not GT.M's fault) on some platforms and is totally unsupported on others. Instead we just need
	.	.	.	; to point $zroutines to the location of the alternative shared library.
	.	.	.	if (SHARED=LINKNEWFROMTYPE) do
	.	.	.	.	set sharedLibSuffix=".copy"
	.	.	.	.	set lines(9)=" set $zroutines="""_dir_"/lib"_rtn_sharedLibSuffix_LIBSUFFIX_""""
	.	.	.	set lines(11)=""
	.	.	else  do
	.	.	.	set lines(11)=" hang 0.01 if $&ydbposix.cp("""_dir_"/"_rtn_".m.copy"","""_dir_"/"_rtn_".m"",.errno)"
	.	.
	.	.	; Will we relink the potentially different version of the routine?
	.	.	if (RELINKRTN) do
	.	.	.	set lines(12)=" do"
	.	.	.	set lines(13)=" . new $etrap"
	.	.	.	set lines(14)=" . set $etrap=""write """"ZLINK FAILED: """"_$piece($piece($zstatus,"""","""",3),""""-"""",3),! set $ecode="""""""""""
	.	.	.	set lines(15)=" . zlink """_rtn_""""
	.	.	else  set (lines(12),lines(13),lines(14),lines(15))=""
	.	.
	.	.	; Will we recursively call a potentially different version of the routine?
	.	.	set lines(16)=$select(EXECUTERTN:" do ^"_rtn_"()",1:"")
	.	.
	.	.	; Finally, generate a test case for the chosen options.
	.	.	do generateTestCase($increment(i),.lines)

	set file="test_count"
	open file:newversion
	use file
	write i
	set $x=0
	close file
	quit

generateTestCase(index,lines)
	new i,file,updatedRoutine,linkTypeChanged,linkSourceChanged,zlinkFailed

	; Generate the test to run.
	set file="test"_index_".m"
	open file:newversion
	use file
	for i=1:1 quit:('$data(lines(i)))  write:(""'=lines(i)) lines(i),!
	write " write ""In callback:"",!",!
	write " zshow ""B""",!
	write " quit",!
	close file

	set file="test"_index_".cmp"
	open file:newversion
	use file

	set (updatedRoutine,zlinkFailed)=0
	set linkTypeChanged=((STARRED=LINKEDFROMTYPE)&(STARRED'=LINKNEWFROMTYPE))!((STARRED'=LINKEDFROMTYPE)&(STARRED=LINKNEWFROMTYPE))
	set linkSourceChanged=((LINKEDFROMTYPE=STARRED)!(LINKNEWFROMTYPE=STARRED))&(LINKEDFROMTYPE'=LINKNEWFROMTYPE)

	write "After installation:",!
	write:(ZBREAKINSTALLED) "rtn+2^rtn",!
	write "This is rtn",!
	write:(ZBREAKINSTALLED) "driving ZBREAK",!

	; Let us first consider the case when we recursively invoke the callback function.
	if (RECURSE) do
	.	; When we are trying to relink a routine and have either updated the code or are attempting a different link type than
	.	; originally, the zlink will not be bypassed, but since we already have a version of the same routine on the stack, we
	.	; cannot allow two versions unless recursive relink is enabled.
	.	if (('RECURSIVERELINK)&(RELINKRTN)&(UPDATERTN!linkTypeChanged)) do
	.	.	write "ZLINK FAILED: LOADRUNNING",!
	.	.	set zlinkFailed=1
	.
	.	; If we are executing the routine, its identifier message (and potentially the one from the ZBREAK if it is still in
	.	; effect) should get printed.
	.	if (EXECUTERTN) do
	.	.	; When recursing, a new copy of the routine is only possible when the routine has been updated and if the
	.	.	; recursive relink is enabled. But even then we must have either explicitly relinked the routine or both
	.	.	; originally linked it from a starred directory and not installed any ZBREAKs since (because the installation
	.	.	; of ZBREAKs on autorelink-enabled routine disables autorelink).
	.	.	if ((RECURSIVERELINK)&(UPDATERTN)&((RELINKRTN)!((STARRED=LINKEDFROMTYPE)&('ZBREAKINSTALLED)))) do
	.	.	.	write "This is rtn copy",!
	.	.	.	; Remember that the routine has changed now.
	.	.	.	set updatedRoutine=1
	.	.	else  do
	.	.	.	write "This is rtn",!
	.	.
	.	.	; To have a ZBREAK go off, it should have been installed, and the routine should have either not been
	.	.	; explicitly relinked or the relink (explicit or not) should have failed, thus ultimately neutralizing it.
	.	.	write:((ZBREAKINSTALLED)&((zlinkFailed)!('RELINKRTN))) "driving ZBREAK",!
	.
	.	; If we are not executing the routine but have updated and relinked it in the recursive relink case (meaning that the
	.	; relink took effect), we want to note down the fact the routine has changed.
	.	set:((RECURSIVERELINK)&(UPDATERTN)&(RELINKRTN)) updatedRoutine=1
	.
	.	write "In callback:",!
	.
	.	; To have ZBREAKs in effect at the time of the recursive callback, they must have been installed in the first place.
	.	; But because a ZLINK is supposed to remove ZBREAKs, we either should have not relinked the routine, updated it to a
	.	; different version (thus preserving the original version's ZBREAKs), or we are now linking from a different source
	.	; (ensures that we are not bypassing the link).
	.	write:((ZBREAKINSTALLED)&((UPDATERTN)!('RELINKRTN)!(linkSourceChanged))) "rtn+2^rtn",!

	; Now we are considering the case when we either falled into the callback label in the base frame upon returing from the first
	; external routine call or never called the external routine at all, simply continuing into the code below.
	if (('RECURSE)!CONTINUEINBASEFRAME) do
	.	; If we are executing the routine, its identifier message (and potentially the one from the ZBREAK if it is still in
	.	; effect) should get printed.
	.	if (EXECUTERTN) do
	.	.	; At this point we are not recursing, so recursive relink does not matter, yet we must still have either
	.	.	; explicitly relinked the routine or both originally linked it from a starred directory and not installed any
	.	.	; ZBREAKs since (because the installation of ZBREAKs on autorelink-enabled routine disables autorelink).
	.	.	; Alternatively, the routine might have already been updated by an earlier logic.
	.	.	if (updatedRoutine)!((UPDATERTN)&((RELINKRTN)!((STARRED=LINKEDFROMTYPE)&('ZBREAKINSTALLED)))) do
	.	.	.	write "This is rtn copy",!
	.	.	else  do
	.	.	.	write "This is rtn",!
	.	.	.
	.	.	.	; To have a ZBREAK go off, it should have been installed, and the routine should have neither been
	.	.	.	; explicitly nor implicitly relinked (the latter guaranteed by the conditions of this else block).
	.	.	.	write:((ZBREAKINSTALLED)&('RELINKRTN)) "driving ZBREAK",!
	.
	.	write "In callback:",!
	.
	.	; To have ZBREAKs in effect at the end of the execution chain, they must have been installed in the first place.
	.	; But because a ZLINK is supposed to remove ZBREAKs, we should have relinked the routine neither explicitly nor
	.	; implicitly. (The latter is guaranteed by updatedRoutine being FALSE, since all alternative conditions for
	.	; implicitly linking the routine at this stage are violated by the presence of the ZBREAK and no explicit ZLINK.)
	.	write:((ZBREAKINSTALLED)&('RELINKRTN)&('updatedRoutine)) "rtn+2^rtn",!

	close file

	quit

generateRoutine(file,code)
	open file:newversion
	use file
	write "rtn(callback)",!
	write " ",code,!
	write " set x=0 ; place to set a zbreak",!
	write " do:(""""'=$get(callback)) @callback",!
	write " quit",!
	close file
	quit
