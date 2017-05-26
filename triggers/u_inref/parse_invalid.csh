#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2010-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
source $gtm_tst/com/dbcreate.csh mumps 5 255 4096 8192

# Testing the trigger command file parsing
# trigvn -command=cmd[,...] -xecute=strlit [-[z]delim="expr]" [-pieces=[lvn=]int1[:int2][;...]] [-options=[isolation][,consistencycheck]]
# trigvn	:
# 	Null Subscripts		^trigvn
#	Ranges			^trigvn(:) , ^trigvn(:2;5:) , ^trigvn(:"b";"m":"x")
#	Multiple Ranges		^trigvn(0,:,:) , ^trigvn(";":":";5:)
#				^trigvn(:,55;66;77:,:) , ^trigvn(2:,:"m";10;20;25;30;35;44;50,:)
#	Allow LVNs		^trigvn(tvar=:,tvar2="a":"z",tvar3=:10;20)
#
# -command=	S[ET],K[ILL],ZTK[ill],ZK[ill],ZW[ithdraw]
# 	Set only
# 	Kill only
# 	Set and Kill type
#
# -xecute=	"do ^twork"
# 		"do tsubrtn^twork"
# 		"do ^twork()"
# 		"do tsubrtn^twork()"
# 		"do ^twork(lvnname)"
# 		"do tsubrtn^twork(""5"",5)"
#
# -[z]delim=
# 	Single character	,
# 	Multiple characters	~"`
# 	With $[Z]Char		\$zchar(126)_\$char(96) aka ~`
# 	W/nonprinting $[z]char	\$zchar(9)_\$char(254)_""""
# 	Unicode character	\$char(8364)_\$char(36)_`
# 	\$zchar on Unicode chars	\$zchar(8364)_\$zchar(65284) 1st bytes of the euro and full dollar
#
# -piece=
# 	single piece	1
# 	multiple pieces	4;5;6  <--- doubles as collapsable
# 	range of piece	1:8
# 	discontiguous	1:3;7:8
# 	collapsable range
# 	with LVN	tlvn=1:3;5:6;7:8
#
# -options=
# 	isolation		i,isolation
# 	noisolation		noi,noisolation
# 	c[onsistencycheck]	c
# 	noc[onsistencycheck]	noc
#
# -name=
# 	allow use of all graphic characters 32-126
# 	allow names up to 28 characters
# 	disallow use of all non-graphic characters 1-31,127-155
#	disallow names over 28 characters

cat > zload.m << MPROG
zload
	set file=\$zcmdline
byfile
	set x='\$ztrigger("file",file)
byitem
	open file:readonly
	use file
	for  read line quit:\$zeof  do
	.	use \$p
	.	set x=\$ztrigger("item",line)
	.	if 'x  write "FAILED: ",line,!
	. 	use file
	close file
	quit
show
	use \$p
	if '\$ztrigger("select") write "Select failed",!
	write !
	quit
MPROG
$convert_to_gtm_chset zload.m

echo "Invalid test cases"

echo "======================="
echo "Invalid global variable name"
# Disallow use of anything other than an M-literal, like @, local and global variable names in subscripts
#    1 require subscript		^trigvn()
#    2 block use of another global var	^trigvn(^globalvar)
#    3 block local variables		^trigvn(localvar)
#    4 block indirection		^trigvn(@("blah"))
#    5 invliad trigger			^#t
#    6 invalid global vairable name	^1a

set ntest="invalid_global"
cat  > ${ntest}.trg  <<TFILE
-*
;    1 require subscript		^trigvn()
+^a() -command=SET -xecute="do ^twork"
;    2 block use of another global var	^trigvn(^globalvar)
+^a(^a(1)) -command=SET -xecute="do ^twork"
;    3 block local variables		^trigvn(localvar)
+^a(lvn) -command=SET -xecute="do ^twork"
;    4 block indirection		^trigvn(@("blah"))
+^a(@("blah")) -command=SET -xecute="do ^twork"
;    5 invliad trigger			^#t
+^#t -command=SET -xecute="do ^twork"
;    set k=32 for x=k:1:126 if \$select(\$char(x)="%":0,\$char(x)]"z":1,\$char(x)']"@":1,\$select(\$char(x)]"\`":0,\$char(x)']"Z":0,1:1):1,1:0) write \$char(94,x,97,9),"-command=s -xecute=""Do invalid^gvn""",!
;    6 invalid global vairable names	^1a
+^\!a	-command=s -xecute="Do invalid^gvn"
+^"a	-command=s -xecute="Do invalid^gvn"
+^#a	-command=s -xecute="Do invalid^gvn"
+^\$a	-command=s -xecute="Do invalid^gvn"
+^&a	-command=s -xecute="Do invalid^gvn"
+^'a	-command=s -xecute="Do invalid^gvn"
+^(a	-command=s -xecute="Do invalid^gvn"
+^)a	-command=s -xecute="Do invalid^gvn"
+^*a	-command=s -xecute="Do invalid^gvn"
+^+a	-command=s -xecute="Do invalid^gvn"
+^,a	-command=s -xecute="Do invalid^gvn"
+^-a	-command=s -xecute="Do invalid^gvn"
+^.a	-command=s -xecute="Do invalid^gvn"
+^/a	-command=s -xecute="Do invalid^gvn"
+^0a	-command=s -xecute="Do invalid^gvn"
+^1a	-command=s -xecute="Do invalid^gvn"
+^2a	-command=s -xecute="Do invalid^gvn"
+^3a	-command=s -xecute="Do invalid^gvn"
+^4a	-command=s -xecute="Do invalid^gvn"
+^5a	-command=s -xecute="Do invalid^gvn"
+^6a	-command=s -xecute="Do invalid^gvn"
+^7a	-command=s -xecute="Do invalid^gvn"
+^8a	-command=s -xecute="Do invalid^gvn"
+^9a	-command=s -xecute="Do invalid^gvn"
+^:a	-command=s -xecute="Do invalid^gvn"
+^;a	-command=s -xecute="Do invalid^gvn"
+^<a	-command=s -xecute="Do invalid^gvn"
+^=a	-command=s -xecute="Do invalid^gvn"
+^>a	-command=s -xecute="Do invalid^gvn"
+^?a	-command=s -xecute="Do invalid^gvn"
+^@a	-command=s -xecute="Do invalid^gvn"
+^[a	-command=s -xecute="Do invalid^gvn"
+^\\a	-command=s -xecute="Do invalid^gvn"
+^]a	-command=s -xecute="Do invalid^gvn"
+^^a	-command=s -xecute="Do invalid^gvn"
+^_a	-command=s -xecute="Do invalid^gvn"
+^\`a	-command=s -xecute="Do invalid^gvn"
+^{a	-command=s -xecute="Do invalid^gvn"
+^|a	-command=s -xecute="Do invalid^gvn"
+^}a	-command=s -xecute="Do invalid^gvn"
+^~a	-command=s -xecute="Do invalid^gvn"
TFILE
$convert_to_gtm_chset ${ntest}.trg
$MUPIP trigger -triggerfile=${ntest}.trg -noprompt
if ($status != 0) echo "PASS ${ntest}"
else echo "FAIL see ${ntest}.trg"
endif
$gtm_exe/mumps -run zload ${ntest}.trg >&! ${ntest}.zloadout
$grep -c FAILED ${ntest}.zloadout

echo "======================="
echo "Invalid Commands"
# Test for invalid commands
#
#    1. No command specified
#    2. nulls in the command string
#    	a) blank
#    	b) =,
#    	c) =set,
#    	d) =set,,k
#    	e) =,set,
#    3. zkill vs ztkill
#	a) same line
#	b) zkill vs ztkill on separate lines
#	c) different trigger loads
#    4. bad commands
#    	a) =SETty,KILLaz
#    	b) =kzk,skill
#    	c) =NOTREAL

set ntest="invalid_command"
cat  > ${ntest}.trg  <<TFILE
-*
;    1. No command specified
+^a(:) -xecute="do ^twork"
;    2. nulls in the command string
;    	blank
+^a(:) -command= -xecute="do ^twork"
;    	=,
+^a(:"b";"m":"x") -piece=1:8 -xecute="do ^tkilla" -delim="\`"  -command=, -options=noc,noi
;    	=set,
+^a(:2;5:) -command=s,, -xecute="do ^tkilla" -delim=\$zchar(126)_\$char(96) -piece=1 -options=isolation
;    	=set,,k
+^b(:) -command=k,,zw -xecute="do ^twork"
;    	=,set,
+^a(:) -command=,zw, -xecute="do ^twork"
;    3. zkill vs ztkill
;	a) same line
+^a(2:,:"m";10;20;25;30;35;44;50,:) -command=ztk,kilL -xecute="do multi^tkilla" -delim=\$zchar(9)_\$char(254)_""  -piece=1:3;7:8
;	b) zkill vs ztkill on separate lines
+^a(1:,"ztkill";10) -command=kilL -xecute="do multi^tkilla"
+^a(1:,"ztkill";10) -command=set -xecute="do set^tkilla" -delim=\$zchar(9)_\$char(254)_""  -piece=1:3;7:8
+^a(1:,"ztkill";10) -command=ztk -xecute="do multi^tkilla"
TFILE
$convert_to_gtm_chset ${ntest}.trg
$MUPIP trigger -triggerfile=${ntest}.trg -noprompt
if ($status != 0) echo "PASS ${ntest}"
else echo "FAIL see ${ntest}.trg"
endif
$gtm_exe/mumps -run zload ${ntest}.trg >&! ${ntest}.zloadout
$grep -c FAILED ${ntest}.zloadout
echo ""

#    3. zkill vs ztkill
#	c) different trigger loads
set ntest="kill_vs_ztkill_1"
echo $ntest
cat  > ${ntest}.trg  <<TFILE
-*
+^k(1:,"ztkill";10) -command=kilL -xecute="do multi^tkilla"
+^d(1:,"ztkill";10) -command=kilL -xecute="do multi^tkilla"
+^d(1:,"ztkill";10) -command=set -xecute="do set^tkilla" -delim=\$zchar(9)_\$char(254)_""  -piece=1:3;7:8
TFILE
$convert_to_gtm_chset ${ntest}.trg
$MUPIP trigger -triggerfile=${ntest}.trg -noprompt
if ($status != 0) echo "FAIL see ${ntest}.trg"
$gtm_exe/mumps -run zload ${ntest}.trg >&! ${ntest}.zloadout
$grep FAILED ${ntest}.zloadout # should not print anything
$show

echo ""
set ntest="kill_vs_ztkill_2"
#	a) same line
echo $ntest
cat  > ${ntest}.trg  <<TFILE
; duplicated
-^d(1:,"ztkill";10) -command=set -xecute="do set^tkilla" -delim=\$zchar(9)_\$char(254)_""  -piece=1:3;7:8

; we should not prevent ztkill in a remove operation
-^d(1:,"ztkill";10) -command=ztk -xecute="do multi^tkilla"

; do not allow a Kill and ZTKill on the same line
-^k(1:,"ztkill";10) -command=k,ztk -xecute="do multi^tkilla"
TFILE
$convert_to_gtm_chset ${ntest}.trg
$MUPIP trigger -triggerfile=${ntest}.trg
if ($status != 0) echo "PASS ${ntest}"
else echo "FAIL see ${ntest}.trg"
endif
$gtm_exe/mumps -run zload ${ntest}.trg >&! ${ntest}.zloadout || cat ${ntest}.zloadout
$show

echo ""
set ntest="kill_vs_ztkill_3"
#	b) zkill vs ztkill on separate lines
echo $ntest
cat  > ${ntest}.trg  <<TFILE
; try loading a ZTKill
+^d(1:,"ztkill";10) -command=ztk -xecute="do multi^tkilla"
TFILE
$convert_to_gtm_chset ${ntest}.trg
$MUPIP trigger -triggerfile=${ntest}.trg
if ($status != 0) echo "PASS ${ntest}"
else echo "FAIL see ${ntest}.trg"
endif
$gtm_exe/mumps -run zload ${ntest}.trg >&! ${ntest}.zloadout || cat ${ntest}.zloadout
$gtm_exe/mumps -run show^zload
echo ""

#    4. bad commands
set ntest="bad_command"
echo $ntest
cat  > ${ntest}.trg  <<TFILE
-*
;    	a) =SETty,KILLaz
-^b(":":";") -command=sETty,KILLaz  -xecute="set mc=""""" -delim=\$zchar(8364)_\$zchar(65284) -piece=1:3;5:6;7:8 -options=consistencycheck
;    	b) =kzk,skill
-^c(:,":":";";5:) -command=skill,zkz  -xecute="set mc=""""" -options=consistencycheck
;    	c) =NOTREAL
-^d(":":";":) -command=NOTREAL  -xecute="set mc=""""" -options=consistencycheck
TFILE
$convert_to_gtm_chset ${ntest}.trg
$MUPIP trigger -triggerfile=${ntest}.trg -noprompt
if ($status != 0) echo "PASS ${ntest}"
else echo "FAIL see ${ntest}.trg"
endif
$gtm_exe/mumps -run zload ${ntest}.trg >&! ${ntest}.zloadout
$grep -c FAILED ${ntest}.zloadout

echo "======================="
echo "Invalid xecute strings"
set ntest="invalid_xecute"
cat  > ${ntest}.trg  <<TFILE
-*
; blank xecute string
+^a(2:,:"m";10;20;25;30;35;44;50,:) -command=zk,zw,kilL xecute=
; no xecute string
+^a(2:,:"m";10;20;25;30;35;44;50,:) -command=zk,zw,kilL
; space before xecute string
+^a(2:,:"m";10;20;25;30;35;44;50,:) -command=zk,zw,kilL xecute= "set ^a=1"
TFILE
$convert_to_gtm_chset ${ntest}.trg
$MUPIP trigger -triggerfile=${ntest}.trg -noprompt
if ($status != 0) echo "PASS ${ntest}"
else echo "FAIL see ${ntest}.trg"
endif
$gtm_exe/mumps -run zload ${ntest}.trg >&! ${ntest}.zloadout
$grep -c FAILED ${ntest}.zloadout

echo "======================="
echo "Invalid piece and delim"
set ntest="invalid_piecedelim"
cat  > ${ntest}.trg  <<TFILE
-*
; pieces w/o delim="blah"
+^a(:,":":";";5:) -command=sET -xecute="set mc=""""" -piece=1:3;5:6;7:8 -options=consistencycheck
; delim and pieces w/o commands=set
+^a(:"b";"m":"x") -piece=1:8 -xecute="do ^tkilla" -delim="\`"  -command=zkILL -options=noc,noi
+^a(tvar=:,tvar2="a";"g":"z",tva3r=:10;20) -delim="~" -piece=4;6 -command=kiLL -xecute="do tsubrtn^twork" -options=i,c
+^a(tvar=:,tvar2="a";"g":"z",tvar3=:10;20) -delim="~" -piece=4;5;6 -xecute="do tsubrtn^twork" -options=i,c
; pieces out of order
+^a(:,":":";";5:) -command=sET -xecute="do ^comeInPiece" -delim="|" -piece=10:3;5:6;7:8 -options=consistencycheck
; piece ranges overlap
+^a(:,":":";";5:) -command=sET -xecute="do ^comeInPiece" -delim=";" -piece=1:66;5:8 -options=consistencycheck
; use wrong values for pieces
+^a(:,":":";";5:) -command=sET -xecute="do ^goInPieces" -delim="k" -piece=0:66;5:8 -options=consistencycheck
+^a(:,":":";";4:) -command=sET -xecute="do ^goInPieces" -delim=";" -piece=5:8,9 -options=noi
+^a(:,":":";";3:) -command=sET -xecute="do ^goInPieces" -delim="?" -piece=;5:9 -options=noc
+^a(:,":":";";2:) -command=sET -xecute="do ^goInPieces" -delim="i" -piece=5:A;19 -options=noi
+^a(:,":":";";1:) -command=sET -xecute="do ^goInPieces" -delim="m" -piece=.;5:/;19
TFILE
$convert_to_gtm_chset ${ntest}.trg
$MUPIP trigger -triggerfile=${ntest}.trg -noprompt
if ($status != 0) echo "PASS ${ntest}"
else echo "FAIL see ${ntest}.trg"
endif
$gtm_exe/mumps -run zload ${ntest}.trg >&! ${ntest}.zloadout
$grep -c FAILED ${ntest}.zloadout

echo "======================="
echo "Invalid options"
set ntest="invalid_option"
cat  > ${ntest}.trg  <<TFILE
-*
; blank options
+^a(tvar=:,tvar2="t":"z",tvar3=:10;20) -delim="""" -piece=4:6 -command=s -xecute="do tsubrtn^twork" -options=
; invalid option
+^a(tvar=:,tvar2="a";"g":"z",tvar3=:10;20) -delim="^" -piece=4;5;6 -command=s  -xecute="do tsubrtn^twork" -options=i,cons,no
; null option
+^a(tvar=:,tvar2="a";"g":"z",tvar3=:10;20) -delim="^" -piece=46 -command=s  -xecute="do tsubrtn^twork" -options=i,,noi
; conflicting options
+^a(tvar=:,tvar2="a";"g":"z",tvar3=:10;20) -delim="^" -piece=4;5;6 -command=s  -xecute="do tsubrtn^twork" -options=consistencycheck,noc
TFILE
$convert_to_gtm_chset ${ntest}.trg
$MUPIP trigger -trig=${ntest}.trg -noprompt
if ($status != 0) echo "PASS ${ntest}"
else echo "FAIL see ${ntest}.trg"
endif
$gtm_exe/mumps -run zload ${ntest}.trg >&! ${ntest}.zloadout
$grep -c FAILED ${ntest}.zloadout

echo "======================="
echo "Control Characters in error lines"
set ntest="control_chars"
$GTM << GTM_EOF >> ${ntest}_create_trigfile.out
set f="${ntest}.trg"
set l1="Long line without +/- "
set l2=" and few control chars"
open f:write use f
write "-*",!
write l1
for i=0:1:255 w \$c(i) if '(i#50) w l2,!,l1
close f
GTM_EOF

$convert_to_gtm_chset ${ntest}.trg
$MUPIP trigger -trig=${ntest}.trg -noprompt
if ($status != 0) then
	echo "PASS ${ntest}"
else
	echo "FAIL see ${ntest}.trg"
endif
$gtm_exe/mumps -run zload ${ntest}.trg >&! ${ntest}.zloadout
if ("linux" == $gtm_test_osname) then
	# scylla requires -a to treat the binary file as text, but -a doesn't work on non-Linux platforms
	set opt = "-ac"
else
	set opt = "-c"
endif
$grep $opt FAILED ${ntest}.zloadout

echo "======================="
echo "======================="
echo "======================="
echo "Unicode test cases next"
# TODO
# Unicode in the GVN (wrong by default)
# Unicode subscripts and delim work
# High 127 in GVN (wrong by default)
# High 127 in subscripts and delim (wrong by default)

echo "======================="
echo "Unicode global variable name"


$gtm_tst/com/dbcheck.csh -extract

