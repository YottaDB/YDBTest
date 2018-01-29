#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# Test that libgtmshr.so/libgtmutil.so are soft links to libyottadb.so/libyottadbutil.so
#

cd $gtm_dist
foreach subdir (. utf8)
	echo 'Test that '$subdir'/libyottadb.so exists in $gtm_dist'
	$echoline
	$gtm_tst/com/lsminusl.csh $subdir/libyottadb.so | $tst_awk '{print $1,$2,$3,$4,$9,$10,$11}'
	echo ""
	echo 'Test that '$subdir'/libgtmshr.so is a softlink to '$subdir'/libyottadb.so'
	$echoline
	$gtm_tst/com/lsminusl.csh $subdir/libgtmshr.so | $tst_awk '{print $1,$2,$3,$4,$9,$10,$11}'
	echo ""
	echo 'Test that '$subdir'/libyottadbutil.so exists in $gtm_dist'
	$echoline
	$gtm_tst/com/lsminusl.csh $subdir/libyottadbutil.so | $tst_awk '{print $1,$2,$3,$4,$9,$10,$11}'
	echo ""
	echo 'Test that '$subdir'/libgtmutil.so is a softlink to '$subdir'/libyottadbutil.so'
	$echoline
	$gtm_tst/com/lsminusl.csh $subdir/libgtmutil.so | $tst_awk '{print $1,$2,$3,$4,$9,$10,$11}'
	echo ""
end
