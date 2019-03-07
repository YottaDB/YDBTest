#!/usr/local/bin/tcsh -f
#################################################################
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
#
# Test that ZSTEP OVER and ZSTEP OUTOF work if an extrinsic function returns using QUIT @ syntax
#

$echoline | sed 's/#/-/g'
echo "Test that ZSTEP INTO works with QUIT"
$gtm_dist/mumps -run zstinto1

$echoline | sed 's/#/-/g'
echo "Test that ZSTEP INTO works with QUIT @"
$gtm_dist/mumps -run zstinto2

$echoline | sed 's/#/-/g'
echo "Test that ZSTEP OVER works with QUIT"
$gtm_dist/mumps -run zstover1

$echoline | sed 's/#/-/g'
echo "Test that ZSTEP OVER works with QUIT @"
$gtm_dist/mumps -run zstover2

$echoline | sed 's/#/-/g'
echo "Test that ZSTEP OUTOF works with QUIT"
$gtm_dist/mumps -run zstoutof1

$echoline | sed 's/#/-/g'
echo "Test that ZSTEP OUTOF works with QUIT @"
$gtm_dist/mumps -run zstoutof2

