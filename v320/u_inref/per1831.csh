#! /usr/local/bin/tcsh -f
# Compile M program with very long line and create listing file.
#  Verify that listing file output is readable and unambiguous.
\cp $gtm_tst/$tst/inref/per1831.m .
setenv MUMPS "$gtm_exe/mumps"
$MUMPS -list=per1831.lis per1831.m
#
# Remove page headers (which include date/time stamps) from listing:
set per1831cwd = `pwd`
egrep -v "page|$per1831cwd|`date +%Y`" per1831.lis
