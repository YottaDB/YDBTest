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
echo '# [YDB#1331] RECORDSIZE of a device with a UTF-8 or UTF-16 CHSET must hold any one character        #'
echo "#----------------------------------------------------------------------------------------------------#"
echo
echo '# A character takes up to 4 bytes in UTF-8 and in UTF-16. A device with a smaller RECORDSIZE wrote a'
echo '# character that did not fit anyway, producing records longer than RECORDSIZE, looped forever writing'
echo '# a UTF-16 surrogate pair, or issued BADCHAR reading a valid FIXED file. Now OPEN and USE issue'
echo '# RECSIZETOOSMALL for such a device, and a USE, or an OPEN of an open device, that fails leaves the device'
echo '# as it was. The STDERR device of a PIPE, whose RECORDSIZE was 0, now gets the RECORDSIZE of the PIPE.'
echo '#'
echo '# Each case names the error it expects, or the bytes in hex that the file must hold, and prints PASS or'
echo '# FAIL.'
echo

cp $gtm_tst/$tst/inref/ydb1331.m .

echo '# Stage 1 : devices with a UTF-8 or UTF-16 CHSET, in UTF-8 mode'
echo '# Command : $gtm_dist/mumps -run utf^ydb1331'
echo '# Before the fix, each OPEN and USE with a RECORDSIZE of 1 to 3 worked (except RECORDSIZE=3 with UTF-16,'
echo '# which issued RECSIZENOTEVEN), so the cases that expect RECSIZETOOSMALL printed FAIL, and the pipeerr'
echo '# READ returned an empty string (an assert failure in iorm_readfl.c in a Debug build). recsize0, pipeerrvar'
echo '# and pipeerrrec had the same result'
echo '#   expect RECSIZETOOSMALL for a RECORDSIZE of 1 to 3, leaving a device that is open as it was, RECORDSIZE=4'
echo '#   to hold any character, and the STDERR device of a FIXED PIPE to READ its line'
$switch_chset "UTF-8" >& switch_chset_utf8.out
$gtm_dist/mumps -run utf^ydb1331
echo

echo '# Stage 2 : devices in M mode'
echo '# Command : $gtm_dist/mumps -run m^ydb1331'
echo '# Before the fix, the same result'
echo '#   expect RECORDSIZE=1 to work, also with OCHSET="UTF-8", which M mode ignores, and the STDERR device of a'
echo '#   FIXED PIPE to READ its line'
$switch_chset M >& switch_chset_m.out
$gtm_dist/mumps -run m^ydb1331
echo

echo "# Done"
