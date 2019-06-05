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
# test for conversion utility routines
# these are the tests in the manual
# for utf8 characters
#
# Test the entire range of ascii,control and punctuation characters,i.e 1-255 limit
# For LCASE UCASE functions check some special casing characters and their behavior
# execute an awk file that will generate a M routine containing such special chars.

# The whole section gets to run only if gtm_chset=UTF-8
$switch_chset "UTF-8"
$tst_awk -f $gtm_tst/com/convert.awk $gtm_tst/com/special_casing.txt
#
$GTM < $gtm_tst/mpt_extra/inref/conv_utf8a.inp
#
