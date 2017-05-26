#!/usr/local/bin/tcsh
#################################################################
#								#
#	Copyright 2013, 2014 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#;;;Test the unix behavior for the disk device timed reads in follow mode with timeout
#;;;for both M and unicode

$switch_chset M

# Create one-region gld and associated .dat file
$gtm_tst/com/dbcreate.csh mumps 1

# Set encryption attributes, if needed.
source $gtm_tst/$tst/u_inref/set_key_and_iv.csh

$echoline
echo "**************************** followtimeout ****************************"
$echoline
# report number of read interrupts when mumps exits
setenv gtmdbglvl 0x00080000

$gtm_dist/mumps -run followtimeout >& followtimeout.out

# make sure the reader, writer, and interrupt processes are done
set pid1=`cat reader_timeout_pid`
$gtm_tst/com/wait_for_proc_to_die.csh $pid1 120
if ($status) then
	echo "TEST-E-ERROR process $pid1 did not die."
endif
set pid2=`cat reader_timeout_pid`
$gtm_tst/com/wait_for_proc_to_die.csh $pid2 120
if ($status) then
	echo "TEST-E-ERROR process $pid2 did not die."
endif
set pid3=`cat sendintr_timeout_pid`
$gtm_tst/com/wait_for_proc_to_die.csh $pid3 120
if ($status) then
	echo "TEST-E-ERROR process $pid3 did not die."
endif

# check for read interrupts unless not chosen randomly
if (! -e "sendintr_timeout_not_pid") then
	set numint=`$grep interrupted reader_timeout.mje`
	if ($#numint) then
		if (0 == `echo $numint | $tst_awk '{print $8}'`) then
			echo "Read interrupt count is zero in reader_timeout.mje"
		endif
	else
		echo "Read interrupt count missing from reader_timeout.mje"
	endif
endif

# just output the start information
$head -n 1 followtimeout.out
echo "Output of reader_timeout.mjo:"
cat reader_timeout.mjo

$echoline
echo "**************************** gtm8109 in M mode ****************************"
$echoline
unsetenv gtmdbglvl
$gtm_dist/mumps -run gtm8109

if ("TRUE" == $gtm_test_unicode_support) then
# Large block containing GTM input redirection commands.  Not indenting.
# report number of read interrupts when mumps exits
setenv gtmdbglvl 0x00080000

$echoline
echo "**************************** utffollowtimeout ****************************"
$echoline

$switch_chset UTF-8
$gtm_dist/mumps -run utffollowtimeout >& utffollowtimeout.out

# make sure the reader, writer, and interrupt processes are done
set pid1=`cat utfreader_timeout_pid`
$gtm_tst/com/wait_for_proc_to_die.csh $pid1 120
if ($status) then
	echo "TEST-E-ERROR process $pid1 did not die."
endif
set pid2=`cat utfwriter_timeout_pid`
$gtm_tst/com/wait_for_proc_to_die.csh $pid2 120
if ($status) then
	echo "TEST-E-ERROR process $pid2 did not die."
endif
set pid3=`cat utfsendintr_timeout_pid`
$gtm_tst/com/wait_for_proc_to_die.csh $pid3 120
if ($status) then
	echo "TEST-E-ERROR process $pid3 did not die."
endif

# check for read interrupts unless not chosen randomly
if (! -e "utfsendintr_timeout_not_pid") then
	set numint=`$grep interrupted utfreader_timeout.mje`
	if ($#numint) then
		if (0 == `echo $numint | $tst_awk '{print $8}'`) then
			echo "Read interrupt count is zero in utfreader_timeout.mje"
		endif
	else
		echo "Read interrupt count missing from utfreader_timeout.mje"
endif
endif
# just output the start information
$head -n 1 utffollowtimeout.out
echo "Output of utfreader_timeout.mjo:"
cat utfreader_timeout.mjo

$echoline
echo "**************************** gtm8109 in UTF mode ****************************"
$echoline
unsetenv gtmdbglvl
$gtm_dist/mumps -run gtm8109

endif	#end of UTF block

$gtm_tst/com/dbcheck.csh
