#################################################################
#								#
# Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# GTM-9057 - Verify that MUPIP JOURNAL -EXTRACT can be sent to a FIFO device
#
echo '# Release note:'
echo '#'
echo '#   MUPIP JOURNAL -EXTRACT accepts a named pipe (FIFO) as its output device. A process'
echo '#   needs to open one end of the FIFO (in read mode) and the device can then be passed'
echo '#   as an extract output device. Previously, such extracts could not be written into a'
echo '#   FIFO.(GTM-9057)'
echo '#'
setenv gtm_test_jnl SETJNL			# We want/need journaling
#
echo
echo '# Create database'
$gtm_tst/com/dbcreate.csh mumps 1
echo
echo '# Do a few updates to create some journal records'
$gtm_dist/mumps -dir << EOF
for i=1:1:20 set ^value(\$justify(i,3))=\$justify(i,5)
EOF
echo
echo '# Startup a reader process that opens a pipe named "fifo.input" that is waiting for'
echo '# input.'
($gtm_dist/mumps -run gtm9057 & ; echo $! >&! readerpid.txt) >&! reader.log
echo
echo '# Wait until "fifo.input" exists so we know it is ready to receive'
@ waits = 0
# Sleep until the file is available
while (! -e fifo.input)
    @ waits = $waits + 1
    if (300 < $waits) then
	echo 'Terminating wait for FIFO to be established - exiting'
	exit 1
    endif
    sleep 1
end
echo
echo '# FIFO reader is waiting - feed it with the extract from our journal file'
$MUPIP journal -extract=fifo.input -forward mumps.mjl
echo
echo '# Extract complete, now notify the reader it is done too'
$gtm_dist/mumps -run ^%XCMD 'open "fifo.input":fifo use "fifo.input" write "doneDoneDONE",!'
echo
echo '# Wait for reader shutdown after it gets termination notice above'
set readerpid = `cat readerpid.txt`
$gtm_tst/com/wait_for_proc_to_die.csh $readerpid 300
#
# Print out the logfile from the reader. Note this file contains the '[1] <readerpid>` message when
# the reader terminates. So we exclude that line by removing "] <readerpid>" messages from the log.
# Normally the message is "[1] <readerpid>" but I don't think we can depend on the numeric value.
#
echo
echo "# Reader log"
cat reader.log | grep -v "] $readerpid"
echo
echo '# Extract data read by reader:'
cat jnl_extract_match.txt
echo
echo '# Validate DB'
$gtm_tst/com/dbcheck.csh
