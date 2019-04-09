#!/usr/local/bin/tcsh
#################################################################
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
# This module is derived from FIS GT.M.
#################################################################
#
# D9I07-002692 test of zprint with an object-source mismatch
#
\cp $gtm_tst/$tst/inref/d002692.m foo.m
$gtm_exe/mumps -object=foo.o foo.m
mv foo.o d002692.o
$GTM <<GTM_EOF
	zprint +0^d002692
	write !,"Pass from D9I07002692"
GTM_EOF
