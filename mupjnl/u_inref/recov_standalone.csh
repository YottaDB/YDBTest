#! /usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2003-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
echo "Test case 70: Recovery needs standlaone access"
$gtm_tst/com/dbcreate.csh mumps 2
echo mupip set -journal=enable,on,before -reg DEFAULT
$MUPIP set -journal=enable,on,before -reg DEFAULT
echo mupip set -journal=enable,on,before -reg AREG
$MUPIP set -journal=enable,on,before -reg AREG
$GTM << aaa
s ^x=1
s ^a=1
aaa
cp mumps.dat backup_mumps.dat
cp a.dat backup_a.dat
set output = "recover_back_1.out"
$GTM << aaa
w "^x=",^x,!
w "$MUPIP journal -recover -back mumps.mjl,a.mjl",!
zsy "$MUPIP journal -recover -back mumps.mjl,a.mjl >&! ${output}x"
zsy "$MUPIP journal -recover -back a.mjl"
aaa

$grep -qE '.dat.*(File is in use|File already open) by another process' ${output}x
if ($status) then
	echo "SETJNL-E-ERROR : Expected File is in use or File already open error from the above command, but did not find it in ${output}x"
endif
$grep -v 'YDB-E-MUNOACTION' ${output}x >&! $output
echo "------------------------------------------------------------------------------------"
set output = "recover_back_2.out"
$GTM << aaa
w "^a=",^a,!
w "$MUPIP journal -recover -back mumps.mjl,a.mjl",!
zsy "$MUPIP journal -recover -back mumps.mjl,a.mjl >&! ${output}x"
aaa

$grep -qE '.dat.*(File is in use|File already open) by another process' ${output}x
if ($status) then
	echo "SETJNL-E-ERROR : Expected File is in use or File already open error from the above command, but did not find it in ${output}x"
endif
$grep -v 'YDB-E-MUNOACTION' ${output}x >&! $output
echo "------------------------------------------------------------------------------------"
set output = "recover_forw_1.out"
$GTM << aaa
w "^x=",^x,!
w "$MUPIP journal -recover -forw -nochecktn mumps.mjl,a.mjl",!
zsy "$MUPIP journal -recover -forw -nochecktn mumps.mjl,a.mjl >&! ${output}x"
aaa

$grep -qE '.dat.*(File is in use|File already open) by another process' ${output}x
if ($status) then
	echo "SETJNL-E-ERROR : Expected File is in use or File already open error from the above command, but did not find it in ${output}x"
endif
$grep -v 'YDB-E-MUNOACTION' ${output}x >&! $output
echo "------------------------------------------------------------------------------------"
set output = "recover_forw_2.out"
$GTM << aaa
w "^a=",^a,!
w "$MUPIP journal -recover -forw -nochecktn mumps.mjl,a.mjl",!
zsy "$MUPIP journal -recover -forw -nochecktn mumps.mjl,a.mjl >&! ${output}x"
aaa

$grep -qE '.dat.*(File is in use|File already open) by another process' ${output}x
if ($status) then
	echo "SETJNL-E-ERROR : Expected File is in use or File already open error from the above command, but did not find it in ${output}x"
endif
$grep -v 'YDB-E-MUNOACTION' ${output}x >&! $output
$gtm_tst/com/dbcheck.csh
