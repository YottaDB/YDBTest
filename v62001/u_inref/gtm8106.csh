#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2014 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# Verify VIEW "GVSRESET" and DSE CHANGE -FILEHEADER -GVSTATSRESET work; also VIEW accepts lower-case regions and * as all regions
$gtm_tst/com/dbcreate.csh mumps 1
$gtm_dist/mumps -run gtm8106
chmod 444 mumps.dat
$gtm_dist/mumps -run readonly^gtm8106
chmod 666 mumps.dat
$gtm_tst/com/dbcheck.csh

