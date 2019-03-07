#! /usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2012-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
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
# Procedure to test "r x:0"
setenv TERM xterm
expect -f $gtm_tst/$tst/u_inref/rx0.exp >&! rx0.outx
cat rx0.expected

# Comments from test/expect/inref/rx0.txt, the original test case
#
# The test rx0 cannot run like other test scripts because the main purpose of
# rx0 is to test the command "r x:0". It will timeout immediately if there is
# nothing ALREADY available. But our usual way to do the test is to do it by
# the instream.csh, which is exactly one of the ways that makes something
# ALREADY available to a read. I am trying to find another way to test it, but
# for now, you might want to do the test by hand. Just start the GT.M. and write
# the command "d ^rx0". And see if it PASS.
#
# -- Xianguan Li 06/09/97
#
# rx0.m JOBs a second process that kills the first after a few seconds - when
# manually run this seems unnecessary (or even confusing), but is a residual from
# earlier attempts at more automation and is left for now. Also, on VMS V999 used
# for daily testing has $zv V9.9-0 and won't work since rx0start.com will have the
# wrong ver command.
#
# If you are running the same copy in a different server (if the files are in NFS), make sure you delete .o before you run again.
# -- Sam Weiner 2004/5/18 update by Roger 30 Jan 2008
#
# --------------------------------------------------------------------------------
# I talked with Sam to understand the comments from above. Previously, the
# "do ^rx0" command would have been run within a HEREDOC which would change the
# characteristics of $PRINCIPAL.
#
# #1# HEREDOC
# 	$gtm_exe/mumps -direct << EOF
# zshow "d"
# EOF
# 	Produces:
# 	YDB>
# 	0 OPEN RMS
#
# #2# %XCMD
# 	Invocation						Output
# 	mumps -run %XCMD 'zshow "d"'				/dev/pts/24 OPEN TERMINAL NOPAST NOESCA NOREADS TYPE WIDTH=237 LENG=55
# 	mumps -run %XCMD 'zshow "d"' < /dev/null		0 OPEN RMS
# 	cat /dev/null | mumps -run %XCMD 'zshow "D"'		0 OPEN FIFO
# 	mumps -run %XCMD 'zshow "D"' |cat -			/dev/pts/24 OPEN TERMINAL NOPAST NOESCA NOREADS TYPE WIDTH=237 LENG=66
#
#
# #3# MUMPS -RUN
# Using an M program instead of a HEREDOC
# 	cat > zshowd.m << MPROG
# zshowd
#  zshow "d"
# MPROG
#
# 	Invocation						Output
# 	mumps -run zshowd					/dev/pts/24 OPEN TERMINAL NOPAST NOESCA NOREADS TYPE WIDTH=237 LENG=55
# 	mumps -run zshowd < /dev/null				0 OPEN RMS
# 	cat /dev/null | mumps -run -run zshowd			0 OPEN FIFO
# 	mumps -run zshowd  |cat -				/dev/pts/24 OPEN TERMINAL NOPAST NOESCA NOREADS TYPE WIDTH=237 LENG=66
#
#
#
# It is now possible to run this test in an automated fashion from a single
# machine with expect. The expect execution command is (replace <HOSTNAME>):
# expect -f $gtm_test/T999/expect/u_inref/remote_rx0.exp <HOSTNAME> $gtm_test/T999 expect V990 p
#
# The following is cut'n'paste code. If the test fails anywhere, expect will hang
# due a pattern mismatch.
#
#tcsh
#set prompt="rx0 `hostname`:$PWD >"
#source $cms_tools/server_list
#mkdir -p /testarea1/$user/${gtm_verno}/drive_rx0
#cd /testarea1/$user/${gtm_verno}/drive_rx0
#set prompt="rx0 $PWD > "
#foreach host ( $server_args sagaloo sagpaneer )
#echo $host
#expect -f $gtm_test/T990/expect/u_inref/remote_rx0.exp $host $gtm_test/T990 $gtm_verno
#end
#exit
#
# -- Amul Shah 2011/04/12
