#!/usr/local/bin/tcsh -f
#################################################################
#                                                               #
# Copyright (c) 2022-2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.                                          #
#                                                               #
#       This source code contains the intellectual property     #
#       of its copyright holder(s), and is made available       #
#       under a license.  If you do not know the terms of       #
#       the license, please stop and do not read further.       #
#                                                               #
#################################################################
echo '# gtm7952 test:'
echo '#'
echo '# gtm7952.csh drives a test for the SIGSAFE attribute for entries in the external call table.'
echo '# During the development for the GTM-9331 test (which also uses this support), we noted that'
echo '# this testing was missing since it was implemented in V6.3-006. The testing is discussed in'
echo '# this post: https://gitlab.com/YottaDB/DB/YDBTest/-/issues/492#note_1218063954'
echo
echo '# Building call-in library and external call table'
$gt_cc_compiler $gtt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $gtm_tst/$tst/inref/gtm7952.c
$gt_ld_shl_linker ${gt_ld_option_output}libgtm7952${gt_ld_shl_suffix} $gt_ld_shl_options gtm7952.o $gt_ld_syslibs
rm gtm7952.o # Avoid interference with M routine compilations
#
setenv	GTMXC	gtm7952.tab
echo "`pwd`/libgtm7952${gt_ld_shl_suffix}" > $GTMXC   # Push out path to external call shared library
echo '# (note there are two external calls that call the same routine but one has SIGSAFE declared and the other does not'
cat >> $GTMXC << xx
sigdisable1:	gtm_long_t	signalDisable()
sigdisable2:	gtm_long_t	signalDisable():SIGSAFE
xx
echo
echo '# Create database'
$gtm_tst/com/dbcreate.csh mumps
$echoline
set syslog_start = `date +"%b %e %H:%M:%S"`
echo
echo '# Drive gtm7952 test routine to test use of SIGSAFE when defining external calls'
$gtm_dist/mumps -run gtm7952
echo
echo '# Checking syslog for expected TIMERHANDLER warning given during drive of non-SIGSAFE routine'
$gtm_tst/com/getoper.csh "$syslog_start" "" syslog.xtr "" ""
set ourpid = `cat tmrhndlrpid.txt`      # Written out by a zsystem driven process inside gtm7952 (@ hangtest^gtm7952)
$grep "$ourpid" syslog.xtr | $grep -E "YDB-W-TIMERHANDLER|GTM-W-TIMERHANDLER"
echo
$echoline
echo
echo '#'
echo '# Here is the documentation for the traces found in the following listings. First, here is what we expect to'
echo '# find in gtm7952_strace_1.txt which is the run WITHOUT specifying SIGSAFE - meaning it will verify that the'
echo '# SIGALRM signal handler is still set as expected and if not, will reset it.'
echo '#'
echo '# 1. rt_sigaction(SIGALRM, NULL, {sa_handler=SIG_DFL, sa_mask=[], sa_flags=0}, 8) = 0'
echo '# 2. rt_sigaction(SIGALRM, {sa_handler=SIG_IGN,.*'
echo '# 3. rt_sigaction(SIGALRM, {sa_handler=.*'
echo '# 4. rt_sigaction(SIGALRM, {sa_handler=SIG_IGN,.*'
echo '# 5. rt_sigaction(SIGALRM, NULL, {sa_handler=SIG_IGN,.*'
echo '# 6. rt_sigaction(SIGALRM, {sa_handler=.*'
echo '#'
echo '# In the above system call trace extract:'
echo '# - Line 1 & 2 are done by sig_init() when (a) saving all signals and then (b) setting all signals to SIG_IGN.'
echo '# - Line 3 is when the signal is activated by the first timer call.'
echo '# - Line 4 is when the signal is reset by gtm7952.c in the external call setting the signal back to ignore.'
echo '# - Line 5 is done in check_timer_pops when it is examining the handler to see if it was modified.'
echo '# - Line 6 is also done in check_timer_pops when it decides the signal handler needs to be reset.'
echo '#'
echo '# Now the calls used when SIGSAFE is specified:'
echo '#'
echo '# 1. rt_sigaction(SIGALRM, NULL, {sa_handler=SIG_DFL, sa_mask=[], sa_flags=0}, 8) = 0'
echo '# 2. rt_sigaction(SIGALRM, {sa_handler=SIG_IGN,.*'
echo '# 3. rt_sigaction(SIGALRM, {sa_handler=.*'
echo '# 4. rt_sigaction(SIGALRM, {sa_handler=SIG_IGN,.*'
echo '#'
echo '# In the above SIGSAFE designated system call trace extract:'
echo '# - Lines 1-4 are all identical to the above calls but this version does no examination of the handler.'
echo '# - In this manner, we can prove that the SIGSAFE designation does what it says it does.'
echo '#'
echo '# Additionally, the check above for a TIMERHANDLER error in the syslog shows we were in the non-SIGSAFE'
echo '# situation and the handler was changed and then was fixed.'
echo '#'
echo
echo '# Search the strace files created while calling signalDisable() with and without the SIGSAFE definition. First,'
echo '# search the the file created by calling the C routine via sigdisable1 such that SIGSAFE is NOT in effect:'
$grep rt_sigaction gtm7952_strace_1.txt | grep SIGALRM # show calls
echo
echo '# Now the SIGACTION calls used when SIGSAFE is specified:'
$grep rt_sigaction gtm7952_strace_2.txt | grep SIGALRM # show calls
echo
echo '# Verify database'
$gtm_tst/com/dbcheck.csh
