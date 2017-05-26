#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2005, 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# TEST to checkmupip integ features

# disable random 4-byte collation header in DT leaf block since this test output is sensitive to DT leaf block layout
setenv gtm_dirtree_collhdr_always 1
#
$gtm_tst/com/dbcreate.csh mumps
# assuming the below set updates blocks 0,1,2,3,4
$GTM << gtm_eof
set ^a=1
halt
gtm_eof
# this databse will be used throughout the test
cp mumps.dat mumps_bak.dat
# set an alias that will be used throughout this test
alias d1 '$DSE change -fileheader -blks_to_upgrade=1'
#
##################### -FILE & -REGION qualifier section ###################
#				Section 1				  #
foreach type ("region DEFAULT" "file mumps.dat")
	# manually corrupt blks_to_upgrade
	d1
	#
	echo ""
	echo "mupip integ $type with fast option"
	echo ""
	$MUPIP integ -noonline -fast -$type >>&! run1.out
	cat run1.out
	if (`$grep -E "DBBTUWRNG|DBBTUFIXED" run1.out|wc -l`) then
		echo "TEST-E-ERROR DBBTUWRNG DBBTUFIXED message not expected as fast option given to INTEG"
	else
		echo "PASS did not get DBBTUWRNG warning"
	endif
	#
	echo ""
	echo "mupip integ $type"
	echo ""
	# Note, below -noonline is required as otherwise -online will be chosen by default which will not fix the
	# DBBTUWRNG error.
	$MUPIP integ -noonline -$type >>&! run2.out
	cat run2.out
	if ( 2 != `$grep -E "DBBTUWRNG|DBBTUFIXED" run2.out|wc -l` ) then
		echo "TEST-E-ERROR. DBBTUWRNG DBBTUFIXED message expected but got none"
	else
		echo "PASS got expected DBBTUWRNG DBBTUFIXED warning"
	endif
	# again do an integ to ensure previous -reg command does fix the issue
	$MUPIP integ -$type >>&! run3.out
	cat run3.out
	if (`$grep -E "DBBTUWRNG|DBBTUFIXED" run3.out|wc -l`) then
		echo "TEST-E-ERROR. DBBTUWRNG error not fixed by previous integ"
	else
		echo "PASS integ error got fixed"
	endif
	rm -f run*.out
	cp mumps_bak.dat mumps.dat
end
########## -FILE & -REGION qualifier section with other integrity errors #####
#				Section 2				     #
cp mumps_bak.dat mumps.dat
# manually corrupt blks_to_upgrade
d1
# manually create other integirty error like dbtntoolg
$DSE change -block=3 -tn=500
# run a loop for two times for both -file & -region qualifiers & ensure error is thrown
# integ_err_chk.csh does that. it also needs an env. var to check the kind of error.
# so the caller provides that in mupip_err_chk var.
setenv mupip_err_chk "DBTNTOOLG"
$gtm_tst/$tst/u_inref/integ_err_chk.csh
#
#				Section 3				     #
cp mumps_bak.dat mumps.dat
# manually corrupt blks_to_upgrade
d1
# manually create other integirty error like gtm-w-mukillip
$DSE change -fileheader -kill_in_prog=1
setenv mupip_err_chk "GTM-W-MUKILLIP"
$gtm_tst/$tst/u_inref/integ_err_chk.csh
#
############################ MUTNWARN section #################################
#				Section 4				      #
cp mumps_bak.dat mumps.dat
#
# MUTNWARN_V4 = 2**32 - 128M - (4 * 128M) - 1
# MUTNWARN_V6 = 2**64 - 512M - (4 * 512M) - 1
$MUPIP set -version=V4 -file mumps.dat
# change current transaction as MUTNWARN_V4
setenv curval "D7FFFFFF"
setenv maxtnval "D7FFFFFF"
$gtm_tst/$tst/u_inref/integ_err_chk.csh "warn"
# change current transaction as the above MUTNWARN_V4 + 1
setenv curval "D8000000"
setenv maxtnval "D8000000"
$gtm_tst/$tst/u_inref/integ_err_chk.csh "warn"
# change current transaction as the above MUTNWARN_V4 - 1
setenv curval "D7FFFFFE"
setenv maxtnval "D7FFFFFE"
$gtm_tst/$tst/u_inref/integ_err_chk.csh "nowarn"
#
# change version using set
$MUPIP set -version=V6 -file mumps.dat
if ( $status) then
	echo "TEST-E-ERROR.  MUPIP set version failed"
endif
# change current transaction as 2 * 32 - 2 * 29
setenv curval "E0000000"
setenv maxtnval "E0000000"
$gtm_tst/$tst/u_inref/integ_err_chk.csh "nowarn"
# change current transaction as 2 * 32
setenv curval "100000000"
setenv maxtnval "100000000"
$gtm_tst/$tst/u_inref/integ_err_chk.csh "nowarn"
# change current transaction as 2 * 48
setenv curval "1000000000000"
setenv maxtnval "1000000000000"
$gtm_tst/$tst/u_inref/integ_err_chk.csh "nowarn"
# change current transaction as 2 * 63
setenv curval "8000000000000000"
setenv maxtnval "8000000000000000"
$gtm_tst/$tst/u_inref/integ_err_chk.csh "nowarn"
# change current transaction as MUTNWARN_V6 - 1
setenv maxtnval "FFFFFFFF73FFFFFE"
setenv maxtnval "FFFFFFFF73FFFFFE"
$gtm_tst/$tst/u_inref/integ_err_chk.csh "nowarn"
# change current transaction as MUTNWARN_V6
setenv curval "FFFFFFFF73FFFFFF"
setenv maxtnval "FFFFFFFF73FFFFFF"
$gtm_tst/$tst/u_inref/integ_err_chk.csh "warn"
# change current transaction as MUTNWARN_V6 + 1
setenv curval "FFFFFFFF74000000"
setenv maxtnval "FFFFFFFF74000000"
$gtm_tst/$tst/u_inref/integ_err_chk.csh "warn"
################ MUTNWARN section end #####################
# integ.out used to capture errors earlier will get displayed here at the completion of test
# so zipping them
$tst_gzip integ.out
$gtm_tst/com/dbcheck.csh -noonline
