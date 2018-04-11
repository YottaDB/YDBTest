#!/usr/local/bin/tcsh -f
#################################################################
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
# This module is derived from FIS GT.M.
#################################################################

#
# Test all possible combinations for BADCHAR error
# Test VIEW:"BADCHAR", $VIEW("BADCHAR"), $gtm_badchar, and the BADCHAR error
#
$echoline
$gtm_tst/com/dbcreate.csh mumps 1 125 1000 1024
# generate badchar routine using genbadchar.m - this will create lbadchar.m that will be executed by unicodesampledata
$gtm_exe/mumps -run ^genbadchars
# disable badchar behavior when we fill the database because it will cause compilation error otherwise
setenv gtm_badchar "no"
$GTM << EOF >&! unicodesampledata_with_warnings.outx
do global^unicodesampledata
write "write \$VIEW(BADCHAR)"
write "Expcted output 0"
write \$VIEW("BADCHAR")
do ^viewbadchar("notexpected")
do convert^viewbadchar
EOF
#
$tst_awk -f $gtm_tst/com/filter_litnongraph.awk unicodesampledata_with_warnings.outx
unsetenv gtm_badchar # restore GTM default behavior for BADCHAR
$GTM << EOF
write "write \$VIEW(BADCHAR)"
write "Expected output 1"
write \$VIEW("BADCHAR")
do ^viewbadchar("expected")
do convert^viewbadchar
EOF
#
setenv gtm_badchar "y"
$GTM << EOF
write "write \$VIEW(BADCHAR)"
write "Expected output 1"
write \$VIEW("BADCHAR")
do ^viewbadchar("expected")
do convert^viewbadchar
EOF
#
$GTM << EOF
view "NOBADCHAR"
write "write \$VIEW(BADCHAR)"
write "Expected output 0"
write \$VIEW("BADCHAR")
do ^viewbadchar("notexpected")
do convert^viewbadchar
EOF
#
setenv gtm_badchar "n"
$GTM << EOF
write "write \$VIEW(BADCHAR)"
write "Expected output 0"
write \$VIEW("BADCHAR")
do ^viewbadchar("notexpected")
do convert^viewbadchar
EOF
#
setenv gtm_badchar "1"
$GTM << EOF
write "write \$VIEW(BADCHAR)"
write "Expected output 1"
write \$VIEW("BADCHAR")
do ^viewbadchar("expected")
do convert^viewbadchar
EOF
#
setenv gtm_badchar "k"
$GTM << EOF
write "write \$VIEW(BADCHAR)"
write "Expected output 1"
write \$VIEW("BADCHAR")
do ^viewbadchar("expected")
do convert^viewbadchar
EOF
#
setenv gtm_badchar "f"
$GTM << EOF
write "write \$VIEW(BADCHAR)"
write "Expected output 0"
write \$VIEW("BADCHAR")
do ^viewbadchar("notexpected")
do convert^viewbadchar
EOF
#
grep -E "TEST-E-EXPECTED|TEST-E-UNEXPECTED" *badchar_*.out # includes viewbadchar_* and alwaysbadchar* outputs
if ($status) then
	echo "BADCHAR PASSED"
endif
# the reason we are redirecting the check_error_exist.csh output to a logx extension file is because
# the output of check_error_exist.csh is HUGE. It will be a pain to traverse even a PASSED reference file
# So instead do a grep -v of the redirected logx extension file to see if there are any issues other than YDB-E-BADCHAR
# if check_error_exist.csh itself has failed with issues then viewbadchar_expected.out wouldn't have been processed
# and the test sytem will catch them at the end of the run - so no worries there too.
$gtm_tst/com/check_error_exist.csh  viewbadchar_expected.out "YDB-E-BADCHAR" >&! check_error_exist.logx
$gtm_tst/com/check_error_exist.csh  viewbadchar_zconvert.out "YDB-E-BADCHAR" >&! check_error_exist.logy
$gtm_tst/com/check_error_exist.csh  alwaysbadchar.out "YDB-E-BADCHAR" >&! alwaysbadchar.loga
# first check YDB-E-BADCHAR is seen or not in the redirected logs
set stat1x=`$grep "%YDB\-E\-BADCHAR" check_error_exist.logx|wc -l`
# then check for any other -E- errors in the redirected log
set stat2x=`$grep "\-E\-" check_error_exist.logx|grep -v "YDB\-E\-BADCHAR"|wc -l`
#
set stat1y=`$grep "YDB\-E\-BADCHAR" check_error_exist.logy|wc -l`
set stat2y=`$grep "\-E\-" check_error_exist.logy|grep -v "YDB\-E\-BADCHAR"|wc -l`
#
set stat1a=`$grep "YDB\-E\-BADCHAR" alwaysbadchar.loga|wc -l`
set stat2a=`$grep "\-E\-" alwaysbadchar.loga|grep -v "YDB\-E\-BADCHAR"|wc -l`
if ( (0 != $stat1x) && (0 != $stat1y) && (0 != $stat1a) && (0 == $stat2x) && (0 == $stat2y) && (0 == $stat2a) ) then
	echo "PASS. Expected error YDB-E-BADCHAR seen and not other errors detected"
else
	echo "TEST-E-ERROR. Either BADCHAR not seen or some other errors detected. check check_error_exist.log[x,y] logs"
endif
#
# check for INVDLRCVAL error here. Since this error depends on VIEW "BADCHAR" seetting we will have i captured here
# insted of in the errors subtest
$gtm_tst/com/check_error_exist.csh  invdlrcval_expected.out "YDB-E-INVDLRCVAL" >&! check_error_exist.logz
set stat1z=`$grep "%YDB\-E\-INVDLRCVAL" check_error_exist.logz|wc -l`
# then check for any other -E- errors in the redirected log
set stat2z=`$grep "\-E\-" check_error_exist.logz|grep -v "YDB\-E\-INVDLRCVAL"|wc -l`
if ( (0 != $stat1z) && (0 == $stat2z) ) then
	echo "PASS. Expected error YDB-E-INVDLRCVAL seen and not other errors detected"
else
	echo "TEST-E-ERROR. Either INVDLRCVAL not seen or some other errors detected. check check_error_exist.logz"
endif
#
$echoline
echo "Test for zconvert BADCHAR error when on three arguments"
$gtm_exe/mumps -run ^differentutf
#
$echoline
grep -E "TEST-E-EXPECTED|TEST-E-UNEXPECTED" zconvert_*.out
if !($status) then
	echo "TEST-E-ERROR ZCONVERT BADCHAR test doesn't produce expected results"
endif
$gtm_tst/com/check_error_exist.csh  zconvert_badchar.out "YDB-E-BADCHAR" >&! check_error_exist.logxx
set stat1xx=`$grep "%YDB\-E\-BADCHAR" check_error_exist.logxx|wc -l`
# then check for any other -E- errors in the redirected log
set stat2xx=`$grep "\-E\-" check_error_exist.logxx|grep -v "YDB\-E\-BADCHAR"|wc -l`
if ( (0 != $stat1xx) && (0 == $stat2xx) ) then
	echo "PASS. Expected error YDB-E-BADCHAR seen and not other errors detected for ZCONVERT"
else
	echo "TEST-E-ERROR. Either BADCHAR not seen or some other errors detected for ZCONVERT. check check_error_exist.logxx"
endif
#
$echoline
echo "Test compiling UTF-16 encoded m routine produces YDB-E-LSEXPECTED "
$GTM << EOF
write "BEGIN UTF-16 WRITE",!
set file="testutf16.m" open file:(new:OCHSET="UTF-16") use file
write "testutf16 ;"
write " write ""HELLO WORLD"",!"
write " quit"
close file
write "END OF UTF-16 WRITE",!
EOF
$gtm_exe/mumps testutf16.m >&! testutf16.out
# note: BADCHAR is expected only if they are present within a string literal
# for the below YDB-E-LSEXPECTED is the expected error
#NOTE: Even YDB-E-LSEXPECTED  is issued only if ochset is UTF-16 and NOT for UTF-16LE or UTF-16BE
$gtm_tst/com/check_error_exist.csh  testutf16.out "YDB-E-LSEXPECTED"
#
$gtm_tst/com/dbcheck.csh
