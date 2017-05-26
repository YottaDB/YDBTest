#!/usr/local/bin/tcsh
#################################################################
#								#
#	Copyright 2006, 2014 Fidelity Information Services, Inc	#
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
	echo "	; Ｙａｄａ ｙａｄａ" >>&! $fname
	echo '	w "ಕಖಗಘಙ	",!' >>&! $fname
	echo '	set ^xyz1="Ｙａｄａ",^xyz2="ｙａｄａ"' >>&! $fname
	echo '	write "安刀就开始开始",!' >>&! $fname
	echo "	q" >>&! $fname
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
$GTM << EOF
D ^%RCE
unicodetmp*

始开始OLD
开开开NEW



zwr
D ^%RCE
unicodertn*

ಕಖಗಘಙ	
ಚ	ಛಜಝಞ



zwr
EOF
#
echo "#####################"$cnt"###################"
@ cnt = $cnt + 1
echo "Testing RCE 2"
$GTM << EOF
d ^%RCE
unicodertn*

Ｙａｄａ
Ａｄａｙ
n
zwr
EOF
#
echo "#####################"$cnt"###################"
@ cnt = $cnt + 1
echo "Testing RSEL and CALL RCE 1"
cat $rtndir/unicodertn1.m
$GTM << EOF
d ^%RSEL
unicodertn1

s %ZF="Ａｄａｙ"
s %ZN="☀★☃☂☁☢"
S %ZC=1
s %ZD="ｒｓｅ.out"
open %ZD
d CALL^%RCE
zwr
EOF
#
cat ｒｓｅ.out
cat $rtndir/unicodertn1.m
#
echo "#####################"$cnt"###################"
@ cnt = $cnt + 1
echo "Testing RSE 1"
#
$GTM << EOF
d ^%RSE
unicodertn*
unicodetmp*
-unicodertn*

开开开NEW

zwr
EOF
#
echo "#####################"$cnt"###################"
@ cnt = $cnt + 1
echo "Testing RSE 2"
$GTM << EOF
write "RSE SHOULD NOT match the string below"
d ^%RSE
unicodertn*

ಚಛಜಝಞ

zwr
EOF
#
echo "#####################"$cnt"###################"
@ cnt = $cnt + 1
echo "Testing RSEL and CALL RCE 2"
$GTM << EOF
d ^%RSEL
unicodertn1
unicodezz

s %ZF="ಕಖಗಘಙ"
d CALL^%RSE
zwr
s %ZD="callｒｓｅ.out"
open %ZD
d CALL^%RSE
zwr
close %ZD
EOF
#
cat callｒｓｅ.out
#
setenv gtmroutines "$save_gtmroutines"
$gtm_tst/com/dbcheck.csh
