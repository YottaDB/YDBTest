#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2015 Fidelity National Information 		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Test a known case of gv_altkey corruption that leads to bad $zprevious() results.

# Set up multiple regions with wide enough ranges on the second subscript, which is where we will operate
# with $zprevious() commands. This is to ensure that our searches stay within the same search map.
cat > gdesetup.cmd <<eof
add -name x(1)   -reg=REG1
add -name x(1,1:10) -reg=REG2
add -name x(1,11:20) -reg=REG3

add -region REG1 -dyn=REG1
change -region REG1 -std -record_size=512 -key_size=128
add -segment REG1 -file=REG1
change -segment REG1 -block_size=512
add -region REG2 -dyn=REG2
change -region REG2 -std -record_size=512 -key_size=128
add -segment REG2 -file=REG2
change -segment REG2 -block_size=512
add -region REG3 -dyn=REG3
change -region REG3 -std -record_size=512 -key_size=128
add -segment REG3 -file=REG3
change -segment REG3 -block_size=512
change -region DEFAULT -std -record_size=512 -key_size=128
change -segment DEFAULT -block_size=512
eof

$GDE >&! gde.log <<eof
@gdesetup.cmd
exit
eof

$MUPIP create >&! mupip.log

$gtm_dist/mumps -run gvaltkeyverif

# We created the database using a specific global mapping instead of dbcreate.csh script.
$gtm_tst/com/dbcheck.csh
