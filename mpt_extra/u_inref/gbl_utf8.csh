#!/usr/local/bin/tcsh
#################################################################
#								#
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	#
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
# for utf8 character set
#
$switch_chset "UTF-8"
$gtm_tst/com/dbcreate.csh .
# initialize the globals to various strings - all multi bytes
echo init
set cnt = 1
echo ""
echo "########################################## "$cnt" ########################################"
@ cnt = $cnt + 1
echo "Testing %G 1"
$GTM << EOF >&! gblinit.outx
do unicode^gblinit
D ^%G

*

D ^%G

?D

?D
unia
uniA
unia*


d ^%GD
*

D ^%GD
samplegbl
uni:^z
%uni*
*

EOF
#
# Filter out the %YDB-W-LITNONGRAPH, warnings
$tst_awk -f $gtm_tst/com/filter_litnongraph.awk gblinit.outx
echo ""
echo "########################################## "$cnt" ########################################"
@ cnt = $cnt + 1
echo "Testing %G 2"
$GTM << EOF
s str="...Ｘ..."
s x="Ｘ"
D ^%G

?1"uniA".E
?4A1"TMP"
?.E("ＤＩＥＧＯ")
uniX123(599,*)
uniX123(599,\$E(str,4,4))
uniX123(599,x)
uniA(1:10)
uniCTMP(?.E1"Ｉ".E)
uniCTMP(?.E3N)
uniX123(*)

EOF

$GTM << EOF
d ^%G

samplegbl("我":"下")
samplegbl("下":"我")
samplegbl("３":"６")
samplegbl("Τ")
samplegbl("２",*)
samplegbl("levels",?.E1"▄".E)
samplegbl(\$ZCHAR(240,144,128,131))
samplegbl("我能吞下玻璃而不伤身体")
samplegbl("的编纂",*)
samplegbl("¾",*)
samplegbl(-5:27)


EOF

echo ""
echo "########################################## "$cnt" ########################################"
@ cnt = $cnt + 1
echo "Testing %GC"
$GTM << EOF
do ^%GC

?
samplegbl
samplegblcp

write "zwriting samplegbl",!
zwrite ^samplegbl
write "zwriting samplegblcp, should be the same as above",!
zwrite ^samplegblcp
EOF
#
echo ""
echo "########################################## "$cnt" ########################################"
@ cnt = $cnt + 1
echo "Testing %GC"
$GTM << EOF
do ^%GCE
?
%uniYYY:^uniX123
?D

♚♝
♞♘
?

?


EOF
#
echo ""
echo "########################################## "$cnt" ########################################"
@ cnt = $cnt + 1
echo "Testing %GCE"
$GTM << EOF
s ^cc("₁₂")="₁₂"
s ^cc("₁₂2")="₁₂2"
s ^cc("30")=65612
s ^cc("45")=344
s ^cc("₁₂₁₂")="0₁₂2₁₂"
do ^%GCE
cc

₁₂
₃₅



do ^%G

cc

EOF
#
echo ""
echo "########################################## "$cnt" ########################################"
@ cnt = $cnt + 1
echo "Testing %GO"
$GTM << EOF
do ^%GO
samplegbl
?
?D

SINGLEBYTEＭＵＬＴＩＢＹＴＥ
ZWR
unicodefileａｂｃ.zwr
zwrite
do ^%GO
samplegbl
?
?D

ＭＵＬＴＩＢＹＴＥSINGLEBYTE
GO
unicodefileａｂｃ.go
zwrite
EOF
#
# do an extract of the database with all the globals
$MUPIP extract orig.ext
$tail -n +3 orig.ext >&! orig1.ext
#
$GTM << EOF
k ^samplegbl
d ^%GI
unicodefileａｂｃ.zwr

zwr
EOF
#
# compare whether the global that got killed is restored by doing a mupip extract now and checking with the saved copy
$MUPIP extract gioutput_zwr.ext
$tail -n +3 gioutput_zwr.ext >&! gioutput_zwr1.ext
diff orig1.ext gioutput_zwr1.ext
#
$GTM << EOF
k ^samplegbl
d ^%GI
unicodefileａｂｃ.go

zwr
EOF
#
$MUPIP extract gioutput_go.ext
$tail -n +3 gioutput_go.ext >&! gioutput_go1.ext
diff orig1.ext gioutput_go1.ext
#
echo ""
echo "########################################## "$cnt" ########################################"
@ cnt = $cnt + 1
echo "Testing %GSE"
$GTM << EOF
d ^%GSE

samplegbl*
?
?D
'samplegblcp
%*
a?cd
?D
A*
c

♞♘
%*
A

ｅ	♞♘
samplegbl*

ü
samplegbl*

ü
samplegbl*

u¨
mix*

我能 end here
mix*

♋
mix*

我能吞下玻璃而不伤身体 end here
mix*

我能吞下玻而不伤身体 end here

EOF
#
$gtm_tst/com/dbcheck.csh
