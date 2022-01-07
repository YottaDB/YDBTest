#!/usr/local/bin/tcsh
#################################################################
#								#
# Copyright (c) 2003-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2018-2022 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# test for conversion utility routines
# these are the tests in the manual

#
$gtm_tst/com/dbcreate.csh -key=1000 -record_size=1048576 -block=4096
cp $gtm_tst/$tst/inref/gtm8223{a,b,c,d,e,f}.{go,zwr} ./
cp $gtm_tst/$tst/inref/gtm8022.{go,zwr} ./
# initialize the globals to various strings
echo init
$GTM << EOF >&! gblinit.outx
do ^gblinit
EOF
#
# Filter out the %YDB-W-LITNONGRAPH, warnings
$tst_awk -f $gtm_tst/com/filter_litnongraph.awk gblinit.outx
set cnt = 1
echo "#####################"$cnt"###################"
@ cnt = $cnt + 1
$GTM << EOF
D ^%G

*

EOF
#
echo "#####################"$cnt"###################"
@ cnt = $cnt + 1
echo help
$GTM << EOF
D ^%G
?

?
?D

?D
a
A
a*


EOF
#
echo "#####################"$cnt"###################"
@ cnt = $cnt + 1
$GTM << EOF
s str="...X..."
s x="X"
D ^%G

?1"A".E
?1A1"TMP"
?.E("RICK")
X123(599,*)
X123(599,\$E(str,4,4))
X123(599,x)
A(1:10)
CTMP(?.E1"I".E)
CTMP(?.E3N)
X123(*)

EOF

$GTM << EOF
d ^%G

CTMP("A":"Y",*)
CTMP(:"Y",*)
CTMP("Y":)


EOF

echo "#####################"$cnt"###################"
@ cnt = $cnt + 1
$GTM << EOF
d ^%G

C
C(1)
C(1,*)

EOF
#
echo "#####################"$cnt"###################"
@ cnt = $cnt + 1
$GTM << EOF
do ^%GC

?
b
g

zwr
zwr ^g
EOF
#
echo "#####################"$cnt"###################"
@ cnt = $cnt + 1
$GTM << EOF
do ^%GCE
?
a:^b
?D

bcd
BCD
?

?


EOF
#
echo "#####################"$cnt"###################"
@ cnt = $cnt + 1
$GTM << EOF
s ^bb(12)=12
s ^bb(122)=122
s ^bb(30)=656
s ^bb(45)=344
s ^bb(1212)=012212
do ^%GCE
bb

12
35



do ^%G

bb

EOF
#
echo "#####################"$cnt"###################"
@ cnt = $cnt + 1
$GTM << EOF

EOF
#
echo "#####################"$cnt"###################"
@ cnt = $cnt + 1
$GTM << EOF
d ^%GD
?

d ^%GD
*

D ^%GD
a
c:^s
b%
b*
*

EOF
#
echo "#####################"$cnt"###################"
@ cnt = $cnt + 1
$GTM << EOF
d ^%GO
A
B
?
?D
b
'b

LABEL
ZWR
file.zwr
zwr
EOF
#
ls file.zwr
#
echo "#####################"$cnt"###################"
@ cnt = $cnt + 1
$GTM << EOF
k ^A
k ^B
d ^%GI
file.zwr

zwr
do ^%GI
gtm8223a.go

do ^%GI
gtm8223a.zwr

do ^%GI
gtm8223b.go

do ^%GI
gtm8223b.zwr

do ^%GI
gtm8223c.go

do ^%GI
gtm8223c.zwr

do ^%GI
gtm8223d.go

do ^%GI
gtm8223d.zwr

do ^%GI
gtm8223e.go

do ^%GI
gtm8223e.zwr

do ^%GI
gtm8223f.go

do ^%GI
gtm8223f.zwr

do ^%GI
gtm8022.go

do ^%GI
gtm8022.zwr

EOF
$gtm_dist/mupip load file.zwr
#
echo "#####################"$cnt"###################"
@ cnt = $cnt + 1
$GTM << EOF
d ^%GSE
?

a
?
?D
b
'a
%*
a?cd
?D
A*
c

bcd
%*
A

a	a

EOF
#
echo "#####################"$cnt"###################"
@ cnt = $cnt + 1
$GTM << EOF
DO ^%GSEL
?
a
b
A
%XXX
A%MP
e?gh
b:h
-f*
?D

zwr
EOF
#
echo "#####################"$cnt"###################"
@ cnt = $cnt + 1
$GTM << EOF
d ^%GSEL
A

zwr
d CALL^%GSEL
?D
B

zwr
EOF
#
echo "#####################"$cnt"###################"
@ cnt = $cnt + 1
$GTM << EOF
set ^qqqzzzzzzzzzzzzzzzzzzzzzz67="27 chars"
set ^qqqzzzzzzzzzzzzzzzzzzzzzz6789="29 chars"
set ^qqqzzzzzzzzzzzzzzzzzzzzzzzzzzzz="31 chars"
set ^qqzzzzzz="8 charas"
set ^qqzzzzzzz="9 chars"
set ^qqzzzzzzzzzzzzzzzzz="19 chars"
set ^qqzzzzzzzzzzzzzzzzzzzzzzzzzzzzz="31 chars"
d ^%GSEL
qqq*
qqzzzzzzzzzzzzzzzzzz*
-qqqzzzzzzzzzzzzzzzzzzzzzzzzzzz*
q*
-qqqzzzzzzzzzzzzzzzzzzzzzz6*

zwrite
halt
EOF
#
$gtm_tst/com/dbcheck.csh
