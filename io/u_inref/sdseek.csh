#!/usr/local/bin/tcsh
#################################################################
#								#
# Copyright 2013, 2014 Fidelity Information Services, Inc	#
#								#
# Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#;;;sdseek.csh
#;;;Test the unix seek behavior of the sequential device with both M and unicode tests
#;;;This work was done under the GTM-7809
#;;;
$switch_chset M

# Create one-region gld and associated .dat file
$gtm_tst/com/dbcreate.csh mumps 1

$gt_cc_compiler -o strip_cr -I$gtm_tst/$tst/inref -I$gtm_dist $gtm_tst/$tst/inref/strip_cr.c
rm -f strip_cr.o

$echoline
echo "**************************** mseek ****************************"
$echoline
$gtm_dist/mumps -run mseek
$echoline
echo "**************************** seek on PRINCIPAL in heredoc ****************************"
$echoline
$gtm_exe/mumps -dir <<EOF >heredocseek
; the inseek will go back to the set cnt=cnt+1 line and do this until cnt is 5
set cnt=0
write "first output",!
set cnt=cnt+1
if 5=cnt use \$p:inseek="+28"
w cnt,! use \$p:inseek="-72"
use \$p:outseek="0"
; the outseek will go back to the beginning of heredocseek and overwrite what was there.  The set is to dupicate the output
set cnt=0
w "secnd output",!
EOF
cat heredocseek

$echoline
echo "**************************** test1 seek on PRINCIPAL with redirected in/out ****************************"
$echoline
echo "input from a file and output to a file"
$gtm_exe/mumps -run test1^mseek < mvariable > test1.out
cat test1.out

echo "input from a pipe and output to a pipe ignores seeks"
cat mvariable | $gtm_exe/mumps -run test1^mseek | cat

# show inseek/outseek on PRINCIPAL redirected from /dev/null or empty file is ignored without error
$echoline
echo "**************************** test2 inseek/outseek ignored for null/empty files  ****************************"
$echoline
$gtm_exe/mumps -run test2^mseek < /dev/null > /dev/null
touch nullfile
$gtm_exe/mumps -run test2^mseek < nullfile > nullfile
$echoline
echo "**************************** rewind PRINCIPAL in heredoc ****************************"
$echoline
$gtm_exe/mumps -dir <<EOF >heredocseek
; the inrewind will go back to the beginning of the here doc do this until cnt is 4
if '\$data(cnt) set cnt=0 write "first output",!
set cnt=cnt+1
w cnt,!
if 4'=cnt use \$p:inrewind
use \$p:outrewind
; the outrewind will go back to the beginning of hereseek and overwrite what was there.  The set is to dupicate the output
set cnt=0
w "secnd output",!
EOF
cat heredocseek
$echoline
echo "**************************** rewind1 rewind on PRINCIPAL with redirected in/out ****************************"
$echoline
echo "input from a file and output to a file"
$gtm_exe/mumps -run rewind1^mseek < mvariable > rewind1.out
cat rewind1.out

echo "input from a pipe and output to a pipe ignores rewinds"
cat mvariable | $gtm_exe/mumps -run rewind1^mseek | cat

# show inseek/outseek on PRINCIPAL redirected from /dev/null or empty file is ignored without error
$echoline
echo "**************************** rewind2 inrewind/outrewind ignored for null/empty files  ****************************"
$echoline
$gtm_exe/mumps -run rewind2^mseek < /dev/null > /dev/null
touch nullfile
$gtm_exe/mumps -run rewind2^mseek < nullfile > nullfile

$echoline
echo "**************************** truncate output of PRINCIPAL in heredoc ****************************"
$echoline
$gtm_exe/mumps -dir <<EOF >heredoctrunc
; write 4 lines then back up 2 line, truncate and write 2 more - expect YDB> before the new lines
for i=1:1:4 write "Line "_i_" - abcdefdhijklmnopqrstuvwxyz",!
use \$p:outseek="-79"
for i=3:1:4 write "After truncate Line "_i_" - abcdefdhijklmnopqrstuvwxyz",!
EOF
cat heredoctrunc
$echoline
echo "**************************** truncate1 truncate output on PRINCIPAL with redirected in/out *********************"
$echoline
echo "input from a file and output to a file"
$gtm_exe/mumps -run truncate1^mseek < mvariable > truncate1.out
cat truncate1.out

echo "input from a pipe and output to a pipe ignores truncates"
cat mvariable | $gtm_exe/mumps -run truncate1^mseek | cat


# show truncate on PRINCIPAL redirected to /dev/null or empty file is ignored without error
$echoline
echo "**************************** truncate2 truncate ignored for null/empty files  ****************************"
$echoline
$gtm_exe/mumps -run truncate2^mseek < /dev/null > /dev/null
cat > nullfile < /dev/null
$gtm_exe/mumps -run truncate2^mseek < nullfile > nullfile

if ("TRUE" == $gtm_test_unicode_support) then
	$echoline
	echo "**************************** utfseek ****************************"
	$echoline
	$switch_chset UTF-8
	$gtm_dist/mumps -run utfseek
	$echoline
	echo "**************************** utest1 seek on PRINCIPAL with redirected in/out ****************************"
	$echoline
	echo "utf-8 no bom - input from a file and output to a file"
	$gtm_exe/mumps -run utest1^utfseek 0 < useek8nobom > utest1.out
	cat utest1.out

	echo "utf-8 no bom - input from a pipe and output to a pipe ignores seeks"
	cat useek8nobom | $gtm_exe/mumps -run utest1^utfseek 0 | cat

	echo "utf-8 with bom - input from a file and output to a file"
	$gtm_exe/mumps -run utest1^utfseek 3 < useek8withbom > utest2.out
	cat utest2.out

	echo "utf-8 with bom - input from a pipe and output to a pipe ignores seeks"
	cat useek8withbom | $gtm_exe/mumps -run utest1^utfseek 3 | cat

	echo "**************************** utest2 inseek/outseek ignored for null/empty files  ****************************"
	$echoline
	$gtm_exe/mumps -run utest2^utfseek 0 < /dev/null > /dev/null
	touch unullfile
	$gtm_exe/mumps -run utest2^utfseek 0 < unullfile > unullfile
	$echoline
	echo "**************************** urewind1 rewind PRINCIPAL with redirected in/out ****************************"
	$echoline
	echo "utf-8 no bom - input from a file and output to a file"
	$gtm_exe/mumps -run urewind1^utfseek 0 < useek8nobom > urewind1.out
	cat urewind1.out

	echo "utf-8 no bom - input from a pipe and output to a pipe ignores rewinds"
	cat useek8nobom | $gtm_exe/mumps -run urewind1^utfseek 0 | cat

	echo "utf-8 with bom - input from a file and output to a file"
	$gtm_exe/mumps -run urewind1^utfseek 3 < useek8withbom > urewind2.out
	cat urewind2.out

	echo "utf-8 with bom - input from a pipe and output to a pipe ignores rewinds"
	cat useek8withbom | $gtm_exe/mumps -run urewind1^utfseek 3 | cat
	$echoline
	echo "**************************** urewind2 inrewind/outrewind ignored for null/empty files  ****************************"
	$echoline
	$gtm_exe/mumps -run urewind2^utfseek 0 < /dev/null > /dev/null
	touch unullfile
	$gtm_exe/mumps -run urewind2^utfseek 0 < unullfile > unullfile
	$echoline
	echo "**************************** utruncate1 truncate PRINCIPAL with redirected in/out ****************************"
	$echoline
	echo "utf-8 no bom - input from a file and output to a file"
	$gtm_exe/mumps -run utruncate1^utfseek 0 < useek8nobom > utruncate1.out
	cat utruncate1.out

	echo "utf-8 no bom - input from a pipe and output to a pipe ignores truncatess"
	cat useek8nobom | $gtm_exe/mumps -run utruncate1^utfseek 0 | cat

	echo "utf-8 with bom - input from a file and output to a file"
	$gtm_exe/mumps -run utruncate1^utfseek 3 < useek8withbom > utruncate2.out
	cat utruncate2.out

	echo "utf-8 with bom - input from a pipe and output to a pipe ignores truncates"
	cat useek8withbom | $gtm_exe/mumps -run utruncate1^utfseek 3 | cat

	$echoline
	echo "**************************** utruncate2 truncate ignored for null/empty files  ****************************"
	$echoline
	$gtm_exe/mumps -run utruncate2^utfseek 0 < /dev/null > /dev/null
	touch unullfile
	$gtm_exe/mumps -run utruncate2^utfseek 0 < unullfile > unullfile
endif

$gtm_tst/com/dbcheck.csh
