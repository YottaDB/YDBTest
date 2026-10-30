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
echo '# [YDB#1348] WRITE /mnemonic to a SOCKET device accepts BLOCK only as the whole mnemonic, and does   #'
echo '# not read past the end of the "BLOCK" literal                                                       #'
echo "#----------------------------------------------------------------------------------------------------#"
echo
echo '# WRITE /mnemonic to a SOCKET device checked for BLOCK with memcmp() using the length of the mnemonic'
echo '# in the WRITE. A mnemonic longer than BLOCK made memcmp() read past the end of the literal "BLOCK"'
echo '# (which an ASAN build reports as a global-buffer-overflow), and any prefix of BLOCK was accepted as'
echo '# BLOCK. The mnemonic now has to be BLOCK (in any case), as LISTEN, WAIT, PASS, ACCEPT and TLS already'
echo '# have to be the whole mnemonic, and any other mnemonic issues INVCTLMNE.'
echo '# Each stage does its WRITE to a listening socket in a new process and prints PASS or WRONG.'
echo

cp $gtm_tst/$tst/inref/ydb1348.m .
foreach label (long b blo blocks block)
	switch ($label)
	case "long":
		echo '# Stage 1 : WRITE /BLOCKG121, a mnemonic that starts with BLOCK and is longer than it'
		echo '# Before the fix : INVCTLMNE too, but memcmp() read past the end of "BLOCK", which an ASAN build'
		echo '#                  reported as a global-buffer-overflow, terminating the process'
		echo '# With the fix   : expect INVCTLMNE'
		breaksw
	case "b":
		echo '# Stage 2 : WRITE /B("OFF"), the 1-character prefix of BLOCK'
		echo '# Before the fix : taken as WRITE /BLOCK("OFF"), which issues SOCKBLOCKERR on a listening socket, so'
		echo '#                  the line below was a WRONG line'
		echo '# With the fix   : expect INVCTLMNE'
		breaksw
	case "blo":
		echo '# Stage 3 : WRITE /BLO("CLEAR"), a 3-character prefix of BLOCK'
		echo '# Before the fix : taken as WRITE /BLOCK("CLEAR"), with no error, so the line below was a WRONG line'
		echo '# With the fix   : expect INVCTLMNE'
		breaksw
	case "blocks":
		echo '# Stage 4 : WRITE /BLOCKS("CLEAR"), BLOCK followed by one more character'
		echo '# Before the fix : the same output (this stage is a control)'
		echo '# With the fix   : expect INVCTLMNE'
		breaksw
	case "block":
		echo '# Stage 5 : WRITE /BLOCK("CLEAR") and WRITE /block("CLEAR")'
		echo '# Before the fix : the same output (this stage is a control)'
		echo '# With the fix   : expect no error for both'
		breaksw
	endsw
	echo '# Command : $gtm_dist/mumps -run '"$label"'^ydb1348'
	$gtm_dist/mumps -run $label^ydb1348
	echo
end
echo "# Done"
