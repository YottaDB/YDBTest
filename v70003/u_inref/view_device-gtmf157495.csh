#!/usr/local/bin/tcsh -f
#################################################################
#
# Copyright (c) 2023-2024 YottaDB LLC and/or its subsidiaries.
# All rights reserved.
#
#	This source code contains the intellectual property
#	of its copyright holder(s), and is made available
#	under a license.  If you do not know the terms of
#	the license, please stop and do not read further.
#
#################################################################

cat <<echo_text
########################################################################################
# Test that new function \$VIEW("DEVICE",<device>) retuns the specified device status
########################################################################################

echo_text

echo '# test1: Print status of split $ZPIN and $ZPOUT device type TERMINAL as OPEN.'
echo '#        Does not test CLOSE as it is impossible to close $principal.'
$gtm_dist/mumps -run viewTerminal^viewDevice </dev/tty >zpout.log
cat zpout.log
echo

echo "# test2: Print status of open and closed regular (RMS) file."
$gtm_dist/mumps -run viewFile^viewDevice
echo

echo "# test3: Print status of open and closed FIFO."
echo '#        Prints nothing after CLOSE because it is impossible to close FIFO without it disappearing'
$gtm_dist/mumps -run viewFifo^viewDevice
echo

echo "# test4: Print status of open and closed PIPE."
echo '#        Prints nothing after CLOSE because it is impossible to close PIPE without it disappearing'
$gtm_dist/mumps -run viewPipe^viewDevice
echo

echo "# test5: Print status of open and closed SOCKET."
$gtm_dist/mumps -run socketListen^viewDevice &
$gtm_dist/mumps -run socketConnect^viewDevice
echo

echo "# test6: Print status of open and closed NULL device."
$gtm_dist/mumps -run viewNull^viewDevice
echo
