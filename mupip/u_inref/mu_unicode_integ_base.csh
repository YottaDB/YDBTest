#! /usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2017 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.                                          #
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
setenv gtmgbldir integneg.gld
$gtm_tst/com/dbcreate.csh integneg 1 128 256 1024 100 256
set subs1="αβγδε"
set subs2="ＡＤＩＲ"
set subs3="লায়েক"
set subs4="我能吞下玻璃而不伤身体"
set subs12="$subs1$subs2"
set subs34="$subs3$subs4"
$GTM << EOF
f i=1:1:100  s ^a("$subs1",i)=i
f i=1:1:100  s ^a("$subs2",i)=100+i
f i=1:1:100  s ^a("$subs3",i)=200+i
f i=1:1:100  s ^a("$subs4",i)=300+i
f i=1:1:100  s ^a("$subs12",i)=400+i
f i=1:1:100  s ^a("$subs34",i)=500+i
f i=1:1:100  s ^a("$subs1","$subs2",i)=600+i
f i=1:1:100  s ^a("$subs1","$subs2","$subs3",i)=700+i
h
EOF
#
set verbose on
$MUPIP integ -reg "*" -subscript=\"^a\"
$MUPIP integ -reg "*" -subscript=\"^a\(\"\"$subs1\"\"\)\"
$MUPIP integ -reg "*" -subscript=\"^a\(\"\"$subs1\"\"\)\":\"^a\(\"\"$subs1\"\",1000\)\"
$MUPIP integ -reg "*" -subscript=\"^a\(\"\"$subs1\*\"\"\)\"
$MUPIP integ -reg "*" -subscript=\"^a\(\"\"$subs2\"\"\)\"
$MUPIP integ -reg "*" -subscript=\"^a\(\"\"$subs3\*\"\"\)\"
$MUPIP integ -reg "*" -subscript=\"^a\(\"\"$subs12\"\"\)\":\"^a\(\"\"$subs12\"\",450\)\"
$MUPIP integ -reg "*" -subscript=\"^a\(\"\"$subs34\"\"\)\"
$MUPIP integ -reg "*" -subscript=\"^a\(\"\"$subs1\"\"\):^a\(\"\"$subs2\"\"\)\"
$MUPIP integ -reg "*" -subscript=\"^a\(\"\"$subs1\"\"\):^a\(\"\"$subs4\*\"\"\)\"
$MUPIP integ -reg "*" 
unset verbose
# Please make sure below does corrupt the subscrip collation
$DSE << EOF
add -rec=2 -bl=3 -data="DSEDAT1" -key="^a(1111)"
add -rec=2 -bl=6 -data="DSEDAT2" -key="^a(2222)"
quit
EOF
$MUPIP integ -reg "*" -full
$DSE <<EOF
remove -rec=2 -bl=3
remove -rec=2 -bl=6
EOF
$gtm_tst/com/dbcheck.csh
