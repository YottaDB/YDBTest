#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2015 Fidelity National Information 		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#                                                               #
# Copyright (c) 2017-2018 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# This is a test to ensure the correctness of output and its consistency
# between tt and rm devices. See GTM-8239 description for more information
# on the test cases exercised in this script.

# Check that in the direct mode in the terminal the zcompile error is
# printed on the next and not the same line as the command itself.
echo "Case 1."

expect > case1.expect.outx <<eof
set timeout 120
spawn /usr/local/bin/tcsh -f
expect "*>"
send -- "set prompt=\"termmumps > \"\r"
expect "*set prompt=\"termmumps > \""
expect "termmumps >"
send -- "$GTM\r"
expect "YDB>"
send -- "zcompile \"xyz\"\r"
send -- "halt\r"
expect "termmumps >"
send -- "exit\r"
expect eof
eof

echo '$grep "YDB>.*FILENOTFND" case1.expect.outx'
$grep "YDB>.*FILENOTFND" case1.expect.outx
echo

# Check that no newlines are missing and no redundant newlines are
# inserted when an error occurs and is printed while $X is non-zero.
echo "Case 2."

cat > case2.m <<eof
case2
 write "hello"
 write 1/0
 quit
eof

($gtm_dist/mumps -run case2 > case2.mumps.out) >&! case2.mumps.err
$gtm_dist/mumps -run case2 >&! case2.mumps.out+err

expect > case2.expect.outx <<eof
set timeout 120
spawn /usr/local/bin/tcsh -f
expect "*>"
send -- "set prompt=\"termmumps > \"\r"
expect "*set prompt=\"termmumps > \""
expect "termmumps >"
send -- "$gtm_dist/mumps -run case2\r"
expect "YDB>"
send -- "halt\r"
expect "termmumps >"
send -- "exit\r"
expect eof
eof

echo "cat case2.mumps.out"
cat case2.mumps.out
echo

echo "cat case2.mumps.err"
cat case2.mumps.err
mv case2.mumps.err case2-mumps-err.logx
echo

echo "cat case2.mumps.out+err"
cat case2.mumps.out+err
echo

echo '$grep "hello.*DIVZERO" case2.expect.outx'
$grep "hello.*DIVZERO" case2.expect.outx
echo

# Check that no redundant newlines are inserted when an error occurs
# and something is printed from the error trap while $X is non-zero.
echo "Case 3."

cat > case3.m <<eof
case3
 set \$etrap="write ""world"",!"
 write "hello"
 set x=1/0
 quit
eof

($gtm_dist/mumps -run case3 > case3.mumps.out) >&! case3.mumps.err
$gtm_dist/mumps -run case3 >&! case3.mumps.out+err
expect > case3.expect.outx <<eof
set timeout 120
spawn /usr/local/bin/tcsh -f
expect "*>"
send -- "set prompt=\"termmumps > \"\r"
expect "*set prompt=\"termmumps > \""
expect "termmumps >"
send -- "$gtm_dist/mumps -run case3\r"
expect "termmumps >"
send -- "exit\r"
expect eof
eof

echo "cat case3.mumps.out"
cat case3.mumps.out
echo

echo "cat case3.mumps.err"
cat case3.mumps.err
echo

echo "cat case3.mumps.out+err"
cat case3.mumps.out+err
echo

echo '$grep -w "hello" case3.expect.outx'
$grep -w "hello" case3.expect.outx
echo

# Check that no redundant newlines appear in GDE's output on errors.
echo "Case 4."

$GDE >&! case4.gde.out+err <<eof
change -region DEFAULT -
exit
eof

echo "cat case4.gde.out+err"
cat case4.gde.out+err
echo

# Check that ZSYSTEM does not insert a redundant newline.
echo "Case 5."

cat > case5.m <<eof
case5
 write "hello"
 zsystem "touch cba"
 write " world"
 quit
eof

$gtm_dist/mumps -run case5 >&! case5.mumps.out+err

echo "cat case5.mumps.out+err"
cat case5.mumps.out+err
echo

# Verify that printing errors correctly affects $Y when
# both stdout and stderr are conjoined to the same place.
echo "Case 6."

expect > case6.expect.outx <<eof
set timeout 120
spawn /usr/local/bin/tcsh -f
expect "*>"
send -- "set prompt=\"termmumps > \"\r"
expect "*set prompt=\"termmumps > \""
expect "termmumps >"
send -- "$GTM\r"
expect "YDB>"
send -- "zcompile \"xyz\" write \"\\\$y is \"_\\\$y\r"
send -- "halt\r"
expect "termmumps >"
send -- "exit\r"
expect eof
eof

echo '$grep "$y is [0-9]" case6.expect.outx'
$grep '$y is [0-9]' case6.expect.outx
echo

cat > case6.m <<eof
case6
 write "hello"
 set x=1/0
 quit
eof

$gtm_dist/mumps -run case6 >&! case6.mumps.out+err <<eof
write "\$y is "_\$y
halt
eof

echo "cat case6.mumps.out+err"
cat case6.mumps.out+err
echo

$gtm_tst/com/dbcreate.csh mumps
echo

# Ensure that a WRITE interrupted with a deadly signal does not cause
# GT.M I/O function nesting when the principal device is a terminal.
echo "Case 7."

expect > case7.expect.outx <<eof
set timeout 120
spawn /usr/local/bin/tcsh -f
expect "*>"
send -- "set prompt=\"termmumps > \"\r"
expect "*set prompt=\"termmumps > \""
expect "termmumps >"
send -- "$gtm_dist/mumps -run case7^gtm8239\r"
expect "termmumps >"
send -- "exit\r"
expect eof
eof

echo '$grep -E "(YDB\-|FAIL)" case7.expect.outx | $grep -v "%YDB\-F\-KILLBYSIGUINFO"'
$grep -E "(YDB\-|FAIL)" case7.expect.outx | $grep -v "%YDB\-F\-KILLBYSIGUINFO"
echo

# Ensure that a WRITE interrupted with a deadly signal does not cause
# GT.M I/O function nesting when the principal device is a file.
echo "Case 8."
$gtm_dist/mumps -run case8^gtm8239 >&! case8.outx

echo '$grep -E "(YDB\-|FAIL)" case8.outx | $grep -v "%YDB\-F\-KILLBYSIGUINFO"'
$grep -E "(YDB\-|FAIL)" case8.outx | $grep -v "%YDB\-F\-KILLBYSIGUINFO"
echo

# Ensure that a WRITE interrupted with a deadly signal does not cause
# GT.M I/O function nesting when the principal device is a pipe.
echo "Case 9."
$gtm_dist/mumps -run case9^gtm8239 |& cat >&! case9.outx

echo '$grep -E "(YDB\-|FAIL)" case9.outx | $grep -v "%YDB\-F\-KILLBYSIGUINFO"'
$grep -E "(YDB\-|FAIL)" case9.outx | $grep -v "%YDB\-F\-KILLBYSIGUINFO"
echo

# Ensure that when a READ is interrupted, and the interrupt handler produces
# an error, no bad things happen if the principal device is a terminal.
echo "Case 10."

expect > case10.expect.outx <<eof
set timeout 120
spawn /usr/local/bin/tcsh -f
expect "*>"
send -- "set prompt=\"termmumps > \"\r"
expect "*set prompt=\"termmumps > \""
expect "termmumps >"
send -- "$gtm_dist/mumps -run case10^gtm8239\r"
expect "YDB>"
send -- "halt\r"
expect "termmumps >"
send -- "exit\r"
expect eof
eof

echo '$grep -E "(YDB\-|FAIL)" case10.expect.outx | $grep -vE "%YDB\-E\-(ERRWZINTR|ZINTDIRECT)"'
$grep -E "(YDB\-|FAIL)" case10.expect.outx | $grep -vE "%YDB\-E\-(ERRWZINTR|ZINTDIRECT)"
echo

# Ensure that when a READ is interrupted, and the interrupt handler produces
# an error, no bad things happen if the principal device is a file.
echo "Case 11."
$gtm_dist/mumps -run case11^gtm8239 < /dev/null >&! case11.outx

echo '$grep -E "(YDB\-|FAIL)" case11.outx | $grep -vE "%YDB\-E\-(ERRWZINTR|ZINTDIRECT)"'
$grep -E "(YDB\-|FAIL)" case11.outx | $grep -vE "%YDB\-E\-(ERRWZINTR|ZINTDIRECT)"
echo

# Ensure that when a READ is interrupted, and the interrupt handler produces
# an error, no bad things happen if the principal device is a pipe.
echo "Case 12."
touch alive
$gtm_dist/mumps -run emptyPipe^gtm8239 |& $gtm_dist/mumps -run case12^gtm8239 >&! case12.outx

echo '$grep -E "(YDB\-|FAIL)" case12.outx | $grep -vE "%YDB\-E\-(ERRWZINTR|ZINTDIRECT)"'
$grep -E "(YDB\-|FAIL)" case12.outx | $grep -vE "%YDB\-E\-(ERRWZINTR|ZINTDIRECT)"
echo

# Ensure that long concatenated messages from utilities are not subject to wrapping
# at terminal width regardless of newline characters.
echo "Case 13."

setenv gtm_linktmpdir .

expect > case13.expect.outx <<eof
set timeout 120
set stty_init "columns 240 rows 54"
spawn /usr/local/bin/tcsh -f
expect "*>"
send -- "set prompt=\"termmumps > \"\r"
expect "*set prompt=\"termmumps > \""
expect "termmumps >"
send -- "$gtm_dist/mumps -run case13^gtm8239\r"
expect "termmumps >"
send -- "exit\r"
expect eof
eof

echo '$grep "\-E\-" case13.expect.outx'
$grep "\-E\-" case13.expect.outx
echo

# Ensure that interrupting a READ with a SIGTERM does not cause issues when
# the principal device is a terminal.
echo "Case 14."

expect > case14.expect.outx <<eof
set timeout 120
spawn /usr/local/bin/tcsh -f
expect "*>"
send -- "set prompt=\"termmumps > \"\r"
expect "*set prompt=\"termmumps > \""
expect "termmumps >"
send -- "$gtm_dist/mumps -run case14^gtm8239\r"
expect "termmumps >"
send -- "exit\r"
expect eof
eof

echo '$grep -E "(YDB\-|FAIL)" case14.expect.outx | $grep -v "%YDB\-F\-FORCEDHALT"'
$grep -E "(YDB\-|FAIL)" case14.expect.outx | $grep -v "%YDB\-F\-FORCEDHALT"
echo

# Ensure that interrupting a READ with a SIGTERM does not cause issues when
# the principal device is a file.
echo "Case 15."
touch alive
($gtm_dist/mumps -run case15^gtm8239 < /dev/null) >&! case15.outx

echo '$grep -E "(YDB\-|FAIL)" case15.outx | $grep -v "%YDB\-F\-FORCEDHALT"'
$grep -E "(YDB\-|FAIL)" case15.outx | $grep -v "%YDB\-F\-FORCEDHALT"
echo

# Ensure that interrupting a READ with a SIGTERM does not cause issues when
# the principal device is a pipe.
echo "Case 16."
$gtm_dist/mumps -run emptyPipe^gtm8239 |& $gtm_dist/mumps -run case16^gtm8239 >&! case16.outx

echo '$grep -E "(YDB\-|FAIL)" case16.outx | $grep -v "%YDB\-F\-FORCEDHALT"'
$grep -E "(YDB\-|FAIL)" case16.outx | $grep -v "%YDB\-F\-FORCEDHALT"
echo

# Ensure that when a READ is interrupted, and the interrupt handler is attempting
# a WRITE, no bad things happen if the principal device is a terminal.
echo "Case 17."

expect > case17.expect.outx <<eof
set timeout 120
spawn /usr/local/bin/tcsh -f
expect "*>"
send -- "set prompt=\"termmumps > \"\r"
expect "*set prompt=\"termmumps > \""
expect "termmumps >"
send -- "$gtm_dist/mumps -run case17^gtm8239\r"
expect "YDB>"
send -- "halt\r"
expect "termmumps >"
send -- "exit\r"
expect eof
eof

echo '$grep -E "(YDB\-|FAIL)" case17.expect.outx | $grep -vE "%YDB\-E\-(ERRWZINTR|ZINTDIRECT)"'
$grep -E "(YDB\-|FAIL)" case17.expect.outx | $grep -vE "%YDB\-E\-(ERRWZINTR|ZINTDIRECT)"
echo

# Ensure that when a READ is interrupted, and the interrupt handler is attempting
# a WRITE, no bad things happen if the principal device is a file.
echo "Case 18."
($gtm_dist/mumps -run case18^gtm8239 < /dev/null) >&! case18.outx

echo '$grep -E "(YDB\-|FAIL)" case18.outx | $grep -vE "%YDB\-E\-(ERRWZINTR|ZINTDIRECT)"'
$grep -E "(YDB\-|FAIL)" case18.outx | $grep -vE "%YDB\-E\-(ERRWZINTR|ZINTDIRECT)"
echo


# Ensure that when a READ is interrupted, and the interrupt handler is attempting
# a WRITE, no bad things happen if the principal device is a pipe.
echo "Case 19."
touch alive
$gtm_dist/mumps -run emptyPipe^gtm8239 |& $gtm_dist/mumps -run case19^gtm8239 >&! case19.outx

echo '$grep -E "(YDB\-|FAIL)" case19.outx | $grep -vE "%YDB\-E\-(ERRWZINTR|ZINTDIRECT)"'
$grep -E "(YDB\-|FAIL)" case19.outx | $grep -vE "%YDB\-E\-(ERRWZINTR|ZINTDIRECT)"
echo

$gtm_tst/com/dbcheck.csh
