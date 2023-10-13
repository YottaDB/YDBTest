#!/usr/local/bin/tcsh -f
#################################################################
#                                                               #
# Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#                                                               #
#       This source code contains the intellectual property     #
#       of its copyright holder(s), and is made available       #
#       under a license.  If you do not know the terms of       #
#       the license, please stop and do not read further.       #
#                                                               #
#################################################################
#
echo '# gtm8010 release note:'
echo '# OPEN "/dev/null" with deviceparameters works appropriately. The only deviceparameters'
echo '# GT.M actually attempts to implement for /dev/null are [NO]WRAP and EXCEPTION= and, at'
echo '# least in theory, the device should never give an exception. Previously, such an OPEN'
echo '# handled deviceparameters inappropriately, which could cause unintended WRAP behavior'
echo '# or an attempt to instantiate an exception handler constructed out of garbage, which,'
echo '# in turn, could cause a segmentation violation (SIG-11). The workaround was to specify'
echo '# no deviceparmeters on an OPEN of /dev/null. In addition, GT.M appropriately handles'
echo '# EXCEPTION= values settings whose lengths are between 128 and 255 bytes long. Previously,'
echo '# GT.M mishandled such settings potentially resulting in a segmentation violation (SIG-11).'
echo '# The second issue has not been reported by a customer, but was observed in development.'
echo '# (GTM-8010)'
echo '#'
echo '# Since the first part of this issue ([NO]WRAP, EXCEPTION= SIG11s) was addressed in YottaDB'
echo '# by YDB commit YDB@5a7d473c and tested by a4a3bbab, we only implement the "In addition," part'
echo '# of the above release note.'
echo '#'
echo '# Test explanation:'
echo '#'
echo '#   - Starts with an exception string that increments the variable errcnt if the exception'
echo '#     string is driven.'
echo '#   - Start a loop that does 26 iterations.'
echo '#   - Each iteration adds a "SET x=nn" command to exception string where nn is the iteration'
echo '#     number.'
echo '#   - Each iteration prints out the iterations and the exception string length. The actual'
echo '#     string is written to gtm8010_exception_string.txt so the longer length strings do not'
echo '#     pollute the reference file.'
echo '#   - Then each iteration opens the null device using the exception string. We also do a USE'
echo '#     of the device and a short write before closing the device. If this all occurs without'
echo '#     error, the iteration passes. If an error occurs, we try to catch it so the subsequent'
echo '#     iterations continue. Of course if a SIG-11 occurs, it is all over but this test does'
echo '#     not seem to evoke that type of failure on older releases.'
echo '#'
echo '# More on why no SIG-11:'
echo '#   The fix made for the SIG-11 was identified. It came from the fact that the single byte'
echo '#   length field was loaded into an integer without cast so value came in as a signed char.'
echo '#   This means that for lengths from 128 to 255, the length field of the exception string'
echo '#   was seen to be negative. There are several potential places a negative value can get'
echo '#   into trouble. In the upstream case, it seems to have usually produced a SIG-11. But'
echo '#   this particular test has seen both assert failures (running r1.38 debug) and more'
echo '#   commonly, we get this STACKCRIT failure on V70000 (and r1.38 pro) and earlier releases'
echo '#   that stems from an INDRMAXLEN error trying to compile the exception string and it'
echo '#   re-invoking handlers and looping until it gets STACKCRIT.'
echo '#'
echo '#   So the bottom line is that this test is having the same problem as the original issue,'
echo '#   but it is manifesting itself in multiple and different ways than the original issue'
echo '#   only reporting it ended in a SIG-11 if it ended badly.'
echo '#'
echo
echo '# Driving gtm8010'
$gtm_dist/mumps -run gtm8010
echo
@ gtm_status = $status
if ($gtm_status == 0) then
    echo '# gtm8010 complete'
else
    echo '# gtm8010 complete with errors'
endif
