#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo "#----------------------------------------------------------------------------------------------------#"
echo '# [YDB#1280] $VIEW("SPSIZE") and $VIEW("SPSIZESORT") return correct values once a size reaches 2GiB  #'
echo "#----------------------------------------------------------------------------------------------------#"
echo
echo '# op_fnview.c converted each size to an mval through a 32-bit int, so a stringpool size, a count of'
echo '# bytes in use, or the space a $VIEW("SPSIZESORT") garbage collection needs wrapped around to a'
echo '# negative or unrelated positive number once it reached 2GiB.'
echo '#'
echo '# The routine fills the stringpool with 2100MiB of live strings. The process needs about 8GiB of'
echo '# memory at its peak, which is why r208/instream.csh excludes this subtest on systems with less than'
echo '# 16GiB. The garbage collection mode is left to ydb_stp_gcol_nosort, which do_random_settings.csh'
echo '# sets at random: every expected value below holds in both modes.'
echo

cp $gtm_tst/$tst/inref/ydb1280.m .

echo '# Command : $ydb_dist/yottadb -run ydb1280'
echo
$ydb_dist/yottadb -run ydb1280
echo

echo "# Done"
