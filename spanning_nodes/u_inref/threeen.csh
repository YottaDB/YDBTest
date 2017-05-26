#!/usr/local/bin/tcsh
#################################################################
#								#
#	Copyright 2012, 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# disable random 4-byte collation header in DT leaf block since this test output is sensitive to DT leaf block layout
setenv gtm_dirtree_collhdr_always 1
# This is a stress test fot spanning nodes. It solves 3n+1 problem for 10000.
$GDE change -segment DEFAULT -block_size=512 -file=mumps.dat
$GDE change -region DEFAULT -null_subscripts=always -stdnull -rec=3000 -key=200
$gtm_exe/mupip create
echo "1 10000" | $gtm_dist/mumps -run threeen1cpu
$gtm_dist/mupip integ -reg "*"
