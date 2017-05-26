#!/usr/local/bin/tcsh
#################################################################
#								#
#	Copyright 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#;;;Test the unix bahavior of the disk device with both M and unicode tests
#;;;This work was done under the GTM-7540
#;;;
# The following table shows the state conditions for timed reads for the disk reads
# It shows any modifications to the input variable X and Status Variables.

# Operation		Case			$DEVICE		$ZA	$TEST		X	$ZEOF
#
# READ X:1	  Normal Termination		   0		 0	  1	    Data Read     0
# READ X:1       Timeout with no data read	   0		 0	  0	  empty string	  0
# READ X:1     Timeout with partial data read	   0		 0	  0       Partial data    0
# READ X:1		End of File     1,Device detected EOF	 9	  1       empty string    1
# READ X:0	  Normal Termination		   0		 0	  1	    Data Read	  0
# READ X:0	  No data available		   0		 0	  0	  empty string	  0
# READ X:0     Timeout with partial data read	   0		 0	  0	  Partial data	  0
# READ X:0		End of File	1,Device detected EOF	 9	  1	  empty string	  1
# READ X:N		Error		1,<error signature>	 9  indeterminate empty string	  0

$switch_chset M

# Create one-region gld and associated .dat file
$gtm_tst/com/dbcreate.csh mumps 1

$echoline
echo "**************************** diskfollow ****************************"
$echoline
$gtm_dist/mumps -run diskfollow >& diskfollow.out

# make sure the reader and writer processes are done
set pid1=`cat reader_pid`
$gtm_tst/com/wait_for_proc_to_die.csh $pid1 120
if ($status) then
	echo "TEST-E-ERROR process $pid1 did not die."
endif
set pid2=`cat writer_pid`
$gtm_tst/com/wait_for_proc_to_die.csh $pid2 120
if ($status) then
	echo "TEST-E-ERROR process $pid2 did not die."
endif

cat diskfollow.out
echo "Output of reader.mjo:"
cat reader.mjo

$echoline
echo "**************************** fixfollow ****************************"
$echoline

$gtm_dist/mumps -run fixfollow >& fixfollow.out

# make sure the fixed reader and writer processes are done
set pid1=`cat fixreader_pid`
$gtm_tst/com/wait_for_proc_to_die.csh $pid1 120
if ($status) then
	echo "TEST-E-ERROR process $pid1 did not die."
endif
set pid2=`cat fixwriter_pid`
$gtm_tst/com/wait_for_proc_to_die.csh $pid2 120
if ($status) then
	echo "TEST-E-ERROR process $pid2 did not die."
endif

cat fixfollow.out
echo "Output of fixreader.mjo:"
cat fixreader.mjo

if ("TRUE" == $gtm_test_unicode_support) then
# Large block containing GTM input redirection commands.  Not indenting.

$echoline
echo "**************************** utfdiskfollow ****************************"
$echoline

$switch_chset UTF-8
$gtm_dist/mumps -run utfdiskfollow >& utfdiskfollow.out

# make sure the reader and writer processes are done
set pid1=`cat utfreader_pid`
$gtm_tst/com/wait_for_proc_to_die.csh $pid1 120
if ($status) then
	echo "TEST-E-ERROR process $pid1 did not die."
endif
set pid2=`cat utfwriter_pid`
$gtm_tst/com/wait_for_proc_to_die.csh $pid2 120
if ($status) then
	echo "TEST-E-ERROR process $pid2 did not die."
endif

cat utfdiskfollow.out
echo "Output of utfreader.mjo:"
cat utfreader.mjo

$echoline
echo "**************************** utffixfollow ****************************"
$echoline

# report number of read interrupts when mumps exits
setenv gtmdbglvl 0x00080000

$gtm_dist/mumps -run utffixfollow >& utffixfollow.out

# make sure the reader, writer, and interrupt processes are done
set pid1=`cat utffixreader_pid`
$gtm_tst/com/wait_for_proc_to_die.csh $pid1 120
if ($status) then
	echo "TEST-E-ERROR process $pid1 did not die."
endif
set pid2=`cat utffixwriter_pid`
$gtm_tst/com/wait_for_proc_to_die.csh $pid2 120
if ($status) then
	echo "TEST-E-ERROR process $pid2 did not die."
endif
set pid3=`cat utffixsendintr_pid`
$gtm_tst/com/wait_for_proc_to_die.csh $pid3 120
if ($status) then
	echo "TEST-E-ERROR process $pid3 did not die."
endif

# check for read interrupts
set numint=`$grep interrupted utffixreader.mje`
if ($#numint) then
	if (0 == `echo $numint | $tst_awk '{print $8}'`) then
		echo "Read interrupt count is zero in utffixreader.mje"
	endif
else
	echo "Read interrupt count missing from utffixreader.mje"
endif
# just output the start information
$head -n 1 utffixfollow.out
echo "Output of utffixreader.mjo:"
cat utffixreader.mjo

# stop reporting number of read interrupts when mumps exits
unsetenv gtmdbglvl

$echoline
echo "**************************** badcharfollow ****************************"
$echoline

$gtm_dist/mumps -run badcharfollow >& badcharfollow.outx
cat badcharfollow.outx

endif	#end of UTF block

$gtm_tst/com/dbcheck.csh
