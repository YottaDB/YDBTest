#!/usr/local/bin/tcsh -f
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
#
# Test for $gtmroutines and $ZROUTINES to include multibyte unicode characters
#
$echoline
$gtm_tst/com/dbcreate.csh mumps 1
mkdir dir安我们 dirｄｉｒ
setenv gtmroutines "dir安我们 dirｄｉｒ $gtmroutines"
echo 'GTM_TEST_DEBUGINFO $gtmroutines corresponds to '"$gtmroutines"
cd dir安我们
# create some sample routines
cat << \EOF > testroutine1.m
testroutine1 ;
		write "testｒｏｕｔｉｎｅ１ called "
		set ^aglobal="♚♝A♞♜"
		zwrite ^aglobal
		quit
\EOF
cd ../dirｄｉｒ
cat << \EOF > testroutine2.m
testroutine2 ;
		write "testｒｏｕｔｉｎｅ２ called "
		set ^bglobal="ΨΈẸẪΆΨ"
		zwrite ^bglobal
		quit
\EOF
cd $tst_working_dir
# invoke the created m-routines
$GTM << eof
write "GTM_TEST_DEBUGINFO ZROUTINES = "_\$ZROUTINES,!
do ^testroutine1
do ^testroutine2
halt
eof
# check the object files are created in correct directories
find . -name "testroutine1.o"
find . -name "testroutine2.o"
set stat1=`ls ./dir安我们/testroutine1.o|wc -l`
set stat2=`ls ./dirｄｉｒ/testroutine2.o|wc -l`
if ( 0 == $stat1 || 0 == $stat2 ) then
	echo "TEST-E-ERROR, object files not created in the respective directories"
else
	echo "PASS"
endif
$echoline
#
$gtm_tst/com/dbcheck.csh
