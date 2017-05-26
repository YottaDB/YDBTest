#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# Test error scenarios of very long subscript lengths
set star5 = "*****"
set star10 = "${star5}${star5}"
set star50 = "${star10}${star10}${star10}${star10}${star10}"
set star100 = "${star50}${star50}"
set star500 = "${star100}${star100}${star100}${star100}${star100}"
set star1000 = "${star500}${star500}"
set a5 = "${star5:as/*/a/}"
set a10 = "${star10:as/*/a/}"
set a50 = "${star50:as/*/a/}"
set a100 = "${star100:as/*/a/}"
set a500 = "${star500:as/*/a/}"
set a1000 = "${star1000:as/*/a/}"
set z5 = "${star5:as/*/z/}"
set z10 = "${star10:as/*/z/}"
set z50 = "${star50:as/*/z/}"
set z100 = "${star100:as/*/z/}"
set z500 = "${star500:as/*/z/}"
set z1000 = "${star1000:as/*/z/}"
$GDE << EOF
template -region -stdnull
change -region DEFAULT -stdnull
add -seg XSEG -f="x.dat" -block_size=2048
add -reg XREG -d=XSEG -record_size=2000 -key_size=1019
! subscripts just within the limit i.e 1019 should work
add -name a("${star1000}${star10}***1") -r=xreg
add -name b("${star1000}${star10}***1":"${star1000}${star10}**99") -r=xreg
add -name c("****") -reg=xreg
! Subscripts just exceeding the upper limit i.e 1019 should not work
add -name A("${star1000}${star10}****1") -reg=XREG
change -name B("${star1000}${star10}****1") -reg=DEFAULT
rename -name C("${star1000}${star10}****1") d("**small**")
rename -name c("****") D("${star1000}${star10}****1")
delete -name E("${star1000}${star10}****1")
! Check with lengths way over the boundary
add -name ALONG("${star1000}${star1000}1") -reg=XREG
change -name BLONG("${star1000}${star1000}${star50}1") -reg=DEFAULT
rename -name CLONG("${star1000}${star1000}${star100}1") d("**small**")
rename -name c("****") DLONG("${star1000}${star1000}${star500}1")
delete -name ELONG("${star1000}${star1000}${star1000}****1")
! Multiple subscripts with and without ranges when together exceeds 1019, should error out
add -name F("${star1000}${star10}*1","a") -reg=XREG
add -name G("${star1000}${star10}1","aa":"zz") -reg=XREG
change -name H("${star500}${star100}${star100}1","${a500}":"${z100}") -reg=NOTEXISTING
rename -name c("NotExisting") I("${star500}${star100}${star100}1","${a100}":"${z500}")
delete -name J("${star500}${star10}","${a500}${a10}":"${z1000}")
EOF

$MUPIP create
$GTM << GTM_EOF
set ^a("${star1000}${star10}***1")=1
set ^y("${star1000}${star10}****1")=1
set ^yglobalvariable("$a100","$a1000")=1
GTM_EOF
