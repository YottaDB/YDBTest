#!/usr/local/bin/tcsh
#################################################################
#								#
# Copyright 2006, 2014 Fidelity Information Services, Inc	#
#								#
# Copyright (c) 2019 YottaDB LLC and/or its subsidiaries.	#
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
setenv save_gtmroutines "$gtmroutines"
$gtm_tst/com/dbcreate.csh mumps 1
setenv gtmroutines ".($gtm_tst/$tst/inref .) $gtm_exe/utf8 ./dirｄｉｒｅｃｔｏｒｙ/rtns"
mkdir dirｄｉｒｅｃｔｏｒｙ
mkdir dirｄｉｒｅｃｔｏｒｙ/rtns
set rtndir="dirｄｉｒｅｃｔｏｒｙ/rtns"
foreach i (unicodertn unicodetmpy unicodetmpz unicodet unicodertnx unicodertn1 unicodertn45678 unicodertn456789 unicodertn45678901234567890 unicodertn4567890123456789012345678901 unicodeabcd unicodezz)
	set fname = "dirｄｉｒｅｃｔｏｒｙ/rtns/${i}.m"
	echo "$i	;; " >&! $fname
	echo "	;; This is the description for $i" >>&! $fname
	cat $gtm_tst/mpt_extra/inref/rtn_utf8a.inp >>&! $fname
	$convert_to_gtm_chset $fname
end
set cnt = 1
echo "#####################"$cnt"###################"
@ cnt = $cnt + 1
echo "Testing FL"
$GTM << EOF
D ^%FL
unicodertn*
-unicodertn?
unicodert?x
%G
?D


EOF
#
echo "#####################"$cnt"###################"
@ cnt = $cnt + 1
echo "Testing RCE 1"
$GTM < $gtm_tst/mpt_extra/inref/rtn_utf8b.inp
#
echo "#####################"$cnt"###################"
@ cnt = $cnt + 1
echo "Testing RCE 2"
$GTM < $gtm_tst/mpt_extra/inref/rtn_utf8c.inp
#
echo "#####################"$cnt"###################"
@ cnt = $cnt + 1
echo "Testing RSEL and CALL RCE 1"
cat $rtndir/unicodertn1.m
$GTM < $gtm_tst/mpt_extra/inref/rtn_utf8d.inp
#
cat ｒｓｅ.out
cat $rtndir/unicodertn1.m
#
echo "#####################"$cnt"###################"
@ cnt = $cnt + 1
echo "Testing RSE 1"
#
$GTM < $gtm_tst/mpt_extra/inref/rtn_utf8e.inp
#
echo "#####################"$cnt"###################"
@ cnt = $cnt + 1
echo "Testing RSE 2"
$GTM < $gtm_tst/mpt_extra/inref/rtn_utf8f.inp
#
echo "#####################"$cnt"###################"
@ cnt = $cnt + 1
echo "Testing RSEL and CALL RCE 2"
$GTM < $gtm_tst/mpt_extra/inref/rtn_utf8g.inp
#
cat callｒｓｅ.out
#
setenv gtmroutines "$save_gtmroutines"
$gtm_tst/com/dbcheck.csh
