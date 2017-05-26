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
gdefill	; simple fill routine to create some globals in the form:
	; Xx0123<...>, for X:A,B,C,D,E, and x:a,b,c,d,e
	set gbls="ABCDE"
	set letters="abcde"
	set maxlen=$ztrnlnm("maxlen")
	set filen="gdefill.out"
	open filen:(append)
	use filen
	for xg=1:1:5  do
	. set gbl=$EXTRACT(gbls,xg,xg)
	. for xl=1:1:5  do
	.. set let=$EXTRACT(letters,xl,xl)
	.. set num=""
	.. for xn=3:1:(maxlen+1)  do
	... set num=num_(xn#10)
	... set gblnum="^"_gbl_let_num
	... set gblnum1=gblnum
	... set @gblnum1=1
	... set gblnum2=gblnum_"a"
	... set @gblnum2=2
	... set gblnum3=gblnum_"(1)"
	... set @gblnum3=3
	... set gblnum4=gblnum_"a(1)"
	... set @gblnum4=4
	; and some globals on the boundary
	set ^Ab=1,^Ab(1)=2
	set ^Ba3456789010=1,^Ba3456789010(1)=2
	set ^Bb34567890123456789010=1,^Bb34567890123456789010(1)=2
	set ^Bc34567890123456789012345678A=1,^Bc34567890123456789012345678A(1)=2
	set ^Ca345678902=1,^Ca345678902(1)=2
	set ^Cb3456789012345678902=1,^Cb3456789012345678902(1)=2
	set ^Cc34567890123456789012345678A=1,^Cc34567890123456789012345678A(1)=2
	set ^Cd34567890123456789012345678900=1,^Cd34567890123456789012345678900(1)=2
	set ^Da345678902=1,^Da345678902(1)=2
	set ^Db3456789012345678902=1,^Db3456789012345678902(1)=2
	set ^Dc3456789012345678901234567890=1,^Dc3456789012345678901234567890(1)=2
	set ^Dd34567890123456789012345678901=1,^Dd34567890123456789012345678901(1)=2
	set ^Dd34567890123456789012345678902=1,^Dd34567890123456789012345678902(1)=2
	set ^Dd3456789012345678901234567891=1,^Dd3456789012345678901234567891(1)=2
	zwrite ^?.E

	close filen
	quit
set2(maxlen,iter)	; set globals for gde_long2.com
	 ; set's them in four chunks (so as not to open 62 regions)
	 ; iter shows which ones to set.
	 set gbl="A"
	 set num=""
	 set filen="set2_gdefill.out"
	 open filen:(append)
	 use filen
	 set ^A=1
	 set ^B=1
	 set ^C=1
	 for xn=2:1:maxlen  do
	 . set num=num_(xn#10)
	 . set gblnum="^"_gbl_num
	 . set numnext=((xn+1)#10)
	 . if (xn#31=iter)  do
	 .. for gbltoset=gblnum,gblnum_"A",gblnum_"(1)",gblnum_"a(1)",gblnum_numnext,gblnum_numnext_"A",gblnum_numnext_"(1)",gblnum_numnext_"a(1)"  do
	 ... set @gbltoset=gbltoset
	 close filen
	 quit
set3(maxlen,iter)	; set globals for gde_long3.com
	 set num=""
	 set length=maxlen-1
	 for i=2:1:length  do
	 . set num=num_(i#10)
	 set gbl="A"_num
	 set letters="0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
	 set filen="set3_gdefill.out"
	 open filen:(append)
	 use filen
	 for xn=1:1:62  do
	 . set let=$EXTRACT(letters,xn,xn)
	 . set gblnum="^"_gbl_let
	 . if (xn#62=iter) do
	 .. set gblnum1=gblnum
	 .. write gblnum1,!
	 .. set @gblnum1=1
	 .. set gblnum2=gblnum_"a"
	 .. write gblnum2,!
	 .. set @gblnum2=2
	 .. set gblnum3=gblnum_"(1)"
	 .. write gblnum3,!
	 .. set @gblnum3=3
	 .. set gblnum4=gblnum_"a(1)"
	 .. write gblnum4,!
	 .. set @gblnum4=4
	 close filen
	quit
order3	; test name level $ORDER() (in both directions) of max length names works
	write "Will test name level $ORDER() (in both directions) of max length names works",!
	write "Will loop through only the globals that are set using set3^gdefill",!
	write "loop through all globals A23* to verify $ORDER",!
	set x="^%" for  set x=$order(@x,1) q:x'["^A2"  write x,!
	write "loop through all globals A23* to verify $ORDER(x,-1)",!
	set x="^Aa" for  set x=$order(@x,-1) q:x=""  write x,!
	quit
