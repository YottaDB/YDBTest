#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2007, 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# D9H05-002658 [Narayanan] SIG-11 in jnl_write at KTB (due to gvcst_zprevious memory corruption)

setenv gtm_test_spanreg 0	# Due to differing key sizes across regions, its hard to introduce spanning regions
$gtm_tst/com/dbcreate.csh mumps 3

# Assign different key-sizes to different regions.
$DSE << DSE_EOF
find -reg=DEFAULT
change -file -key=25
find -reg=AREG
change -file -key=100
find -reg=BREG
change -file -key=200
DSE_EOF

setenv gtmdbglvl 48	# enable verification of allocated/free chains in malloced memory

$GTM << GTM_EOF
	do ^d002658
GTM_EOF

$gtm_tst/com/dbcheck.csh
